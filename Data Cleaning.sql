create database SupplyChain;

use supplychain;

CREATE TABLE supply_chain (
  -- Order & shipping days
  type                        VARCHAR(50),
  days_shipping_real          INT,
  days_shipping_sched         INT,
  benefit_per_order           DECIMAL(10,2),
  sales_per_customer          DECIMAL(10,2),
  delivery_status             VARCHAR(50),
  late_delivery_risk          TINYINT,

  -- Category
  category_id                 INT,
  category_name               VARCHAR(100),

  -- Customer info
  customer_city               VARCHAR(100),
  customer_country            VARCHAR(100),
  customer_email              VARCHAR(150),
  customer_fname              VARCHAR(100),
  customer_id                 INT,
  customer_lname              VARCHAR(100),
  customer_password           VARCHAR(100),
  customer_segment            VARCHAR(50),
  customer_state              VARCHAR(100),
  customer_street             VARCHAR(200),
  customer_zipcode            VARCHAR(20),

  -- Department
  department_id               INT,
  department_name             VARCHAR(100),

  -- Location coordinates
  latitude                    DECIMAL(10,6),
  longitude                   DECIMAL(10,6),

  -- Market & order
  market                      VARCHAR(50),
  order_city                  VARCHAR(100),
  order_country               VARCHAR(100),
  order_customer_id           INT,
  order_date                  VARCHAR(20),
  order_id                    INT,
  order_item_cardprod_id      INT,
  order_item_discount         DECIMAL(10,2),
  order_item_discount_rate    DECIMAL(10,4),
  order_item_id               INT,
  order_item_product_price    DECIMAL(10,2),
  order_item_profit_ratio     DECIMAL(10,4),
  order_item_quantity         INT,
  sales                       DECIMAL(10,2),
  order_item_total            DECIMAL(10,2),
  order_profit_per_order      DECIMAL(10,2),
  order_region                VARCHAR(100),
  order_state                 VARCHAR(100),
  order_status                VARCHAR(50),
  order_zipcode               VARCHAR(20),

  -- Product
  product_card_id             INT,
  product_category_id         INT,
  product_description         TEXT,
  product_image               VARCHAR(300),
  product_name                VARCHAR(200),
  product_price               DECIMAL(10,2),
  product_status              TINYINT,

  -- Shipping
  shipping_date               VARCHAR(20),
  shipping_mode               VARCHAR(50)
);

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DataCoSupplyChainDataset.csv'
INTO TABLE supply_chain
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from supply_chain;

select count(*) from supply_chain;

--- DATA CLEANING ----

--- Order date

ALTER TABLE supply_chain
ADD order_date_clean DATETIME After order_date;

UPDATE supply_chain
SET order_date_clean =
CASE
    WHEN order_date LIKE '%/%'
        THEN STR_TO_DATE(order_date, '%c/%e/%Y %H:%i')
    WHEN order_date LIKE '%-%'
        THEN STR_TO_DATE(order_date, '%m-%d-%Y %H:%i')
END;

SELECT order_date, order_date_clean
FROM supply_chain
LIMIT 20;

alter table supply_chain drop column order_date;

ALTER TABLE supply_chain
CHANGE order_date_clean order_date DATETIME;

--- shipping date---

ALTER TABLE supply_chain
ADD shipping_date_clean DATETIME after shipping_date;

UPDATE supply_chain
SET shipping_date_clean =
CASE
    WHEN shipping_date LIKE '%/%'
        THEN STR_TO_DATE(shipping_date, '%c/%e/%Y %H:%i')
    WHEN shipping_date LIKE '%-%'
        THEN STR_TO_DATE(shipping_date, '%m-%d-%Y %H:%i')
END;

SELECT shipping_date, shipping_date_clean
FROM supply_chain
LIMIT 20;

alter table supply_chain drop column shipping_date;

ALTER TABLE supply_chain
CHANGE shipping_date_clean shipping_date DATETIME;

-- Total row count
SELECT COUNT(*) AS total_rows FROM supply_chain;

