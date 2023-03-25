-- #2 to find the number of new and repeated customers on a given order date
-- create a table
CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  order_date datetime NOT NULL,
  order_amount INTEGER NOT NULL
);
-- insert some values
INSERT INTO orders VALUES (1, 100, '2022-01-01', 2000);
INSERT INTO orders VALUES (2, 200, '2022-01-01', 2500);
INSERT INTO orders VALUES (3, 300, '2022-01-01', 4500);

INSERT INTO orders VALUES (4, 100, '2022-01-02', 2200);
INSERT INTO orders VALUES (5, 400, '2022-01-02', 2700);
INSERT INTO orders VALUES (6, 500, '2022-01-02', 5500);

INSERT INTO orders VALUES (7, 100, '2022-01-03', 2700);
INSERT INTO orders VALUES (8, 400, '2022-01-03', 3500);
INSERT INTO orders VALUES (9, 600, '2022-01-03', 5500);

-- your query
with first_visit as (
select customer_id, min(order_date) as min_order_date from orders
group by customer_id),
visit_flag as (
select od.* , fv.min_order_date,
case when od.order_date = fv.min_order_date then 1 else 0 end as first_visit_flag,
case when od.order_date != fv.min_order_date then 1 else 0 end as repeated_visit_flag
from orders od
JOIN first_visit fv
ON od.customer_id = fv.customer_id)
select order_date,
sum(first_visit_flag) as no_of_new_customers,
sum(repeated_visit_flag) as no_of_repeated_customers,
sum(case when first_visit_flag = 1 then order_amount else 0 end) as first_visit_order_amount,
sum(case when repeated_visit_flag = 1 then order_amount else 0 end) as repeat_visit_order_amount
from visit_flag 
group by order_date
order by order_date;

-- #3 To find total floor visits, max floor visits , resources used by each employee
--create
create table entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));

--insert
insert into entries 
values ('A','Bangalore','A@gmail.com',1,'CPU'),('A','Bangalore','A1@gmail.com',1,'CPU'),('A','Bangalore','A2@gmail.com',2,'DESKTOP')
,('B','Bangalore','B@gmail.com',2,'DESKTOP'),('B','Bangalore','B1@gmail.com',2,'DESKTOP'),('B','Bangalore','B2@gmail.com',1,'MONITOR');

--your query
WITH most_floor as (
SELECT x.name,
x.floor as most_visited_floor
FROM (SELECT 
name,
floor,
count(1) as floor_count,
RANK() over(PARTITION BY name ORDER BY count(1) desc) as rank_max_floor
FROM entries 
GROUP BY name, floor) x
WHERE x.rank_max_floor = 1
),
distinct_resources as ( 
SELECT r.name, string_agg(r.resources,',') as resources_used
FROM (SELECT name, resources
FROM entries GROUP BY name, resources) r group by name)
SELECT tv.name, 
tv.total_visits,
mf.most_visited_floor,
dr.resources_used
FROM most_floor mf
JOIN (SELECT name, count(1) as total_visits 
FROM entries 
GROUP BY name ) tv
ON mf.name = tv.name 
JOIN distinct_resources dr
ON mf.name = dr.name   