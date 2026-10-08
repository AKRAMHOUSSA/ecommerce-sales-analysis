-- Data Cleaning

create table ec_sales
like ecommerce_sales_data;

insert ec_sales
select * from ecommerce_sales_data;

with duplicates as
( select *, row_number() over(partition by `Order ID`, `order date`, `customer name`, region, city, category, `Sub-Category` , 
                                      `product name`,quantity,`unit price`, discount, sales, profit,`Payment Mode`) as row_dup
from ec_sales) 
select * from duplicates
where row_dup >1;

 -- Verified: No duplicate records found.

 -- standardizing data
 
select *  from ec_sales
where profit is null
or profit= '';

SELECT * FROM ec_sales WHERE category != TRIM(category);

select distinct(category)
from ec_sales
order by category asc;

 -- (no blanks no nulls no trims founded)

alter table ec_sales
modify `order date` date;

select `order date`
from ec_sales
order by 1 asc;

  -- Exploratory Data

select round(SUM(profit),2) as profit,round(SUM(sales),2) as revenue, round(sum(profit)*100/sum(sales),2) as Overall_Profit_Margin
from ec_sales;

select category, round(sum(quantity),2) as sum_quantity,
     rank() over(order by round(sum(quantity),2) desc) as rank_sum_quantity
     from ec_sales
group by category;   -- quatity

select category, round(sum(sales),2) as total_sales ,
     rank() over(order by round(sum(sales),2) desc) as rank_sales_total
     from ec_sales
group by category;   -- sales

select category, round(sum(profit),2)  as total_profit ,
     rank() over(order by round(sum(profit),2) desc) as rank_profit_total
     from ec_sales
group by category;  -- profit

select `Sub-Category`, round(sum(sales),2) as total_sales, 
     rank() over(order by round(sum(sales),2) desc) as rank_total_sales
     from ec_sales
group by `Sub-Category`;      -- sales

select `Sub-Category`, round(sum(profit),2)  as total_profit, 
     rank() over(order by round(sum(profit),2) desc) as rank_total_profit
     from ec_sales
group by `Sub-Category`;  -- profit

select `Sub-Category`, round(sum(quantity),2)  as total_profit, 
     dense_rank() over(order by round(sum(quantity),2) desc) as rank_total_profit
     from ec_sales
group by `Sub-Category`;  -- quantity

select `Sub-Category`, round(sum(profit)*100/sum(sales), 2) as profit_margin
from ec_sales
group by `Sub-Category`
order by profit_margin desc; -- profit margin

select Category, round(sum(profit)*100/sum(sales), 2) as profit_margin
from ec_sales
group by Category
order by profit_margin desc;   -- profit margin

 -- customer performence 

SELECT purchase_count, COUNT(*) AS num_customers, 
       ROUND(COUNT(*) / (SELECT COUNT(DISTINCT `customer name`) FROM ec_sales) * 100, 2) AS pct_of_customers
FROM (
    SELECT `customer name`, COUNT(*) AS purchase_count
    FROM ec_sales
    GROUP BY `customer name`
) t
GROUP BY purchase_count
ORDER BY purchase_count DESC;

 -- REGION AND CITY PERFORMANCE

select region, count(*)
from ec_sales
group by region
ORDER BY count(*) DESC ;

select region, round(sum(profit),2) as sum_profit
from ec_sales
group by region
order by sum_profit desc;

select region, round(sum(sales),2) as sum_sales
from ec_sales
group by region
order by sum_sales desc;

SELECT region, `sub-category`, ROUND(SUM(profit),2) AS sum_total,
       RANK() OVER(PARTITION BY region ORDER BY ROUND(SUM(profit),2) DESC) AS rnk
FROM ec_sales
GROUP BY region, `sub-category`;

SELECT region, Category, ROUND(SUM(profit),2) AS sum_total,
       RANK() OVER(PARTITION BY region ORDER BY ROUND(SUM(profit),2) DESC) AS rnk
FROM ec_sales
GROUP BY region, Category;

SELECT region, `sub-category`, ROUND(SUM(sales),2) AS sum_total,
       RANK() OVER(PARTITION BY region ORDER BY ROUND(SUM(sales),2) DESC) AS rnk
FROM ec_sales
GROUP BY region, `sub-category`;

SELECT region, Category, ROUND(SUM(sales),2) AS sum_total,
       RANK() OVER(PARTITION BY region ORDER BY ROUND(SUM(sales),2) DESC) AS rnk
FROM ec_sales
GROUP BY region, Category;

SELECT region, `sub-category`, ROUND(SUM(profit),2) AS min_profit
FROM ec_sales
WHERE (region = 'North' AND `sub-category` = 'Puzzle')
   OR (region = 'South' AND `sub-category` = 'Spices')
GROUP BY region, `sub-category`;

 -- city 
 
select count(distinct city) as cities_total 
from ec_sales;

select city, count(*) as branch_total
from ec_sales
group by city
order by branch_total desc;

select city, round(sum(sales),2) as revenue
from ec_sales
group by city
order by revenue desc;

select city, round(sum(profit),2) as revenue
from ec_sales
group by city
order by revenue desc;

select city, category, round(sum(sales),2) as Profit_total,
       rank() over(partition by city order by round(sum(sales),2) desc) as rk
       from ec_sales
       group by city, category;
 
 select city, category, revenue_total, rk 
 from ( select city, category, round(sum(sales),2) as revenue_total,
       rank() over(partition by city order by round(sum(sales),2) desc) as rk
       from ec_sales
       group by city, category) as ff
 where rk = 1 
