from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
import time
import os
import datetime

from backend.db import get_connection, test_connection

app = FastAPI(
    title="Dairy Farm Studio & Herd Management System",
    description="Enterprise DBMS Studio with Live MySQL 8.0 Persistence",
    version="2.0.0"
)

# -----------------------------------------------------------------------------
# Pydantic Schemas
# -----------------------------------------------------------------------------
class AnimalCreate(BaseModel):
    animal_tag: str = Field(..., min_length=2, max_length=50)
    breed_id: int = Field(..., gt=0)
    gender: str = Field(..., pattern="^(Male|Female)$")
    date_of_birth: str = Field(..., description="YYYY-MM-DD")
    status: str = Field(default="Active", pattern="^(Active|Sold|Deceased|Transferred)$")

class MilkRecordCreate(BaseModel):
    animal_id: int = Field(..., gt=0)
    session_date: str = Field(..., description="YYYY-MM-DD")
    session_time: str = Field(..., description="HH:MM:SS or HH:MM")
    session_type: str = Field(..., pattern="^(Morning|Evening|Other)$")
    quantity_litres: float = Field(..., gt=0)

class SaleCreate(BaseModel):
    buyer_id: int = Field(..., gt=0)
    yield_id: int = Field(..., gt=0)
    sale_date: str = Field(..., description="YYYY-MM-DD")
    quantity_sold: float = Field(..., gt=0)
    rate_per_litre: float = Field(..., gt=0)
    payment_amount: Optional[float] = 0.0
    payment_method: Optional[str] = "UPI"

class QualityTestCreate(BaseModel):
    yield_id: int = Field(..., gt=0)
    test_date: str = Field(..., description="YYYY-MM-DD")
    fat_percentage: float = Field(..., ge=1.0, le=10.0)
    snf_percentage: float = Field(..., ge=4.0, le=15.0)
    density: float = Field(..., ge=1.000, le=1.050)

class FeedIssueCreate(BaseModel):
    feed_id: int = Field(..., gt=0)
    animal_id: int = Field(..., gt=0)
    issue_date: str = Field(..., description="YYYY-MM-DD")
    quantity: float = Field(..., gt=0)

class SQLConsoleRequest(BaseModel):
    sql: str = Field(..., min_length=4)

def serialize_row(row: Dict[str, Any]) -> Dict[str, Any]:
    """Helper to cleanly serialize MySQL dates, datetimes, decimals and timedeltas."""
    res = {}
    for k, v in row.items():
        if isinstance(v, (datetime.date, datetime.datetime)):
            res[k] = v.isoformat()
        elif isinstance(v, datetime.timedelta):
            total_seconds = int(v.total_seconds())
            hours = total_seconds // 3600
            minutes = (total_seconds % 3600) // 60
            seconds = total_seconds % 60
            res[k] = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
        elif hasattr(v, '__float__'):
            res[k] = float(v)
        else:
            res[k] = v
    return res

# -----------------------------------------------------------------------------
# System Status & Dashboard Endpoints
# -----------------------------------------------------------------------------
@app.get("/api/health")
def api_health():
    status = test_connection()
    return {"app": "online", "database": status}

