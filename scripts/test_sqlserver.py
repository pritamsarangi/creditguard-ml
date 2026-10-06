"""Verify Python -> SQL Server using Windows Authentication."""

from __future__ import annotations

import os

import pyodbc
from dotenv import load_dotenv

load_dotenv()

SERVER = os.getenv("DB_SERVER", r"localhost\SQLEXPRESS")
DATABASE = os.getenv("DB_NAME", "CreditGuard")
DRIVER = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")

connection_string = (
    f"DRIVER={{{DRIVER}}};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

with pyodbc.connect(connection_string, timeout=5) as connection:
    cursor = connection.cursor()
    cursor.execute("SELECT @@SERVERNAME, DB_NAME(), SYSTEM_USER")
    row = cursor.fetchone()

    print(f"Server   : {row[0]}")
    print(f"Database : {row[1]}")
    print(f"User     : {row[2]}")
