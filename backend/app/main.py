from __future__ import annotations

from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import models  # noqa: F401 - registers ORM models
from .api.routes import router
from .core.config import settings
from .db import Base, engine
from .api.auth_routes import router as auth_router
app = FastAPI(
    title="CreditGuard API",
    description="Educational credit default risk prediction API.",
    version="1.0.0",
)

origins = [item.strip() for item in settings.cors_origins.split(",") if item.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins if origins != ["*"] else ["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

Path(settings.model_path).parent.mkdir(parents=True, exist_ok=True)
Base.metadata.create_all(bind=engine)
app.include_router(router)
app.include_router(auth_router)


@app.get("/")
def root() -> dict:
    return {
        "name": "CreditGuard API",
        "version": app.version,
        "docs": "/docs",
        "disclaimer": "Educational prototype only; not a lending or credit decision.",
    }
