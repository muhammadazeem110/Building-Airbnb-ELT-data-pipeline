{{
    config(
        indexes = [
            {"columns":["lga_sk"], "unique": True}
        ]
    )
}}


SELECT
    {{dbt_utils.generate_surrogate_key(["lga_code", "dbt_valid_from"])}} as lga_sk,
    lga_code,
    lga_name,
    dbt_updated_at as updated_at,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to,
    CASE
        WHEN dbt_valid_from IS NULL THEN TRUE ELSE FALSE
    END AS is_current
FROM {{ref("snap_lga")}}