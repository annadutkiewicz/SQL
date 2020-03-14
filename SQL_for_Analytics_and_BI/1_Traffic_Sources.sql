#1. FINDING TOP TRAFFIC SOURCES
SELECT
	utm_source,
    utm_campaign,
    http_referer,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY
	utm_source,
    utm_campaign,
    http_referer
ORDER BY sessions DESC

#2.  TRAFFIC CONVERSION RATES
SELECT
	#website_sessions.utm_source,
    #website_sessions.utm_campaign,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE
	website_sessions.utm_source = 'gsearch' AND
    website_sessions.utm_campaign = 'nonbrand' AND
    website_sessions.created_at < '2012-04-14'
GROUP BY
	utm_source,
    utm_campaign

#3. TRAFFIC SOURCE TRENDING
SELECT
	#YEAR(created_at) as year,
	#WEEK(created_at) as week,
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE
	created_at < '2012-05-10' AND
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand'
GROUP BY
	YEAR(created_at),
	WEEK(created_at)
    
#4. TRAFFIC SOURCE BID OPTIMIZATION    
SELECT
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at < '2012-05-11' AND
    utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand'
GROUP BY
	website_sessions.device_type

#5. TRAFFIC SOURCE SEGMENT TRENDING
SELECT
    MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM website_sessions
WHERE
	(created_at BETWEEN '2012-04-15' AND '2012-06-09') AND
    utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand'
GROUP BY
	YEAR(created_at),
    WEEK(created_at)