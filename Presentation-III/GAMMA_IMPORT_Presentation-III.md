# Dairy Farm Studio • Enterprise DBMS Management System
## Presentation-III: Full-Stack Working Demonstration & UI Implementation
*Student: Mohammed Zaid (Roll No: 25WU0102163) • Faculty Mentor: Dr. Kiran Mayee Adavala • Live MySQL 8.0*

---

### Working Demonstration & Architecture Overview
#### Live Full-Stack Architecture Interfacing Directly with MySQL 8.0

> **8 Studio Modules**  
> Comprehensive workbench covering Dashboard KPIs, Herd Registry, Milk Yields, Quality Lab, Feed Stock, 3NF Billing, SQL Studio, and Schema Inspector.

> **Obsidian & Emerald UI**  
> Modern dark studio aesthetic inspired by Supabase Studio and Linear.app from `VoltAgent/awesome-design-md`.

> **1.38 ms Telemetry**  
> Sub-2 millisecond query latency executed natively against MySQL Community Server 8.0.46 on `localhost:3306`.

> **Before/After Audit Protocol**  
> Real-time slide-down audit drawer displaying database row count deltas on every INSERT and DELETE operation.

---

### 3-Tier System Architecture & Tech Stack
#### Enterprise Decoupled Stack Connected to MySQL 8.0

### Tier 1: Presentation Layer
* **HTML5 + Vanilla CSS3**: High-performance semantic frontend with zero heavy CSS framework dependencies.
* **Modern Studio System**: Deep obsidian canvas (`#090a0d`), hairline panels (`#12141a`), Supabase emerald (`#3ecf8e`), and Linear lavender (`#5e6ad2`).
* **Modular Single-Page App (SPA)**: Tabbed navigation switching seamlessly between 8 functional modules.

### Tier 2: Application API Gateway
* **FastAPI (Python 3.12)**: Asynchronous REST backend handling structured API endpoints.
* **PyMySQL Driver**: Native database driver with parameterized SQL execution and connection lifecycle handling.
* **Pydantic Validation**: Strong request validation enforcing types, formats, and non-empty payloads.

### Tier 3: Database Engine
* **MySQL 8.0 Community**: Active database `dairy_farm_db` with 14 base relations, 1 summary view, and 4 active triggers.

---

### Live Executive Telemetry & KPI Dashboard
#### Real-Time Aggregated Farm Production and Commercial Overview

> **50 Cattle**  
> Active livestock master records tracked in table `animal`.

> **991.0 Litres**  
> Cumulative milk harvested across 50 production sessions in `milk_yield`.

> **₹18,905.00**  
> 3NF reconciled commercial sales revenue computed via trigger `after_sale_item`.

> **0 Stock Alerts**  
> Feed commodity levels safe above reorder thresholds in `feed_item`.

### Harvest Distribution & Laboratory Averages
* **Morning Milking Harvest**: 494.0 Litres
* **Evening Milking Harvest**: 497.0 Litres
* **Lab Quality Averages**: 3.95% Butterfat • 8.60% Solids-Not-Fat (SNF) • 1.030 Specific Density

---

### Cattle Master Registry & CRUD Management
#### Biological Lifecycle Tracking with Foreign Key Cascades

### Real-Time Features
* **Authentic Cattle Identities**: Every animal displays a registered name (e.g. *Nandini, Kamdhenu, Gauri, Mangala*) alongside official ear tags (*A1001 - A1050*).
* **Dynamic Search & Filtering**: Real-time client-side search across cattle names, ear tags, and breed classifications.
* **Real Commercial & Feed Entities**: Warehouse commodities (*Alfalfa Hay, Corn Silage, Cottonseed Cake*) and cooperative buyers (*Amul, Mother Dairy, Nandini, Heritage Fresh*) replace placeholder numbers.
* **Operational Status Filtering**: Instant filter by `Active`, `Sold`, `Deceased`, or `Transferred`.
* **Atomic Modal Registration**: Form validation enforcing `UNIQUE KEY` constraint on cattle ear tags.
* **Cascade Delete Safety**: Safety confirmation dialog detailing child record purges in `health_visit`, `vaccination`, and `milking_session`.

---

### Interactive SQL Studio: In-Browser Query Engine
#### Sub-2ms Live Query Execution with Dynamic Tabular Results

```sql
SELECT a.animal_id, a.animal_tag, b.breed_name, my.quantity_litres,
       qt.fat_percentage, qt.snf_percentage, si.quantity_sold, s.total_amount, bu.buyer_name
FROM animal a
JOIN breed b ON a.breed_id = b.breed_id
JOIN milking_session ms ON a.animal_id = ms.animal_id
JOIN milk_yield my ON ms.session_id = my.session_id
LEFT JOIN quality_test qt ON my.yield_id = qt.yield_id
LEFT JOIN sale_item si ON my.yield_id = si.yield_id
LEFT JOIN sale s ON si.sale_id = s.sale_id
LEFT JOIN buyer bu ON s.buyer_id = bu.buyer_id
WHERE a.animal_id = 20;
```

