{{
  config({    
    "materialized": "incremental",
    "incremental_predicates": [],
    "incremental_strategy": "delete+insert",
    "on_schema_change": 'append_new_columns',
    "unique_key": ["LOADED_AT", "YEAR", "MONTH"]
  })
}}

WITH IOT AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT') }}

),

IOT_BATCHES AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT_BATCHES') }}

),

max_loaded_at AS (

  {#Identifies the most recent data load timestamp from IoT batches.#}
  SELECT 
    MAX(LOADED_AT) AS max_loaded_at
  
  FROM IOT_BATCHES AS in0

),

default_loaded_at AS (

  {#Determines the most recent loading date, defaulting to a historical date if no data is available.#}
  SELECT coalesce(max_loaded_at, '1900-01-01') AS max_loaded_at
  
  FROM max_loaded_at AS in0

),

SQLStatement_1 AS (

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
  
  FROM SQLStatement_1 AS in0
  
  GROUP BY 
    LOADED_AT, YEAR(TS), MONTH(TS)

),

reported_at AS (

  {#Formats data to include loading timestamps and record counts for reporting.#}
  SELECT 
    COALESCE(LOADED_AT, '1900-01-01') AS LOADED_AT,
    YEAR AS YEAR,
    MONTH AS MONTH,
    N_RECORDS_LOADED AS N_RECORDS_LOADED,
    current_timestamp() AS REPORTED_AT
  
  FROM count_by_date AS in0

)

SELECT *

FROM reported_at
