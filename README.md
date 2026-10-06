# CreditGuard

**CreditGuard** is an educational end-to-end machine-learning project that estimates credit-card default risk and exposes the model through a FastAPI backend, Microsoft SQL Server persistence, and a Flutter mobile application.

> **Educational prototype only.** CreditGuard is not a lending, underwriting, pricing, eligibility, approval, or denial system and must not be used for real-world credit decisions.

## Current stack

- **ML:** Python, pandas, scikit-learn, XGBoost
- **Backend:** FastAPI + Pydantic
- **Database:** Microsoft SQL Server Express via SQLAlchemy + pyodbc
- **Mobile:** Flutter + GetX + `http`
- **Model persistence:** `joblib`

## Dataset

The project uses the **UCI Default of Credit Card Clients** dataset.

- 30,000 rows
- Binary target: default payment in the following month
- Original dataset: 23 explanatory variables

Source: UCI Machine Learning Repository, dataset 350.

## ML workflow

```text
UCI dataset
→ cleaning / EDA
→ train / validation / test split
→ candidate model comparison
→ threshold evaluation
→ 23 vs 10 vs 8 input comparison
→ compact product model
→ saved pipeline
→ FastAPI inference
```

The notebook compares multiple classifiers, including classical scikit-learn
models and stronger ensemble/boosting approaches.

### Selected product candidate

The current application uses:

```text
Algorithm                XGBoost
Product input count      8
Classification threshold 0.25
ROC-AUC                  ~0.768
Recall                   ~0.581
F1                       ~0.535
Accuracy                 ~77.7%
```

The 8-input model was selected because it retained performance reasonably close
to the full 23-input model while making the mobile assessment substantially
simpler.

### Model inputs

The model receives:

```text
LIMIT_BAL
AGE
PAY_0
PAY_2
BILL_AMT1
BILL_AMT2
PAY_AMT1
PAY_AMT2
```

The Flutter application does not expose these raw dataset column names. It uses
user-friendly labels such as credit limit, age, recent repayment status, bill
amounts, and recent payment amounts.

# Architecture

```text
                    +---------------------------+
                    | UCI Credit Card Dataset   |
                    +-------------+-------------+
                                  |
                                  v
                    +---------------------------+
                    | Pandas / Cleaning / EDA   |
                    +-------------+-------------+
                                  |
                                  v
                    +---------------------------+
                    | Feature Engineering       |
                    +-------------+-------------+
                                  |
                                  v
                    +---------------------------+
                    | Train / Validation / Test |
                    +-------------+-------------+
                                  |
                                  v
        +---------------------------------------------------+
        |        Candidate Model Comparison                 |
        |                                                   |
        | Logistic Regression                               |
        | Decision Tree                                     |
        | Random Forest                                     |
        | Extra Trees                                       |
        | SVC                                               |
        | Gradient Boosting                                 |
        | HistGradientBoosting                              |
        | XGBoost                                           |
        | LightGBM                                          |
        | CatBoost                                          |
        +----------------------+----------------------------+
                               |
                               v
                    +---------------------------+
                    | Model Evaluation          |
                    | - Accuracy                |
                    | - Precision               |
                    | - Recall                  |
                    | - F1                      |
                    | - ROC-AUC                 |
                    | - PR-AUC                  |
                    +-------------+-------------+
                                  |
                                  v
                    +---------------------------+
                    | Threshold Evaluation      |
                    | Selected Threshold: 0.25  |
                    +-------------+-------------+
                                  |
                                  v
                    +---------------------------+
                    | Input Reduction Compare   |
                    | 23 vs 10 vs 8 Inputs      |
                    +-------------+-------------+
                                  |
                                  v
                    +---------------------------+
                    | Final Product Model       |
                    | XGBoost                   |
                    | 8 Input Features          |
                    +-------------+-------------+
                                  |
                                  v
                    +---------------------------+
                    | joblib Model Artifact     |
                    | model_stronger_notebook   |
                    +-------------+-------------+
                                  |
                                  v
                    +---------------------------+
                    | FastAPI Backend           |
                    | POST /api/v1/predictions  |
                    +-------------+-------------+
                                  |
               +------------------+------------------+
               |                                     |
               v                                     v
      +----------------------+              +----------------------+
      | Microsoft SQL Server |              | Flutter Mobile App   |
      | Prediction History   |              | Assessment Form      |
      | Model Results        |              | Result Screen        |
      +----------+-----------+              +----------+-----------+
                 |                                     |
                 +------------------+------------------+
                                    |
                                    v
                         +-----------------------+
                         | User-Friendly Result  |
                         | - Risk Level          |
                         | - Probability         |
                         | - Summary             |
                         | - Contextual Factors  |
                         | - Disclaimer          |
                         +-----------------------+
```                         

See [`architecture.md`](architecture.md) for more detail.

## Repository structure

```text
creditguard/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   ├── core/
│   │   ├── ml/
│   │   ├── db.py
│   │   ├── main.py
│   │   ├── models.py
│   │   └── schemas.py
│   └── requirements.txt
├── ml_pipeline/
│   ├── CreditGuard_ML_Stronger_Models.ipynb
│   ├── feature_engineering.py
│   └── runtime.py
├── flutter_app/
│   ├── lib/
│   ├── android/
│   └── pubspec.yaml
├── artifacts/
├── data/
├── reports/
├── scripts/
├── tests/
├── sql_schema.sql
├── architecture.md
├── .env.example
└── README.md
```

