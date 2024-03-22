CREATE DATABASE IF NOT EXISTS walmartSales;

drop table if exists sales;
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

select * from sales 
where 1 = 0; 

--------------------------------------------------------------

------------------ Feature Engineering------------------------

-- time of day

select time,
		case 
			when time  >= '00:00:00' and time <= '12:00:00' then "Morning"
            when time  > '12:00:00' and time <= '16:00:00' then "Afternoon"
            when time  > '16:00:00' and time <= '23:59:59' then "Evening"
            else time
            end as new_time
from sales;

-- Adding new column
alter table sales
add column TimePeriod varchar(15);

-- populating rows into colums TimePeriod
update sales
set TimePeriod = (case 
			when time  >= '00:00:00' and time <= '12:00:00' then "Morning"
            when time  > '12:00:00' and time <= '16:00:00' then "Afternoon"
            when time  > '16:00:00' and time <= '23:59:59' then "Evening"
            else time
            end);
            
select * from sales;


------ Day_Name

select date, dayname(date)
from sales;

alter table sales
add column Day_Name varchar(15);

update sales
set Day_Name = (dayname(date));
            
----------- Month_Name----------

select date, monthname(date) from sales;

alter table sales
add column Month_Name varchar(15);

update sales
set Month_Name = (monthname(date));
            
----------------------------------------

------ Exploratory Data Analysis(EDA) ----------------

---------- Generic---------------------------------
-- 1. How many unique cities does the data have?

select city, count(city) 
from sales
group by city;

-- Ans 3 Unique cities with count of occurance 
-----------------------------------------------
-- 2. In which city is each branch?

select * from sales;

select city,branch from sales
group by branch, city
order by branch;

-- or

select distinct(city), branch
from sales;

---------------------------------------------------

---------------- Product --------------------
-- How many unique product lines does the data have?

select product_line, count(product_line)
from sales
group by product_line;

-- What is the most common payment method?

select payment,count(payment) MostCommonPaymentMethod
from sales
group by payment
order by MostCommonPaymentMethod desc;

-- What is the most selling product line?

with Prod_ranking (line,ranking) as
(
select product_line,
rank() over (order by count(product_line) desc) ranking
from sales
group by product_line
)
select line
from Prod_ranking
where ranking = 1;

-- What is the total revenue by month?


select Month_Name, 
sum(total),
rank() over (order by sum(total) desc)
from sales
group by Month_Name;

-- What month had the largest COGS?

select Month_Name from 
(select Month_Name, max(cogs),
rank() over (order by max(cogs) desc) as r
from sales
group by Month_Name) as m
where m.r = 1;

-- What product line had the largest revenue?


select product_line,
sum(total) as sum
from sales 
group by product_line
order by sum desc;


-- What is the city with the largest revenue?

select city,
sum(total) as sum
from sales
group by city
order by sum desc;

-- What product line had the largest VAT?

select product_line,
avg(tax_pct) as AvgTax
from sales
group by product_line
order by AvgTax desc;


-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

with Avg_Sales_Per_ProdLine(Avg) as
(select 
avg(total) as Avg
from sales)
select sales.product_line,Avg_Sales_Per_ProdLine.Avg as totalAvg,avg(sales.total) as groupedAvg,
case
		when Avg_Sales_Per_ProdLine.Avg < avg(sales.total)  then 'Good'
        else 'Bad'
        end
        as AvgStatus
from Avg_Sales_Per_ProdLine, sales
group by sales.product_line;

-- Which branch sold more products than average product sold?

with AvgProd(avgSold) as
(
select avg(quantity)
from sales
)
select sales.branch, avg(sales.quantity) as avg,AvgProd.avgSold
from AvgProd, sales
group by sales.branch
having avg > AvgProd.avgSold;

-- What is the most common product line by gender
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line

select product_line,
avg(rating) AvgRating
from sales
group by product_line
order by AvgRating Desc;


-- ------------------------------------------Sales Data Analysis---------------------------------------------

-- 1. Number of sales made in each time of the day per weekday?

select TimePeriod,
count(quantity) as c
from sales
where Day_Name <> 'Saturday' and Day_Name <> 'Sunday'
group by TimePeriod
order by c;

-- 2. Which of the customer types brings the most revenue?

select customer_type from
		(select customer_type,
		sum(total) as totalSum
		from sales
		group by customer_type
		order by totalSum) 
		as s
where s.totalSum limit 1,1
;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?

select city from
(select city,
avg(tax_pct) as a
from sales
group by city
order by a desc) as pct
where pct.a limit 1
;

-- Which customer type pays the most in VAT?

select customer_type from
		(
        select customer_type,
		avg(tax_pct) as tax
		from sales
		group by customer_type
		order by tax desc
        ) as taxtbl
where taxtbl.tax limit 1;


-- ------------------------------------------ Customer Data Analysis---------------------------------------------

-- How many unique customer types does the data have?

select distinct(customer_type)
from sales;

-- How many unique payment methods does the data have?

select distinct(payment)
from sales;

-- What is the most common customer type?

select customer_type from
		(select customer_type,
		count(customer_type) as c
		from sales
		group by customer_type
		order by c desc) 
as CustCount
where c limit 1;


-- Which customer type buys the most?

select customer_type from
		(select customer_type,
		sum(quantity) as totalQty
		from sales
		group by customer_type
		order by totalQty Desc) 
as CustTotalBuy
where totalQty limit 1;

-- What is the gender of most of the customers?

select gender,
count(gender) as c
from sales
group by gender
order by c desc;

-- What is the gender distribution per branch?

select branch, gender,
count(gender) as GenderDistribution
from sales
group by gender,branch
order by branch;

-- Which time of the day do customers give most ratings?

select TimePeriod,
count(rating) as TotalRating
from sales 
group by TimePeriod
order by TotalRating Desc;

-- Which time of the day do customers give most ratings per branch?

select branch, TimePeriod, TotalRating
from    (select branch, TimePeriod,
		avg(rating) as TotalRating,
		rank() over (partition by branch order by avg(rating) desc) as r
		from sales 
		group by TimePeriod,branch) 
as newtbl
where r = 1;


-- Which day fo the week has the best avg ratings?

select Day_Name,
avg(rating) as AgvRating
from sales
group by Day_Name
order by AgvRating Desc;

-- Which day of the week has the best average ratings per branch?

with RatingTable(branch, Day_Name, AvgRating, Ranking) as
		(select branch, Day_Name, 
		avg(rating) as AvgRating,
		rank() over (partition by branch order by avg(rating) desc) as Ranking
		from sales 
		group by Day_Name,branch
		order by branch)
select branch, Day_Name, AvgRating from RatingTable
where Ranking = 1;

