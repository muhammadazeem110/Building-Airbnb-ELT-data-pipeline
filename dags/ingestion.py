import pandas as pd
import logging
import psycopg2
from airflow import DAG
from datetime import datetime, timedelta
from airflow.operators.python import PythonOperator
# from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")


def ingesting_data(file_path, table_name):
    try:
        logging.info(f"File path received: {file_path}")
        df = pd.read_csv(file_path)
        logging.info(f"DataFrame shape: {df.shape}")

        hook = PostgresHook(postgres_conn_id="airbnb_connection")
        engine = hook.get_sqlalchemy_engine()
        with engine.connect() as connection:
            df.to_sql(table_name, connection, if_exists="append", index=False)

        logging.info(f"Successfully ingested data into {table_name}")

    except Exception as e:
        logging.warning(f"Error occured: {e} in ingesting {file_path} to {table_name}.")


def ingesting_airbnb(airbnb_file_path):
    ingesting_data(airbnb_file_path, "airbnb_05_2020")


def ingesting_census_g01(census_g01_file_path):
    ingesting_data(census_g01_file_path, "2016Census_G01_NSW_LGA")


def ingesting_census_g02(census_g02_file_path):
    ingesting_data(census_g02_file_path, "2016Census_G02_NSW_LGA")


def ingesting_lga_code(lga_code_file_path):
    ingesting_data(lga_code_file_path, "NSW_LGA_CODE")


def ingesting_lga_suburb(lga_suburb_file_path):
    ingesting_data(lga_suburb_file_path, "NSW_LGA_SUBURB")


default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2025, 5, 12),
    "email": "airflow@gmail.com",
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(seconds=30),
}

dag = DAG(
    "ingesting_datasets",
    default_args=default_args,
    description="This DAG handles the ingestion of local CSV files into their respective tables in the Postgres Bronze schema, forming the first layer of the Medallion architecture.",
    schedule=None,
)


airbnb_task = PythonOperator(
    task_id="ingest_airbnb",
    python_callable=ingesting_airbnb,
    op_args=["/opt/airflow/datasets/NSW_LGA_CODE.csv"],
    dag=dag,
)

census_g01_task = PythonOperator(
    task_id="ingest_census_g01",
    python_callable=ingesting_census_g01,
    op_args=["/opt/airflow/datasets/2016Census_G01_NSW_LGA.csv"],
    dag=dag,
)

census_g02_task = PythonOperator(
    task_id="ingest_census_go2",
    python_callable=ingesting_census_g02,
    op_args=["/opt/airflow/datasets/2016Census_G02_NSW_LGA.csv"],
    dag=dag,
)

lga_code = PythonOperator(
    task_id="ingest_lga_code",
    python_callable=ingesting_lga_code,
    op_args=["/opt/airflow/datasets/NSW_LGA_CODE.csv"],
    dag=dag,
)

lga_suburb = PythonOperator(
    task_id="ingest_lga_suburb",
    python_callable=ingesting_lga_suburb,
    op_args=["/opt/airflow/datasets/NSW_LGA_SUBURB.csv"],
    dag=dag,
)

airbnb_task >> census_g01_task >> census_g02_task >> lga_code >> lga_suburb
