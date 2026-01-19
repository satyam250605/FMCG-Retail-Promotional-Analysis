CREATE DATABASE IF NOT EXISTS atliq_campaign_analysis;
USE atliq_campaign_analysis;

						-- Ad-Hoq Requests --

-- 1. Provide a list of products with a base price greater than 500 and that 
-- are featured in promo type of "BOGOF" (Buy one get one free)

SELECT 
	p.product_code, 
    p.product_name, 
	f.base_price
FROM dim_products p
JOIN fact_events f 
	ON p.product_code = f.product_code
WHERE f.promo_type = "BOGOF" AND base_price>500; 

-- 2. Generate a report that provides an overview of the number of stores in each city

SELECT 
	city, 
    COUNT(store_id) AS store_count
FROM dim_stores
GROUP BY city
ORDER BY store_count DESC;

-- 3. Generate a report that displays each campaign along with the total_revenue generated
-- before and after the campaign 

SELECT 
	c.campaign_name,
	CONCAT(ROUND(SUM(rr.revenue_before_campaign)/1000000,0),"M") AS before_revenue_campaign,
	CONCAT(ROUND(SUM(rr.revenue_after_campaign)/1000000,0),"M") AS after_revenue_campaign
FROM revenue_view rr
JOIN dim_campaigns c 
	ON c.campaign_id = rr.campaign_id
GROUP BY c.campaign_name;

-- 4. Produce a report that calculates the Incremental Sold Quantity (ISU%) 
-- for each category during the Diwali campaign.
-- Additionally, provide rankings for the categories based on their ISU%. 

WITH cte1 AS (
	SELECT 
		p.category,
        SUM(iq.quantity_sold_before_promo) AS Total_before,
        SUM(iq.quantity_sold_after_promo) AS Total_after
	FROM incremental_qty_table iq 
    JOIN dim_products p 
		USING(product_code)
	JOIN dim_campaigns c 
		USING(campaign_id)
	WHERE c.campaign_name = "Diwali"
	GROUP BY p.category
)

SELECT 
	category,
    Total_before,
    Total_after,
	ROUND(((Total_after - Total_before)/Total_before)*100,1) AS ISU,
    RANK() OVER(ORDER BY ((Total_after - Total_before)/Total_before)*100 DESC) AS rnk
FROM cte1;

-- Note:- ISU(Incremental Sold Unit Percentage) is the metric which shows the percentage change or 
-- growth (whether its negative or positive).

-- 5. Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), 
-- across all campaigns. 

WITH cte1 AS (
	SELECT 
		p.product_name, 
        p.category,
        SUM(rr.revenue_before_campaign) AS revenue_BP,
        SUM(rr.revenue_after_campaign) AS revenue_AP
	FROM revenue_view rr 
    JOIN dim_products p 
		USING(product_code)
	GROUP BY p.product_name, p.category
    
)

SELECT * 
FROM (
		SELECT 
			product_name,
			category,
			ROUND(((revenue_AP - revenue_BP)/revenue_BP)*100,1) AS IR_pct,
			RANK() OVER(ORDER BY ((revenue_AP - revenue_BP)/revenue_BP)*100 DESC) AS IR_rank
		FROM cte1
        ) t
WHERE IR_rank<=5;

			-- ## Store Performance Analysis ##
-- 1. Which are the top 10 stores in terms of Incremental Revenue (IR) generated from the promotions?

SELECT 
	store_id,
	(SUM(revenue_after_campaign) - SUM(revenue_before_campaign)) AS Incremental_revenue 
FROM revenue_view
GROUP BY store_id
ORDER BY Incremental_revenue DESC
LIMIT 10;

-- 2. Which are the bottom 10 stores when it comes to Incremental Sold Units (ISU) 
-- during the promotional period?

SELECT 
	store_id,
    SUM(incremental_qty) AS Incremental_quantity
FROM incremental_qty_table
GROUP BY store_id
ORDER BY Incremental_quantity ASC
LIMIT 10;

-- 3. How does the performance of stores vary by city? Are there any common characteristics 
-- among the top-performing stores that could be leveraged across other stores?

SELECT *, 
	(incremental_revenue_mln/store_cnt) AS revenue_per_store
FROM (
SELECT 
	st.city,
    COUNT(s.store_id) AS store_cnt,
    ROUND(SUM(s.revenue_before_campaign)/1000000,1) AS revenue_before_mln,
	ROUND(SUM(s.revenue_after_campaign)/1000000,1) AS revenue_after_mln,
    ROUND((SUM(s.revenue_after_campaign) - SUM(s.revenue_before_campaign))/1000000,1) AS incremental_revenue_mln
FROM summary s
JOIN dim_stores st 
	ON st.store_id = s.store_id
GROUP BY st.city 
ORDER BY incremental_revenue_mln DESC) t;

				-- ## Store Performance Analysis ##

