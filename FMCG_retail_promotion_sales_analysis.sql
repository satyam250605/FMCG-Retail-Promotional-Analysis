-- 1. Provide a list of products with a base price greater than 500 and that 
-- are featured in promo type of "BOGOF" (Buy one get one free)

SELECT 
	DISTINCT p.product_name
FROM 
	dim_products p 
JOIN 
	fact_events f ON p.product_code = f.product_code
WHERE 
	f.base_price>500 AND f.promo_type = "BOGOF"; 

-- 2. Generate a report that provides an overview of the number of stores in each city

SELECT 	
	city,
    COUNT(store_id) AS store_count
FROM 
	dim_stores 
GROUP BY 
	city
ORDER BY 
	store_count DESC;

-- 3. Generate a report that displays each campaign along with the total_revenue generated
-- before and after the campaign 

SELECT 
	campaign_name,
    before_campaign_revenue,
    after_campaign_revenue,
    ROUND((after_campaign_revenue - before_campaign_revenue)*100/before_campaign_revenue,1) AS pct_growth
FROM (
	SELECT 
		c.campaign_name,
		CONCAT(ROUND(SUM(pa.revenue_before_campaign)/1000000,1),"M") AS before_campaign_revenue,
		CONCAT(ROUND(SUM(pa.revenue_after_campaign)/1000000,1),"M") AS after_campaign_revenue
	FROM 
		dim_campaigns c 
	JOIN 
		promo_analysis pa ON pa.campaign_id = c.campaign_id 
	GROUP BY 
		c.campaign_name
) t ;

-- 4. Produce a report that calculates the Incremental Sold Quantity (ISU%) 
-- for each category during the Diwali campaign.
-- Additionally, provide rankings for the categories based on their ISU%

WITH category_ISU AS (
	SELECT 
		p.category, 
        SUM(pa.incremental_qty)/SUM(quantity_sold_before_promo)*100 AS ISU_percent
	FROM 
		dim_products p 
    JOIN 
		promo_analysis pa ON pa.product_code = p.product_code
	WHERE 
		pa.campaign_id = 'CAMP_DIW_01'
	GROUP BY 
		p.category
)

SELECT 
	category,
    ISU_percent,
    DENSE_RANK() OVER(ORDER BY ISU_percent DESC) AS ISU_Rank
FROM category_ISU ;


-- 5. Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), 
-- across all campaigns. 

SELECT 
	p.product_name,
    ROUND(SUM(incremental_revenue)/SUM(revenue_before_campaign)*100,1) AS IR_pct,
    RANK() OVER(ORDER BY ROUND(SUM(incremental_revenue)/SUM(revenue_before_campaign),1) DESC) AS rnk
FROM 
	dim_products p 
JOIN 
	promo_analysis pa ON pa.product_code = p.product_code
GROUP BY 
	p.product_name
ORDER BY 
	IR_pct DESC
LIMIT 5;

					-- Store Level Performance Insights --

-- 1. Which are the top 10 stores in terms of Incremental Revenue (IR) generated from the promotions?

SELECT 
	DISTINCT store_id,
    ROUND(SUM(incremental_revenue)/1000000,1) AS Total_IR
FROM 
	promo_analysis
GROUP BY 
	store_id
ORDER BY 
	Total_IR DESC
LIMIT 10;
	
-- 2. Which are the bottom 10 stores when it comes to Incremental Sold Units (ISU) 
-- during the promotional period?

SELECT 
	DISTINCT store_id,
    SUM(incremental_qty) AS Total_ISU
FROM 
	promo_analysis
GROUP BY 
	store_id
ORDER BY 
	Total_ISU ASC
LIMIT 10;

-- 3. How does the performance of stores vary by city? Are there any common characteristics 
-- among the top-performing stores that could be leveraged across other stores?

SELECT 
	city,
    (Total_IR/Store_count) AS IR_per_store,
    (Total_ISU/Store_count) AS ISU_per_store
FROM 
(
	SELECT 
		ds.city,
		COUNT(DISTINCT ds.store_id) AS Store_count,
		ROUND(SUM(incremental_revenue)/1000000,1) AS Total_IR,
		SUM(incremental_qty) AS Total_ISU
	FROM 
		promo_analysis pa 
	JOIN 
		dim_stores ds ON ds.store_id = pa.store_id 
	GROUP BY 
		ds.city
) t;
				-- Promotional Type Analysis -- 

-- 1. What are the top 2 promotion types that resulted in the highest Incremental Revenue?
	
SELECT 
	promo_type,
	ROUND(SUM(incremental_revenue)/1000000,1) AS Total_IR
FROM 
	promo_analysis 
GROUP BY 
	promo_type
ORDER BY 
	Total_IR DESC
LIMIT 2;

-- 2. What are the bottom 2 promotion types in terms of their impact on Incremental Sold Units?

SELECT 
	promo_type,
	SUM(incremental_qty) AS Total_ISU
FROM 
	promo_analysis 
GROUP BY 
	promo_type
ORDER BY 
	Total_ISU ASC
LIMIT 2;

-- 3.Is there a significant difference in the performance of discount-based promotions versus 
-- BOGOF (Buy One Get One Free) or cashback promotions?
-- Which promotions strike the best balance between Incremental Sold Units and maintaining healthy margins?
-- THIS ANSWERS BOTH

SELECT 
	promo_group,
    SUM(incremental_qty) AS Total_ISU,
    ROUND(SUM(incremental_revenue)/1000000,1) AS Total_IR
FROM 
	promo_analysis
GROUP BY 
	promo_group; 

					-- Product & Category Analysis -- 

-- 1. Which product categories saw the most significant lift in sales from the promotions?

SELECT 
	category,
    Before_campaign_revenue,
    after_campaign_revenue,
    ROUND((after_campaign_revenue - before_campaign_revenue)*100/before_campaign_revenue,1) AS pct_change
FROM 
(
	SELECT 
		p.category,
		ROUND(SUM(revenue_before_campaign)/1000000,1) AS Before_campaign_revenue,
		ROUND(SUM(revenue_after_campaign)/1000000,1) AS after_campaign_revenue
	FROM 
		promo_analysis pa 
	JOIN 
		dim_products p ON p.product_code = pa.product_code
	GROUP BY 
		p.category
) t ;

-- 2. Are there specific products that respond exceptionally well or poorly to promotions?

SELECT 
	p.product_name,
    ROUND(SUM(pa.revenue_before_campaign)/1000000,2) AS Before_campaign_revenue,
	ROUND(SUM(pa.revenue_after_campaign)/1000000,2) AS after_campaign_revenue
FROM 
	dim_products p 
JOIN 
	promo_analysis pa ON pa.product_code = p.product_code
GROUP BY 
	p.product_name
ORDER BY after_campaign_revenue DESC;

-- 3. What is the correlation between product category and promotion type effectiveness? 

SELECT 
	pa.promo_type,
    p.category,
    SUM(pa.incremental_qty) AS Total_ISU,
    ROUND(SUM(pa.incremental_revenue)/1000000,2) AS Total_IR
FROM 
	promo_analysis pa 
JOIN 
	dim_products p ON p.product_code = pa.product_code
GROUP BY 
	pa.promo_type, p.category
ORDER BY 
	pa.promo_type;