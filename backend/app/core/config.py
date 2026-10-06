from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import quote_plus

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parents[3]
load_dotenv(BASE_DIR / ".env")


def default_database_url() -> str:
    """
    Build a local SQL Server connection string using Windows Authentication.

    Public repository defaults are intentionally machine-neutral.
    Override DB_SERVER / DB_NAME in your local .env file when needed.
    """
    server = os.getenv("DB_SERVER", r"localhost\SQLEXPRESS")
    database = os.getenv("DB_NAME", "CreditGuard")
    driver = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")

    odbc = (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    return "mssql+pyodbc:///?odbc_connect=" + quote_plus(odbc)


@dataclass(frozen=True)
class Settings:
    database_url: str = os.getenv("DATABASE_URL") or default_database_url()

    model_path: str = os.getenv(
        "MODEL_PATH",
        str(BASE_DIR / "artifacts" / "model_stronger_notebook.joblib"),
    )
    model_metadata_path: str = os.getenv(
        "MODEL_METADATA_PATH",
        str(BASE_DIR / "artifacts" / "model_stronger_notebook_metadata.json"),
    )

    model_version: str = os.getenv("MODEL_VERSION", "notebook_v4")
    model_name: str = os.getenv("MODEL_NAME", "xgboost_compact_8")

    classification_threshold: float = float(
        os.getenv("CLASSIFICATION_THRESHOLD", "0.25")
    )

    low_risk_max: float = float(os.getenv("LOW_RISK_MAX", "0.20"))
    high_risk_min: float = float(os.getenv("HIGH_RISK_MIN", "0.40"))

    cors_origins: str = os.getenv("CORS_ORIGINS", "*")


settings = Settings()