@app.get("/api/dashboard")
def get_dashboard_metrics():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            # 1. Total Animals
            cursor.execute("SELECT COUNT(*) AS total FROM animal;")
            total_animals = cursor.fetchone()["total"]

            # 2. Total Milk Harvested
            cursor.execute("SELECT COALESCE(SUM(quantity_litres), 0) AS total_litres FROM milk_yield;")
            total_milk = float(cursor.fetchone()["total_litres"])

            # 3. Total Commercial Sales
            cursor.execute("SELECT COALESCE(SUM(total_amount), 0) AS total_revenue FROM sale;")
            total_sales = float(cursor.fetchone()["total_revenue"])

            # 4. Low Stock Feed Items
            cursor.execute("SELECT COUNT(*) AS low_stock FROM feed_item WHERE available_quantity <= reorder_level;")
            low_stock = cursor.fetchone()["low_stock"]

            # 5. Shift Distribution
            cursor.execute("""
                SELECT ms.session_type, ROUND(SUM(my.quantity_litres), 1) AS litres
                FROM milking_session ms
                JOIN milk_yield my ON ms.session_id = my.session_id
                GROUP BY ms.session_type;
            """)
            shifts = cursor.fetchall()

            # 6. Top Breeds count
            cursor.execute("""
                SELECT b.breed_name, COUNT(a.animal_id) AS count
                FROM breed b
                JOIN animal a ON b.breed_id = a.breed_id
                GROUP BY b.breed_id, b.breed_name
                ORDER BY count DESC
                LIMIT 5;
            """)
            top_breeds = cursor.fetchall()

            # 7. Quality Grade Overview
            cursor.execute("""
                SELECT 
                    ROUND(AVG(fat_percentage), 2) as avg_fat,
                    ROUND(AVG(snf_percentage), 2) as avg_snf,
                    ROUND(AVG(density), 3) as avg_density
                FROM quality_test;
            """)
            quality_overview = cursor.fetchone()

            return {
                "total_animals": total_animals,
                "total_milk_litres": total_milk,
                "total_sales_revenue": total_sales,
                "low_stock_feed_items": low_stock,
                "shifts": [serialize_row(r) for r in shifts],
                "top_breeds": [serialize_row(r) for r in top_breeds],
                "quality": serialize_row(quality_overview) if quality_overview else {}
            }
    finally:
        conn.close()

@app.get("/api/breeds")
def get_breeds():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT breed_id, breed_name, description FROM breed ORDER BY breed_name ASC;")
            return [serialize_row(r) for r in cursor.fetchall()]
    finally:
        conn.close()

# -----------------------------------------------------------------------------
# Module 1: Herd Management
# -----------------------------------------------------------------------------
@app.get("/api/animals")
def list_animals(search: Optional[str] = None, status: Optional[str] = None, limit: int = 100):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            query = """
                SELECT 
                    a.animal_id,
                    a.animal_tag,
                    b.breed_name,
                    a.breed_id,
                    a.gender,
                    a.date_of_birth,
                    a.status
                FROM animal a
                JOIN breed b ON a.breed_id = b.breed_id
                WHERE 1=1
            """
            params = []
            if status and status != "ALL":
                query += " AND a.status = %s"
                params.append(status)
            if search:
                query += " AND (a.animal_tag LIKE %s OR b.breed_name LIKE %s)"
                params.extend([f"%{search}%", f"%{search}%"])

            query += " ORDER BY a.animal_id DESC LIMIT %s"
            params.append(limit)

            cursor.execute(query, tuple(params))
            rows = cursor.fetchall()

            cursor.execute("SELECT COUNT(*) AS total_count FROM animal;")
            total_count = cursor.fetchone()["total_count"]

            return {
                "total": total_count,
                "records": [serialize_row(r) for r in rows]
            }
    finally:
        conn.close()

@app.post("/api/animals")
def create_animal(item: AnimalCreate):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS cnt_before FROM animal;")
            count_before = cursor.fetchone()["cnt_before"]

            sql = """
                INSERT INTO animal (animal_tag, breed_id, gender, date_of_birth, status)
                VALUES (%s, %s, %s, %s, %s);
            """
            cursor.execute(sql, (
                item.animal_tag.strip(),
                item.breed_id,
                item.gender,
                item.date_of_birth,
                item.status
            ))
            new_id = cursor.lastrowid
            conn.commit()

            cursor.execute("SELECT COUNT(*) AS cnt_after FROM animal;")
            count_after = cursor.fetchone()["cnt_after"]

            cursor.execute("""
                SELECT a.animal_id, a.animal_tag, b.breed_name, a.gender, 
                       a.date_of_birth, a.status
                FROM animal a JOIN breed b ON a.breed_id = b.breed_id
                WHERE a.animal_id = %s;
            """, (new_id,))
            inserted_row = serialize_row(cursor.fetchone())

            return {
                "success": True,
                "message": f"Successfully registered cattle [{item.animal_tag}] into dairy_farm_db",
                "animal_id": new_id,
                "before_count": count_before,
                "after_count": count_after,
                "record": inserted_row
            }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

