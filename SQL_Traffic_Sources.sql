/* Let's find what are our top traffic sources by seeing a breakdown
by UTM source, campaign and referring domain*/

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

/*Result: We should drill deeper into gsearch nonbrand campaign traffic
to explore potential optimization as it looks like gsearch nonbrand is
major traffic source. Based on what is paid for clicks, at least 4%
CVR is needed*/

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

/*Result: We received 0.0288 conversion rate, i.e. we are below 4% threshold.
The impact of bid reductions should be monitored and performance trending by device type
should be analyzed to refine bidding strategy. Bids were now reduced for gsearch nonbrand
so let's see how it looks after Apr-15th*/

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
    
/*Result: Non brand traffic seem to be sensitive to bid changes and volume is down,
so we are goint to monitor volume traffic and think about how to make the campaigns
more efficient to increase volume again*/
    
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

/*Result: For desktop versions, conversion rate equals to 3.7%, for mobile traffic
it is less than 1%. We are going to increase bids for desktop and analyze if bid changes
make an impact*/

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
    
/*Result: 