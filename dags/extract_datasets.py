from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import os
import shutil
import logging

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s:")

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2025, 5, 9),
    "email": "airflow@gmail.com",
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

dags = DAG(
    "extracting_datasets",
    default_args=default_args,
    description="A dag to extract '05-2020.csv' , 'Census LGA', 'LGA mapping' datasets into airflow storage bucket.",
    schedule_interval=None,
)


def extract_data():
    airbnd_dataset = "sources/airbnd"
    census_datasets = "sources/Census LGA"
    lga_dataset = "sources/LGA"

    destination_path = "datasets/"

    # create destination dir if not exist
    os.makedirs(destination_path, exist_ok=True)

    for path in [census_datasets, lga_dataset]:
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

    if os.path.exists(airbnd_dataset):
        target_file = "05-2020.csv"
        full_file_path = os.path.join(airbnd_dataset, target_file)
        
        if os.path.isfile(full_file_path):
            try:
                shutil.copy(full_file_path, destination_path)
                logging.info(f"{target_file} is copied.")
            except Exception as e:
                logging.error(f"Failed to copy {target_file}: {e}")
        else:
            logging.warning(f"Target file not found {full_file_path}")
    else:
        logging.warning(f"Airbnd dataset directory not found: {airbnd_dataset}")


extract_task = PythonOperator(
    task_id = 'extract_datasets_task',
    python_callable = extract_data,
    dag = dags
)

if __name__ == '__main__':
    extract_data()