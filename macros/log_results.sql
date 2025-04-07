{% macro log_results(results) %}
    {% if execute %}
        {{ log("updating audit table", info=True) }}
        {% for res in results %}
  
            {% set load_log_query %}
            INSERT INTO AUDIT.EDW_LOAD_LOG (
                EDW_TABLE_NAME, LOAD_START, LOAD_END, LOAD_STATUS, ERROR_MESSAGE, CREATE_DATE, UPDATE_DATE, CREATED_BY_USER)
            VALUES (
                SPLIT_PART('{{ res.node.unique_id }}', '.', -1), 
                DATEADD(SECOND, -{{ res.execution_time }}, CURRENT_TIMESTAMP()),
                CURRENT_TIMESTAMP(), 
                '{{ res.status }}',
                '{{ res.message }}',
                CURRENT_TIMESTAMP(),
                CURRENT_TIMESTAMP(),
                CURRENT_USER)
            {% endset %}
  
            {% do run_query(load_log_query) %}

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
            {{ log("operated on " ~ res.adapter_response.rows_affected ~ " rows", info=True) }}
        {% endfor %}
        {{ log("finished updating audit table", info=True) }}
    {% endif %}
{% endmacro %}
