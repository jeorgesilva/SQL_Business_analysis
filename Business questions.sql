USE magist123;

#--------------------------------------------------------------------------------------------------
#-- 2.1. In relation to the products: ------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------
#-- What categories of tech products does Magist have?
#--------------------------------------------------------------------------------------------------
SELECT DISTINCT
    product_category_name_english AS tech_product_categories
FROM
    product_category_name_translation
WHERE
    product_category_name_english IN (
		'computers_accessories',
        'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics'
	)
;
#--------------------------------------------------------------------------------------------------
#-------How many products of these tech categories have been sold-------------------------
#--------------------------------------------------------------------------------------------------

#todo - check the prices

WITH price_categories AS (
	SELECT 
		oi.price,
		t.product_category_name_english AS tech_product_categories,
		COUNT(oi.order_item_id) AS total_produtos_vendidos
	FROM
		orders AS o
			JOIN
		order_items AS oi ON o.order_id = oi.order_id
			JOIN
		products AS p ON oi.product_id = p.product_id
			JOIN
		product_category_name_translation AS t ON p.product_category_name = t.product_category_name
	WHERE
		o.order_purchase_timestamp >= '2017-04-01'
			AND o.order_purchase_timestamp < '2018-04-01'
			AND t.product_category_name_english IN ('computers_accessories' , 'telephony',
			'computers',
			'audio',
			'tablets_printing_image',
			'pc_gamer',
			'electronics')
	GROUP BY tech_product_categories, oi.price)
    SELECT *,  CASE
        WHEN price > 500 THEN 'Expensive'
        WHEN price > 250 THEN 'Regular'
        WHEN price > 100 THEN 'Acceptable'
        WHEN price > 50 THEN 'Cheap'
        ELSE 'Very Cheap'
    END AS price_category
    FROM price_categories
	ORDER BY total_produtos_vendidos DESC;
		
#--------------------------------------------------------------------------------------------------
-- (within the time window of the database snapshot)? 
-- What percentage does that represent from the overall number of products sold?
#--------------------------------------------------------------------------------------------------

