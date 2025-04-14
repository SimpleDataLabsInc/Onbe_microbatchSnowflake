import os
import sys
import pendulum
from datetime import timedelta
import airflow
from airflow import DAG
from airflow.models.param import Param
from airflow.decorators import task
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
from best_neil_onbe_microbatchsnowflake_report_iot_batches.tasks import iot_batches
PROPHECY_RELEASE_TAG = "__PROJECT_ID_PLACEHOLDER__/__PROJECT_RELEASE_VERSION_PLACEHOLDER__"

with DAG(
    dag_id = "best_neil_Onbe_microbatchSnowflake_report_iot_batches", 
    schedule_interval = None, 
    default_args = {"owner" : "Prophecy", "retries" : 0, "ignore_first_depends_on_past" : True, "do_xcom_push" : True}, 
    params = {'DBT_TARGET' : Param("""DEV""", type = "string", title = """DBT_TARGET""")}, 
    start_date = pendulum.today('UTC'), 
    catchup = False, 
    max_active_runs = 1
) as dag:
    iot_batches_op = iot_batches()
