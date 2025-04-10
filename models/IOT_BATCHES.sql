{{
  config({    
    "materialized": "table"
  })
}}

WITH IOT AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT') }}

),

IOT_BATCHES_1 AS (

  SELECT * 
  
  FROM {{ source('ONBE_DEMO_DEV.PUBLIC', 'IOT_BATCHES') }}

)

SELECT *

FROM IOT
