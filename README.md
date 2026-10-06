# Dairy Farm Herd and Milk Collection Management System

**DBMS Course Project Submission — Semester III (2026–2027)**  
* **Student Name**: Mohammed Zaid  
* **Roll Number**: 25WU0102163  
* **Section**: AIML Panthers  
* **Course**: Database Management Systems  
* **Faculty Guide**: Dr. Kiran Mayee Adavala  

---

## 📂 Repository Structure

According to the official **DBMS Course Project Instructions**, this repository is organized into five mandatory submission units:

```
DBMS-Course-Project/
├── Presentation-I/
│   └── Presentation-I_Problem_Description.pdf      # Problem identification, data silos, operational scope
├── Presentation-II/
│   ├── Presentation-II_Database_Architecture.pdf   # 10-slide architectural deck (Exported from Gamma)
│   ├── Presentation-II_Database_Architecture.pptx  # 10-slide PowerPoint presentation deck
│   ├── GAMMA_IMPORT_Presentation-II.md             # Markdown source for Gamma.app
│   ├── ER_Diagram_and_Relational_Schema.png        # Conceptual ER model & 3NF relational schema
│   ├── Queries_for_DBMS_project.sql                # 30+ production queries (including Query #29)
│   └── dairy_farm_db_full.sql                      # Complete MySQL dump (DDL, DML, Triggers, Views)
├── Presentation-III/
│   ├── Presentation-III_Live_Demonstration.pdf     # 10-slide live demo deck (Exported from Gamma)
│   ├── Presentation-III_Live_Demonstration.pptx    # 10-slide PowerPoint presentation deck
│   ├── GAMMA_IMPORT_Presentation-III.md            # Markdown source for Gamma.app
│   ├── source_code/                                # Complete FastAPI + Studio CRUD web application
│   │   ├── backend/                                # Python FastAPI REST API server & PyMySQL connector
│   │   ├── static/                                 # Enterprise Studio UI (8 modules, before/after audit)
│   │   ├── requirements.txt                        # Python dependencies
│   │   └── run.bat                                 # One-click launch script for Windows
│   └── screenshots/                                # Live demonstration screenshots
├── Project-Report/
│   └── DBMS_Project_Report_Mohammed_Zaid.docx       # Full 16-section project report
└── README.md                                       # System overview and quick-start instructions
```

---

## 🛠️ Technology Stack & Requirements

* **Database Engine**: MySQL Server 8.0.x (InnoDB Engine, utf8mb4)
* **Database Modeling & Administration**: DBeaver Community Edition 24.x
* **Backend Application**: Python 3.11+ / FastAPI / Uvicorn
* **Database Driver**: PyMySQL (v1.2.3)
* **Frontend**: HTML5, Vanilla CSS3, JavaScript (Fetch API)

---

## ⚡ Quick Demonstration Guide

### 1. Database Setup (MySQL)
The database schema and sample records are located in:
`Presentation-II/dairy_farm_db_full.sql`

To restore the database:
```sql
CREATE DATABASE IF NOT EXISTS dairy_farm_db;
USE dairy_farm_db;
SOURCE Presentation-II/dairy_farm_db_full.sql;
```

### 2. Running the Presentation-III Web Application
```cmd
cd Presentation-III/source_code
run.bat
```
*Open your browser at:* **`http://127.0.0.1:8000`**

### 3. Live Demonstration Protocol (10-Minute Viva Sequence)
1. **View Records**: Browse the 50 baseline cattle records and milk production logs.
2. **Insert Operation**: Click *Add New Animal*, register tag `A9999`, and show the live Transaction Audit Banner transition from **50 → 51 rows**.
3. **Delete Operation**: Delete record `A9999` and show the transaction count transition back to **50 rows** via `ON DELETE CASCADE`.
4. **Presentation-II Master Query**: Run Query #29 in DBeaver tracing `animal_id = 20` across the 8-table relational chain to demonstrate end-to-end traceability.
