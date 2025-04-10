{{
  config({    
    "materialized": "incremental",
    "incremental_strategy": "merge",
    "on_schema_change": 'fail',
    "unique_key": ["LOADED_AT", "DATE"]
  })
}}

WITH IOT AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT') }}

),

count_by_date AS (

  SELECT 
    LOADED_AT AS LOADED_AT,
    DATE(ts) AS DATE,
    COUNT(*) AS N_RECORDS_LOADED
  
  FROM IOT AS iot_incremental
  
  GROUP BY 
    LOADED_AT, DATE(TS)

),

reported_at AS (

  {#Generates a report of records loaded by date, ensuring all dates are accounted for.#}
  SELECT 
    COALESCE(LOADED_AT, '1900-01-01') AS LOADED_AT,
    DATE,
    N_RECORDS_LOADED,
    current_timestamp() AS REPORTED_AT
  
  FROM count_by_date

)

SELECT *

FROM reported_at

{% if is_incremental() %}
  WHERE 
    LOADED_AT > (SELECT MAX(LOADED_AT) FROM {{ this }})
{% endif %}