### Studio Capabilities
* **Preset Shortcuts**: 1-click execution for Query #29 (Trace Animal #20), shift yields, Grade A milk lots, and `animal_milk_summary` view.
* **Live Telemetry**: Real-time execution timer displaying millisecond latency (e.g. `1.38 ms`).
* **Dynamic Result Renderer**: Automatically parses query column descriptions and renders tabular grids.

---

### Schema & Relational Architecture Inspector
#### Authoritative Specification of all 14 Base Tables and Views

| Table Name | Engine | Row Count | Primary Key | Foreign Key Reference | Normalization |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `breed` | InnoDB | 50 | `breed_id` | *None (Root Lookup)* | 3NF |
| `animal` | InnoDB | 50 | `animal_id` | `breed_id` | 3NF |
| `health_visit` | InnoDB | 50 | `visit_id` | `animal_id` [CASCADE] | 3NF |
| `vaccination` | InnoDB | 50 | `vaccination_id` | `animal_id` [CASCADE] | 3NF |
| `breeding_event` | InnoDB | 50 | `breeding_id` | `animal_id`, `sire_id` | 3NF (Unary) |
| `feed_item` | InnoDB | 50 | `feed_id` | *None (Warehouse Master)* | 3NF |
| `feed_issue` | InnoDB | 50 | `issue_id` | `feed_id`, `animal_id` | 3NF (Associative) |
| `milking_session`| InnoDB | 50 | `session_id` | `animal_id` [CASCADE] | 3NF |
| `milk_yield` | InnoDB | 50 | `yield_id` | `session_id` [CASCADE] | 3NF |
| `quality_test` | InnoDB | 50 | `test_id` | `yield_id` [CASCADE] | 3NF |
| `buyer` | InnoDB | 50 | `buyer_id` | *None (Customer Master)* | 3NF |
| `sale` | InnoDB | 50 | `sale_id` | `buyer_id` | 3NF (Header) |
| `sale_item` | InnoDB | 50 | `(sale_id, yield_id)`| `sale_id`, `yield_id` | 3NF (Composite) |
| `payment` | InnoDB | 50 | `payment_id` | `sale_id` [CASCADE] | 3NF |
| `animal_milk_summary`| VIEW | 50 | — | *Joined Analytical View* | Derived |

---

### Live CRUD Demonstration & Verification Protocol
#### Standardized 4-Step Protocol for 10-Minute Viva Evaluation

### Step 1: Baseline Dashboard Telemetry
* Verify connection indicator to `localhost:3306` with Repeatable Read ACID isolation.
* Verify baseline counts: 50 cattle, 991.0 L milk, ₹18,905.00 revenue.

### Step 2: Atomic Cattle INSERT
* Click `+ Register Cattle`. Fill ear tag `A9999`, select breed `Gir Cross`, gender `Female`, DOB.
* Submit form: MySQL executes atomic `INSERT INTO animal`. Slide-down audit drawer logs: **Before: 50, After: 51, Delta: +1**.

### Step 3: Milking Yield Transaction
* Click `+ Log Milk Yield`. Select cow `A9999`, date, time, morning shift, quantity `18.5 L`.
* Commit multi-table transaction across `milking_session` and `milk_yield`.

### Step 4: Referential CASCADE Delete
* Click `Delete` on test cow `A9999`. Confirm deletion warning.
* MySQL executes `DELETE FROM animal WHERE animal_id = ?`. Child clinical logs and sessions are automatically purged via `ON DELETE CASCADE`. Count drops from **51 to 50 (Delta: -1)**.

---

### Viva Defense: High-Impact Examiner Questions & Answers
#### Deep Technical Answers Ready for Faculty Examination

### Database Connectivity & Security
* **Q: How does the application connect to MySQL?**  
  *A:* Through PyMySQL using native connection pooling. Configuration is decoupled in `backend/config.py` using host, port 3306, user `root`, and database `dairy_farm_db`.
* **Q: How do you prevent SQL injection attacks?**  
  *A:* All database queries use parameterized placeholders (`%s`) and Pydantic schemas. User inputs are never concatenated directly into SQL command strings.

### Transaction Management & ACID
* **Q: How is transaction atomicity ensured during milk logging?**  
  *A:* Milking sessions require inserting into `milking_session`, retrieving the generated `session_id`, and inserting into `milk_yield`. Wrapped in `try ... conn.commit()` with `except ... conn.rollback()`.
* **Q: What happens if two users update the same record simultaneously?**  
  *A:* MySQL InnoDB uses row-level locks and Repeatable Read isolation (MVCC) to ensure consistent read snapshots and prevent dirty reads.

---

### Deliverables & Submission Package
#### Complete Verification of Course Deliverables

* **Source Code Repository**: Clean, runnable full-stack application inside `Presentation-III/source_code/`.
* **One-Click Execution**: Local startup script `run.bat` launching Uvicorn on `http://127.0.0.1:8000`.
* **Complete Documentation**: Full project report document `DBMS_Project_Report_Mohammed_Zaid.docx` (4,500+ words).
* **Presentation Artifacts**: Both 10-slide PowerPoint decks regenerated in 16:9 widescreen dark theme with live screenshots.
