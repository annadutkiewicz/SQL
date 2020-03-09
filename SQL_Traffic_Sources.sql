SELECT
	website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions, #website_session_id should be unique but used DISTINCT just in case
	COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id

WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000 #arbitrary

GROUP BY
	utm_content
ORDER BY sessions DESC;


#Finding Top Traffic Sources
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

#Result: We should drill deeper into gsearch nonbrand campaign traffic
#to explore potential optimization.