@app.delete("/api/animals/{animal_id}")
def delete_animal(animal_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT animal_id, animal_tag FROM animal WHERE animal_id = %s;", (animal_id,))
            animal = cursor.fetchone()
            if not animal:
                raise HTTPException(status_code=404, detail=f"Animal ID {animal_id} does not exist.")

            cursor.execute("SELECT COUNT(*) AS cnt_before FROM animal;")
            count_before = cursor.fetchone()["cnt_before"]

            # CASCADE deletes associated visits, sessions, yields
            cursor.execute("DELETE FROM animal WHERE animal_id = %s;", (animal_id,))
            conn.commit()

            cursor.execute("SELECT COUNT(*) AS cnt_after FROM animal;")
            count_after = cursor.fetchone()["cnt_after"]

            return {
                "success": True,
                "message": f"Deleted cattle [{animal['animal_tag']}] (ID: {animal_id}) from database. Cascades cleared child relations.",
                "deleted_animal_tag": animal["animal_tag"],
                "deleted_id": animal_id,
                "before_count": count_before,
                "after_count": count_after
            }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

# -----------------------------------------------------------------------------
# Module 2: Milk Collection & Production
# -----------------------------------------------------------------------------
@app.get("/api/milk-records")
def list_milk_records(limit: int = 100):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    ms.session_id,
                    ms.animal_id,
                    a.animal_tag,
                    b.breed_name,
                    ms.session_date,
                    ms.session_time,
                    ms.session_type,
                    my.yield_id,
                    my.quantity_litres
                FROM milking_session ms
                JOIN animal a ON ms.animal_id = a.animal_id
                JOIN breed b ON a.breed_id = b.breed_id
                JOIN milk_yield my ON ms.session_id = my.session_id
                ORDER BY ms.session_id DESC
                LIMIT %s;
            """
            cursor.execute(sql, (limit,))
            records = cursor.fetchall()

            cursor.execute("SELECT COUNT(*) AS total_count FROM milk_yield;")
            total_count = cursor.fetchone()["total_count"]

            return {
                "total": total_count,
                "records": [serialize_row(r) for r in records]
            }
    finally:
        conn.close()

@app.post("/api/milk-records")
def add_milk_record(item: MilkRecordCreate):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT animal_id, animal_tag FROM animal WHERE animal_id = %s;", (item.animal_id,))
            animal = cursor.fetchone()
            if not animal:
                raise HTTPException(status_code=404, detail=f"Animal ID {item.animal_id} does not exist.")

            cursor.execute("SELECT COUNT(*) AS cnt_before FROM milk_yield;")
            count_before = cursor.fetchone()["cnt_before"]

            time_val = item.session_time if len(item.session_time.split(":")) == 3 else f"{item.session_time}:00"
            sql_session = """
                INSERT INTO milking_session (animal_id, session_date, session_time, session_type)
                VALUES (%s, %s, %s, %s);
            """
            cursor.execute(sql_session, (
                item.animal_id,
                item.session_date,
                time_val,
                item.session_type
            ))
            session_id = cursor.lastrowid

            sql_yield = """
                INSERT INTO milk_yield (session_id, quantity_litres)
                VALUES (%s, %s);
            """
            cursor.execute(sql_yield, (session_id, item.quantity_litres))
            yield_id = cursor.lastrowid

            conn.commit()

            cursor.execute("SELECT COUNT(*) AS cnt_after FROM milk_yield;")
            count_after = cursor.fetchone()["cnt_after"]

            return {
                "success": True,
                "message": f"Logged {item.quantity_litres} L for cattle [{animal['animal_tag']}] (Session #{session_id}) committed atomically.",
                "session_id": session_id,
                "yield_id": yield_id,
                "before_count": count_before,
                "after_count": count_after
            }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

@app.delete("/api/milk-records/{session_id}")
def delete_milk_record(session_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT ms.session_id, a.animal_tag, my.quantity_litres
                FROM milking_session ms
                JOIN animal a ON ms.animal_id = a.animal_id
                LEFT JOIN milk_yield my ON ms.session_id = my.session_id
                WHERE ms.session_id = %s;
            """, (session_id,))
            rec = cursor.fetchone()
            if not rec:
                raise HTTPException(status_code=404, detail=f"Milking session #{session_id} not found.")

            cursor.execute("SELECT COUNT(*) AS cnt_before FROM milk_yield;")
            count_before = cursor.fetchone()["cnt_before"]

            cursor.execute("DELETE FROM milking_session WHERE session_id = %s;", (session_id,))
            conn.commit()

            cursor.execute("SELECT COUNT(*) AS cnt_after FROM milk_yield;")
            count_after = cursor.fetchone()["cnt_after"]

            return {
                "success": True,
                "message": f"Deleted session #{session_id} for {rec['animal_tag']}. Cascade cleaned yield lot.",
                "deleted_session_id": session_id,
                "before_count": count_before,
                "after_count": count_after
            }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

