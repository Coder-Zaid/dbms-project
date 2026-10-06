# Dairy Farm Studio • Presentation-III Live Demonstration

**Student**: Mohammed Zaid (`25WU0102163`)  
**Section**: AIML Panthers  
**Faculty Mentor**: Dr. Kiran Mayee Adavala  
**DBMS**: MySQL Community Server 8.0.46  
**Active Database**: `dairy_farm_db` (14 Tables, 50 Rows Each)  
**Design Reference**: [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md.git) (`supabase` & `linear.app`)

---

## Architecture Overview
The application has been elevated from a basic CRUD viewer into an **Enterprise Studio** inspired by Supabase Studio and Linear.app:
- **Obsidian Dark Theme**: Obsidian canvas (`#090a0d`), deep panels (`#12141a`), hairline borders (`#222630`), Supabase signature emerald (`#3ecf8e`), and Linear lavender (`#5e6ad2`).
- **Telemetry & Isolation**: Real-time status badge monitoring `localhost:3306`, MySQL 8.0, and Repeatable Read ACID transactions.
- **8 Dedicated Modules**:
  1. **Dashboard & KPIs**: Production analytics, shift harvest breakdown, quality averages, and top breeds.
  2. **Herd Registry (Animals)**: Master cattle inventory with ear tag indexing, status filtering, and live deletion with cascade safety warnings.
  3. **Milk Collection & Yield**: Milking session logging linked directly to yield records.
  4. **Quality Control Lab**: Laboratory milk testing (Butterfat %, SNF %, Specific Density, Grade A tagging).
  5. **Feed & Nutrition Stock**: Warehouse commodity tracking with reorder alert thresholds and animal dispensation logs.
  6. **Commercial Sales & 3NF Billing**: Invoice settlement tracking showing total amounts, payments made, and outstanding balances.
  7. **Interactive SQL Studio**: In-browser SQL console supporting arbitrary queries with execution telemetry and preset shortcuts (e.g. Query 29 trace for Animal #20).
  8. **Schema & Table Inspector**: Interactive specification of all 14 base relations, primary keys, and foreign keys.

---

## How to Run Locally

### Option 1: One-Click Launch Script
Double-click `run.bat` located inside `source_code/`.

### Option 2: Command Line Launch
```bash
cd source_code
pip install -r requirements.txt
python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000
```
Open your browser at:
```
http://127.0.0.1:8000
```

---

## Live Screenshots
- **Dashboard & KPIs**: `screenshots/dashboard.png`
- **Herd Master Registry**: `screenshots/herd_registry.png`
- **Interactive SQL Studio**: `screenshots/sql_studio.png`
- **Schema & Architecture Inspector**: `screenshots/schema_inspector.png`
