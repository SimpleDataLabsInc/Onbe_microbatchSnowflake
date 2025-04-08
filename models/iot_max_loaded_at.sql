{{
  config({    
    "materialized": "ephemeral"
  })
}}

WITH IOT_BATCHES AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT_BATCHES') }}

),

max_loaded_at AS (

  {#Identifies the most recent data load timestamp from IoT batches.#}
  SELECT 
    MAX(LOADED_AT) AS max_loaded_at
  
  FROM IOT_BATCHES AS in0

)

SELECT *

FROM max_loaded_at
