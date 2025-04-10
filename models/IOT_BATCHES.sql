{{
  config({    
    "materialized": "incremental",
    "incremental_strategy": "merge",
    "on_schema_change": 'fail',
    "unique_key": ["LOADED_AT", "DATE"]
  })
}}

{{
  config({    
    "materialized": "incremental",
    "alias": "IOT_BATCHES",
    "incremental_predicates": [],
    "incremental_strategy": "merge",
    "on_schema_change": 'append_new_columns',
    "unique_key": ["LOADED_AT", "DATE"]
  })
}}

WITH iot_incremental AS (

  SELECT *
  
  FROM IOT
  
  {% if is_incremental() %}
    WHERE 
      LOADED_AT > (
        SELECT COALESCE( MAX(LOADED_AT), '1900-01-01')
        FROM IOT_BATCHES_1
  {% endif %}

),

count_by_date AS (

  SELECT 
    LOADED_AT AS LOADED_AT,
    DATE(ts) AS DATE,
    COUNT(*) AS N_RECORDS_LOADED
  
  FROM iot_incremental
  
  GROUP BY 
    LOADED_AT, DATE(TS)

),

reported_at AS (

  SELECT 
    LOADED_AT,
    DATE,
    N_RECORDS_LOADED,
    current_timestamp() AS REPORTED_AT
  
  FROM count_by_date

)

SELECT *

FROM reported_at


WITH IOT AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT') }}

),

IOT_BATCHES_1 AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT_BATCHES') }}

)

