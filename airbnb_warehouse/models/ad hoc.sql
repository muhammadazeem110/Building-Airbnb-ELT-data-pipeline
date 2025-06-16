-- PART 4:

-- a. What are the demographic differences (e.g., age group distribution, household size)
-- between the top 3 performing and lowest 3 performing LGAs based on estimated
-- revenue per active listing over the last 12 months?

WITH revenue_active AS (
    SELECT
        lga_code,
        DATE_TRUNC('month', scraped_date) AS month,
        ROUND(SUM(estimated_revenue), 2) AS estimated_revenue,
        SUM(active_listing) AS total_active_listing
    FROM analytics_gold.fact_airbnb_listing fal
    JOIN analytics_gold.dim_lga dl
        ON fal.lga_sk = dl.lga_sk
    GROUP BY lga_code, DATE_TRUNC('month', scraped_date)
),
revenue AS (
    SELECT 
        lga_code, 
        ROUND(SUM(estimated_revenue) / NULLIF(SUM(total_active_listing), 0), 2) AS revenue_per_active_listing
    FROM revenue_active
    GROUP BY lga_code
),
top_3_revenue AS (
    SELECT
        r.lga_code,
        r.revenue_per_active_listing,
        d.Tot_P_P AS total_population,
        d.Age_0_4_yr_P AS age_0_4,
        d.Age_5_14_yr_P AS age_5_14,
        d.Age_15_19_yr_P AS age_15_19,
        d.Age_20_24_yr_P AS age_20_24,
        d.Age_25_34_yr_P AS age_25_34,
        d.Age_35_44_yr_P AS age_35_44,
        d.Age_45_54_yr_P AS age_45_54,
        d.Age_55_64_yr_P AS age_55_64,
        d.Age_65_74_yr_P AS age_65_74,
        d.Age_75_84_yr_P AS age_75_84,
        d.Age_85ov_P AS age_85_plus
    FROM revenue r
    JOIN analytics_gold.ref_census_demographics d
        ON r.lga_code = d.lga_code
    ORDER BY r.revenue_per_active_listing DESC
    LIMIT 3
),
bottom_3_revenue AS (
    SELECT
        r.lga_code,
        r.revenue_per_active_listing,
        d.Tot_P_P AS total_population,
        d.Age_0_4_yr_P AS age_0_4,
        d.Age_5_14_yr_P AS age_5_14,
        d.Age_15_19_yr_P AS age_15_19,
        d.Age_20_24_yr_P AS age_20_24,
        d.Age_25_34_yr_P AS age_25_34,
        d.Age_35_44_yr_P AS age_35_44,
        d.Age_45_54_yr_P AS age_45_54,
        d.Age_55_64_yr_P AS age_55_64,
        d.Age_65_74_yr_P AS age_65_74,
        d.Age_75_84_yr_P AS age_75_84,
        d.Age_85ov_P AS age_85_plus
    FROM revenue r
    JOIN analytics_gold.ref_census_demographics d
        ON r.lga_code = d.lga_code
    ORDER BY r.revenue_per_active_listing ASC
    LIMIT 3
)
-- SELECT * FROM top_3_revenue
-- UNION ALL
-- SELECT * FROM bottom_3_revenue;
SELECT
    ROUND(
        (
            AVG(top.revenue_per_active_listing) - AVG(bottom.revenue_per_active_listing)
        ) / NULLIF(AVG(top.revenue_per_active_listing) + AVG(bottom.revenue_per_active_listing), 0) * 100,
        2
    ) AS diff_revenue_percentage
FROM top_3_revenue AS top, bottom_3_revenue AS bottom;
-- Output : So Top 3 lga's revenue is 70% more than the revenue of bottom 3 lga's




-- b. Is there a correlation between the median age of a neighbourhood (from Census
-- data) and the revenue generated per active listing in that neighbourhood?

-- revenue generated per active listing in that neighbourhood
WITH revenue as (select
	lga_sk,
	listing_neighbourhood,
	sum(estimated_revenue) / sum(active_listing) as revenue_per_lga
from analytics_gold.fact_airbnb_listing fal
join analytics_gold.dim_listing dl
	on fal.listing_sk = dl.listing_sk
group by listing_neighbourhood, lga_sk),
-- median age of a neighbourhood
demographics as (select
			lga_code,
			Tot_P_P as total_population,
			-- Age groups with estimated midpoints
	        Age_0_4_yr_P * 2.5 +
	        Age_5_14_yr_P * 10 +
	        Age_15_19_yr_P * 17 +
	        Age_20_24_yr_P * 22 +
	        Age_25_34_yr_P * 29.5 +
	        Age_35_44_yr_P * 39.5 +
	        Age_45_54_yr_P * 49.5 +
	        Age_55_64_yr_P * 59.5 +
	        Age_65_74_yr_P * 69.5 +
	        Age_75_84_yr_P * 79.5 +
	        Age_85ov_P * 90 AS weighted_age_sum
from analytics_gold.ref_census_demographics),
age_distribution as(
	-- Estimated Median Age ≈ SUM(People × Midpoint) / Total Population
    SELECT
        lga_code,
        ROUND(weighted_age_sum / NULLIF(total_population, 0), 1) AS estimated_median_age
    FROM demographics
),

revenue_age_data as (select lga_name, dl.lga_code, revenue_per_lga, estimated_median_age
from revenue
join analytics_gold.dim_lga dl
	on revenue.lga_sk = dl.lga_sk
join age_distribution ad
	on ad.lga_code = dl.lga_code)
	
