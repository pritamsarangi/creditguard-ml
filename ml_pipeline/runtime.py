from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import joblib
import numpy as np
import pandas as pd


MODEL_FEATURES = [
    "LIMIT_BAL",
    "AGE",
    "PAY_0",
    "PAY_2",
    "BILL_AMT1",
    "BILL_AMT2",
    "PAY_AMT1",
    "PAY_AMT2",
]


class ModelRuntime:
    def __init__(
        self,
        model_path: str | Path,
        metadata_path: str | Path,
        model_version: str = "notebook_v4",
        classification_threshold: float = 0.25,
    ) -> None:
        self.model_path = Path(model_path)
        self.metadata_path = Path(metadata_path)

        self.model = None
        self.metadata: dict[str, Any] = {}

        self.model_version = model_version
        self.default_classification_threshold = classification_threshold

        self.load()

    @property
    def is_ready(self) -> bool:
        return self.model is not None

    def load(self) -> None:
        if not self.model_path.exists():
            raise FileNotFoundError(
                f"Model artifact not found: {self.model_path}"
            )

        self.model = joblib.load(self.model_path)

        if self.metadata_path.exists():
            self.metadata = json.loads(
                self.metadata_path.read_text(encoding="utf-8")
            )
            self.model_version = self.metadata.get(
                "model_version",
                self.model_version,
            )

    def predict(self, payload: dict[str, Any]) -> dict[str, Any]:
        assert self.model is not None

        model_input = self._to_model_input(payload)

        frame = pd.DataFrame(
            [model_input],
            columns=MODEL_FEATURES,
        )

        probability = self._predict_probability(frame)

        classification_threshold = float(
            self.metadata.get(
                "classification_threshold",
                self.default_classification_threshold,
            )
        )

        predicted_default = int(
            probability >= classification_threshold
        )

        risk_level, risk_label = self._risk_band(probability)
        summary = self._build_summary(
            probability=probability,
            risk_level=risk_level,
        )

        factors = self._build_context_factors(payload)

        return {
            "model_name": self.metadata.get(
                "model_name",
                "compact_8_inputs",
            ),
            "algorithm": self.metadata.get(
                "algorithm",
                "XGBoost",
            ),
            "model_version": self.model_version,
            "default_probability": round(probability, 6),
            "predicted_default": predicted_default,
            "classification_threshold": classification_threshold,
            "risk": {
                "level": risk_level,
                "label": risk_label,
                "estimated_probability": round(probability, 6),
                "percentage": int(round(probability * 100)),
            },
            "summary": summary,
            "factors": factors,
            "explanation_note": (
                "The factors below are user-friendly contextual signals "
                "derived from the information you entered. They should not "
                "be interpreted as causal explanations of the ML model."
            ),
            "disclaimer": (
                "Educational prototype only; this estimate is not a lending "
                "or credit decision."
            ),
        }

    def _to_model_input(
        self,
        payload: dict[str, Any],
    ) -> dict[str, Any]:
        return {
            "LIMIT_BAL": payload["credit_limit"],
            "AGE": payload["age"],
            "PAY_0": payload["recent_payment_status"],
            "PAY_2": payload["previous_payment_status"],
            "BILL_AMT1": payload["current_bill_amount"],
            "BILL_AMT2": payload["previous_bill_amount"],
            "PAY_AMT1": payload["latest_payment_amount"],
            "PAY_AMT2": payload["previous_payment_amount"],
        }

    def _predict_probability(
        self,
        frame: pd.DataFrame,
    ) -> float:
        if hasattr(self.model, "predict_proba"):
            return float(
                self.model.predict_proba(frame)[0, 1]
            )

        if hasattr(self.model, "decision_function"):
            decision = float(
                self.model.decision_function(frame)[0]
            )
            return float(
                1.0 / (1.0 + np.exp(-decision))
            )

        prediction = int(self.model.predict(frame)[0])
        return float(prediction)

    def _risk_band(
        self,
        probability: float,
    ) -> tuple[str, str]:

        low_max = float(
            self.metadata
            .get("risk_thresholds", {})
            .get("low_max", 0.20)
        )

        high_min = float(
            self.metadata
            .get("risk_thresholds", {})
            .get("high_min", 0.40)
        )

        if probability < low_max:
            return "low", "Low Risk"

        if probability < high_min:
            return "medium", "Medium Risk"

        return "high", "High Risk"

    def _build_summary(
        self,
        probability: float,
        risk_level: str,
    ) -> dict[str, str]:

        percentage = int(round(probability * 100))

        if risk_level == "low":
            return {
                "title": "Your estimated default risk is low",
                "message": (
                    f"The model produced an estimated default probability "
                    f"of about {percentage}% based on the information "
                    "you provided."
                ),
            }

        if risk_level == "medium":
            return {
                "title": "Your estimated default risk is moderate",
                "message": (
                    f"The model produced an estimated default probability "
                    f"of about {percentage}%. Some recent financial "
                    "patterns may require attention."
                ),
            }

        return {
            "title": "Your estimated default risk is high",
            "message": (
                f"The model produced an estimated default probability "
                f"of about {percentage}%. Several recent financial "
                "patterns are associated with increased estimated risk."
            ),
        }

    def _build_context_factors(
        self,
        payload: dict[str, Any],
    ) -> list[dict[str, str]]:

        factors: list[dict[str, str]] = []

        recent_status = int(
            payload["recent_payment_status"]
        )

        previous_status = int(
            payload["previous_payment_status"]
        )

        if recent_status >= 2:
            factors.append({
                "title": "Recent repayment history",
                "status": "warning",
                "message": (
                    "A recent repayment delay is associated with "
                    "higher estimated default risk."
                ),
            })
        elif recent_status == 1:
            factors.append({
                "title": "Recent repayment history",
                "status": "warning",
                "message": (
                    "A recent short payment delay may increase "
                    "the estimated risk."
                ),
            })
        else:
            factors.append({
                "title": "Recent repayment history",
                "status": "positive",
                "message": (
                    "Your most recent repayment status shows no "
                    "positive delay code."
                ),
            })

        if previous_status > recent_status:
            factors.append({
                "title": "Repayment trend",
                "status": "positive",
                "message": (
                    "Your most recent repayment status is better "
                    "than the previous period."
                ),
            })
        elif previous_status < recent_status:
            factors.append({
                "title": "Repayment trend",
                "status": "warning",
                "message": (
                    "Your most recent repayment status is worse "
                    "than the previous period."
                ),
            })

        credit_limit = float(payload["credit_limit"])
        current_bill = float(payload["current_bill_amount"])

        utilization = (
            current_bill / credit_limit
            if credit_limit > 0
            else 0.0
        )

        if utilization >= 0.80:
            factors.append({
                "title": "Credit usage",
                "status": "warning",
                "message": (
                    "Your current bill is high compared with "
                    "your available credit limit."
                ),
            })
        elif utilization <= 0.30:
            factors.append({
                "title": "Credit usage",
                "status": "positive",
                "message": (
                    "Your current bill is relatively low compared "
                    "with your credit limit."
                ),
            })
        else:
            factors.append({
                "title": "Credit usage",
                "status": "neutral",
                "message": (
                    "Your current bill uses a moderate portion "
                    "of your available credit limit."
                ),
            })

        latest_payment = float(
            payload["latest_payment_amount"]
        )

        if current_bill > 0:
            payment_ratio = latest_payment / current_bill

            if payment_ratio < 0.10:
                factors.append({
                    "title": "Latest payment",
                    "status": "warning",
                    "message": (
                        "Your latest payment is small compared "
                        "with the current bill amount."
                    ),
                })
            elif payment_ratio >= 0.25:
                factors.append({
                    "title": "Latest payment",
                    "status": "positive",
                    "message": (
                        "Your latest payment covers a meaningful "
                        "portion of the current bill amount."
                    ),
                })

        return factors[:3]
