USE meesho_paytm_db
GO

PRINT '>> Inserting Data Into: customers';
BULK INSERT customers
FROM 'D:\Project\Meesho-Paytm project guide\customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


PRINT '>> Inserting Data Into: resellers';
BULK INSERT resellers
FROM 'D:\Project\Meesho-Paytm project guide\resellers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


PRINT '>> Inserting Data Into: products';
BULK INSERT products
FROM 'D:\Project\Meesho-Paytm project guide\products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


PRINT '>> Inserting Data Into: orders';
BULK INSERT orders
FROM 'D:\Project\Meesho-Paytm project guide\orders.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


PRINT '>> Inserting Data Into: payment_events';
BULK INSERT payment_events
FROM 'D:\Project\Meesho-Paytm project guide\payment_events.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);