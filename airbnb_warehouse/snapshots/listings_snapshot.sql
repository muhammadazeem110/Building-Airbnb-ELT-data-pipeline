{% snapshot snap_listings %}

{{ config(
    target_schema='snapshots',
    unique_key='listing_id',
    strategy='timestamp',
    updated_at='scraped_date'
) }}

select * from {{ ref("int_airbnb_listings") }}

{% endsnapshot %}