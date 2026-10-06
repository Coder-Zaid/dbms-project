import pymysql
from pymysql.cursors import DictCursor
from backend.config import DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD

def get_connection():
    """
    Returns an active, authenticated PyMySQL connection to dairy_farm_db.
    """
    return pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        cursorclass=DictCursor,
        autocommit=False  # Explicit transaction control for ACID guarantees
    )

def test_connection():
    """
    Validates database accessibility and returns connection status details.
    """
    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT DATABASE() AS current_db, VERSION() AS version;")
            res = cursor.fetchone()
        conn.close()
        return {"connected": True, "database": res["current_db"], "version": res["version"]}
    except Exception as e:
        return {"connected": False, "error": str(e)}
