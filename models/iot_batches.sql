{{
  config({    
    "materialized": "incremental",
    "incremental_strategy": "delete+insert",
    "on_schema_change": 'append_new_columns',
    "unique_key": ["LOADED_AT", "YEAR", "MONTH"]
  })
}}

WITH IOT AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT') }}

),

incremental_iot_data AS (

  SELECT *
  
  FROM IOT
  
  {% if is_incremental() %}
    WHERE 
      LOADED_AT > (SELECT MAX(LOADED_AT) FROM {{ this }})
  {% endif %}

),

count_by_date AS (

  {#Tracks the number of records loaded over time, organized by year and month.#}
  SELECT 
    LOADED_AT AS LOADED_AT,
    YEAR(TS) AS YEAR,
    MONTH(TS) AS MONTH,
    COUNT(*) AS N_RECORDS_LOADED
  
  FROM incremental_iot_data AS in0
  
  GROUP BY 
    LOADED_AT, YEAR(TS), MONTH(TS)

),

reported_at AS (

  {#Formats data to include loading timestamps and record counts for reporting.#}
  SELECT 
    LOADED_AT AS LOADED_AT,
    YEAR AS YEAR,
    MONTH AS MONTH,
    N_RECORDS_LOADED AS N_RECORDS_LOADED,
    current_timestamp() AS REPORTED_AT
  
  FROM count_by_date AS in0

)

SELECT *

FROM reported_at
