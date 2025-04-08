{{
  config({    
    "materialized": "view",
    "alias": "iot_v"
  })
}}

WITH IOT AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT') }}

)

SELECT *

FROM IOT
