from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import os
import shutil
import logging

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")


def extract_data():
    airbnb_dataset = "/opt/airflow/sources/airbnb"
    census_datasets = "/opt/airflow/sources/Census LGA"
    lga_dataset = "/opt/airflow/sources/LGA"
    destination_path = "/opt/airflow/datasets/"

    # create destination dir if not exist
    os.makedirs(destination_path, exist_ok=True)

    for path in [census_datasets, lga_dataset, airbnb_dataset]:
        if not os.path.exists(path):
            logging.warning(f"Source directory not found: {path}")
            continue
        else:
            for file in os.listdir(path):
                full_file_path = os.path.join(path, file)
                if os.path.isfile(full_file_path):
                    try:
                        shutil.copy(full_file_path, destination_path)
                        logging.info(f"Copied: {file}")
                    except Exception as e:
                        logging.error(f"Failed to copy {file}: {e}")

    # if os.path.exists(airbnb_dataset):
    #     target_file = "05_2020.csv"
    #     full_file_path = os.path.join(airbnb_dataset, target_file)

    #     if os.path.isfile(full_file_path):
    #         try:
    #             shutil.copy(full_file_path, destination_path)
    #             logging.info(f"Copied: {target_file}")
    #         except Exception as e:
    #             logging.error(f"Failed to copy {target_file}: {e}")
    #     else:
    #         logging.warning(f"Target file not found {full_file_path}")
    # else:
    #     logging.warning(f"airbnb dataset directory not found: {airbnb_dataset}")


default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2025, 5, 9),
    "email": "airflow@gmail.com",
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(seconds=30),
}


dag = DAG(
    "extracting_datasets_dag",
    default_args=default_args,
    description="A dag to extract ['05-2020.csv' , 'Census LGA', 'LGA mapping'] datasets and upload them into airflow storage bucket.",
    schedule=None,
)

extract_task = PythonOperator(
    task_id="extract_datasets_task", python_callable=extract_data, dag=dag
)

extract_task