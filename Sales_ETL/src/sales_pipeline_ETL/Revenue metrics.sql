CREATE MATERIALIZED VIEW revenue_by_customer_segment_gold
AS 
SELECT c.cust_id, SUM(o.order_amount) AS total_revenue 
FROM payment_silver p 
LEFT OUTER JOIN order_silver o ON p.order_id = o.order_id
LEFT OUTER JOIN customer_silver c ON o.cust_id = c.cust_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY c.cust_id ;

CREATE MATERIALIZED VIEW city_wise_revenue_gold
AS 
SELECT c.city, sum(o.order_amount) AS total_revenue
FROM payment_silver p 
LEFT OUTER JOIN order_silver o ON p.order_id = o.order_id
LEFT OUTER JOIN customer_silver c ON o.cust_id = c.cust_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY c.city;