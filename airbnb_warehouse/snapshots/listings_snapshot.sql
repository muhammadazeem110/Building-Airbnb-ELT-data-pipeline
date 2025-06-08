{% snapshot snap_listings %}

{{
    config(
        target_schema='snapshots',
        unique_key='surrogate_key',
        strategy='check',
        check_cols='all'
    )
}}

with base as (
    select
        {{ dbt_utils.generate_surrogate_key(["listing_id", "scraped_date"]) }} as surrogate_key,
        *
    from {{ ref("int_airbnb_listings") }}
)

select *
from base

{% endsnapshot %}
