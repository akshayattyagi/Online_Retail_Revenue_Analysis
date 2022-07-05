
create database retail;
use retail;
CREATE TABLE brands
(
  product_id VARCHAR(150) NOT NULL,
  brand VARCHAR(150),
  PRIMARY KEY     (product_id)
); 
select * from brands;
update brands set brand = "None" WHERE brand = "";
CREATE TABLE finance
(
  product_id VARCHAR(150) NOT NULL,
  listing_price float , sale_price float, discount float,
  revenue float,
  PRIMARY KEY     (product_id)
); 

CREATE TABLE info
(
  product_id VARCHAR(150) NOT NULL,
  product_name varchar(150),
  description varchar(500),
  brand VARCHAR(150),
  PRIMARY KEY     (product_id)
); 

CREATE TABLE reviews
(
  product_id VARCHAR(150) NOT NULL,
  product_name VARCHAR(150),rating	float,reviews	float,
  
  PRIMARY KEY     (product_id)
); 

CREATE TABLE traffic
(
  product_id VARCHAR(150) NOT NULL,
  last_visited	timestamp,
  PRIMARY KEY     (product_id)
); 
-- 1 joining all the data as a single table
select  * from brands
inner join finance
using(product_id)
inner join info
using(product_id)
inner join reviews
using(product_id)
inner join traffic
using(product_id)
;
-- 2 select no of products of diff  price
SELECT brand, listing_price , COUNT(*) as count
from  finance
INNER JOIN brands 
    ON finance.product_id = brands.product_id
    WHERE listing_price > 0
    GROUP BY brand,listing_price
order by COUNT(*) desc ;

-- 3 Labeling price ranges


SELECT brands.brand as brand, COUNT(*) as count , SUM(revenue) as total_revenue,
CASE WHEN listing_price < 42 THEN 'Budget'
    WHEN listing_price >= 42 AND listing_price < 74 THEN 'Average'
    WHEN listing_price >= 74 AND listing_price < 129 THEN 'Expensive'
    ELSE 'Elite' END AS price_category
FROM finance 
INNER JOIN brands 
    ON finance.product_id = brands.product_id
where brand != "None"
GROUP BY brand, price_category
ORDER BY total_revenue DESC;

-- 4 Average discount by brand
SELECT b.brand, AVG(f.discount) *100 AS average_discount
FROM brands as b
INNER JOIN finance as f 
    ON b.product_id = f.product_id
where brand != "None"
GROUP BY b.brand
ORDER BY average_discount;

-- 5 Correlation between revenue and reviews
SELECT corr(r.reviews, f.revenue) AS review_revenue_corr
FROM reviews as r
INNER JOIN finance as f
    ON r.product_id = f.product_id;
    
-- 6 no of reviews per brand 

select b.brand,sum(r.reviews) as reviews
from reviews as r
inner join brands as b
on r.product_id=b.product_id
where brand !="None"
group by brand;

-- 7 no  of reviews per month for each brand in diff years 
select b.brand,month(t.last_visited) as Month, year(t.last_visited) as Year,count(r.reviews) as reviews
from brands as b
inner join reviews as r
using(product_id)
inner join traffic as t
using(product_id)
Where Month(t.last_visited) is not null  and  brand != "None"
group by brand,Month,Year
order by brand,Month,Year;

-- 8 categories the products in diff  sales title

SELECT b.brand, f.discount, COUNT(*) as count , SUM(f.revenue) as total_revenue,
CASE WHEN discount < 0.5 and discount>0.0 THEN 'Upto 50% sale'
    WHEN discount = 0.5 THEN 'Flat 50% sale'
    WHEN discount = 0.0 THEN 'NO sale'
    WHEN discount > 0.5  THEN 'Best Deals'
    END AS Sale_Title
FROM finance as f
INNER JOIN brands as b
    ON f.product_id = b.product_id
where brand != "None"
GROUP BY brand, Sale_Title
ORDER BY total_revenue DESC;

-- 9 Finding maximum average discount using CTE
with avgs  as (select b.brand,avg(f.listing_price) as avg_listing_price ,avg(f.sale_price) as Avg_sales_price,
avg(f.discount) as avg_discount
 from brands as b
 inner join finance as f
 using(product_id)
 where brand!="None"
 group by brand) 
select brand, max(avg_listing_price) from avgs;
