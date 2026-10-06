from __future__ import annotations

from pathlib import Path

from ml_pipeline.runtime import ModelRuntime

from ..core.config import settings


try:
    model_runtime = ModelRuntime(
        model_path=settings.model_path,
        metadata_path=settings.model_metadata_path,
        model_version=settings.model_version,
        classification_threshold=settings.classification_threshold,
    )
except FileNotFoundError:
    model_runtime = object.__new__(ModelRuntime)
    model_runtime.model_path = Path(settings.model_path)
    model_runtime.metadata_path = Path(settings.model_metadata_path)
    model_runtime.model = None
    model_runtime.metadata = {}
    model_runtime.model_version = settings.model_version
    model_runtime.default_classification_threshold = (
        settings.classification_threshold
    )