-- What are the top 2 promotion types that resulted in the highest Incremental Revenue?

SELECT 
	promo_type,
    ROUND(SUM(revenue_before_campaign)/1000000,1) AS revenue_before_mln,
    ROUND(SUM(revenue_after_campaign)/1000000,1) AS revenue_after_mln,
    ROUND((SUM(revenue_after_campaign) - SUM(revenue_before_campaign))/1000000,1) AS incremental_revenue
FROM summary
GROUP BY promo_type
ORDER BY incremental_revenue DESC
LIMIT 2 ;

-- What are the bottom 2 promotion types in terms of their impact on Incremental Sold Units?

SELECT 
	promo_type,
    SUM(quantity_sold_before_promo) AS quantity_before,
    SUM(quantity_sold_after_promo) AS quantity_after,
    SUM(incremental_qty) AS incremental_qty_total
FROM summary
GROUP BY promo_type
ORDER BY incremental_qty_total ASC
LIMIT 2;

-- Is there a significant difference in the performance of discount-based promotions versus 
-- BOGOF (Buy One Get One Free) or cashback promotions?
-- Which promotions strike the best balance between Incremental Sold Units and maintaining healthy margins?
-- THIS ANSWERS BOTH

SELECT 
	promo_group,
    SUM(quantity_sold_before_promo) AS quantity_before,
    SUM(quantity_sold_after_promo) AS quantity_after,
    ROUND(SUM(revenue_before_campaign)/1000000,1) AS revenue_before_mln,
    ROUND(SUM(revenue_after_campaign)/1000000,1) AS revenue_after_mln,
    ROUND((SUM(revenue_after_campaign) - SUM(revenue_before_campaign))/1000000,1) AS incremental_revenue_mln,
	SUM(incremental_qty) AS incremental_qty_total
FROM promo_analysis
GROUP BY promo_group
ORDER BY incremental_qty_total, incremental_revenue_mln DESC;

				-- ## Product and Category Analysis ##
                
-- Which product categories saw the most significant lift in sales from the promotions?

SELECT 
	category,
    avg_base_price,
    ROUND(revenue_before/1000000,1) AS revenue_before_mln,
    ROUND(revenue_after/1000000,1) AS revenue_after_mln,
    ROUND((revenue_after - revenue_before)/1000000,1) AS incremental_revenue_mln,
    incremental_qty
FROM (
	SELECT 
		p.category,
        ROUND(AVG(base_price),1) AS avg_base_price,
		SUM(s.revenue_before_campaign) AS revenue_before,
		SUM(s.revenue_after_campaign) AS revenue_after,
        SUM(incremental_qty) AS incremental_qty
	FROM summary s 
	JOIN dim_products p 
		USING(product_code)
	GROUP BY p.category
) t
ORDER BY incremental_revenue_mln DESC;


-- This shows that the category 'Combo 1' is value driven category as it has higher revenue 
-- with the low volume which means that the avg base price is higher for that category
-- and the category 'Grocery & Staples' is volume-driven category as it has low revenue
-- but high volume

-- Are there specific products that respond exceptionally well or poorly to promotions?

SELECT 
	p.product_name,
    p.category,
	SUM(s.quantity_sold_before_promo) AS qty_sold_before,
	SUM(s.quantity_sold_after_promo) AS qty_sold_after,
	SUM(s.incremental_qty) AS ISU,
    ROUND((SUM(revenue_after_campaign)-SUM(revenue_before_campaign))/1000000,1) AS Incremental_revenue
FROM summary s
JOIN dim_products p 
	USING(product_code)
GROUP BY p.product_name, p.category
ORDER BY Incremental_revenue DESC;

-- What is the correlation between product category and promotion type effectiveness? 

SELECT 
    p.category,
    s.promo_type,
	SUM(s.quantity_sold_before_promo) AS qty_sold_before,
	SUM(s.quantity_sold_after_promo) AS qty_sold_after,
	SUM(s.incremental_qty) AS ISU,
    ROUND((SUM(revenue_after_campaign)-SUM(revenue_before_campaign))/1000000,1) AS Incremental_revenue
FROM summary s
JOIN dim_products p 
	USING(product_code)
GROUP BY p.category, s.promo_type
ORDER BY Incremental_revenue DESC;

