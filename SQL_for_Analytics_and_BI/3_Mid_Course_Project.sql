/*1. Gsearch seems to be the biggest driver of our business. Could you pull monthly trends
for gsearch sessions and orders so that we can showcase the growth there?*/
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

/*2. Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and
brand campaigns separately . I am wondering if brand is picking up at all. If so, this is a good story to tell.*/
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

/*3. While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device
type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.*/
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

/*4. I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from
Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?*/