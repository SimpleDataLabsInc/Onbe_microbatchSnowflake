from best_neil_onbe_microbatchsnowflake_report_iot_batches.utils import *

def iot_batches():
    from airflow.operators.python import PythonOperator
    from datetime import timedelta
    import os
    import zipfile
    import tempfile

    return PythonOperator(
        task_id = "iot_batches",
        python_callable = invoke_dbt_runner,
        op_kwargs = {
          "is_adhoc_run_from_same_project": False,
          "is_prophecy_managed": False,
          "run_deps": False,
          "run_seeds": False,
          "run_parents": False,
          "run_children": False,
          "run_tests": True,
          "run_mode": "model",
          "entity_kind": "model",
          "entity_name": "IOT_BATCHES",
          "project_id": "91",
          "git_entity": "tag",
          "git_entity_value": "__PROJECT_FULL_RELEASE_TAG_PLACEHOLDER__",
          "git_ssh_url": "https://github.com/SimpleDataLabsInc/Onbe_microbatchSnowflake",
          "git_sub_path": "",
          "select": "",
          "threads": "",
          "exclude": "",
          "run_props": " --profile snowflake -t {{ params.DBT_TARGET }} --vars {\"DBT_TARGET\":\"{{ var.value.AIRFLOW_INSTANCE_ENV }}\"}",
          "envs": {"DBT_DATABRICKS_INVOCATION_ENV" : "prophecy", "DBT_PROFILES_DIR" : "/home/airflow/gcs/plugins"}
        },
    )
