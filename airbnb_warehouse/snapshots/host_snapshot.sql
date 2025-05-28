{% snapshot snap_host %}

{{
    config(
        target_schema = "snapshots",
        unique_key = "host_id",
        strategy = "timestamp",
        updated_at = "scraped_date"
    )
}}

select * from {{ref("int_airbnb_hosts")}}

{% endsnapshot %}
