{% macro log_results(results) %}


{% if execute %}

{#
    {% set load_log_table %}
ONBE_DEMO_{{- var('DBT_TARGET') -}}.PUBLIC.DBT_LOAD_LOG
#}

    {% set load_log_table %}
{{- target.database ~ '.' ~ target.schema -}}.DBT_LOAD_LOG
    {% endset %}

    {{- log( 'Updating audit table ' ~ load_log_table, info=True) -}}
    {{- log( 'DBT invocation ID is ' ~ invocation_id, info=True ) -}}


    {% for r in results %}
       {{ log( 'DBT Model "' ~
               r.node.relation_name ~
               '" operated on ' ~
               r.adapter_response.rows_affected ~
               ' rows.', info=True) }}
    {% endfor %}

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

        {% for r in results %}
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

            {% if not loop.last %},
            {% else %};
            {% endif %}

        {% endfor %}

    {% endset %}

    {{ print( load_log_insert) }}

    {% do run_query( load_log_insert) %}

    {{ log( 'Audit table update complete', info=True) }}


{% endif %}
{% endmacro %}

 