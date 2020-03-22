/*
1. Gsearch seems to be the biggest driver of our business. Could you pull monthly trends
for gsearch sessions and orders so that we can showcase the growth there?
*/
SELECT
	YEAR(website_sessions.created_at) AS year,
	MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY 1, 2;

###################################################################################################################

/*
2. Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and
brand campaigns separately . I am wondering if brand is picking up at all. If so, this is a good story to tell
*/
SELECT
	YEAR(website_sessions.created_at) AS year,
	MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_conv_rate,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_conv_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY 1, 2;

###################################################################################################################

/*
3. While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device
type? I want to flex our analytical muscles a little and show the board we really know our traffic sources
*/
SELECT
	YEAR(website_sessions.created_at) AS year,
	MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN orders.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_nonbrand_conv_rate,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_nonbrand_orders,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN orders.order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_nonbrand_conv_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY 1, 2;

###################################################################################################################

/*
4. I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from
Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
*/
SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE created_at < '2012-11-27';

SELECT
	YEAR(website_sessions.created_at) AS year,
	MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1, 2;

###################################################################################################################

/*
5. I’d like to tell the story of our website performance improvements over the course of the first 8 months.
Could you pull session to order conversion rates, by month?
*/
SELECT
	YEAR(website_sessions.created_at) AS year,
	MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS orders_to_sessions_conv_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1, 2;

###################################################################################################################

/*
6. For the gsearch lander test, please estimate the revenue that test earned us. Hint: Look at the increase in CVR
from the test (Jun 19 Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)
*/
#STEP 0: first pageview_id for /lander-1
SELECT
	created_at,
	MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

#STEP 1: finding first pageviews for given sessions
CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19 00:35:54' AND '2012-07-28'
	AND website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	website_pageviews.website_session_id;

#STEP 2: bringing landing page to each session, restricting to home and lander-1
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON first_test_pageviews.min_pageview_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

#STEP 3: make a table to bring in orders
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT
	nonbrand_test_sessions_w_landing_pages.website_session_id,
    nonbrand_test_sessions_w_landing_pages.landing_page,
    orders.order_id AS order_id
FROM nonbrand_test_sessions_w_landing_pages
	LEFT JOIN orders
		ON nonbrand_test_sessions_w_landing_pages.website_session_id = orders.website_session_id;

#STEP 4: find difference between conversion rates 
SELECT
	landing_page,
    COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS orders_to_sessions_conv_rate
FROM nonbrand_test_sessions_w_orders
GROUP BY 1;

#STEP 5: finding most recent pageview for gsearch nonbrand where traffic was sent to /home
SELECT
	MAX(website_sessions.website_session_id) AS moset_recent_gsearch_nonbrand_home_pageview
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_pageviews.pageview_url = '/home'
    AND website_sessions.created_at < '2012-11-27';
#max website_session_id = 17145

#STEP 6: counting sessions since test
SELECT
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND website_session_id > 17145
    AND created_at < '2012-11-27';
/*
22,972 website sessions since the test
incremental conversion rate = 0.0406-0.0318 = 0.0088
incremental orders: 0.0088*22972 = 202 since Jul, 29th
roughly 4 months so roughly 50 extra orders per month
*/
    
###################################################################################################################

/*
7. For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each
of the two pages to orders . You can use the same time period you analyzed last time (Jun 19 Jul 28)
*/
#STEP 1: select all pageviews for relevant sessions and identify each pageview as specific funnel step
CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT
	website_session_id,
    MAX(homepage) AS saw_homepage,
    MAX(custom_lander) AS saw_custom_lander,
    MAX(products_page) AS products_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM (
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    #website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.utm_source = 'gsearch'
ORDER BY
	website_pageviews.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY
	website_session_id;

#STEP 2: create session-level conversion funnel view
SELECT
	CASE
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic'
	END AS segment,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flags
GROUP BY 1;

#STEP 3: aggregate data to assess funnel performance
SELECT
	CASE
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic'
	END AS segment,
    COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM session_level_made_it_flags
GROUP BY 1;
    
###################################################################################################################

/*
8. I’d love for you to quantify the impact of our billing test , as well. Please analyze the lift generated from the test
(Sep 10 Nov 10), in terms of revenue per billing page session , and then pull the number of billing page sessions
for the past month to understand monthly impact
*/
SELECT
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd) / COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM (
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id,
    orders.price_usd
FROM website_pageviews
	LEFT JOIN orders
		ON website_pageviews.website_session_id = orders.website_session_id
WHERE website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
	AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
) AS billing_pageviews_and_order_data
GROUP BY 1;
# $22.83 revenue per billing page seen for old version
# $31.34 revenue per billing page seen for old version
# LIFT: $8.51 per billing page view

SELECT
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE pageview_url IN ('/billing', '/billing-2')
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27'
# 1193 billing sessions past month
# LIFT: $8.51 per billing session
# VALUE OF BILLING TEST: $10,150 over the past month