{{
  config({    
    "materialized": "view"
  })
}}

WITH incremental_filter AS (

  SELECT *
  
  FROM ONBE_DEMO_{{ var('DBT_TARGET') }}.PUBLIC.IOT
  
  WHERE LOADED_AT > (
          SELECT MAX(LOADED_AT)
          
          FROM ONBE_DEMO_{{ var('DBT_TARGET') }}.PUBLIC.IOT_BATCHES
         )

)

SELECT *

FROM incremental_filter
