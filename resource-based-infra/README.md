```bash
gcloud auth login
gcloud auth application-default login

python3 -m venv .venv
. .venv/bin/activate
python -m pip --upgrade pip
python -m pip install dbt-core dbt-bigquery
```