SELECT
    SUM(CASE WHEN product_category_name_translation.product_category_name_english IN (
        'computers_accessories',
        'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics'
    ) THEN 1 ELSE 0 END) AS `Tech Products Sold`,
    COUNT(order_items.order_item_id) AS `Total Products Sold`,
    (CAST(SUM(CASE WHEN product_category_name_translation.product_category_name_english IN (
        'computers_accessories',
        'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics'
    ) THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(order_items.order_item_id)) AS `Percentage Sold Tech Products`
FROM
    order_items
    JOIN products ON order_items.product_id = products.product_id
    JOIN product_category_name_translation ON products.product_category_name = product_category_name_translation.product_category_name
    JOIN orders ON order_items.order_id = orders.order_id
WHERE orders.order_purchase_timestamp >= '2017-04-01' AND orders.order_purchase_timestamp < '2018-04-01';

#--------------------------------------------------------------------------------------------------
-- What’s the average price of the products being sold? 120,65€
#--------------------------------------------------------------------------------------------------
SELECT 
    AVG(price) AS average_sold_price
FROM
    order_items
;
#--------------------------------------------------------------------------------------------------
-- avg price for tech products -- 106€
#--------------------------------------------------------------------------------------------------

SELECT 
    AVG(price) AS average_sold_price
FROM
    orders AS o
JOIN
    (SELECT DISTINCT order_id, product_id, price FROM order_items) AS oi ON o.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
    AND t.product_category_name_english IN (
        'computers_accessories',
        'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics'
    );

#--------------------------------------------------------------------------------------------------
-- Are expensive tech products popular? 
# HOW MANY FROM EACH CATEGORIE WAS SOLD, HOW IS THE PERCENTAGE FROM THE TOTAL
#--------------------------------------------------------------------------------------------------

SELECT
    CASE WHEN oi.price > 120 THEN 'Expensive'
    ELSE 'Regular'
    END AS `Price Category`,
    COUNT(oi.order_item_id) AS `Sales Amount`
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-03-31'
    AND t.product_category_name_english IN (
        'computers_accessories',
        'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics'
    )
GROUP BY `Price Category`
ORDER BY `Sales Amount` DESC;
#--------------------------------------------------------------------------------------------------
-- Minimum, maximum, average prices per tech category
#--------------------------------------------------------------------------------------------------

SELECT product_category_name_english, MIN(price), MAX(price), ROUND(AVG(price),2)
FROM
    order_items
	JOIN products ON order_items.product_id = products.product_id
	JOIN product_category_name_translation ON products.product_category_name = product_category_name_translation.product_category_name
WHERE
    product_category_name_translation.product_category_name_english IN (
		'computers_accessories',
        'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics')
GROUP BY product_category_name_english;

#--------------------------------------------------------------------------------------------------
-- Brazilian average wages 2018 (484€) + given the high tech industry prices, 
-- we set the following price range
-- very cheap (0 - 20), cheap (21 - 130), medium price (131 - 500), 
-- expensive (501 - 1.000), premium (1.001 - 7.000)
#--------------------------------------------------------------------------------------------------

SELECT
    CASE
        WHEN oi.price > 500 THEN 'Expensive'
        WHEN oi.price > 250 THEN 'Regular'
        WHEN oi.price > 100 THEN 'Acceptable'
        WHEN oi.price > 50 THEN 'Cheap'
        ELSE 'Very Cheap'
    END AS price_category,
    COUNT(oi.order_item_id) AS sales_amount
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-03-31'
    AND t.product_category_name_english IN (
        'computers_accessories',
        'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics'
    )
GROUP BY price_category
ORDER BY sales_amount DESC;

# -----------------------------------------------------------------------------------------
--  2.2 --- from ------Hanna --------------------------------------------------------------
# -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- 2) How many sellers are there? 
-- -----------------------------------------------------------------------------------------

SELECT COUNT(DISTINCT seller_id) FROM sellers;

--    How many Tech sellers are there?
SELECT 
    product_category_name_english,
    COUNT(DISTINCT oi.seller_id) AS seller_amount
FROM
    order_items oi
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pcnt USING (product_category_name)
WHERE
    product_category_name_english IN ('computers_accessories' , 'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics')
GROUP BY product_category_name_english
ORDER BY seller_amount DESC;

-- -----------------------------------------------------------------------------------------
-- 3) What percentage of overall sellers are Tech sellers? 638/3095*100 = 20,61%
-- -----------------------------------------------------------------------------------------

WITH total_sellers AS (
    -- Counts the total number of distinct sellers 
    SELECT COUNT(DISTINCT seller_id) AS total_seller_count
    FROM sellers
),
tech_sellers AS (
    -- Counts the total number of distinct sellers on Tech categories
    SELECT COUNT(DISTINCT oi.seller_id) AS tech_seller_count
    FROM order_items AS oi
    LEFT JOIN products AS p USING (product_id)
    LEFT JOIN product_category_name_translation AS pcnt USING (product_category_name)
    WHERE pcnt.product_category_name_english IN (
        'computers_accessories',
        'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics'
    )
)
SELECT
    -- selects athe countings and take the percentage
    ts.tech_seller_count,
    tos.total_seller_count,
    CAST(ts.tech_seller_count AS REAL) * 100.0 / tos.total_seller_count AS percentage_tech_sellers
FROM
    tech_sellers AS ts,
    total_sellers AS tos;
    
 -- --------------------------------------------------------------   
-- 4) What is the total amount earned by all sellers? total revenue in the refered period: 9636693,77€
-- --------------------------------------------------------------

SELECT SUM(payment_value) FROM order_payments
JOIN orders USING(order_id)
WHERE order_purchase_timestamp BETWEEN '2017-04-01 00:00:00' AND '2018-03-31 23:59:59';

