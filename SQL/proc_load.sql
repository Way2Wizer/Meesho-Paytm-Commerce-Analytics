USE meesho_paytm_db
GO 

-------------------------------------------------------------------------------------
-- PART 1 : performance indexing 
-- (creating secondary paths so complex functions execute instantly)
-------------------------------------------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_orders_customer_id' 
      AND object_id = OBJECT_ID('dbo.orders')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_orders_customer_id 
    ON dbo.orders(customer_id);
    
    PRINT 'SUCCESS: Index IX_orders_customer_id created.';
END
ELSE
BEGIN
    PRINT 'SKIP: Index IX_orders_customer_id already exists.';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_orders_product_id' 
      AND object_id = OBJECT_ID('dbo.orders')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_orders_product_id 
    ON dbo.orders(product_id);
    
    PRINT 'SUCCESS: Index IX_orders_product_id created.';
END
ELSE
BEGIN
    PRINT 'SKIP: Index IX_orders_product_id already exists.';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_orders_payment_perf' 
      AND object_id = OBJECT_ID('dbo.orders')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_orders_payment_perf 
    ON dbo.orders(payment_method, order_value);
    
    PRINT 'SUCCESS: Index IX_orders_payment_perf created.';
END
ELSE
BEGIN
    PRINT 'SKIP: Index IX_orders_payment_perf already exists.';
END
GO

-------------------------------------------------------------------------------------
-- PART 2 : foundational query - AOV & revenue by payment method and city tier 
-- (identifing the consumer payemnt behaviors)
-------------------------------------------------------------------------------------

PRINT '-> running query 1: AOV & Revenue by payment method and city tier..'
SELECT 
	c.city_tier,
	o.payment_method,
	count(o.order_id) AS total_orders, 
	SUM(o.order_value) AS total_revenue_inr, 
	AVG(o.order_value) AS average_order_value_aov
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.city_tier, O.payment_method
ORDER BY c.city_tier, total_revenue_inr DESC;
GO

-------------------------------------------------------------------------------------
-- PART 3 : Intermediate query - the "No go zone"
-- (pinpoint where discounts creates toxic product return rates)
-------------------------------------------------------------------------------------

PRINT '-> running query 2: return rates v/s discount depth...'
SELECT 
    p.category,
    o.discount_pct,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_value) AS gross_revenue,
    ROUND(CAST(SUM(o.return_flag)AS DECIMAL(10,2)) / COUNT(o.order_id)* 100, 2)AS return_rate_percentage
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category, o.discount_pct
ORDER BY p.category, o.discount_pct;
GO

-------------------------------------------------------------------------------------
--PART 4 : Advanced Query A - algorithmic RFM(recency,frequency,monetary)
-- (Using statistical quintiles [NTILE] to isolate high-value cohorts)
-------------------------------------------------------------------------------------

PRINT '-> running query 3: RFM customer segmentation..';
WITH CustomerMetrics AS (
    SELECT
        customer_id,
        DATEDIFF(day, MAX(order_date), (SELECT MAX(order_date) FROM orders)) AS recency_days, -- measuring elapsed time since last order
        COUNT(order_id) AS frequency_count,
        SUM(order_value) AS total_monetary_value
    FROM orders
    GROUP BY customer_id
),

RFMScoring AS (
    SELECT
         customer_id,
         recency_days,
         frequency_count,
         total_monetary_value,
         -- 1-5 score, lower recency are better, orders DESC
         NTILE(5) OVER (ORDER BY recency_days DESC) AS R_Score,
         NTILE(5) OVER (ORDER BY frequency_count ASC) AS F_Score,
         NTILE(5) OVER (ORDER BY total_monetary_value ASC) AS M_Score
    FROM CustomerMetrics
)

SELECT TOP 50
    customer_id,
    recency_days,
    frequency_count,
    total_monetary_value,
    R_Score,
    F_Score,
    M_Score,
    (R_Score + F_Score + M_Score) AS total_rfm_score,
    CASE
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'CORE POWER USERS'
        WHEN R_Score <= 2 AND F_Score >= 3 THEN 'AT RISK / SLIPPING LOYAL CUSTOMERS'
        WHEN R_Score >= 4 AND F_Score = 1 THEN 'NEW PROMISING SIGNUPS'
        ELSE 'REGULAR MARKET PLACE BROWSERS'
    END AS customer_segment
FROM RFMScoring
ORDER BY total_monetary_value DESC;
GO

-------------------------------------------------------------------------------------
--PART 5 : Advanced Query B - Master month on month cohort retention
-- (calculating customers lifetime value via time series cohort analysis)
-------------------------------------------------------------------------------------

PRINT '-> running query 4: month on month cohort retention matrix...';
WITH CustomerFirstPurchase AS (
    SELECT 
        customer_id,
        DATEADD(MONTH, DATEDIFF(MONTH, 0, MIN(order_date)), 0) AS cohort_month 
        -- normalise date to the absolute first day of the order month
    FROM orders
    GROUP BY customer_id
),

Orderlog AS (
    SELECT
        o.customer_id,
        cfp.cohort_month,
        DATEADD(MONTH, DATEDIFF(MONTH, 0, o.order_date), 0) AS current_order_month,
        DATEDIFF(MONTH, cfp.cohort_month, DATEADD(MONTH, DATEDIFF(MONTH, 0, o.order_date), 0)) AS month_number
        -- determin exact months between cohort start and subsequent purchase
    FROM orders o
    JOIN CustomerFirstPurchase cfp ON o.customer_id = cfp.customer_id
),

CohortSizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS total_cohort_size
    FROM CustomerFirstPurchase
    GROUP BY cohort_month
),

RetentionCounts AS(
    SELECT 
        o.cohort_month,
        o.month_number,
        COUNT(DISTINCT o.customer_id) AS active_customers
    FROM OrderLog o
    GROUP BY o.cohort_month, o.month_number
)

SELECT
    FORMAT(r.cohort_month, 'yyyy-MM') AS Cohort,
    cs.total_cohort_size AS [Starting Cohort Size],
    r.month_number AS [Months Elapsed],
    r.active_customers AS [Returning Customers],
    ROUND(CAST(r.active_customers AS DECIMAL(10,2)) / cs.total_cohort_size * 100, 2) AS [Retention %]
FROM RetentionCounts r
JOIN CohortSizes cs ON r.cohort_month = cs.cohort_month
WHERE r.month_number <= 6
-- evaluate half year lifecycle curve
ORDER BY r.cohort_month, r.month_number;

GO