{% snapshot snap_suburb %}

{{
    config(
        target_schema = "snapshots",
        unique_key = "surrogate_key",
        strategy= "check",
        check_cols = ["suburb_name"]
    )
}}

SELECT
    {{dbt_utils.generate_surrogate_key(["lga_name", "suburb_name"])}} as surrogate_key, 
    *
FROM {{ref("int_suburb_lga_map")}}

{% endsnapshot %}