{% macro log_results(results) %}

{% if execute %}

{{ log("updating audit table", info=True) }}

{%- set load_log_values -%}

  {%- for r in results -%}
    {{ [ r.node.relation_name,
         r.adapter_response.query_id,
         r.timing|map(attribute="started_at")|min|string,
         r.timing|map(attribute="completed_at")|max|string,
         r.status.value|string,
         r.message
       ] | join("',\n'")
    }}
  {%- endfor -%}
{%- endset -%}

{{ print( load_log_values ) }}

{%- set load_log_insert -%}
    INSERT INTO ONBE_DEMO_DEV.EDW_LOAD_LOG (
        EDW_TABLE_NAME,
        LOAD_START,
        LOAD_END,
        LOAD_STATUS,
        ERROR_MESSAGE,
        CREATE_DATE,
        UPDATE_DATE,
        CREATED_BY_USER )
    VALUES
    ( '{{ [ load_log_values ]|join(",\n") }}' );
{% endset %}

{{ print( load_log_insert) }}

{{ print( "result:\n" ~ results|pprint) }}


{#

{{- log("operated on " ~ r.adapter_response.rows_affected ~ " rows", info=True) -}}

{% set load_log_record = run_query(load_log_select) %}

{% do load_log_record.print_json(indent=2) %}


{% set run_id_query %}
SELECT RUN_ID FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
{% endset %}

{% set run_id_result = run_query(run_id_query) %}
{% set run_id = run_id_result['data'][0][0] %}

{% if res.status != 'success' %}
    {% set error_log_query %}
    INSERT INTO AUDIT.EDW_ERROR_LOG (
        ERROR_MESSAGE, ORIGINAL_RUN_ID)
    VALUES (
        '{{ res.message }}', '{{ run_id }}')
    {% endset %}

    {% do run_query(error_log_query) %}
{% endif %}

{{ log("Inserted row with RUN_ID: " ~ run_id, info=True) }}

#}

{{- log("finished updating audit table", info=True) -}}

{%- endif -%}

{%- endmacro -%}
