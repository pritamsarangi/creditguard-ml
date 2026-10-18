# CreditGuard

**CreditGuard** is an educational credit-card default-risk assessment application built with a compact eight-input XGBoost model, a FastAPI API, and a Flutter client for Web and Android. Users authenticate with an email one-time password (OTP), submit an assessment, view the estimated risk and contextual factors, and revisit their own prediction history.

> **Educational demonstration only.** CreditGuard must not be used for lending, underwriting, pricing, eligibility, approval, denial, or other real-world credit decisions. Model scores are not calibrated real-world probabilities, and contextual factors are not causal explanations.

## Live demo

| Component | URL |
| --- | --- |
| Flutter Web | [Open CreditGuard](https://creditguard-web.pritamsarangi70.workers.dev) |
| FastAPI documentation | [Swagger UI](https://creditguard-api-0izj.onrender.com/docs) |
| API health | [Health endpoint](https://creditguard-api-0izj.onrender.com/api/v1/health) |

The API runs on a Render free instance, which may sleep when idle. The first request after inactivity can be slow enough to time out; retrying after the service wakes may succeed. Avoid repeatedly requesting OTP emails.

**Deployment status:** The hosted Flutter Web flow and a signed Android release APK were tested with email OTP, prediction submission, history, and logout. These are functional smoke tests, **not** a security audit or load test.

## Technology stack

- **Machine learning:** Python, pandas, scikit-learn, XGBoost; serialized pipeline via `joblib`
- **Backend:** FastAPI, Pydantic, SQLAlchemy, JWT access tokens and rotating refresh sessions
- **Database:** Neon PostgreSQL in deployment; Microsoft SQL Server Express available for local development
- **Email:** Brevo transactional email for OTP delivery
- **Frontend:** Flutter (Android + Web), `flutter_bloc`, `go_router`, Dio
- **Hosting:** Render for FastAPI and Cloudflare Workers static assets for Flutter Web

## Architecture

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

## Dataset and ML evaluation

The model was developed using the [UCI Default of Credit Card Clients dataset](https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients), containing 30,000 observations, 23 original explanatory variables, and a binary target indicating default payment in the following month.

The notebook workflow covers data cleaning and exploratory analysis, train/validation/test splitting, candidate-model comparisons, threshold evaluation, and comparison of 23-, 10-, and 8-feature configurations. The chosen application model uses eight inputs to make the assessment form simpler.

| Property | Value |
| --- | --- |
| Model | XGBoost, compact eight-input version |
| Model version | `notebook_v4` |
| Default classification threshold | `0.25` |
| ROC-AUC (reported notebook evaluation) | approximately `0.768` |
| Recall (reported notebook evaluation) | approximately `0.581` |
| F1 (reported notebook evaluation) | approximately `0.535` |
| Accuracy (reported notebook evaluation) | approximately `77.7%` |

These figures are historical notebook evaluation results, not live production metrics. The `/api/v1/model/info` endpoint currently returns an empty `selected_metrics` object.

### Inputs and risk bands

| Dataset feature | Flutter form field |
| --- | --- |
| `LIMIT_BAL` | Credit limit |
| `AGE` | Age |
| `PAY_0` | Most recent repayment status |
| `PAY_2` | Previous repayment status |
| `BILL_AMT1` | Current bill amount |
| `BILL_AMT2` | Previous bill amount |
| `PAY_AMT1` | Latest payment amount |
| `PAY_AMT2` | Previous payment amount |

Repayment status is selected from readable dropdown options (for example, **Paid as agreed**, **Current / no recorded delay**, **1 month late**, **2 months late**), not by manually entering dataset codes.

The application currently categorizes model output into **Low** (below 0.20), **Medium** (0.20 to below 0.40), and **High** (0.40 or greater) risk bands. The separate `0.25` classification threshold determines the binary predicted-default output. Neither threshold should be interpreted as a validated real-world policy rule.

## Repository layout

```text
backend/       FastAPI routes, services, database models and requirements
flutter_app/   Flutter Web and Android client
ml_pipeline/   Notebooks and model runtime
artifacts/     Selected serialized model and metadata
scripts/       Development utilities
tests/         Repository tests (where available)
.env.example   Configuration template
architecture.md
README.md
```

## Local backend setup (Windows / PowerShell)

From the repository root:

```powershell
python -m venv ..\.venv
..\.venv\Scripts\Activate.ps1
pip install -r backend\requirements.txt
Copy-Item .env.example .env
```

Edit the private `.env` file. For SQL Server Express, configure `DB_SERVER`, `DB_NAME` and `DB_DRIVER`, then create the database schema using the repository's SQL setup instructions. For PostgreSQL, set `DATABASE_URL` to a SQLAlchemy-compatible URL beginning with `postgresql+psycopg://` and install the PostgreSQL driver if it is not included in your local environment.

Configure `OTP_SECRET_KEY`, `JWT_SECRET_KEY`, `BREVO_API_KEY`, and `BREVO_SENDER_EMAIL` to use email authentication. **Never commit real credentials.**

Start the API from the repository root:

```powershell
uvicorn backend.app.main:app --host 127.0.0.1 --port 8000
```

Open `http://127.0.0.1:8000/docs`. For Android devices on the same network, bind the API to `0.0.0.0` instead and use the computer's LAN address.

The selected model is committed at `artifacts/model_stronger_notebook.joblib`, with accompanying metadata. You do **not** need to retrain the model to run the existing application. The saved pipeline was validated with `scikit-learn==1.7.2`; dependency compatibility matters when loading Python model artifacts.

## API overview

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/api/v1/health` | API and model readiness |
| `GET` | `/api/v1/model/info` | Model metadata |
| `POST` | `/api/v1/auth/send-otp` | Request email OTP |
| `POST` | `/api/v1/auth/verify-otp` | Verify OTP and issue session tokens |
| `POST` | `/api/v1/auth/refresh` | Rotate session tokens |
| `POST` | `/api/v1/auth/logout` | Revoke session |
| `GET` | `/api/v1/auth/me` | Current user |
| `POST` | `/api/v1/predictions` | Authenticated risk assessment |
| `GET` | `/api/v1/predictions?limit=20` | Authenticated user prediction history |

Example assessment payload (requires authentication):

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

## Flutter: run and build

From `flutter_app`:

```powershell
flutter pub get
flutter analyze
flutter test
```

Run against the hosted HTTPS API:

```powershell
flutter run -d chrome --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://creditguard-api-0izj.onrender.com
```

For Android, replace `chrome` with the device ID from `flutter devices`.

Create a production Web bundle:

```powershell
flutter build web --release --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://creditguard-api-0izj.onrender.com
```

Output: `flutter_app/build/web/`. The current Cloudflare deployment was uploaded as static assets to a Cloudflare Worker. Manual static uploads do not automatically update when GitHub changes; rebuild and upload the new assets after frontend changes.

Create a signed Android APK after configuring **private** Android release signing credentials:

```powershell
flutter build apk --release --dart-define=APP_ENV=prod --dart-define=API_BASE_URL=https://creditguard-api-0izj.onrender.com
```

Output: `flutter_app/build/app/outputs/flutter-apk/app-release.apk`. The release keystore and `android/key.properties` must remain outside version control. Save an independent backup of the keystore and passwords; future updates must use the same signing identity. The current Android application ID is `com.example.creditguard_flutter`, suitable for a project demo but not a finalized Play Store identity.

See [Flutter client instructions](flutter_app/README.md) for details.

## Deployment configuration

The Render Web Service uses the repository root, installs `backend/requirements-prod.txt`, and starts:

```bash
uvicorn backend.app.main:app --host 0.0.0.0 --port $PORT
```

Deployment environment variables include `DATABASE_URL`, `OTP_SECRET_KEY`, `JWT_SECRET_KEY`, `BREVO_API_KEY`, `BREVO_SENDER_EMAIL`, and `CORS_ORIGINS`. The browser origin must be explicitly allowed:

```dotenv
CORS_ORIGINS=https://creditguard-web.pritamsarangi70.workers.dev
```

This is a public frontend and API URL; **do not** put backend secrets in the Flutter build, source control, or public environment variables.

## Security, operations and limitations

- OTP challenges expire after 5 minutes, limit verification attempts, and have a 60-second per-email resend cooldown. The latest backend change adds basic per-email and global hourly request caps. The rejection behavior has not yet been independently exercised after deployment; limits based on counting database records are not concurrency-safe and do not provide per-IP or distributed abuse protection.
- The API is publicly reachable. The current OTP limits are suitable only as basic controls for a controlled demo; they do not establish production-grade resistance to automated abuse or email flooding.
- Browser refresh tokens are held in JavaScript-accessible memory rather than persistent browser storage. This limits persistence across reloads but does **not** provide HttpOnly-cookie protection against XSS. Public production authentication warrants further review, including the expired-session redirect behavior.
- The signed Android APK has passed a device functional smoke test; the release signature has not been independently audited in this document.
- Render's free instance may be slow on the first request after idle; API timeouts are a known user-experience limitation.
- The eight-input XGBoost score is **not probability-calibrated**. The UI's contextual factors summarize input patterns and are not SHAP values, causal effects, or guaranteed explanations of a specific prediction.
- No independent penetration test, exhaustive backend automated test suite, or accessibility audit is claimed.

## Validation performed

- Flutter analysis and automated tests were passing during development (23 tests reported in the project workflow).
- Local Chrome and Android debug workflows were exercised.
- Hosted Flutter Web: OTP login, prediction, history, logout, and re-login paths were smoke-tested.
- Signed Android release APK: installed and tested on a physical OnePlus device against the hosted API, without requiring USB during application use.
- Render deployment and model-readiness endpoints were confirmed operational. The latest OTP-limiting deployment was reported **Live**.

## License and attribution

This is an educational portfolio project based on the UCI Default of Credit Card Clients research dataset. Dataset licensing and citation requirements should be reviewed before redistributing the dataset. No software license is granted by this README; consult any repository license file for applicable terms.
