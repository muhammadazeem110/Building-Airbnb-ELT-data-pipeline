from airflow import DAG
from airflow.operators.python import PythonOperator
import logging
from datetime import datetime, timedelta
from cosmos import ProfileConfig, ProjectConfig, DbtDag
from cosmos.profiles import PostgresUserPasswordProfileMapping
from cosmos.operators import DbtRunOperator, DbtSnapshotOperator, DbtTestOperator

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

profile_config = ProfileConfig(
    profile_name="airbnb_warehouse",
    target_name="dev",
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id="airbnb_connection",
        profile_args={"schema": "analytics_silver", "database": "postgres"},
    ),
)

default_args = {
    "owner": "airflow",
    "email": "airflow@gmail.com",
    "depends_on_past": False,
    "start_date": datetime(2025, 5, 22),
    "email_on_start": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(seconds=20),
}

dag = DAG(
    "dbt_silver_ingestion",
    default_args=default_args,
    description="This DAG handles the ingestion of cleaned data into the Postgres Silver schema using dbt for transformation and loading, representing the second layer of the Medallion architecture.",
    schedule=None,
    catchup=False,
)

dbt_airbnb_silver_task = DbtRunOperator(
    task_id="dbt_run_silver_model",
    project_config=ProjectConfig(dbt_project_path="/opt/airflow/airbnb_warehouse"),
    profile_config=profile_config,
    select=["models/silver"],
    dag=dag,
)

listing_snapshot_task = DbtSnapshotOperator(
    task_id="run_listing_snapshot",
    project_config=ProjectConfig(dbt_project_path="/opt/airflow/airbnb_warehouse"),
    profile_config=profile_config,
    select=["snapshot"],
    dag=dag,
)

dbt_airbnb_silver_task >> listing_snapshot_task >>
