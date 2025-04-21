{{
  config({    
    "materialized": "view",
    "database": 'ONBE_DEMO_' ~ var('DBT_TARGET') 
  })
}}

WITH incremental_filter AS (

  SELECT *
  
  FROM IOT
  
  WHERE LOADED_AT > (
          SELECT MAX(LOADED_AT)
          
          FROM IOT_BATCHES
         )

)

SELECT *

FROM incremental_filter
