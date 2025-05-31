{{
    config(
        indexes=[
            {"columns": ["suburb_sk"]}
        ]
    )
}}

SELECT
    {{dbt_utils.generate_surrogate_key(["lga_name", "suburb_name", "dbt_valid_from"])}} as suburb_sk,
    lga_name,
    suburb_name,
    dbt_updated_at as updated_at,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to,
    CASE
        WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE
    END AS is_current
FROM {{ref("snap_suburb")}}