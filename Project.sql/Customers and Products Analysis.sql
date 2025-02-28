-- Table descriptions
SELECT 'Customers' AS table_name, 
       13 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Customers
  
UNION ALL

SELECT 'Products' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Products

UNION ALL

SELECT 'ProductLine' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM ProductLine

UNION ALL

SELECT 'Orders' AS table_name, 
       7 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Orders

UNION ALL

SELECT 'OrderDetails' AS table_name, 
       5 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM OrderDetails

UNION ALL

SELECT 'Payments' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Payments

UNION ALL

SELECT 'Employees' AS table_name, 
       8 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Employees

UNION ALL

SELECT 'Offices' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Offices;
  
  -- Low stock
  
SELECT productCode, low_stock
FROM (
  SELECT productCode, 
         ROUND(SUM(quantityOrdered) * 1.0 / 
               (SELECT quantityInStock
                  FROM products p
                 WHERE od.productCode = p.productCode), 2) AS low_stock
    FROM orderdetails od
   GROUP BY productCode
   ORDER BY low_stock DESC
)
WHERE ROWNUM <= 10;

 -- Product performance
 
 SELECT productCode
FROM (
    SELECT productCode, 
           SUM(quantityOrdered * priceEach) AS prod_perf
    FROM orderdetails od
    GROUP BY productCode
    ORDER BY prod_perf DESC
)
WHERE ROWNUM <= 10;

----- Priority Products for restocking

WITH low_stock_table AS (
  SELECT productCode, 
         ROUND(SUM(quantityOrdered) * 1.0 / 
               (SELECT quantityInStock
                  FROM products p
                 WHERE od.productCode = p.productCode), 2) AS low_stock
    FROM orderdetails od
   GROUP BY productCode
), 

products_to_restock AS (
  SELECT productCode, 
         SUM(quantityOrdered * priceEach) AS prod_perf
    FROM orderdetails od
   WHERE productCode IN (SELECT productCode
                           FROM low_stock_table)
   GROUP BY productCode
)

SELECT productName, productLine
  FROM products p
 WHERE productCode IN (
     SELECT productCode
       FROM (
           SELECT productCode
             FROM products_to_restock
            ORDER BY prod_perf DESC
       )
     WHERE ROWNUM <= 10
);

-- Revenue by customer
SELECT o.customerNumber, 
       SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber;

---Top 5 VIP customers

WITH money_in_by_customer_table AS (
  SELECT o.customerNumber, 
         SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
    FROM products p
    JOIN orderdetails od
      ON p.productCode = od.productCode
    JOIN orders o
      ON o.orderNumber = od.orderNumber
   GROUP BY o.customerNumber
)

SELECT contactLastName, 
       contactFirstName, 
       city, 
       country, 
       mc.revenue
  FROM customers c
  JOIN money_in_by_customer_table mc
    ON mc.customerNumber = c.customerNumber
 WHERE ROWNUM <= 5
 ORDER BY mc.revenue DESC;


-- Top 5 less engaging customers

WITH money_in_by_customer_table AS (
  SELECT o.customerNumber, 
         SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
    FROM products p
    JOIN orderdetails od
      ON p.productCode = od.productCode
    JOIN orders o
      ON o.orderNumber = od.orderNumber
   GROUP BY o.customerNumber
)

SELECT contactLastName, 
       contactFirstName, 
       city, 
       country, 
       mc.revenue
  FROM customers c
  JOIN money_in_by_customer_table mc
    ON mc.customerNumber = c.customerNumber
WHERE ROWNUM <= 5
ORDER BY mc.revenue DESC;

-- Customer LTV
WITH 

money_in_by_customer_table AS (
  SELECT o.customerNumber, 
         SUM(quantityOrdered * (priceEach - buyPrice)) AS revenue
    FROM products p
    JOIN orderdetails od
      ON p.productCode = od.productCode
    JOIN orders o
      ON o.orderNumber = od.orderNumber
   GROUP BY o.customerNumber
)

SELECT AVG(mc.revenue) AS ltv
  FROM money_in_by_customer_table mc;
