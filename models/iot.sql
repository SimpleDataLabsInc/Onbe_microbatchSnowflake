{{
  config({    
    "materialized": "view",
    "alias": "iot_v"
  })
}}

WITH IOT AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT') }}

),

gt_max_loaded_at AS (

  {#Fetches the latest IoT entries since the last recorded load time.#}
  SELECT * 
  
  FROM IOT AS in0
  
  WHERE LOADED_AT > (
          SELECT MAX_LOADED_AT
          
          FROM {{ ref('iot_max_loaded_at')}}
         )

)

SELECT *

FROM gt_max_loaded_at