# -----------------------------------------------------------------------------
# Module 3: Laboratory Quality Control
# -----------------------------------------------------------------------------
@app.get("/api/quality-records")
def list_quality_records():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    qt.test_id,
                    qt.yield_id,
                    a.animal_id,
                    a.animal_tag,
                    qt.test_date,
                    qt.fat_percentage,
                    qt.snf_percentage,
                    qt.density,
                    CASE 
                        WHEN qt.fat_percentage >= 3.50 AND qt.snf_percentage >= 8.50 THEN 'Grade A Premium'
                        ELSE 'Standard Grade'
                    END AS quality_rating
                FROM quality_test qt
                JOIN milk_yield my ON qt.yield_id = my.yield_id
                JOIN milking_session ms ON my.session_id = ms.session_id
                JOIN animal a ON ms.animal_id = a.animal_id
                ORDER BY qt.test_id DESC
                LIMIT 50;
            """
            cursor.execute(sql)
            return [serialize_row(r) for r in cursor.fetchall()]
    finally:
        conn.close()

@app.post("/api/quality-records")
def create_quality_test(item: QualityTestCreate):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS cnt_before FROM quality_test;")
            count_before = cursor.fetchone()["cnt_before"]

            sql = """
                INSERT INTO quality_test (yield_id, test_date, fat_percentage, snf_percentage, density)
                VALUES (%s, %s, %s, %s, %s);
            """
            cursor.execute(sql, (
                item.yield_id,
                item.test_date,
                item.fat_percentage,
                item.snf_percentage,
                item.density
            ))
            test_id = cursor.lastrowid
            conn.commit()

            cursor.execute("SELECT COUNT(*) AS cnt_after FROM quality_test;")
            count_after = cursor.fetchone()["cnt_after"]

            return {
                "success": True,
                "message": f"Successfully committed quality assay (Test #{test_id}) for Milk Lot #{item.yield_id}",
                "test_id": test_id,
                "before_count": count_before,
                "after_count": count_after
            }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

@app.delete("/api/quality-records/{test_id}")
def delete_quality_test(test_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS cnt_before FROM quality_test;")
            count_before = cursor.fetchone()["cnt_before"]

            cursor.execute("DELETE FROM quality_test WHERE test_id = %s;", (test_id,))
            conn.commit()

            cursor.execute("SELECT COUNT(*) AS cnt_after FROM quality_test;")
            count_after = cursor.fetchone()["cnt_after"]

            return {
                "success": True,
                "message": f"Deleted quality test #{test_id} from database",
                "before_count": count_before,
                "after_count": count_after
            }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

# -----------------------------------------------------------------------------
# Module 4: Feed & Nutrition Warehouse
# -----------------------------------------------------------------------------
@app.get("/api/feed-records")
def list_feed_records():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    feed_id, feed_name, unit, available_quantity, reorder_level,
                    CASE 
                        WHEN available_quantity <= reorder_level THEN 'Reorder Required'
                        ELSE 'Optimal'
                    END as stock_status
                FROM feed_item
                ORDER BY available_quantity ASC;
            """)
            items = cursor.fetchall()

            cursor.execute("""
                SELECT 
                    fu.issue_id, fi.feed_name, a.animal_id, a.animal_tag, fu.issue_date, fu.quantity, fi.unit
                FROM feed_issue fu
                JOIN feed_item fi ON fu.feed_id = fi.feed_id
                JOIN animal a ON fu.animal_id = a.animal_id
                ORDER BY fu.issue_id DESC
                LIMIT 30;
            """)
            issues = cursor.fetchall()

            return {
                "inventory": [serialize_row(r) for r in items],
                "recent_issues": [serialize_row(r) for r in issues]
            }
    finally:
        conn.close()

