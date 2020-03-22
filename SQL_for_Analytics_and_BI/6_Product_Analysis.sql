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
SELECT
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url  IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url  IS NOT NULL THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT website_session_id) AS pct_w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mr_fuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT website_session_id) AS pct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) /
    COUNT(DISTINCT website_session_id) AS pct_to_lovebear
FROM sessions_w_next_pageview_url
GROUP BY time_period
;

###################################################################################################################

#4. PRODUCT CONVERISON FUNNELS
#STEP 1: select all pageviews for relevant sessions
CREATE TEMPORARY TABLE sessions_seeing_product_pages
SELECT
	website_session_id,
    website_pageview_id,
	pageview_url AS product_page_seen
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
	AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
;

#STEP 2: figure out which pageview urls to look for
SELECT DISTINCT
	website_pageviews.pageview_url
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON sessions_seeing_product_pages.website_session_id = website_pageviews.website_session_id
			AND sessions_seeing_product_pages.website_pageview_id < website_pageviews.website_pageview_id
;

#STEP 3: pull all pageviews and identify the funnel steps
SELECT
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON sessions_seeing_product_pages.website_session_id = website_pageviews.website_session_id
			AND sessions_seeing_product_pages.website_pageview_id < website_pageviews.website_pageview_id
ORDER BY
	sessions_seeing_product_pages.website_session_id,
	website_pageviews.created_at
;

#STEP 4: create session level conversion funnel view
CREATE TEMPORARY TABLE session_product_level_made_it_flags
SELECT
	website_session_id,
    CASE
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
		WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
		ELSE 'uh oh...check logic'
	END AS product_seen,
    SUM(cart_page) AS to_cart,
    SUM(shipping_page) AS to_shipping,
    SUM(billing_page) AS to_billing,
    SUM(thankyou_page) AS to_thankyou
FROM (
SELECT
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON sessions_seeing_product_pages.website_session_id = website_pageviews.website_session_id
			AND sessions_seeing_product_pages.website_pageview_id < website_pageviews.website_pageview_id
ORDER BY
	sessions_seeing_product_pages.website_session_id,
	website_pageviews.created_at
) AS funnel_steps
GROUP BY
	website_session_id,
    CASE
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
		WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
		ELSE 'uh oh...check logic'
	END
;

#STEP 5: aggregate data to assess funnel performance
SELECT
	product_seen,
    COUNT(website_session_id) AS sessions,
    SUM(to_cart) AS to_cart,
    SUM(to_shipping) AS to_shipping,
    SUM(to_billing) AS to_billing,
    SUM(to_thankyou) AS to_thankyou
FROM session_product_level_made_it_flags
GROUP BY 1
;

SELECT
	product_seen,
    SUM(to_cart) /COUNT(website_session_id) AS product_page_click_rt,
    SUM(to_shipping) / SUM(to_cart) AS cart_click_rt,
    SUM(to_billing) / SUM(to_shipping) AS shipping_click_rt,
    SUM(to_thankyou) / SUM(to_billing) AS billing_click_rt
FROM session_product_level_made_it_flags
GROUP BY 1
;

###################################################################################################################

#5. CROSS SELL ANALYSIS
#STEP 1: identify the relevant /cart page views and their sessions
CREATE TEMPORARY TABLE sessions_seeing_cart
SELECT
	CASE
		WHEN created_at < '2013-09-25' THEN 'A. Pre_Cross_Sell'
        WHEN created_at >= '2013-09-25' THEN 'B. Post_Cross_Sell'
        ELSE 'uh oh...check logic'
	END AS time_period,
	website_session_id AS cart_session_id,
	website_pageview_id AS cart_pageview_id
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
	AND pageview_url = '/cart'
;

#STEP 2: see which of those /cart sessions clicked through the shipping page
CREATE TEMPORARY TABLE cart_sessions_seeing_another_page
SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    MIN(website_pageviews.website_pageview_id) AS pv_id_after_cart
FROM sessions_seeing_cart
	LEFT JOIN website_pageviews
		ON sessions_seeing_cart.cart_session_id = website_pageviews.website_session_id
			AND sessions_seeing_cart.cart_pageview_id < website_pageviews.website_pageview_id
GROUP BY
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id
HAVING 
	MIN(website_pageviews.website_pageview_id) IS NOT NULL
;

#STEP 3: find the orders associated with /cart sessions; analyze products purchased, AOV; aggregate
CREATE TEMPORARY TABLE pre_post_sessions_orders
SELECT
	time_period,
    cart_session_id,
    order_id,
    items_purchased,
    price_usd
FROM sessions_seeing_cart
	INNER JOIN orders
		ON sessions_seeing_cart.cart_session_id = orders.website_session_id
;

SELECT
	time_period,
    COUNT(DISTINCT cart_session_id) AS cart_sessions,
    SUM(clicked_to_another_page) AS clickthroughs,
    SUM(clicked_to_another_page) / COUNT(DISTINCT cart_session_id) AS cart_ctr,
    SUM(items_purchased) / SUM(placed_order) AS products_per_order,
    SUM(price_usd) / SUM(placed_order) AS aov, #average order value
    SUM(price_usd) / COUNT(DISTINCT cart_session_id) AS rev_per_cart_session
