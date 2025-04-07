{{
  config({    
    "materialized": "incremental",
    "batch_size": "day",
    "begin": "2025-04-07",
    "event_time": "LOADED_AT",
    "incremental_strategy": "microbatch",
    "lookback": 0,
    "on_schema_change": 'fail',
    "post_hook": "{{ log_results(results)}}"
  })
}}

WITH IOT AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT') }}

),

count_by_date AS (

  {#Tracks the number of records loaded over time, organized by year and month.#}
  SELECT 
    LOADED_AT AS LOADED_AT,
    YEAR(TS) AS YEAR,
    MONTH(TS) AS MONTH,
    COUNT(*) AS N_RECORDS_LOADED
  
  FROM IOT AS in0
  
  GROUP BY 
    LOADED_AT, YEAR(TS), MONTH(TS)

)

SELECT *

FROM count_by_date
