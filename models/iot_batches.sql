{{
  config({    
    "materialized": "incremental",
    "incremental_predicates": [],
    "incremental_strategy": "delete+insert",
    "on_schema_change": 'fail',
    "unique_key": ["LOADED_AT"]
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
