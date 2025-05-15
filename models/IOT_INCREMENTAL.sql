{{
  config({    
    "materialized": "view"
  })
}}

WITH IOT AS (

  SELECT * 
  
  FROM {{ source('_var_TARGET_DATABASE_.PUBLIC', 'IOT') }}

),

incremental_filter AS (

  SELECT * 
  
  FROM IOT AS in0
  
  WHERE LOADED_AT > (
          SELECT MAX(LOADED_AT)
          
          FROM IOT
         )

)

SELECT *

FROM incremental_filter
