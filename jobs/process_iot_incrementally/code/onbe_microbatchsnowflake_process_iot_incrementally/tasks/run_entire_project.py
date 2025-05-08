from onbe_microbatchsnowflake_process_iot_incrementally.utils import *

def run_entire_project():
    from airflow.operators.python import PythonOperator
    from datetime import timedelta
    import os
    import zipfile
    import tempfile

    return PythonOperator(
        task_id = "run_entire_project",
        python_callable = invoke_dbt_runner,
        op_kwargs = {
          "is_adhoc_run_from_same_project": False,
          "is_prophecy_managed": False,
          "run_deps": False,
          "run_seeds": False,
          "run_parents": False,
          "run_children": False,
          "run_tests": True,
          "run_mode": "project",
          "entity_kind": "model",
          "entity_name": "IOT_INCREMENTAL",
          "project_id": "44652",
          "git_entity": "tag",
          "git_entity_value": "__PROJECT_FULL_RELEASE_TAG_PLACEHOLDER__",
          "git_ssh_url": "https://github.com/SimpleDataLabsInc/Onbe_microbatchSnowflake.git",
          "git_sub_path": "",
          "select": "",
          "threads": "",
          "exclude": "",
          "run_props": "",
          "envs": {"DBT_DATABRICKS_INVOCATION_ENV" : "prophecy"}
        },
    )
