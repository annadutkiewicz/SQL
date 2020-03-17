#1. ANALYZING CHANNEL PORTFOLIOS
SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS total_sessions,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-29'
	AND utm_campaign = 'nonbrand'
GROUP BY
	YEARWEEK(created_at)
;
    
###################################################################################################################

#2. COMPARING CHANNEL CHARACTERISTICS
SELECT
	utm_source,
    COUNT(DISTINCT website_session_id) AS total_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_mobile
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-30'
	AND utm_campaign = 'nonbrand'
GROUP BY
	utm_source
;

###################################################################################################################

#3. CROSS CHANNEL BID OPTIMIZATION
SELECT
	website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id) / COUNT(website_sessions.website_session_id) AS conv_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-18'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1, 2
ORDER BY 1
;

###################################################################################################################

#4. CHANNEL PORTFOLIO TRENDS
SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN (device_type = 'desktop' AND utm_source = 'gsearch') THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN (device_type = 'desktop' AND utm_source = 'bsearch') THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
    COUNT(DISTINCT CASE WHEN (device_type = 'desktop' AND utm_source = 'bsearch') THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN (device_type = 'desktop' AND utm_source = 'gsearch') THEN website_session_id ELSE NULL END) AS b_pct_of_g_dtop,
    COUNT(DISTINCT CASE WHEN (device_type = 'mobile' AND utm_source = 'gsearch') THEN website_session_id ELSE NULL END) AS g_mob_sessions,
    COUNT(DISTINCT CASE WHEN (device_type = 'mobile' AND utm_source = 'bsearch') THEN website_session_id ELSE NULL END) AS b_mob_sessions,
    COUNT(DISTINCT CASE WHEN (device_type = 'mobile' AND utm_source = 'bsearch') THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN (device_type = 'mobile' AND utm_source = 'gsearch') THEN website_session_id ELSE NULL END) AS b_pct_of_g_mob
FROM website_sessions
WHERE website_sessions.created_at BETWEEN '2012-11-04' AND '2012-12-22'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	YEARWEEK(created_at)
;

###################################################################################################################

#5. ANALYZING FREE CHANNELS
SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-12-23';

SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
	COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
	COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand
FROM website_sessions
WHERE website_sessions.created_at < '2012-12-23'
GROUP BY
	YEAR(created_at),
    MONTH(created_at)
;