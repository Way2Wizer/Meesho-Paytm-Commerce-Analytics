# 🛒 Cash vs. Cashless: Meesho x Paytm Adoption Strategy

### Tools Used: Python, SQL Server (T-SQL), Power BI

## 📌 The Business Problem
> E-commerce platforms targeting Tier 2 and Tier 3 markets historically struggle with the logistics costs of Cash on Delivery (COD). This project simulates a strategic partnership between a reseller-driven marketplace (Meesho proxy) and a digital payments layer (Paytm proxy) to analyze the tipping point where digital adoption becomes highly profitable.

---

## 🐍 [Data Generation](Data_Generation/)
*Note: As transaction-level data for these companies is proprietary, I engineered a parameter-grounded synthetic dataset mimicking real-world e-commerce behaviors.*

> The custom Python notebook ([`Data_Generation.ipynb`](Data_Generation/Data_Generation.ipynb)) builds this dataset from scratch. 
> It utilizes `Faker`, `Pandas`, and `Numpy` to simulate 10,000+ orders, injecting business logic such as higher COD probabilities in Tier 3 cities and realistic return-rate elasticity based on discount depths.

## 💾 [Database (Raw Data)](Database/)
The simulated outputs were exported as flat files for database ingestion. 
> Contains the 5 core relational tables: [`customers.csv`](Database/customers.csv), [`orders.csv`](Database/orders.csv), [`payment_events.csv`](Database/payment_events.csv), [`products.csv`](Database/products.csv), and [`resellers.csv`](Database/resellers.csv).

## ⚙️ [SQL Architecture & Analytics](SQL/)
This directory contains the T-SQL scripts used to construct the backend and extract business insights.
>> **Architecture:** Executed [`Database_&_Schema.sql`](SQL/Database_&_Schema.sql) to build a normalized 5-table relational schema with primary/foreign key constraints. 
>> **Data Loading:** Utilized `BULK INSERT` via [`proc_load.sql`](SQL/proc_load.sql) and [`CSV_import.sql`](SQL/CSV_import.sql) to efficiently populate the database.
>> **Advanced Analytics:** 
  > Built native **RFM Customer Segmentation** using `NTILE()` window functions to categorize users into high-value and churn-risk cohorts.
  > Engineered a dynamic, month-on-month **Cohort Retention Matrix** using advanced date-part truncation (`DATEADD`, `DATEDIFF`).

## 📊 [Executive Dashboard](Dashboard_powerbi/)
The final business intelligence layer designed for product and executive stakeholders. 
> **Live File:** [`meesho_paytm.pbix`](Dashboard_powerbi/meesho_paytm.pbix)
> **Static Export:** [`meesho_paytm - Power BI.pdf`](Dashboard_powerbi/meesho_paytm%20-%20Power%20BI.pdf)

---

## 💡 Key Business Insights
1. **The Promo No-Go Zone:** The data reveals a strict threshold—offering a 20% discount drives up order volume, but the product return rate spikes to a toxic level, eroding logistics margins.
2. **Digital Payment Lift:** Digital payments (UPI/Wallet) yield a consistently higher Average Order Value (AOV) compared to COD across all city tiers, proving the ROI of funding cashback campaigns.
