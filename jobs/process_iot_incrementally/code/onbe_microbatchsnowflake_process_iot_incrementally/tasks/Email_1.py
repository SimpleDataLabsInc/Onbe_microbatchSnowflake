from onbe_microbatchsnowflake_process_iot_incrementally.utils import *

def Email_1():
    from airflow.operators.email import EmailOperator
    from datetime import timedelta

    return EmailOperator(
        task_id = "Email_1",
        to = "best.neil@prophecy.io",
        subject = "test",
        html_content = "test",
        cc = None,
        bcc = None,
        mime_subtype = "mixed",
        mime_charset = "utf-8",
        conn_id = "gmail_conn",
    )