order by revenue_total desc;

select city, category, Profit_total, rk 
 from ( select city, category, round(sum(profit),2) as Profit_total,
       rank() over(partition by city order by round(sum(profit),2) desc) as rk
       from ec_sales
       group by city, category) as ff
 where rk = 1
order by Profit_total desc;

select city, category, revenue_total, rk 
 from ( select city, category, round(sum(sales),2) as revenue_total,
       rank() over(partition by city order by round(sum(sales),2) desc) as rk
       from ec_sales
       group by city, category) as ff
 where rk = 10  and Category = 'beauty'
order by revenue_total desc;

select city, category, Profit_total, rk 
 from ( select city, category, round(sum(profit),2) as Profit_total,
       rank() over(partition by city order by round(sum(profit),2) desc) as rk
       from ec_sales
       group by city, category) as ff
 where rk = 10
order by Profit_total desc;

select city, `Sub-Category`, round(sum(profit),2) as Profit_total,
       rank() over(partition by city order by round(sum(profit),2) desc) as rk
       from ec_sales
       group by city, `Sub-Category`;

with summ as (
select city, `Sub-Category`, Profit_total, rk 
 from ( select city, `Sub-Category`, round(sum(profit),2) as Profit_total,
       rank() over(partition by city order by round(sum(profit),2) desc) as rk
       from ec_sales
       group by city, `Sub-Category`) as ff
 where rk = 1  
order by Profit_total desc)

select `Sub-Category`, count(*)
from summ
group by `Sub-Category`;

with summ as (
select city, `Sub-Category`, Profit_total, rk 
 from ( select city, `Sub-Category`, round(sum(profit),2) as Profit_total,
       rank() over(partition by city order by round(sum(profit),2) desc) as rk
       from ec_sales
       group by city, `Sub-Category`) as ff
 where rk = 50  
order by Profit_total desc)

select `Sub-Category`, count(*)
from summ
group by `Sub-Category`;

with summ as (
select city, `Sub-Category`, revenue_total, rk 
 from ( select city, `Sub-Category`, round(sum(sales),2) as revenue_total,
       rank() over(partition by city order by round(sum(sales),2) desc) as rk
       from ec_sales
       group by city, `Sub-Category`) as ff
 where rk = 1 
order by revenue_total desc)

select `Sub-Category`, count(*)
from summ
group by `Sub-Category`;

with summ as (
select city, `Sub-Category`, revenue_total, rk 
 from ( select city, `Sub-Category`, round(sum(sales),2) as revenue_total,
       rank() over(partition by city order by round(sum(sales),2) desc) as rk
       from ec_sales
       group by city, `Sub-Category`) as ff
 where rk = 50 
order by revenue_total desc)

select `Sub-Category`, count(*)
from summ
group by `Sub-Category`;

 -- payment mode performance 

select `payment mode`, count(*) as total
from ec_sales
group by `payment mode`
order by total desc;

 -- sales  performance  over time 
 
select year(`order date`)as year_, round(sum(sales),2) as sales_total
from ec_sales
group by year_
order by sales_total desc ;

select year(`order date`)as year_, Category, round(sum(sales),2) as sales_total,
     rank() over(partition by year(`order date`) order by round(sum(sales),2) desc) as rank_
from ec_sales
group by year_, Category;

select year(`order date`)as year_, `Sub-Category`, round(sum(sales),2) as sales_total,
     rank() over(partition by year(`order date`) order by round(sum(sales),2) desc) as rank_
from ec_sales
group by year_, `Sub-Category`;

select year(`order date`)as year_, round(sum(profit),2) as profit_total
from ec_sales
group by year_
order by profit_total desc ;

select year(`order date`)as year_, Category, round(sum(profit),2) as profit_total,
     rank() over(partition by year(`order date`) order by round(sum(profit),2) desc) as rank_
from ec_sales
group by year_, Category;

select year(`order date`)as year_, `Sub-Category`, round(sum(profit),2) as profit_total,
     rank() over(partition by year(`order date`) order by round(sum(profit),2) desc) as rank_
from ec_sales
group by year_, `Sub-Category`;

 -- month performance 
 
  SELECT YEAR(`order date`) AS year_,
           MONTH(`order date`) AS month_,
           count(sales) AS sales_
    FROM ec_sales
    GROUP BY YEAR(`order date`), MONTH(`order date`)
    order by sales_ desc;

SELECT *,
       RANK() OVER(partition by year_ order BY sales_ DESC) AS month_rank
FROM ( 
    SELECT YEAR(`order date`) AS year_,
           MONTH(`order date`) AS month_,
           round(sum(sales),2) AS sales_
    FROM ec_sales
    GROUP BY YEAR(`order date`), MONTH(`order date`)
) t;

SELECT *,
       RANK() OVER(partition by year_ order BY profit_ DESC) AS month_rank
FROM ( 
    SELECT YEAR(`order date`) AS year_,
           MONTH(`order date`) AS month_,
           round(sum(profit),2) AS profit_
    FROM ec_sales
    GROUP BY YEAR(`order date`), MONTH(`order date`)
) t;
 
  -- correlation sales and discount
select * from ec_sales;

select `sub-category`, sum(Discount) as discount, round(sum(sales),2) as sales_
from ec_sales
group by `sub-category`
order by sales_ desc
limit 10;