{% snapshot snap_hosts %}

{{
    config(
        target_schema = "snapshots",
        unique_key = "host_id",
        strategy = "check",
        check_cols = ['host_name', 'host_neighbourhood', 'host_since', 'host_is_superhost']
    )
}}

select * from {{ref("int_airbnb_hosts")}}

{% endsnapshot %}