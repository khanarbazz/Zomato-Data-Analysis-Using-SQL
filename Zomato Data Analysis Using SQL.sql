create database Zomato_db;
use Zomato_db;

-- Create goldusers_signup table
CREATE TABLE goldusers_signup (
    userid INTEGER,
    gold_signup_date DATE
);

-- Insert data into goldusers_signup table
INSERT INTO goldusers_signup (userid, gold_signup_date) VALUES
(1, '2017-09-22'),
(3, '2017-04-21');

-- Drop users table if it exists and create it
CREATE TABLE users (
    userid INTEGER,
    signup_date DATE
);

-- Insert data into users table
INSERT INTO users (userid, signup_date) VALUES
(1, '2014-09-02'),
(2, '2015-01-15'),
(3, '2014-04-11');

-- Drop sales table if it exists and create it
CREATE TABLE sales (
    userid INTEGER,
    created_date DATE,
    product_id INTEGER
);

-- Insert data into sales table
INSERT INTO sales (userid, created_date, product_id) VALUES
(1, '2017-04-19', 2),
(3, '2019-12-18', 1),
(2, '2020-07-20', 3),
(1, '2019-10-23', 2),
(1, '2018-03-19', 3),
(3, '2016-12-20', 2),
(1, '2016-11-09', 1),
(1, '2016-05-20', 3),
(2, '2017-09-24', 1),
(1, '2017-03-11', 2),
(1, '2016-03-11', 1),
(3, '2016-11-10', 1),
(3, '2017-12-07', 2),
(3, '2016-12-15', 2),
(2, '2017-11-08', 2),
(2, '2018-09-10', 3);

-- Drop product table if it exists and create it
CREATE TABLE product (
    product_id INTEGER,
    product_name TEXT,
    price INTEGER
);

-- Insert data into product table
INSERT INTO product (product_id, product_name, price) VALUES
(1, 'p1', 980),
(2, 'p2', 870),
(3, 'p3', 330);

-- Select statements to display the data in the tables
SELECT * FROM sales;
SELECT * FROM product;
SELECT * FROM goldusers_signup;
SELECT * FROM users;

#######################     ANALYSIS    ##########################

##1.what is total amount each customer spent on zomato ?

select userid,
        sum(price) as amount
from sales as s 
		inner join product as p
		on s.product_id=p.product_id
Group by userid
order by amount desc;

##2.How many days has each customer visited zomato?

select userid,
       count(distinct(created_date))  "Num.of days Visit"
from sales
group by userid
;


##3.what was the first product purchased by each customer?


select userid,
product_name
from (
		select userid,
               product_name,
			   row_number() over(partition by s.userid order by s.created_date asc) as Ranks
		from sales s
              inner join product p
              on s.product_id=p.product_id
				) as 	I
where ranks=1;


##4.what is most purchased item on menu & how many times was it purchased by all customers ?


with Top_product as (
					select product_id,
							count(product_id)
					from sales
							group by product_id
							order by count(product_id) desc
							limit 1)
select userid,
       count(userid) 'Number of times purchased this product',
       product_id
from sales
		where product_id in (
		select product_id
		from top_product)
group by userid,product_id;


##5.which item was most popular for each customer?


SELECT userid,
       product_id,
       product_count
FROM (
    SELECT userid,
           product_id,
           COUNT(product_id) AS product_count,
           ROW_NUMBER() OVER (PARTITION BY userid ORDER BY COUNT(product_id) DESC) AS rnk
    FROM sales
    GROUP BY userid, product_id
) AS ranked_products
WHERE rnk = 1;


##6.which item was purchased first by customer after they become a member ?

select userid,
       product_id,
       product_name
from(
	select userid,
		   s.product_id,
		   product_name,
	       row_number() over(partition by userid order by created_date asc) as Ord_date
	from sales s
	       inner join product p
		   on s.product_id=p.product_id
) as I
where ord_date=1;


##7. which item was purchased just before the customer signup for golden membership?

select s.userid,
	   created_date,
       gold_signup_date
from sales as s
	inner join goldusers_signup as g
	on s.userid=g.userid
	where created_date < gold_signup_date
    order by userid;


##8. what is total orders and amount spent for each member before they become a member?


select s.userid,
	   count(s.product_id) as total_orders,
	   sum(price) as Amount_spend
from sales s
	   inner join goldusers_signup as g
	   on s.userid=g.userid
	   inner join product as p
	   on s.product_id=p.product_id
where created_date > gold_signup_date
group by userid;



##9. rnk all transaction of the customers

select userid,
	   price as Transactions,
	   dense_rank() over(partition by userid order by price desc) as Ranks
from sales s
	   inner join product p
	   on s.product_id=p.product_id;
       






       

  










