# BUSINESS QUESTIONS

-- Checking distinct values and total rows
SELECT 
  COUNT(*) AS total_rows,
  COUNT(DISTINCT order_item_id) AS unique_items,
  COUNT(DISTINCT order_id) AS unique_orders
FROM supply_chain;

--- Duplicate values
SELECT order_item_id, COUNT(*) AS cnt
FROM supply_chain
GROUP BY order_item_id
HAVING cnt > 1;

-- 1. Average shipping delay
SELECT 
  AVG(delay_gap) AS avg_delay
FROM supply_chain;

-- 2. Shipping mode with highest delay
SELECT 
  shipping_mode,
  AVG(delay_gap) AS avg_delay
FROM supply_chain
GROUP BY shipping_mode
ORDER BY avg_delay DESC;

-- 3. % of late vs on-time vs early orders
SELECT 
 delay_gap_category,
  COUNT(*) AS total_orders,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM supply_chain
GROUP BY delay_gap_category;

-- 4. Regions with most delays
SELECT 
  order_region,
  COUNT(*) AS late_orders
FROM supply_chain
WHERE delay_gap > 0
GROUP BY order_region
ORDER BY late_orders DESC;

-- 5. Total sales
SELECT SUM(sales) AS total_sales
FROM supply_chain;

-- 6. Category with highest sales
SELECT 
  category_name,
  SUM(sales) AS total_sales
FROM supply_chain
GROUP BY category_name
ORDER BY total_sales DESC;

-- 7. Customer segment revenue
SELECT 
  customer_segment,
  SUM(sales) AS total_sales
FROM supply_chain
GROUP BY customer_segment
ORDER BY total_sales DESC;

-- 8. Top 10 customers by sales
SELECT 
  customer_name, COUNT(customer_id)as total_orders,
  SUM(sales_per_customer) AS total_sales
FROM supply_chain
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 10;

-- 9. City-wise sales
SELECT order_city, ROUND(SUM(sales), 2) AS total_sales
FROM supply_chain
GROUP BY order_city
ORDER BY total_sales DESC
LIMIT 15;

-- 10. Most profitable products
SELECT 
  product_name,
  ROUND(SUM(order_profit_per_order),0) AS total_profit
FROM supply_chain
GROUP BY product_name
ORDER BY total_profit DESC;

-- 11. Loss-making products
SELECT 
  product_name,
  SUM(order_profit_per_order) AS total_loss
FROM supply_chain
WHERE profit_or_loss = 'loss'
GROUP BY product_name
ORDER BY total_loss;

-- 12. Category profit
SELECT 
  category_name,
  SUM(order_profit_per_order) AS total_profit
FROM supply_chain
WHERE profit_or_loss = 'profit'
GROUP BY category_name
ORDER BY total_profit DESC;

-- 13. Segment order count
select customer_segment,
  COUNT(order_id) AS total_orders
FROM supply_chain
GROUP BY customer_segment;

-- 14.Regions with most delays — missing late %
SELECT 
  order_region,
  COUNT(*) AS total_orders,
  SUM(late_delivery_risk) AS late_orders,
  ROUND(SUM(late_delivery_risk) * 100.0 / COUNT(*), 2) AS late_pct,
  ROUND(AVG(delay_gap), 2) AS avg_delay_days
FROM supply_chain
GROUP BY order_region
ORDER BY late_pct DESC;

-- 15. Highest discount products
SELECT 
  product_name,
  AVG(order_item_discount_rate) AS avg_discount
FROM supply_chain
GROUP BY product_name
ORDER BY avg_discount DESC;

-- 16. Country-wise sales
SELECT order_country, SUM(sales) AS total_sales
FROM supply_chain
GROUP BY order_country
ORDER BY total_sales DESC;

-- 17. Region avg delay
SELECT 
  order_region,
  AVG(delay_gap) AS avg_delay
FROM supply_chain
GROUP BY order_region
ORDER BY avg_delay DESC;

-- 18. Monthly sales
SELECT 
  DATE_FORMAT(order_date, '%Y-%m') AS month,
  SUM(sales) AS total_sales
FROM supply_chain
GROUP BY month
ORDER BY month;

-- 19. Customer segment order volume
SELECT 
  customer_segment,
  COUNT(order_id) AS total_orders
FROM supply_chain
GROUP BY customer_segment;

-- 20. Best-selling products
SELECT 
  product_name,
  SUM(order_item_quantity) AS total_quantity
FROM supply_chain
GROUP BY product_name
ORDER BY total_quantity DESC;

-- 21. Least-selling products
SELECT 
  product_name,
  SUM(order_item_quantity) AS total_quantity
FROM supply_chain
GROUP BY product_name
ORDER BY total_quantity ASC;

-- 22. Factors affecting profit
SELECT 
  category_name,
  shipping_mode,
  AVG(order_item_discount_rate) AS avg_discount,
  AVG(delay_gap) AS avg_delay
FROM supply_chain
GROUP BY category_name, shipping_mode;

-- 23. Best performing combination
SELECT category_name, shipping_mode, order_region,
  COUNT(*) AS total_orders,
  SUM(CASE WHEN profit_or_loss = 'Profit' THEN 1 ELSE 0 END) AS profitable_orders,
  ROUND(AVG(order_profit_per_order), 2) AS avg_profit,
  ROUND(SUM(late_delivery_risk)*100.0/COUNT(*), 2) AS late_pct
FROM supply_chain
GROUP BY category_name, shipping_mode, order_region
ORDER BY avg_profit DESC
LIMIT 15;