Generated datasets, trained binary model files, build outputs, virtual
environments, local IDE files, and secrets are intentionally excluded from Git.

## Backend setup

### 1. Create a virtual environment

From the repository root:

```powershell
python -m venv ..\.venv
..\.venv\Scripts\Activate.ps1
```

Or use any virtual-environment location you prefer.

### 2. Install dependencies

```powershell
pip install -r backend\requirements.txt
```

The saved model was validated using `scikit-learn==1.7.2`. Loading a joblib
artifact with a different scikit-learn version can produce compatibility
warnings or invalid behavior.

### 3. Configure environment

Copy:

```powershell
Copy-Item .env.example .env
```

Edit `.env` for your local SQL Server instance:

```env
DB_SERVER=localhost\SQLEXPRESS
DB_NAME=CreditGuard
DB_DRIVER=ODBC Driver 18 for SQL Server
```

`.env` is ignored by Git.

### 4. Create the database

Run `sql_schema.sql` in SQL Server Management Studio, then verify connectivity:

```powershell
python scripts\test_sqlserver.py
```

### 5. Prepare the model artifact

Binary model artifacts are intentionally excluded from Git.

Run the notebook:

```text
ml_pipeline/CreditGuard_ML_Stronger_Models.ipynb
```

The selected artifact/metadata should be placed at:

```text
artifacts/model_stronger_notebook.joblib
artifacts/model_stronger_notebook_metadata.json
```

### 6. Start FastAPI

```powershell
uvicorn backend.app.main:app --host 0.0.0.0 --port 8000
```

Swagger:

```text
http://127.0.0.1:8000/docs
```

## API

### Health

```http
GET /api/v1/health
```

### Model information

```http
GET /api/v1/model/info
```

### Create prediction

```http
POST /api/v1/predictions
```

Example:

```json
{
  "credit_limit": 120000,
  "age": 32,
  "recent_payment_status": 0,
  "previous_payment_status": 0,
  "current_bill_amount": 90000,
  "previous_bill_amount": 85000,
  "latest_payment_amount": 5000,
  "previous_payment_amount": 5000
}
```

Example response shape:

```json
{
  "id": 8,
  "created_at": "2026-10-04T14:03:03",
  "risk": {
    "level": "low",
    "label": "Low Risk",
    "estimated_probability": 0.104043,
    "percentage": 10
  },
  "summary": {
    "title": "Your estimated default risk is low",
    "message": "The model produced an estimated default probability of about 10% based on the information you provided."
  },
  "factors": [
    {
      "title": "Recent repayment history",
      "status": "positive",
      "message": "Your most recent repayment status shows no positive delay code."
    }
  ],
  "explanation_note": "Contextual signals are not causal model explanations.",
  "disclaimer": "Educational prototype only; this estimate is not a lending or credit decision."
}
```

### Prediction history

```http
GET /api/v1/predictions?limit=20
```

Authentication and user-specific history are planned next.

## Flutter setup

From `flutter_app`:

```powershell
flutter pub get
flutter devices
```

For the Android emulator:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For a physical Android device on the same Wi-Fi network, use the development
machine's current LAN IPv4 address:

```powershell
flutter run -d DEVICE_ID --dart-define=API_BASE_URL=http://YOUR_PC_IP:8000
```

The FastAPI server must be bound to `0.0.0.0` for LAN access.

## Current user flow

```text
Open app
→ enter eight assessment inputs
→ submit assessment
→ FastAPI runs XGBoost inference
→ prediction stored in SQL Server
→ dedicated result screen
→ risk level + estimated probability
→ summary + contextual factors + disclaimer
→ prediction history
```

## Evaluation notes

Accuracy is not treated as the only metric. CreditGuard also compares:

- Precision
- Recall
- F1
- ROC-AUC
- PR-AUC
- Confusion matrix

The default classification threshold was changed from `0.50` to `0.25` after
validation because the project values detecting more potential defaults over
maximizing raw accuracy alone.

## Explainability limitation

The current API factors are simple contextual signals derived from the supplied
inputs. They are useful for UI explanation but are **not** causal explanations
of the XGBoost prediction.

A future version can add SHAP-based local feature attribution.

## Probability limitation

The current percentage is the model's estimated probability. Probability
calibration is still planned and should be evaluated before interpreting the
number as a strongly calibrated real-world probability.

## Tests

```powershell
pytest -q
```

## Roadmap

- [x] Dataset / EDA
- [x] Candidate model comparison
- [x] Compact feature evaluation
- [x] 8-input XGBoost integration
- [x] FastAPI inference
- [x] SQL Server persistence
- [x] Flutter assessment form
- [x] Dedicated result screen
- [x] Prediction history
- [ ] Probability calibration
- [ ] Authentication / JWT
- [ ] User-specific prediction history
- [ ] SHAP explanations
- [ ] Backend/API tests for the new compact contract
- [ ] Screenshots and demo GIF
- [ ] CI
- [ ] Deployment

## Security / repository hygiene

Do not commit:

- `.env`
- database credentials
- local SQL Server machine names
- Android `local.properties`
- Python virtual environments
- Flutter build output
- downloaded datasets
- trained binary model artifacts

Use `.env.example` for documented configuration.

## License / disclaimer

This repository is an educational portfolio project built on a public research
dataset. It is not designed or validated for real credit decision-making.
