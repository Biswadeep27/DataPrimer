-- airbnb problem

create table dbo.airbnb_searches 
(
user_id int,
date_searched date,
filter_room_types varchar(200)
);
delete from airbnb_searches;
insert into dbo.airbnb_searches values
(1,'2022-01-01','entire home,private room')
,(2,'2022-01-02','entire home,shared room,delux room')
,(3,'2022-01-02','private room,shared room')
,(4,'2022-01-03','private room')
;

SELECT * from airbnb_searches;


WITH room_rows AS (
    SELECT
        user_id,
        filter_room_types,
        0 as previous_delim_pos,
        CHARINDEX(',', filter_room_types) AS delim_pos  
    FROM airbnb_searches

    UNION ALL

    SELECT
        user_id,
        filter_room_types,
        delim_pos as previous_delim_pos,
        CHARINDEX(',', filter_room_types, delim_pos + 1) as delim_pos
    FROM room_rows
    WHERE delim_pos > 0
), 
split_rooms as (
SELECT 
user_id,
CASE when delim_pos > 0 then substring(filter_room_types, previous_delim_pos + 1, delim_pos - (previous_delim_pos + 1) )
	else substring(filter_room_types, previous_delim_pos + 1, len(filter_room_types) - previous_delim_pos) end as room_types from room_rows)
select room_types, count(*) as cnt from split_rooms 
group by room_types
order by cnt desc;






-- recursice CTE
create table sales (
product_id int,
period_start date,
period_end date,
average_daily_sales int
);

insert into sales values(1,'2019-01-25','2019-02-28',100),(2,'2018-12-01','2020-01-01',10),(3,'2019-12-01','2020-01-31',1);

SELECT  * from dbo.sales;

-- recursive cte to find yearly toatal sales for each product

with all_dates as (
	select min(period_start) as dates, max(period_end) as max_date from sales
	union all
	select DATEADD(day, 1, dates) as dates, max_date from all_dates 
	where dates < max_date
) select s.product_id , DATEPART(year, a.dates) as report_year, sum(s.average_daily_sales) as total_sales
from sales s inner join all_dates a on a.dates between s.period_start and s.period_end 
group by s.product_id , DATEPART(year, a.dates)
order by s.product_id
OPTION (maxrecursion 10000)


-- deleting duplicates

create table employee (
emp_id int,
emp_name nvarchar(max),
salary int,
create_timestamp datetime2(6)
)

-- drop table employee;

insert into employee 
values (1,'Ankit',15000,getdate());

select * from employee 


select emp_id, count(*) as cnt, min(create_timestamp) from employee group by emp_id having count(*) > 1

-- if there are distinguishable audit columns, we can deside which one to delete and rest of the records can be deleted
delete from employee where (emp_id, create_timestamp) in (select emp_id, min(create_timestamp) as create_timestamp from employee group by emp_id having count(*) > 1);

delete from employee where emp_id, create_timestamp  not in (select emp_id, max(create_timestamp) from employee group by emp_id) -- delete all except max timestamp

-- if we have identical rows in that case
-- approach 1:
-- take a backup 
-- delete the main table
-- select distinct records from temp table and dump into main table

-- approach 2:
-- asign row_number partition by each duplicate attrbute combination and filter only one row_number

insert into employee 
select emp_id, emp_name, salary, create_timestamp 
from (select *, row_number(partition by emp_id order by salary) as rnk from backup_table ) where rnk = 1


-- fast and last value function
create table employee(
    emp_id int,
    emp_name varchar(20),
    dept_id int,
    salary int,
    manager_id int,
    emp_age int
);

insert into employee values(1,'Ankit',100,10000,4,39);
insert into employee values(2,'Mohit',100,15000,5,48);
insert into employee values(3,'Vikas',100,10000,4,37);
insert into employee values(4,'Rohit',100,5000,2,16);
insert into employee values(5,'Mudit',200,12000,6,55);
insert into employee values(6,'Agam',200,12000,2,14);
insert into employee values(7,'Sanjay',200,9000,2,13);
insert into employee values(8,'Ashish',200,5000,2,12);
insert into employee values(9,'Mukesh',300,6000,6,51);
insert into employee values(10,'Rakesh',500,7000,6,50);

select * from employee

select *, first_value(emp_name) over(PARTITION by dept_id order by salary desc) as max_sal_emp
from employee;

select *, last_value(emp_name) over(PARTITION by dept_id order by salary desc) as min_sal_emp
from employee; 

-- both first and last value works like a rolling window function till current row

-- to consider the entire section
select *, last_value(emp_name) over(PARTITION by dept_id order by salary desc rows between CURRENT row and UNBOUNDED FOLLOWING) as min_sal_emp
from employee
order by dept_id, salary desc; 

-- go with first_value and reverse the sorting to avoid the need of using last_value

-- rolling calculation - sum

with year_month_sales as (
select datepart(year, order_date) as order_year,
datepart(month, order_date) as order_month,
sum(sales) as total_sales from TABLE
group by datepart(year, order_date), datepart(month, order_date))
select order_year,
order_month,
sum(total_sales) over(order by order_year, order_month rows between 2 PRECEDING and current row) as rolling_three_sum from year_month_sales


-- find top 25 and bottom 25 percent customers by sales in each region

with customer_sales as (
SELECT Customer_Name as customer_name, Region as region , sum(Sales) as total_sales from orders o 
group by Customer_Name, Region 
)
select * from (
select customer_name, region, total_sales,
NTILE(4) over(partition by region order by total_sales desc) as customer_group from customer_sales) s
where customer_group in (1,4)
order by customer_group,region, total_sales


-- independent vs correlated subquery
-- print the employees who's salary is greater than thw dept avg salary

SELECT * from employee e 

-- independent subquery
select x.dept_id, emp_name , salary, avg_salary from employee e2 
inner join
(select dept_id , avg(salary) as avg_salary from employee e 
group by dept_id ) x
on e2.dept_id = x.dept_id
where salary > avg_salary

-- correlated subquery
-- the inner query runs for each record of outer query

select e1.emp_name, e1.salary from employee e1
where e1.salary > (select avg(e2.salary) from employee e2 where e2.dept_id  = e1.dept_id)


-- write a sql to find students who only know sql python

create table students  (
student_id int,
skill varchar(20)
);
delete from students;
insert into students values
(1,'sql'),(1,'python'),(1,'tableau'),(2,'sql'),(3,'sql'),(3,'python'),(4,'tableau'),(5,'python'),(5,'tableau');

select * from students


select s1.student_id from students s1
where ('python','sql') in (select skill from students s2 where s2.student_id = s1.student_id)

select s1.student_id, s1.skill from students s1 where s1.skill in ('python','sql')
and 2 = (select count(s2.student_id) from students s2 where s1.student_id = s2.student_id)


with cte as (
select student_id, 
count(skill) as total_skills,
count(case when skill in ('python','sql') then skill else null end) as relevant_skills
from students group by student_id
)
select student_id from cte where total_skills = 2 and total_skills = relevant_skills 

select student_id
from students
where student_id not in (select student_id from students where skill not in ('python','sql'))
group by student_id
having count(*) = 2

select student_id
from students s1
where not EXISTS  (select 1 from students s2 where s2.skill not in ('python','sql') and s2.student_id = s1.student_id)
group by student_id
having count(*) = 2


select student_id
from students
group by student_id
having count(*) = 2
except
select student_id
from students
where skill not in  ('python','sql')




