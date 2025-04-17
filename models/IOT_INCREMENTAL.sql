{{
  config({    
    "materialized": "view",
    "database": 'ONBE_DEMO_' ~ var('DBT_TARGET') 
  })
}}

WITH IOT_BATCHES AS (

  SELECT * 
  
  FROM {{ ref('IOT_BATCHES')}}

),

incremental_records AS (

  SELECT *
  
  FROM PUBLIC.IOT
  
  WHERE LOADED_AT > (
          SELECT MAX(LOADED_AT)
          
          FROM IOT_BATCHES
         )

)

SELECT *

FROM incremental_records