@app.post("/api/feed-issues")
def create_feed_issue(item: FeedIssueCreate):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS cnt_before FROM feed_issue;")
            count_before = cursor.fetchone()["cnt_before"]

            sql = """
                INSERT INTO feed_issue (feed_id, animal_id, issue_date, quantity)
                VALUES (%s, %s, %s, %s);
            """
            cursor.execute(sql, (
                item.feed_id,
                item.animal_id,
                item.issue_date,
                item.quantity
            ))
            issue_id = cursor.lastrowid
            conn.commit()

            cursor.execute("SELECT COUNT(*) AS cnt_after FROM feed_issue;")
            count_after = cursor.fetchone()["cnt_after"]

            # Fetch updated feed item stock
            cursor.execute("SELECT feed_name, available_quantity, unit FROM feed_item WHERE feed_id = %s;", (item.feed_id,))
            feed_info = cursor.fetchone()

            return {
                "success": True,
                "message": f"Dispensed {item.quantity} {feed_info['unit']} of {feed_info['feed_name']}. Trigger automatically decremented warehouse stock to {feed_info['available_quantity']} {feed_info['unit']}.",
                "issue_id": issue_id,
                "before_count": count_before,
                "after_count": count_after
            }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

@app.delete("/api/feed-issues/{issue_id}")
def delete_feed_issue(issue_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT feed_id, quantity FROM feed_issue WHERE issue_id = %s;", (issue_id,))
            issue = cursor.fetchone()
            if not issue:
                raise HTTPException(status_code=404, detail="Feed issue not found")

            cursor.execute("SELECT COUNT(*) AS cnt_before FROM feed_issue;")
            count_before = cursor.fetchone()["cnt_before"]

            # Return stock manually since MySQL does not have an AFTER DELETE trigger on feed_issue
            cursor.execute("UPDATE feed_item SET available_quantity = available_quantity + %s WHERE feed_id = %s;", 
                           (issue["quantity"], issue["feed_id"]))
            cursor.execute("DELETE FROM feed_issue WHERE issue_id = %s;", (issue_id,))
            conn.commit()

            cursor.execute("SELECT COUNT(*) AS cnt_after FROM feed_issue;")
            count_after = cursor.fetchone()["cnt_after"]

            return {
                "success": True,
                "message": f"Cancelled feed dispensation #{issue_id} and restored {issue['quantity']} units back into inventory",
                "before_count": count_before,
                "after_count": count_after
            }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

# -----------------------------------------------------------------------------
# Module 5: Commercial Invoicing & Sell Milk (3NF)
# -----------------------------------------------------------------------------
@app.get("/api/buyers")
def list_buyers():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT buyer_id, buyer_name, contact, address FROM buyer ORDER BY buyer_name ASC;")
            return [serialize_row(r) for r in cursor.fetchall()]
    finally:
        conn.close()

@app.get("/api/available-yields")
def list_available_yields():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    my.yield_id,
                    ms.session_id,
                    a.animal_id,
                    a.animal_tag,
                    b.breed_name,
                    ms.session_date,
                    ms.session_type,
                    my.quantity_litres
                FROM milk_yield my
                JOIN milking_session ms ON my.session_id = ms.session_id
                JOIN animal a ON ms.animal_id = a.animal_id
                JOIN breed b ON a.breed_id = b.breed_id
                ORDER BY my.yield_id DESC
                LIMIT 50;
            """
            cursor.execute(sql)
            return [serialize_row(r) for r in cursor.fetchall()]
    finally:
        conn.close()

@app.get("/api/sales-records")
def list_sales_records():
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    s.sale_id,
                    b.buyer_name,
                    b.contact,
                    s.sale_date,
                    s.total_amount,
                    COALESCE(SUM(p.amount), 0) AS amount_paid,
                    ROUND(s.total_amount - COALESCE(SUM(p.amount), 0), 2) AS balance_due,
                    (SELECT COUNT(*) FROM sale_item WHERE sale_id = s.sale_id) AS line_items_count
                FROM sale s
                JOIN buyer b ON s.buyer_id = b.buyer_id
                LEFT JOIN payment p ON s.sale_id = p.sale_id
                GROUP BY s.sale_id, b.buyer_name, b.contact, s.sale_date, s.total_amount
                ORDER BY s.sale_id DESC
                LIMIT 50;
            """
            cursor.execute(sql)
            return [serialize_row(r) for r in cursor.fetchall()]
    finally:
        conn.close()

@app.post("/api/sales")
def create_sale(item: SaleCreate):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS cnt_before FROM sale;")
            count_before = cursor.fetchone()["cnt_before"]

            # 1. Compute total
            calculated_total = round(item.quantity_sold * item.rate_per_litre, 2)

            # 2. Insert into sale header
            sql_sale = """
                INSERT INTO sale (buyer_id, sale_date, total_amount)
                VALUES (%s, %s, %s);
            """
            cursor.execute(sql_sale, (item.buyer_id, item.sale_date, calculated_total))
            sale_id = cursor.lastrowid

            # 3. Insert into sale_item line item
            sql_item = """
                INSERT INTO sale_item (sale_id, yield_id, quantity_sold, rate_per_litre)
                VALUES (%s, %s, %s, %s);
            """
            cursor.execute(sql_item, (sale_id, item.yield_id, item.quantity_sold, item.rate_per_litre))

            # 4. If payment was made, record receipt
            if item.payment_amount and item.payment_amount > 0:
                ref_no = f"PAY-{int(time.time()) % 100000:05d}"
                sql_pay = """
                    INSERT INTO payment (sale_id, payment_date, amount, payment_method, reference_no)
                    VALUES (%s, %s, %s, %s, %s);
                """
                cursor.execute(sql_pay, (sale_id, item.sale_date, item.payment_amount, item.payment_method, ref_no))

            conn.commit()

            cursor.execute("SELECT COUNT(*) AS cnt_after FROM sale;")
            count_after = cursor.fetchone()["cnt_after"]

            cursor.execute("SELECT buyer_name FROM buyer WHERE buyer_id = %s;", (item.buyer_id,))
            buyer_info = cursor.fetchone()

            return {
                "success": True,
                "message": f"Successfully sold {item.quantity_sold} L to {buyer_info['buyer_name']} for ₹{calculated_total:,.2f} (Invoice INV-{sale_id:04d}). 3NF tables synchronized atomically.",
                "sale_id": sale_id,
                "total_amount": calculated_total,
                "before_count": count_before,
                "after_count": count_after
            }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

@app.delete("/api/sales/{sale_id}")
def delete_sale(sale_id: int):
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) AS cnt_before FROM sale;")
            count_before = cursor.fetchone()["cnt_before"]

            # Cascade deletes linked sale_item and payment
            cursor.execute("DELETE FROM sale WHERE sale_id = %s;", (sale_id,))
            conn.commit()

            cursor.execute("SELECT COUNT(*) AS cnt_after FROM sale;")
            count_after = cursor.fetchone()["cnt_after"]

            return {
                "success": True,
                "message": f"Purged Commercial Invoice INV-{sale_id:04d} and associated receipt line items",
                "before_count": count_before,
                "after_count": count_after
            }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

