-- creating database
CREATE DATABASE meesho_paytm_db;
GO

USE meesho_paytm_db;
GO

-- building customers table
IF OBJECT_ID ('customers','U') IS NOT NULL
	DROP TABLE customers;
GO

CREATE TABLE customers(
	customer_id INT PRIMARY KEY,
	city VARCHAR(100),
	city_tier VARCHAR(50),
	signup_date DATE,
	gender VARCHAR(10)
);
GO

-- Resellers Table
IF OBJECT_ID ('resellers','U') IS NOT NULL
	DROP TABLE resellers;
GO

CREATE TABLE resellers (
	reseller_id INT PRIMARY KEY,
	category_focus VARCHAR(100),
	city VARCHAR(100),
	join_date DATE
);
GO

-- building the product table
IF OBJECT_ID ('products','U') IS NOT NULL
	DROP TABLE products;
GO

CREATE TABLE products (
	product_id INT PRIMARY KEY,
	category VARCHAR(100),
	base_price DECIMAL(10,2),
	reseller_id INT,
	FOREIGN KEY (reseller_id) REFERENCES resellers (reseller_id) 
);
GO

-- building the Order table 
IF OBJECT_ID ('orders','U') IS NOT NULL
	DROP TABLE orders;
GO

CREATE TABLE orders (
	order_id INT PRIMARY KEY,
	customer_id INT,
	product_id INT,
	order_date DATE, 
	quantity INT, 
	discount_pct INT, 
	payment_method VARCHAR(50),
	order_value DECIMAL(10,2),
	delivery_status VARCHAR(50),
	return_flag INT,
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

-- building the payment events table
IF OBJECT_ID ('payements_events','U') IS NOT NULL
	DROP TABLE payements_events;
GO

CREATE TABLE payements_events (
	payment_id INT PRIMARY KEY,
	order_id INT,
	payement_status VARCHAR(50),
	cashback_applied INT,
	FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
GO

 