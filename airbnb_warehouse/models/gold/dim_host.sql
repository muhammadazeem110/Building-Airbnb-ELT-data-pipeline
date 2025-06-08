{{ config(
    indexes=[
      {'columns': ['host_sk']}
    ]
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(["dbt_scd_id", "dbt_valid_from"]) }} AS host_sk,
    host_id,
    host_name,
    host_neighbourhood,
    host_since,
    host_is_superhost,
    dbt_updated_at AS updated_at,
    dbt_valid_from AS valid_from,
    dbt_valid_to AS valid_to,
    CASE
        WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE
    END AS is_current
FROM {{ ref("snap_hosts") }}