# -----------------------------------------------------------------------------------------
--    What is the total amount earned by all Tech sellers?
# -----------------------------------------------------------------------------------------
SELECT 
    product_category_name_english,
    ROUND(SUM(price), 1) AS price_sum

FROM
    order_items
        JOIN
				(SELECT DISTINCT
					product_category_name_english, product_id
							FROM
					product_category_name_translation
							JOIN products USING (product_category_name)) AS prod_table_tanslated 
		USING (product_id)
LEFT JOIN orders USING (order_id)
WHERE order_purchase_timestamp BETWEEN '2017-04-01 00:00:00' AND '2018-03-31 23:59:59'
GROUP BY product_category_name_english
HAVING product_category_name_english IN ('computers_accessories' , 'telephony',
    'computers',
    'audio',
    'tablets_printing_image',
    'pc_gamer',
    'electronics')
ORDER BY price_sum DESC;

-- --------------------------------------------------------------
-- Sum of tech companies revenue in 1 year
-- --------------------------------------------------------------
SELECT 
    ROUND(SUM(price), 1) AS price_sum

FROM
    order_items
        LEFT JOIN
				(SELECT DISTINCT
					product_category_name_english, product_id
							FROM
					product_category_name_translation
							JOIN products USING (product_category_name)) AS prod_table_tanslated 
		USING (product_id)
LEFT JOIN orders USING (order_id)
WHERE order_purchase_timestamp BETWEEN '2017-04-01 00:00:00' AND '2018-03-31 23:59:59'
AND product_category_name_english IN ('computers_accessories' , 'telephony',
    'computers',
    'audio',
    'tablets_printing_image',
    'pc_gamer',
    'electronics')
ORDER BY price_sum DESC;

SELECT * FROM orders;
SELECT payment_type, SUM(payment_value) FROM order_payments GROUP BY payment_type; -- Does the table contain returned product payments?
SELECT * FROM order_payments WHERE order_id = '5cfd514482e22bc992e7693f0e3e8df7'; -- How to read this?
SELECT * FROM order_payments;

# -----------------------------------------------------------------------------------------
-- 5) Can you work out the average monthly income of all sellers? 
--   Can you work out the average monthly income of Tech sellers?
# -----------------------------------------------------------------------------------------
SELECT 
    year(order_purchase_timestamp) AS purchase_year, month(order_purchase_timestamp) AS purchase_month, ROUND(AVG(price), 1) AS price_avg
FROM
    order_items
        LEFT JOIN
				(SELECT DISTINCT
					product_category_name_english, product_id
							FROM
					product_category_name_translation
							JOIN products USING (product_category_name)) AS prod_table_tanslated 
		USING (product_id)
LEFT JOIN orders USING (order_id)
WHERE order_purchase_timestamp BETWEEN '2017-10-01 00:00:00' AND '2018-09-30 00:00:00'
AND product_category_name_english IN ('computers_accessories' , 'telephony',
    'computers',
    'audio',
    'tablets_printing_image',
    'pc_gamer',
    'electronics')
GROUP BY purchase_year, purchase_month
ORDER BY price_avg DESC;
#--------------------------- jeorge's try -------------------------
# -----------------------------------------------------------------------------------------
# -- What’s the average time between the order being placed and the product being delivered?
# -----------------------------------------------------------------------------------------
SELECT *
FROM orders;
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date,
            order_purchase_timestamp)) AS timelapse_purchase_delivery
FROM
    orders JOIN (SELECT * FROM geo RIGHT JOIN customers ON customer_zip_code_prefix = zip_code_prefix) AS geo_costumers USING (customer_id)
WHERE order_status LIKE '%delivered%';

# -----------------------------------------------------------------------------------------
# --------alternative----------

SELECT
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) AS average_delivery_time_days
FROM
    orders AS o
WHERE
    o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01';
    
# -----------------------------------------------------------------------------------------
#------------avg ORDER PRICE From each state --------------
# -----------------------------------------------------------------------------------------
SELECT
    g.state,
    AVG(oi.price) AS average_price