-- formula to find the correlation_coefficient
select
	round((
	count(*) * sum(revenue_per_lga * estimated_median_age) - sum(revenue_per_lga) * sum(estimated_median_age)
	) / (
	sqrt(count(*) * sum(revenue_per_lga * revenue_per_lga) - power(sum(revenue_per_lga), 2)) * 
	sqrt(count(*) * sum(estimated_median_age * estimated_median_age) - power(sum(estimated_median_age), 2))
	), 2) as correlation_coefficient
from revenue_age_data
-- Output : so the correlation is 0.67 which means strong.




-- c. What will be the best type of listing (property type, room type and accommodates for)
-- for the top 5 “listing_neighbourhood” (in terms of estimated revenue per active listing)
-- to have the highest number of stays?
-- top 5 neighbourhoods by revenue per listing
with revenue_listing as (
	select
			listing_neighbourhood,
			round(sum(estimated_revenue) / sum(active_listing), 2) as revenue_per_listing
	from analytics_gold.fact_airbnb_listing fal
	join analytics_gold.dim_listing dl
		on fal.listing_sk = dl.listing_sk and fal.scraped_date = dl.scraped_date
	group by listing_neighbourhood
),
top_5_neighbourhood as(
	select *
	from revenue_listing
	order by revenue_per_listing desc
	limit 5
),
-- For those neighbourhoods, find combinations with highest number of stays
listing_stats as (
	select 
			dl.listing_neighbourhood, 
			property_type, 
			room_type, 
			accommodates , 
			sum(number_of_stays) as no_of_stay
	from analytics_gold.fact_airbnb_listing fal
	join analytics_gold.dim_listing dl
		on fal.listing_sk = dl.listing_sk and fal.scraped_date = dl.scraped_date
	where dl.listing_neighbourhood in (select listing_neighbourhood from top_5_neighbourhood)
	group by dl.listing_neighbourhood, property_type, room_type, accommodates
	order by dl.listing_neighbourhood, no_of_stay
),
ranking_listing as (
	select
			*,
			rank() over(partition by listing_neighbourhood order by no_of_stay desc) as rnk
	from listing_stats
)
select
		ranking_listing.listing_neighbourhood, property_type, room_type, accommodates, no_of_stay, revenue_per_listing
from ranking_listing
join revenue_listing 
	on ranking_listing.listing_neighbourhood = revenue_listing.listing_neighbourhood
where rnk = 1;




-- d. For hosts with multiple listings, are their properties concentrated within the same
-- LGA, or are they distributed across different LGAs?
with host as (select 
	host_id,
	listing_neighbourhood,
	count(listing_neighbourhood) as cnt_lga
from analytics_gold.dim_listing
group by host_id, listing_neighbourhood
order by host_id
)
select 
		host_id,
		count(*) as count_lga,
		case when count(*) = 1 then 'Concentrated in one LGA' else 'Distributed across multiple LGAs'
		end as lga_distribution
from host
group by host_id;




-- e. For hosts with a single Airbnb listing, does the estimated revenue over the last 12
-- months cover the annualised median mortgage repayment in the corresponding
-- LGA? Which LGA has the highest percentage of hosts that can cover it?
with cnt_listing_per_host as (
	select
			host_id,
			count(distinct listing_neighbourhood) as cnt_listings
	from analytics_gold.dim_listing dl
	group by host_id
	order by host_id
),
single_listing_host as (
	select *
	from cnt_listing_per_host
where cnt_listings = 1
),
host as (
	select
		dh.host_sk,
		slh.host_id
	from analytics_gold.dim_host dh
	join single_listing_host slh
		on dh.host_id = slh.host_id
	order by slh.host_id
),
host_per_lga as(
	select distinct
					host.host_sk,
					host.host_id,
					listing_neighbourhood
	from analytics_gold.dim_listing dl
	join host
		on dl.host_id = host.host_id
	order by host.host_id
),
revenue_per_lga as (
	select hpl.host_id, hpl.listing_neighbourhood, sum(estimated_revenue) as tot_revenue
	from analytics_gold.fact_airbnb_listing fal
	join host_per_lga hpl
		on fal.host_sk = hpl.host_sk
	group by hpl.host_id, hpl.listing_neighbourhood
	order by hpl.host_id
),
host_lga_code as (
	select host_id, lga_code, lga_name, tot_revenue 
	from analytics_gold.dim_lga dl
	join revenue_per_lga rpl
		on dl.lga_name = rpl.listing_neighbourhood
),
host_with_mortgage as (
	select 
		host_id, 
		hlc.lga_code, 
		lga_name, 
		tot_revenue, 
		(median_mortgage_repay_monthly * 12) as median_mortgage,
		case when tot_revenue >= (median_mortgage_repay_monthly * 12) then 1 else 0 end as revenue_mortgage_coverage
	from host_lga_code hlc
	join analytics_gold.ref_census_economics rce
		on hlc.lga_code = rce.lga_code
	order by host_id asc
)
select
	lga_name, 
	count(host_id) as cnt_hosts, 
	round(100.0 * sum(revenue_mortgage_coverage) / count(*), 2) as percent_convering
from host_with_mortgage
group by lga_name
order by cnt_hosts desc
limit 1;
-- so the highest percent of host conver by "Sydney" with hosts = 6395	and percent_convering = 48.96