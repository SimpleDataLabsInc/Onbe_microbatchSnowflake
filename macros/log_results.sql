{% macro log_results(results) -%}

{%- if execute -%}

    {%- set load_log_table -%}
ONBE_DEMO_{{- var('DBT_TARGET') -}}.PUBLIC.DBT_LOAD_LOG
    {%- endset -%}

    {{- log( 'Updating audit table ' ~ load_log_table, info=True) -}}
    {{- log( 'DBT invocation ID is ' ~ invocation_id, info=True ) -}}


    {% for r in results -%}
       {{ log( 'DBT Model "' ~
               r.node.relation_name ~
               '" operated on ' ~
               r.adapter_response.rows_affected ~
               ' rows.', info=True) }}
    {% endfor -%}

    {% set load_log_insert %}

INSERT INTO {{ load_log_table }} (
    DBT_INVOCATION_ID,
    SNOWFLAKE_QUERY_ID,
    DBT_RELATION_NAME,
    LOAD_START_TS,
    LOAD_END_TS,
    LOAD_STATUS,
    RESULT_MESSAGE,
    N_ROWS_AFFECTED,
    CREATED_AT_TS,
    UPDATED_AT_TS,
    CREATED_BY_USER )
VALUES

        {%- for r in results %}
(
    '{{ invocation_id }}',
    '{{ r.adapter_response.query_id }}',
    '{{ r.node.relation_name }}',
    '{{ r.timing|map(attribute="started_at")|min|string }}',
    '{{ r.timing|map(attribute="completed_at")|max|string }}',
    '{{ r.status.value|string }}',
    '{{ r.message }}',
    {{ r.adapter_response.rows_affected }},
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP(),
    CURRENT_USER()
)

            {%- if not loop.last %},
            {%- else %};
            {%- endif %}

        {%- endfor %}

    {%- endset %}

    {{ print( load_log_insert) }}

    {%- do run_query( load_log_insert) -%}

    {{ log( 'Audit table update complete', info=True) }}

    {#

    {{ print( "Run results:\n\n" ~ results|pprint) }}

    #}


{%- endif -%}

{%- endmacro -%}



{#     everything below is commented out

{% do run_query( load_log_insert) %}

.print_json(indent=2) %}







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

