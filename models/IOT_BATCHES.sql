{{
  config({    
    "materialized": "incremental",
    "database": 'ONBE_DEMO_' ~ var('DBT_TARGET') ,
    "incremental_strategy": "merge",
    "pre-hook": ["{{ print( 'is_incremental(): ' ~ is_incremental())}}"],
    "unique_key": ["LOADED_AT", "DATE"]
  })
}}

WITH IOT AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT') }}

),

records_per_loaded_at AS (

  SELECT 
    LOADED_AT AS LOADED_AT,
    DATE AS DATE,
    COUNT(*) AS N_RECORDS_LOADED
  
  FROM IOT AS in0
  
  GROUP BY 
    LOADED_AT, DATE

),

with_reported_at AS (

  SELECT 
    LOADED_AT AS LOADED_AT,
    DATE AS DATE,
    N_RECORDS_LOADED AS N_RECORDS_LOADED,
    CURRENT_TIMESTAMP() AS REPORTED_AT
  
  FROM records_per_loaded_at AS in0

)

SELECT *

FROM with_reported_at

{% if is_incremental() %}
  WHERE 
    LOADED_AT > (SELECT MAX(LOADED_AT) FROM {{ this }})
{% endif %}