FROM
    order_items AS oi
JOIN
    orders AS o ON oi.order_id = o.order_id
JOIN
    customers AS c ON o.customer_id = c.customer_id
JOIN
    geo AS g ON c.customer_zip_code_prefix = g.zip_code_prefix
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
    AND o.order_status = 'delivered'
GROUP BY
    g.state
ORDER BY
    average_price DESC;

# -----------------------------------------------------------------------------------------
# avg per state - because maybe not every seller has a physical sotrage in every state in brasil
 #why are there null values
# -----------------------------------------------------------------------------------------

SELECT *
FROM orders;
SELECT 
    state,
    AVG(DATEDIFF(order_delivered_customer_date,
            order_purchase_timestamp)) AS timelapse_purchase_delivery
FROM
    orders JOIN (SELECT * FROM geo JOIN customers ON customer_zip_code_prefix = zip_code_prefix) AS geo_costumers USING (customer_id)
WHERE order_status LIKE '%delivered%'
GROUP BY state;

# -----------------------------------------------------------------------------------------
#-------------alternative --------------

SELECT
    g.state,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) AS average_delivery_time_days
FROM
    orders AS o
JOIN
    customers AS c ON o.customer_id = c.customer_id
JOIN
    geo AS g ON c.customer_zip_code_prefix = g.zip_code_prefix
WHERE
    o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
GROUP BY
    g.state
ORDER BY
    average_delivery_time_days DESC;
# -----------------------------------------------------------------------------------------
#-- How many orders are delivered on time vs orders delivered with a delay?
 # -----------------------------------------------------------------------------------------   
    # late
    SELECT COUNT(order_estimated_delivery_date) FROM orders WHERE CAST(order_delivered_customer_date AS DATE) > CAST(order_estimated_delivery_date AS DATE);
	#on time
    SELECT COUNT(order_estimated_delivery_date) FROM orders WHERE CAST(order_delivered_customer_date AS DATE) = CAST(order_estimated_delivery_date AS DATE);
# -----------------------------------------------------------------------------------------
#categorized deliverie dates
# -----------------------------------------------------------------------------------------
SELECT 
    categories, COUNT(order_id)
FROM
    (SELECT 
        CASE
                WHEN CAST(order_delivered_customer_date AS DATE) > CAST(order_estimated_delivery_date AS DATE) THEN 'late'
                WHEN CAST(order_delivered_customer_date AS DATE) = CAST(order_estimated_delivery_date AS DATE) THEN 'on time'
                WHEN CAST(order_delivered_customer_date AS DATE) < CAST(order_estimated_delivery_date AS DATE) THEN 'early'
                ELSE 'unknown'
            END AS categories,
            order_id,
            customer_id,
            order_status,
            order_purchase_timestamp,
            order_delivered_customer_date,
            order_estimated_delivery_date
    FROM
        orders
    WHERE
		order_purchase_timestamp >= '2017-04-01'
    AND order_purchase_timestamp < '2018-03-31'
        AND order_status = 'delivered') AS delivery_categories
        
GROUP BY categories;

# -----------------------------------------------------------------------------------------
#--- Is there any pattern for delayed orders, e.g. big products being delayed more often?
# -----------------------------------------------------------------------------------------
#checking where are the most delayed deliveries -------------------------

SELECT 
    state, COUNT(order_id) AS orders_count
FROM
    orders
        JOIN
    (SELECT 
        *
    FROM
        geo
    RIGHT JOIN customers ON customer_zip_code_prefix = zip_code_prefix) AS geo_costumers USING (customer_id)
WHERE
    CAST(order_delivered_customer_date AS DATE) > CAST(order_estimated_delivery_date AS DATE)
GROUP BY state
ORDER BY orders_count DESC;

