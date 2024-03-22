
# Walmart Sales Database Analysis

This repository contains SQL queries and analysis for the Walmart sales database. The database includes sales data with various attributes such as invoice ID, branch, city, customer type, gender, product line, unit price, quantity, tax percentage, total, date, time, payment method, COGS, gross margin percentage, gross income, and customer ratings.

###  The Detailed SQL queries are added in Data Analysis SQL Project.sql. Also you can take a glimpse of the project in README section.

```markdown


## Database Creation

The database "walmartSales" was created to store sales data. The "sales" table was designed with specific columns to capture relevant information about each sale.

```sql
CREATE DATABASE IF NOT EXISTS walmartSales;

DROP TABLE IF EXISTS sales;
CREATE TABLE sales(
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);
```

## Feature Engineering

### Time of Day
A new column "TimePeriod" was added to categorize sales times into morning, afternoon, and evening based on the time of day.

```sql
-- Adding new column TimePeriod
ALTER TABLE sales
ADD COLUMN TimePeriod VARCHAR(15);

-- Populating rows into column TimePeriod
UPDATE sales
SET TimePeriod = CASE 
    WHEN time >= '00:00:00' AND time <= '12:00:00' THEN 'Morning'
    WHEN time > '12:00:00' AND time <= '16:00:00' THEN 'Afternoon'
    WHEN time > '16:00:00' AND time <= '23:59:59' THEN 'Evening'
    ELSE time
END;
```

### Day and Month Names
Additional columns "Day_Name" and "Month_Name" were added to extract and store the day name and month name from the date column, respectively.

```sql
-- Adding Day_Name column
ALTER TABLE sales
ADD COLUMN Day_Name VARCHAR(15);

-- Updating Day_Name column with day names
UPDATE sales
SET Day_Name = DAYNAME(date);

-- Adding Month_Name column
ALTER TABLE sales
ADD COLUMN Month_Name VARCHAR(15);

-- Updating Month_Name column with month names
UPDATE sales
SET Month_Name = MONTHNAME(date);
```

## Exploratory Data Analysis (EDA)

### Generic Analysis

#### Unique Cities
Identified 3 unique cities in the data with their respective counts of occurrence.

```sql
SELECT city, COUNT(city) AS CityCount 
FROM sales
GROUP BY city;
```

#### Branch Cities
Explored the cities where each branch operates.

```sql
SELECT DISTINCT city, branch
FROM sales
ORDER BY branch;
```

```sql
-- Alternatively
SELECT city, branch
FROM sales
GROUP BY branch, city
ORDER BY branch;
```

### Product Analysis

#### Unique Product Lines
Determined the number of unique product lines in the data.

```sql
SELECT product_line, COUNT(product_line) AS ProductCount
FROM sales
GROUP BY product_line;
```

#### Most Common Payment Method
Identified the most common payment method.

```sql
SELECT payment, COUNT(payment) AS PaymentCount
FROM sales
GROUP BY payment
ORDER BY PaymentCount DESC;
```

#### Most Selling Product Line
Identified the product line with the highest sales volume.

```sql
WITH ProdRanking AS (
    SELECT product_line, RANK() OVER (ORDER BY COUNT(product_line) DESC) AS Rank
    FROM sales
    GROUP BY product_line
)
SELECT product_line
FROM ProdRanking
WHERE Rank = 1;
```

### Customer Analysis

#### Gender Distribution
Examined the gender distribution among customers.

```sql
SELECT gender, COUNT(gender) AS GenderCount
FROM sales
GROUP BY gender
ORDER BY GenderCount DESC;
```

### Sales Data Analysis

#### Rating Analysis
Investigated customer ratings based on time periods and branches.

```sql
-- Overall Rating Analysis
SELECT TimePeriod, COUNT(rating) AS TotalRating
FROM sales 
GROUP BY TimePeriod
ORDER BY TotalRating DESC;
```

```sql
-- Rating Analysis per Branch
SELECT branch, TimePeriod, COUNT(rating) AS TotalRating
FROM (
    SELECT branch, TimePeriod, AVG(rating) AS AvgRating
    FROM sales 
    GROUP BY TimePeriod, branch
) AS RatingData
GROUP BY branch, TimePeriod;
```

## Revenue And Profit Calculations

### Total Revenue by Month
Calculated the total revenue by month and ranked months based on revenue.

```sql
SELECT Month_Name, SUM(total) AS TotalRevenue
FROM sales
GROUP BY Month_Name
ORDER BY TotalRevenue DESC;
```

### Total COGS by Month
Calculated the total cost of goods sold (COGS) by month and ranked months based on COGS.

```sql
SELECT Month_Name, SUM(cogs) AS TotalCOGS
FROM sales
GROUP BY Month_Name
ORDER BY TotalCOGS DESC;
```

### Total Gross Income by Month
Calculated the total gross income by month and ranked months based on gross income.

```sql