-- Check nulls in key columns
SELECT
  SUM(CASE WHEN delivery_status IS NULL THEN 1 ELSE 0 END)      AS null_delivery,
  SUM(CASE WHEN days_shipping_real IS NULL THEN 1 ELSE 0 END)    AS null_days_real,
  SUM(CASE WHEN category_name IS NULL THEN 1 ELSE 0 END)         AS null_category,
  SUM(CASE WHEN order_region IS NULL THEN 1 ELSE 0 END)          AS null_region,
  SUM(CASE WHEN sales_per_customer IS NULL THEN 1 ELSE 0 END)    AS null_sales
FROM supply_chain;

select * from supply_chain;

UPDATE supply_chain
SET
benefit_per_order = TRIM(benefit_per_order),
category_name = TRIM(category_name),
customer_city = TRIM(customer_city),
customer_country = TRIM(customer_country),
customer_fname = TRIM(customer_fname),
customer_lname = TRIM(customer_lname),
customer_segment = TRIM(customer_segment),
customer_state = TRIM(customer_state),
customer_street = TRIM(customer_street),
delivery_status = TRIM(delivery_status),
department_name = TRIM(department_name),
market = TRIM(market),
order_city = TRIM(order_city),
order_country = TRIM(order_country),
order_region = TRIM(order_region),
order_state = TRIM(order_state),
order_status = TRIM(order_status),
product_image = TRIM(product_image),
product_name = TRIM(product_name),
shipping_mode = TRIM(shipping_mode),
type = TRIM(type);

---- Profit or Loss 

Alter table supply_chain
add column profit_or_loss VARCHAR(20) AFTER order_profit_per_order;

UPDATE supply_chain
SET profit_or_loss =
CASE 
   WHEN order_profit_per_order <= 0 THEN 'Loss' 
   Else 'Profit'
   End;

select * from supply_chain;

---- Delay gap

ALTER TABLE supply_chain
ADD COLUMN delay_gap INT
GENERATED ALWAYS AS (
    days_shipping_real - days_shipping_sched
) STORED AFTER days_shipping_sched;

ALTER TABLE supply_chain
drop column delay_gap_category,
ADD COLUMN delay_gap_category varchar(20) AFTER delay_gap;

UPDATE supply_chain 
SET delay_gap_category =
CASE 
   WHEN delay_gap = 0 THEN 'delivered on time'
   WHEN delay_gap < 0 THEN 'delivered early'
   WHEN delay_gap > 0 THEN 'delivered late'
   END;
   
---- Removing UnWanted columns ---

ALTER TABLE supply_chain 
drop column customer_email,
drop column customer_password,
drop column order_zipcode,
drop column product_description,
DROP COLUMN customer_lname,
DROP COLUMN customer_state,
DROP COLUMN customer_street,
DROP COLUMN product_status,
DROP COLUMN product_image,
DROP COLUMN customer_zipcode;

---- Renaming 

alter table supply_chain
rename column customer_fname to customer_name;

SHOW COLUMNS FROM supply_chain;

SELECT late_delivery_risk, delay_gap_category
FROM supply_chain;

SELECT late_delivery_risk, delay_gap_category, COUNT(*) 
FROM supply_chain
GROUP BY late_delivery_risk, delay_gap_category;

select distinct(order_status) from supply_chain;

--- Order Status 

ALTER TABLE supply_chain
ADD COLUMN order_status_categories VARCHAR(50) AFTER order_status;

UPDATE supply_chain 
SET order_status_categories =
    CASE 
        WHEN order_status IN ('COMPLETE', 'CLOSED') THEN 'SUCCESS'
        WHEN order_status IN ('PENDING', 'PENDING_PAYMENT', 'PROCESSING') THEN 'IN_PROGRESS'
        WHEN order_status IN ('CANCELED', 'SUSPECTED_FRAUD') THEN 'FAILED'
        WHEN order_status IN ('ON_HOLD', 'PAYMENT_REVIEW') THEN 'REVIEW'
        ELSE 'OTHER'
    END;
    
--- Profit 

Alter table supply_chain
ADD COLUMN profit_perc int after profit_or_loss;

UPDATE supply_chain
SET profit_perc = (order_profit_per_order / sales) * 100;

select * from supply_chain;

show columns from supply_chain;

--- Export File
SELECT *
FROM supply_chain
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/supply_chain_export.csv'
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