FROM (
SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_sessions_orders.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_sessions_orders.items_purchased,
    pre_post_sessions_orders.price_usd
FROM sessions_seeing_cart
	LEFT JOIN cart_sessions_seeing_another_page
		ON sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
	LEFT JOIN pre_post_sessions_orders
		ON sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
ORDER BY
	cart_session_id
) AS data_list
GROUP BY
	time_period
;

###################################################################################################################

#6. PORTFOLIO EXPANSION ANALYSIS
SELECT
	CASE
		WHEN website_sessions.created_at < '2013-12-12' THEN 'A. Pre_Birthday_Bear'
        WHEN website_sessions.created_at >= '2013-12-12' THEN 'B. Post_Birthday_Bear'
        ELSE 'uh oh...check logic'
	END AS time_period,
    #COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    #COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    #SUM(orders.price_usd) AS total_revenue,
    #SUM(orders.items_purchased) AS total_products_sold,
    SUM(orders.price_usd) / COUNT(DISTINCT orders.order_id) AS aov,
    SUM(orders.items_purchased) / COUNT(DISTINCT orders.order_id) AS products_per_order,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1
;

###################################################################################################################

#7. PRODUCT REFUND RATES
SELECT
	YEAR(order_items.created_at) AS yr,
    MONTH(order_items.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_orders,
    #COUNT(DISTINCT CASE WHEN (order_items.product_id = 1 AND order_item_refunds.order_item_id IS NOT NULL) THEN order_item_refunds.order_id ELSE NULL END) AS p1_refund,
    COUNT(DISTINCT CASE WHEN (order_items.product_id = 1 AND order_item_refunds.order_item_id IS NOT NULL) THEN order_item_refunds.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_refund_rt,
	
    COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_orders,
    #COUNT(DISTINCT CASE WHEN (order_items.product_id = 2 AND order_item_refunds.order_item_id IS NOT NULL) THEN order_item_refunds.order_id ELSE NULL END) AS p2_refund,
    COUNT(DISTINCT CASE WHEN (order_items.product_id = 2 AND order_item_refunds.order_item_id IS NOT NULL) THEN order_item_refunds.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_refund_rt,
	
    COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_orders,
    #COUNT(DISTINCT CASE WHEN (order_items.product_id = 3 AND order_item_refunds.order_item_id IS NOT NULL) THEN order_item_refunds.order_id ELSE NULL END) AS p3_refund,
    COUNT(DISTINCT CASE WHEN (order_items.product_id = 3 AND order_item_refunds.order_item_id IS NOT NULL) THEN order_item_refunds.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_refund_rt,
	
    COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_orders,
    #COUNT(DISTINCT CASE WHEN (order_items.product_id = 4 AND order_item_refunds.order_item_id IS NOT NULL) THEN order_item_refunds.order_id ELSE NULL END) AS p4_refund,
    COUNT(DISTINCT CASE WHEN (order_items.product_id = 4 AND order_item_refunds.order_item_id IS NOT NULL) THEN order_item_refunds.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_refund_rt
FROM order_items
	LEFT JOIN order_item_refunds
		ON order_items.order_item_id = order_item_refunds.order_item_id
WHERE order_items.created_at < '2014-10-15'
GROUP BY 1,2
;

###################################################################################################################

#8. IDENTIFYING REPEAT VISITORS
SELECT
	repeat_sessions,
    COUNT(user_id) AS users
FROM (
	SELECT
		user_id,
        is_repeat_session,
		SUM(is_repeat_session) AS repeat_sessions
	FROM website_sessions
	WHERE created_at BETWEEN '2014-01-01' AND '2014-11-01'
	GROUP BY 1
) AS sessions_number
WHERE is_repeat_session = 0
GROUP BY 1
ORDER BY 1
;

###################################################################################################################

#9. ANALYZING REPEAT BEHAVIOR
CREATE TEMPORARY TABLE min_first_session
SELECT
	website_session_id,
    is_repeat_session,
    user_id,
    MIN(created_at) as min_first
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-03'
	AND is_repeat_session = 0
GROUP BY user_id
;

CREATE TEMPORARY TABLE min_second_session
SELECT
	website_session_id,
    is_repeat_session,
    user_id,
    MIN(created_at) AS min_second
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-03'
	AND is_repeat_session = 1
GROUP BY user_id
;

SELECT
	AVG(days_first_to_second) AS avg_days_first_to_second,
    MIN(days_first_to_second) AS min_days_first_to_second,
    MAX(days_first_to_second) AS max_days_first_to_second
FROM (
SELECT
	#user_id,
	DATEDIFF(min_second, min_first) AS days_first_to_second
FROM min_first_session
	INNER JOIN min_second_session
		ON min_first_session.user_id = min_second_session.user_id
) AS subquery
;

###################################################################################################################

#10. NEW VS REPEAT CHANNEL PATTERNS
SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1,2,3
;

SELECT
	CASE
		WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
        WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 'organic_search'
        WHEN utm_campaign = 'brand' AND http_referer IS NOT NULL THEN 'paid_brand'
        WHEN utm_campaign = 'nonbrand' AND http_referer IS NOT NULL THEN 'paid_nonbrand'
        WHEN utm_source = 'socialbook' AND http_referer IS NOT NULL THEN 'paid_social'
        ELSE 'uh oh...check logic'
	END AS channel_group,
    COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1
ORDER BY repeat_sessions DESC
;

###################################################################################################################

#11. NEW VS REPEAT PERFORMANCE
SELECT
	website_sessions.is_repeat_session,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    #COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    SUM(price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY 1
;