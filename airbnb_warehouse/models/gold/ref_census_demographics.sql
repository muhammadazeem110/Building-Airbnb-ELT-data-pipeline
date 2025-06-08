{{ 
    config(indexes=[
        {"columns": ["lga_sk"]}
    ]) 
}}

SELECT 
    dim_lga.lga_sk,
    census_g01.*
FROM {{ ref("int_census_g01") }} AS census_g01
JOIN {{ ref("dim_lga") }} AS dim_lga
    ON census_g01.lga_code = dim_lga.lga_code
