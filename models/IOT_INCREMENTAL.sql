{{
  config({    
    "materialized": "view"
  })
}}

{% set TARGET_DATABASE = 'ONBE_DEMO_' ~ env_var( 'DBT_TARGET', 'DEV') %}

WITH incremental_filter AS (

  SELECT *
  
  FROM {{TARGET_DATABASE}}.PUBLIC.IOT
  
  WHERE LOADED_AT > (
          SELECT MAX(LOADED_AT)
          
          FROM {{TARGET_DATABASE}}.PUBLIC.IOT_BATCHES
         )

)

SELECT *

FROM incremental_filter