# -----------------------------------------------------------------------------
# Module 6: Live SQL Query Console (Enterprise Studio Feature)
# -----------------------------------------------------------------------------
@app.post("/api/sql-console")
def execute_sql_console(payload: SQLConsoleRequest):
    sql_text = payload.sql.strip()
    # Safety guard: read-only queries for console
    disallowed = ["DROP", "TRUNCATE", "ALTER", "CREATE DATABASE", "GRANT", "REVOKE"]
    for word in disallowed:
        if word in sql_text.upper().split():
            raise HTTPException(status_code=403, detail=f"Command '{word}' is restricted in the interactive SQL studio for safety.")

    conn = get_connection()
    start_time = time.time()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql_text)
            execution_time_ms = round((time.time() - start_time) * 1000, 2)
            
            if cursor.description:
                columns = [desc[0] for desc in cursor.description]
                raw_rows = cursor.fetchall()
                rows = [serialize_row(r) for r in raw_rows]
                return {
                    "success": True,
                    "columns": columns,
                    "rows": rows,
                    "row_count": len(rows),
                    "execution_time_ms": execution_time_ms
                }
            else:
                conn.commit()
                return {
                    "success": True,
                    "affected_rows": cursor.rowcount,
                    "execution_time_ms": execution_time_ms
                }
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        conn.close()

# -----------------------------------------------------------------------------
# Static Frontend Serving
# -----------------------------------------------------------------------------
static_dir = os.path.join(os.path.dirname(__file__), "..", "static")
app.mount("/static", StaticFiles(directory=static_dir), name="static")

@app.get("/")
def serve_index():
    return FileResponse(os.path.join(static_dir, "index.html"))
