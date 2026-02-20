CREATE MATERIALIZED VIEW order_count_by_payment_mode_gold
AS 
SELECT payment_mode, count(*) AS total_orders
FROM payment_silver
GROUP BY payment_mode;

CREATE MATERIALIZED VIEW average_order_value_gold
AS 
SELECT c.cust_id,
      SUM(o.order_amount) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM payment_silver p 
LEFT OUTER JOIN order_silver o ON p.order_id = o.order_id
LEFT OUTER JOIN customer_silver c ON o.cust_id = c.cust_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY c.cust_id;