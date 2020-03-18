#1. PRODUCT LEVEL SALES ANALYSIS

SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
	COUNT(DISTINCT order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd-cogs_usd) AS total_margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY 1,2
;

###################################################################################################################

#2. PRODUCT LAUNCH SALES ANALYSIS
SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    #website_sessions.website_session_id,
    COUNT(DISTINCT orders.order_id) AS orders,
    #COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    #SUM(orders.price_usd) AS revenue,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE WHEN orders.primary_product_id = 1 THEN website_sessions.website_session_id ELSE NULL END) AS product_one_orders,
    COUNT(DISTINCT CASE WHEN orders.primary_product_id = 2 THEN website_sessions.website_session_id ELSE NULL END) AS product_two_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-04-01' AND '2013-04-05'
GROUP BY 1,2
;

###################################################################################################################

#3. PRODUCT PATHING ANALYSIS
#STEP 1: finding the /products pageviews
CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at,
    CASE
		WHEN created_at < '2013-01-06' THEN 'A. Pre_Product_2'
        WHEN created_at >= '2013-01-06' THEN 'B. Post_Product_2'
        ELSE 'uh oh...check logic'
	END AS time_period
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'
	AND pageview_url = '/products'
;

#STEP 2: find next pageview id that occurs after product pageview
CREATE TEMPORARY TABLE sessions_w_next_pageview_id
SELECT
	products_pageviews.time_period,
    products_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
FROM products_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = products_pageviews.website_session_id
			AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
GROUP BY 1,2
;

#STEP 3: find pageview_url associated with any applicable next pageview id
CREATE TEMPORARY TABLE sessions_w_next_pageview_url
SELECT
    sessions_w_next_pageview_id.time_period,
    sessions_w_next_pageview_id.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url
FROM sessions_w_next_pageview_id
	LEFT JOIN website_pageviews
		ON sessions_w_next_pageview_id.min_next_pageview_id = website_pageviews.website_pageview_id
;

#STEP 4: summarize the data and analyze pre and post periods