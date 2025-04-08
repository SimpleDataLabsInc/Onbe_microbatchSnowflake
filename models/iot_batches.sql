{{
  config({    
    "materialized": "incremental",
    "batch_size": "day",
    "begin": "2025-04-07",
    "event_time": "LOADED_AT",
    "incremental_strategy": "microbatch",
    "lookback": 0,
    "on_schema_change": 'append_new_columns'
  })
}}

WITH iot AS (

  SELECT * 
  
  FROM {{ ref('iot')}}

),

count_by_date AS (

  {#Tracks the number of records loaded over time, organized by year and month.#}
  SELECT 
    LOADED_AT AS LOADED_AT,
    YEAR(TS) AS YEAR,
    MONTH(TS) AS MONTH,
    COUNT(*) AS N_RECORDS_LOADED
  
  FROM iot AS in0
  
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