```markdown
### Total Gross Income by Month
Calculated the total gross income by month and ranked months based on gross income.

```sql
SELECT Month_Name, SUM(gross_income) AS TotalGrossIncome
FROM sales
GROUP BY Month_Name
ORDER BY TotalGrossIncome DESC;
```

### Product Line with Highest Revenue
Identified the product line that generated the highest revenue.

```sql
WITH ProductRevenue AS (
    SELECT product_line, SUM(total) AS TotalRevenue
    FROM sales
    GROUP BY product_line
)
SELECT product_line
FROM ProductRevenue
WHERE TotalRevenue = (SELECT MAX(TotalRevenue) FROM ProductRevenue);
```

### City with Highest Revenue
Identified the city that generated the highest revenue.

```sql
WITH CityRevenue AS (
    SELECT city, SUM(total) AS TotalRevenue
    FROM sales
    GROUP BY city
)
SELECT city
FROM CityRevenue
WHERE TotalRevenue = (SELECT MAX(TotalRevenue) FROM CityRevenue);
```

### Product Line with Highest VAT
Identified the product line with the highest Value Added Tax (VAT) percentage.

```sql
WITH ProductVAT AS (
    SELECT product_line, AVG(tax_pct) AS AvgVAT
    FROM sales
    GROUP BY product_line
)
SELECT product_line
FROM ProductVAT
WHERE AvgVAT = (SELECT MAX(AvgVAT) FROM ProductVAT);
```

### Customer Type with Highest VAT Payments
Identified the customer type that makes the highest VAT payments on average.

```sql
WITH CustomerVAT AS (
    SELECT customer_type, AVG(tax_pct) AS AvgVAT
    FROM sales
    GROUP BY customer_type
)
SELECT customer_type
FROM CustomerVAT
WHERE AvgVAT = (SELECT MAX(AvgVAT) FROM CustomerVAT);
```

### Branch with Highest Sales
Identified the branch that had sales quantity higher than the average sales quantity across all branches.

```sql
WITH AvgSales AS (
    SELECT AVG(quantity) AS AvgSalesQty
    FROM sales
)
SELECT branch
FROM (
    SELECT branch, AVG(quantity) AS AvgBranchSales
    FROM sales
    GROUP BY branch
) AS BranchSales
CROSS JOIN AvgSales
WHERE AvgBranchSales > AvgSalesQty;
```

### Most Common Product Line by Gender
Identified the most common product line purchased by each gender.

```sql
SELECT gender, product_line, COUNT(*) AS TotalPurchases
FROM sales
GROUP BY gender, product_line
ORDER BY TotalPurchases DESC;
```

### Average Rating of Each Product Line
Calculated the average rating of each product line.

```sql
SELECT product_line, AVG(rating) AS AvgRating
FROM sales
GROUP BY product_line
ORDER BY AvgRating DESC;
```

### Best Day for Ratings
Identified the day of the week with the best average ratings.

```sql
SELECT Day_Name, AVG(rating) AS AvgRating
FROM sales
GROUP BY Day_Name
ORDER BY AvgRating DESC;
```

### Best Day for Ratings per Branch
Identified the day of the week with the best average ratings for each branch.

```sql
WITH BranchRatings AS (
    SELECT branch, Day_Name, AVG(rating) AS AvgRating,
           RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS RatingRank
    FROM sales
    GROUP BY branch, Day_Name
)
SELECT branch, Day_Name, AvgRating
FROM BranchRatings
WHERE RatingRank = 1;
```

### Summary
- Explored various aspects of the Walmart sales database including customer demographics, product analysis, revenue calculations, and ratings analysis.
- Identified trends such as the most common payment methods, popular product lines, and the best days for ratings.
- Calculated total revenue, gross income, and analyzed VAT payments by customer types and product lines.
- Determined the branch with higher-than-average sales and examined customer purchasing behavior based on gender.
```
