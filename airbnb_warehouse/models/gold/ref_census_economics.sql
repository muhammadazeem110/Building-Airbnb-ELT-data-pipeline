{{ 
    config(indexes=[
        {"columns": ["lga_sk"], "unique": True}
    ]) 
}}

SELECT
    dim_lga.lga_sk,
    census_g02.*
FROM {{ ref("int_census_g02") }} as census_g02 
JOIN {{ ref("dim_lga") }} as dim_lga
    ON census_g02.lga_code = dim_lga.lga_code
