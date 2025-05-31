{% snapshot snap_hosts %}

{{
    config(
        target_schema = "snapshots",
        unique_key = "host_id",
        strategy = "check",
        check_cols = "all"
    )
}}

select * from {{ref("int_airbnb_hosts")}}

{% endsnapshot %}