/*
1. First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter
for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.
*/
SELECT
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
;

###################################################################################################################

/*
2. Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we
launched, for session to order conversion rate, revenue per order, and revenue per session.
*/
SELECT
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr,
    #COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    #COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt,
    #SUM(price_usd) AS revenue,
    SUM(price_usd) / COUNT(DISTINCT orders.order_id) AS revenue_per_order,
    SUM(price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
;

###################################################################################################################

/*
3. I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch
nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type in?
*/
SELECT
	utm_campaign,
    utm_source,
    http_referer
FROM website_sessions
GROUP BY 1,2,3
;

SELECT
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
	COUNT(DISTINCT CASE WHEN website_sessions.http_referer IS NOT NULL AND website_sessions.utm_campaign IS NULL THEN orders.order_id ELSE NULL END) AS organic_orders,
    COUNT(DISTINCT CASE WHEN website_sessions.http_referer IS NULL AND website_sessions.utm_campaign IS NULL THEN orders.order_id ELSE NULL END) AS direct_type_in_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
;

###################################################################################################################

/*
4. Next, let’s show the overall session to order conversion rate trends for those same channels, by quarter.
Please also make a note of any periods where we made major improvements or optimizations.
*/
SELECT
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rt,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rt,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_conv_rt,
	COUNT(DISTINCT CASE WHEN website_sessions.http_referer IS NOT NULL AND website_sessions.utm_campaign IS NULL THEN orders.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN website_sessions.http_referer IS NOT NULL AND website_sessions.utm_campaign IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_conv_rt,
    COUNT(DISTINCT CASE WHEN website_sessions.http_referer IS NULL AND website_sessions.utm_campaign IS NULL THEN orders.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN website_sessions.http_referer IS NULL AND website_sessions.utm_campaign IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
;

###################################################################################################################

/*
5. We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue
and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
*/
SELECT
	YEAR(created_at) AS yr,
	MONTH(created_at) AS mo,
    SUM(CASE WHEN primary_product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN primary_product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN primary_product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN primary_product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN primary_product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN primary_product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN primary_product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN primary_product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM orders
GROUP BY 1,2
;

###################################################################################################################

/*
6. Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products
page, and show how the % of those sessions clicking through another page has changed over time, along with
a view of how conversion from /products to placing an order has improved.
*/