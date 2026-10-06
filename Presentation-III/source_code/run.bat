@echo off
title Dairy Farm DBMS - Live Demonstration
echo ========================================================
echo   DAIRY FARM HERD & MILK COLLECTION MANAGEMENT SYSTEM
echo   Connecting to MySQL Server (dairy_farm_db)...
echo ========================================================
cd /d "%~dp0"
python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000 --reload
pause