# -----------------------------------------------------------------------------------------
# checking if the size matters -----------------
# -----------------------------------------------------------------------------------------
WITH delivery_category AS (
    SELECT
        CASE
            WHEN CAST(order_delivered_customer_date AS DATE) > CAST(order_estimated_delivery_date AS DATE) THEN 'late'
            WHEN CAST(order_delivered_customer_date AS DATE) = CAST(order_estimated_delivery_date AS DATE) THEN 'on time'
            WHEN CAST(order_delivered_customer_date AS DATE) < CAST(order_estimated_delivery_date AS DATE) THEN 'early'
            ELSE 'unknown'
        END AS delivery_status,
        order_id
    FROM
        orders
    WHERE
        order_status = 'delivered'
)
SELECT
    CASE
        WHEN (p.product_width_cm * p.product_length_cm * p.product_height_cm) >= 50000 THEN 'big'
        WHEN (p.product_width_cm * p.product_length_cm * p.product_height_cm) >= 10000 THEN 'medium'
        ELSE 'small'
    END AS size_categories,
    dc.delivery_status,
    COUNT(dc.order_id) AS total_orders
FROM
    delivery_category AS dc 
JOIN
    order_items AS oi ON dc.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
GROUP BY
    size_categories,
    dc.delivery_status;
    
#--------------------------using the time stamp ----------------------------------------------

SELECT
    CASE
        WHEN (p.product_width_cm * p.product_length_cm * p.product_height_cm) >= 50000 THEN 'big'
        WHEN (p.product_width_cm * p.product_length_cm * p.product_height_cm) >= 10000 THEN 'medium'
        ELSE 'small'
    END AS size_categories,
    CASE
        WHEN CAST(o.order_delivered_customer_date AS DATE) > CAST(o.order_estimated_delivery_date AS DATE) THEN 'late'
        WHEN CAST(o.order_delivered_customer_date AS DATE) = CAST(o.order_estimated_delivery_date AS DATE) THEN 'on time'
        WHEN CAST(o.order_delivered_customer_date AS DATE) < CAST(o.order_estimated_delivery_date AS DATE) THEN 'early'
        ELSE 'unknown'
    END AS delivery_status,
    COUNT(o.order_id) AS total_orders
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
WHERE
    o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
GROUP BY
    size_categories,
    delivery_status
ORDER BY
    size_categories,
    delivery_status;
#----------------------------------------------
SELECT * FROM products;
#----------------------------------------------
SELECT COUNT( DISTINCT customer_id)
FROM orders;

SELECT DISTINCT order_status
FROM orders;
#-------------------------------------------------
SELECT COUNT( DISTINCT order_id)
FROM orders;
#---------------------------------------------------
SELECT * FROM geo RIGHT JOIN customers ON customer_zip_code_prefix = zip_code_prefix;
#--------------------------------------------------
SELECT 
    CASE
        WHEN CAST(order_delivered_customer_date AS DATE) > CAST(order_estimated_delivery_date AS DATE) THEN 'late'
        WHEN CAST(order_delivered_customer_date AS DATE) = CAST(order_estimated_delivery_date AS DATE) THEN 'on time'
        WHEN CAST(order_delivered_customer_date AS DATE) < CAST(order_estimated_delivery_date AS DATE) THEN 'early'
        ELSE 'unknown' END AS categories, order_id, customer_id, order_status, order_purchase_timestamp, order_delivered_customer_date, order_estimated_delivery_date
FROM
    orders
WHERE order_status = 'delivered';
##--------------------------------------
SELECT AVG(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) * 100 AS percentage_late_deliveries
FROM
    orders
WHERE order_status = 'delivered';
### ------------ extra questions -----------
/*
1 -What is the average customer satisfaction rate for orders in the analysis period?
2 -What is the rate of cancellations and returns, and is there any correlation with delivery delays or logistical problems?
3 -What is the order volume and revenue of product categories that are most similar to "high-end tech products"? (we have this partialy answered)
4 -what percentage of total revenue come from price ranges similar to EINIAC's?*/

# -----------------------------------------------------------------------------------------
# --- 1 -What is the average customer satisfaction rate for orders in the analysis period?
# -----------------------------------------------------------------------------------------

