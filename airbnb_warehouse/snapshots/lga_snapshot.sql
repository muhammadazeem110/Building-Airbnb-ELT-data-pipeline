{% snapshot snap_lga %}

{{
    config(
        target_schema = "snapshots",
        unique_key = "lga_code",
        strategy = "check",
        check_cols = ["lga_name"]
    )
}}

SELECT * FROM {{ref("int_lga_lookup")}}

{% endsnapshot %}
