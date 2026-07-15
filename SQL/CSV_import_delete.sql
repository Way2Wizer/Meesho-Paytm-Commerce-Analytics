USE meesho_paytm_db;
GO

-- 1. Delete the children first (depends on orders)
DELETE FROM payment_events;
GO

-- 2. Delete the central fact table (depends on customers and products)
DELETE FROM orders;
GO

-- 3. Delete products (depends on resellers)
DELETE FROM products;
GO

-- 4. Delete the independent parent tables last
DELETE FROM resellers;
DELETE FROM customers;
GO

PRINT 'All tables successfully cleared. Ready for reload!';