SELECT
    AVG(r.review_score) AS average_satisfaction_rate
FROM
    orders AS o
JOIN
    order_reviews AS r ON o.order_id = r.order_id
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01';
SELECT MAX(review_score) FROM orders AS o
JOIN
    order_reviews AS r ON o.order_id = r.order_id;
    
# -----------------------------------------------------------------------------------------
#---2 -What is the rate of cancellations and returns, and is there any correlation with delivery delays or logistical problems?
# -----------------------------------------------------------------------------------------
SELECT
    CAST(SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(o.order_id) AS cancellation_rate_percent
FROM
    orders AS o
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01';

# -----------------------------------------------------------------------------------------
# relation with delay delivery
# -----------------------------------------------------------------------------------------

SELECT
    CASE
        WHEN o.order_status = 'canceled' THEN 'Canceled'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Delivered Late'
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'Delivered On Time'
        ELSE 'Other'
    END AS order_outcome,
    COUNT(o.order_id) AS total_orders
FROM
    orders AS o
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
GROUP BY
    order_outcome
ORDER BY
    total_orders DESC;
# -----------------------------------------------------------------------------------------
#-----3 -What is the order volume and revenue of product categories that are most similar to "high-end tech products"? (we have this partialy answered)
# -----------------------------------------------------------------------------------------

SELECT
	t.product_category_name_english AS tech_category,
	COUNT(oi.order_item_id) AS total_products_sold,
    SUM(oi.price) AS total_revenue
FROM
			orders AS o
		JOIN
			customers AS c ON o.customer_id = c.customer_id
		JOIN
			geo AS g ON c.customer_zip_code_prefix = g.zip_code_prefix
		JOIN
			order_items AS oi ON o.order_id = oi.order_id
		JOIN
			products AS p ON oi.product_id = p.product_id
		JOIN
			product_category_name_translation AS t ON p.product_category_name = t.product_category_name
		JOIN
			order_reviews AS ors ON o.order_id = ors.order_id
		JOIN
			order_payments AS op ON o.order_id = op.order_id
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
    AND o.order_status = 'delivered'
    AND t.product_category_name_english IN (
			'computers_accessories',
			'telephony',
			'computers',
			'audio',
			'tablets_printing_image',
			'pc_gamer',
			'electronics')
GROUP BY
    tech_category
ORDER BY
    total_revenue DESC;
 
 # -----------------------------------------------------------------------------------------
 # ------4 -what percentage of total revenue come from price ranges similar to EINIAC's?
# -----------------------------------------------------------------------------------------

SELECT
    (SUM(CASE WHEN op.payment_value BETWEEN 500 AND 1000 THEN op.payment_value ELSE 0 END) * 100.0)
    /
    SUM(op.payment_value) AS percentage_of_revenue
FROM
			orders AS o
		JOIN
			customers AS c ON o.customer_id = c.customer_id
		JOIN
			geo AS g ON c.customer_zip_code_prefix = g.zip_code_prefix
		JOIN
			order_items AS oi ON o.order_id = oi.order_id
		JOIN
			products AS p ON oi.product_id = p.product_id
		JOIN
			product_category_name_translation AS t ON p.product_category_name = t.product_category_name
		JOIN
			order_reviews AS ors ON o.order_id = ors.order_id
		JOIN
			order_payments AS op ON o.order_id = op.order_id
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
    AND o.order_status = 'delivered'
    AND t.product_category_name_english IN (
			'computers_accessories',
			'telephony',
			'computers',
			'audio',
			'tablets_printing_image',
			'pc_gamer',
			'electronics');
    
#----------------------------------------------------------------
 
 SELECT
    (SUM(CASE WHEN (oi.price + oi.freight_value) BETWEEN 500 AND 1000 THEN (oi.price + oi.freight_value) ELSE 0 END) * 100.0) / SUM(oi.price + oi.freight_value) AS percentage_of_revenue
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
JOIN products p USING (product_id) 
JOIN product_category_name_translation t USING (product_category_name)
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
    AND o.order_status = 'delivered' 
    and t.product_category_name_english IN (
        'computers_accessories',
        'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics');
# -----------------------------------------------------------------------------------------
#------how many packages in each state are delivered, and their avarage delivered time
# -----------------------------------------------------------------------------------------

SELECT COUNT(DISTINCT o.order_id) FROM orders;
WITH DELIVERY_METRICS AS (
	SELECT
		state,
		COUNT(DISTINCT o.order_id) AS count_orders # AVG() DELIVERY TIME - AVG PRICE - 
        
	FROM
		orders AS o
	JOIN
		customers AS c ON o.customer_id = c.customer_id
	JOIN
		geo AS g ON c.customer_zip_code_prefix = g.zip_code_prefix
	JOIN
		order_items AS oi ON o.order_id = oi.order_id
	JOIN
		products AS p ON oi.product_id = p.product_id
	JOIN
		product_category_name_translation AS t ON p.product_category_name = t.product_category_name
	JOIN
		order_reviews AS ors ON o.order_id = ors.order_id
	JOIN
		order_payments AS op ON o.order_id = op.order_id
	WHERE
		o.order_status = 'delivered'
		AND o.order_purchase_timestamp >= '2017-04-01'
		AND o.order_purchase_timestamp < '2018-04-01'
		AND t.product_category_name_english IN (
			'computers_accessories',
			'telephony',
			'computers',
			'audio',
			'tablets_printing_image',
			'pc_gamer',
			'electronics')
	GROUP BY
		g.state)
SELECT *
FROM DELIVERY_METRICS
ORDER BY
    count_orders DESC;
    
#----- retoure?---- no info about it in the tables-------------------------------------------
#-------where are the most expensive products sold in Brazil
# TO DO ----- USE ONLY TECH PRODUCTS TO FILTER THE RESULTS -- done
#--- LABEL THE REVIEWS AS DONE WITH PRICES -- done
#---------------------------------------------------------------------------------------------
WITH state_metrics AS (
		SELECT
			g.state,
			COUNT(o.order_id) AS count_delivered_orders,
			ROUND(SUM(oi.price),2) AS orderitems_price_sum,
			ROUND(AVG(oi.price),2) AS avg_state_order_price,
			MAX(oi.price) AS max_price_state,
			MIN(oi.price) AS minimum_state_price,
			ROUND(AVG(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END),2) * 100 AS percentage_late_deliveries,
			ROUND(AVG(ors.review_score),2) AS average_review_score,
			ROUND(SUM(op.payment_value),2) AS total_revenue_payments,
			ROUND(AVG(op.payment_value),2) AS average_payment_value,
			COUNT(op.payment_sequential) AS total_payments_count
		FROM
			orders AS o
		JOIN
			customers AS c ON o.customer_id = c.customer_id
		JOIN
			geo AS g ON c.customer_zip_code_prefix = g.zip_code_prefix
		JOIN
			order_items AS oi ON o.order_id = oi.order_id
		JOIN
			products AS p ON oi.product_id = p.product_id
		JOIN
			product_category_name_translation AS t ON p.product_category_name = t.product_category_name
		JOIN
			order_reviews AS ors ON o.order_id = ors.order_id
		JOIN
			order_payments AS op ON o.order_id = op.order_id
		WHERE
			o.order_status = 'delivered'
			AND o.order_purchase_timestamp >= '2017-04-01'
			AND o.order_purchase_timestamp < '2018-04-01'
			AND t.product_category_name_english IN (
				'computers_accessories',
				'telephony',
				'computers',
				'audio',
				'tablets_printing_image',
				'pc_gamer',
				'electronics'
			)
		GROUP BY
			g.state)
SELECT #now the following query classifies the avarage reviews per state
    state,
    count_delivered_orders,
    orderitems_price_sum,
    avg_state_order_price,
    max_price_state,
    minimum_state_price,
    percentage_late_deliveries,
    average_review_score,
    total_revenue_payments,
    average_payment_value,
    total_payments_count,
    CASE
        WHEN average_review_score >= 4.5 THEN 'Excellent'
        WHEN average_review_score >= 4.0 THEN 'Good'
        WHEN average_review_score >= 3.0 THEN 'Average'
        ELSE 'Poor'
    END AS review_category
FROM
    state_metrics 
ORDER BY
    count_delivered_orders DESC;
    
SELECT * FROM orders;

# -----------------------------------------------------------------------------------------
#diagram 1
# -----------------------------------------------------------------------------------------

SELECT
    -- Soma a receita apenas dos produtos de tecnologia
    SUM(CASE WHEN t.product_category_name_english IN (
        'computers_accessories', 'telephony', 'computers', 'audio',
        'tablets_printing_image', 'pc_gamer', 'electronics'
    ) THEN oi.price + oi.freight_value ELSE 0 END) AS tech_revenue,
    -- Soma a receita de todos os produtos
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
LEFT JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01';

# -----------------------------------------------------------------------------------------
#diagram 2 graficvo de barras vendedores e revenue
# -----------------------------------------------------------------------------------------

SELECT
    t.product_category_name_english AS tech_category,
    SUM(oi.price) AS total_revenue,
    COUNT(DISTINCT oi.seller_id) AS total_sellers
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
    AND t.product_category_name_english IN (
        'computers_accessories', 'telephony', 'computers', 'audio',
        'tablets_printing_image', 'pc_gamer', 'electronics'
    )
GROUP BY
    tech_category
ORDER BY
    total_revenue DESC;
    
# -----------------------------------------------------------------------------------------
#diagram 3
# -----------------------------------------------------------------------------------------

SELECT
    CASE
        WHEN oi.price > 250 THEN 'Expensive'
        WHEN oi.price > 100 THEN 'Regular'
        WHEN oi.price > 50 THEN 'Cheap'
        ELSE 'Very Cheap'
    END AS price_category,
    COUNT(oi.order_item_id) AS sales_amount
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
    AND t.product_category_name_english IN (
        'computers_accessories', 'telephony', 'computers', 'audio',
        'tablets_printing_image', 'pc_gamer', 'electronics'
    )
GROUP BY
    price_category
ORDER BY
    sales_amount DESC;

# -----------------------------------------------------------------------------------------    
#diagram 4 Gráfico de Barras: Preço Médio por Categoria (Comparação)
# -----------------------------------------------------------------------------------------

SELECT
    t.product_category_name_english AS tech_category,
    AVG(oi.price) AS average_price
FROM
    orders AS o
JOIN
    order_items AS oi ON o.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
    AND t.product_category_name_english IN (
        'computers_accessories', 'telephony', 'computers', 'audio',
        'tablets_printing_image', 'pc_gamer', 'electronics'
    )
GROUP BY
    tech_category
ORDER BY
    average_price DESC;
    
SELECT 
    COUNT(DISTINCT oi.seller_id) AS seller_amount
FROM
    order_items oi
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pcnt USING (product_category_name)
WHERE
    product_category_name_english IN ('computers_accessories' , 'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics')
ORDER BY seller_amount DESC;


#-------------------------------------------------
SELECT
    AVG(r.review_score) AS average_satisfaction_rate
FROM
    orders AS o
JOIN
    order_reviews AS r ON o.order_id = r.order_id
JOIN
    order_items AS oi ON o.order_id = oi.order_id
JOIN
    products AS p ON oi.product_id = p.product_id
JOIN
    product_category_name_translation AS t ON p.product_category_name = t.product_category_name
WHERE
    o.order_purchase_timestamp >= '2017-04-01'
    AND o.order_purchase_timestamp < '2018-04-01'
    AND 
    t.product_category_name_english IN (
        'computers_accessories',
        'telephony',
        'computers',
        'audio',
        'tablets_printing_image',
        'pc_gamer',
        'electronics'
    );