SELECT * from spt_fallback_db sfd;

create table icc_world_cup
(
Team_1 Varchar(20),
Team_2 Varchar(20),
Winner Varchar(20)
);

SELECT * from dbo.icc_world_cup iwc ;

INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India');

create table emp_compensation (
emp_id int,
salary_component_type varchar(20),
val int
);

insert into emp_compensation
values (1,'salary',10000),(1,'bonus',5000),(1,'hike_percent',10)
, (2,'salary',15000),(2,'bonus',7000),(2,'hike_percent',8)
, (3,'salary',12000),(3,'bonus',6000),(3,'hike_percent',7);

SELECT * FROM dbo.emp_compensation ec ;


with emp_pivot as (
select emp_id , 
CASE  
	WHEN salary_component_type = 'salary'
	THEN val else 0 end as salary,
CASE  
	WHEN salary_component_type = 'bonus'
	THEN val else 0 end as bonus,
CASE  
	WHEN salary_component_type = 'hike_percent'
	THEN val else 0 end as hike_percent
FROM emp_compensation
)
 select emp_id ,
max(salary) as salary,
max(hike_percent) as hike_percent,
max(bonus) as bonus 
from emp_pivot 
group by emp_id ;
	


select emp_id , 
max(CASE  
	WHEN salary_component_type = 'salary'
	THEN val else 0 end) as salary,
max(CASE  
	WHEN salary_component_type = 'bonus'
	THEN val else 0 end) as bonus,
max(CASE  
	WHEN salary_component_type = 'hike_percent'
	THEN val else 0 end) as hike_percent
into emp_compensation_pivot
FROM emp_compensation
group by emp_id ;

SELECT * from emp_compensation_pivot;

SELECT emp_id , 'salary'  as salary_component_type , salary as val
FROM emp_compensation_pivot ecp 
UNION
SELECT emp_id , 'bonus'  as salary_component_type , bonus as val
FROM emp_compensation_pivot ecp1 
UNION 
SELECT emp_id , 'hike_percent'  as salary_component_type , hike_percent as val
FROM emp_compensation_pivot ecp2 ;

-- case sensitive filtering
select * FROM emp_compensation ec where upper(ec.salary_component_type) = 'SALARY';

-- update with case statement
update orders set cutomer_gender = CASE WHEN cutomer_gender = 'Male' THEN 'Female' ELSE 'MALE' END ;


-- self join
select e.* , m.emp_name as manager_name, m.salary as manager_salary from employee e
join employee m
on e.manager_id = m.emp_id 
where e.salary > m.salary ;


-- cross join
create table products (
id int,
name varchar(10)
);

insert into products VALUES 
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');

create table colors (
color_id int,
color varchar(50)
);
insert into colors values (1,'Blue'),(2,'Green'),(3,'Orange');

create table sizes
(
size_id int,
size varchar(10)
);

insert into sizes values (1,'M'),(2,'L'),(3,'XL');

create table transactions
(
order_id int,
product_name varchar(20),
color varchar(10),
size varchar(10),
amount int
);

insert into transactions values (1,'A','Blue','L',300),(2,'B','Blue','XL',150),(3,'B','Green','L',250),(4,'C','Blue','L',250),
(5,'E','Green','L',270),(6,'D','Orange','L',200),(7,'D','Green','M',250);



--finding duplicates

select count(*), emp_id from table group by emp_id having count(*) > 1

--deleting duplicates

with cte as (
	select emp_id, row_number() over(partition by emp_id order by emp_id) as rn
	from table
)
delete from cte where rn > 1;


--employee who are not present in dept table

select e.* from emp e
LEFT join dept d
ON e.dept_id = d.dept_id
WHERE d.dept_id is NULL

-- select second highest salary of each dep
select department_id, salary as second_highest_salary from
(select department_id, salary, row_number() over(partition by department_id order by salary desc) as rn from emp)x
    where x.rn = 2;

-- self join: emp salary > manager salary
select m.emp_name as manager_name, m.salary as manager_salary,
    e.emp_name, e.salary as emp_salary from
emp m
join emp e
on m.emp_id = e.manager_id
    where m.salary < e.salary;

-- update query to swap genders
update table set gender = case when gender = 'male' then 'female'
								when gender = 'fenale' then 'male' end

-- calculate mode :  most frequent elements
-- cte with count group by id and then selcting max count

with cte as 
(select id, row_number() over(partition by id order by id) as rnk from table )
select id from cte where rnk = (select max(rnk) from cte)


-- custom sort to show a derived detail at the top and then follow the rest of the order

select s.* from
(select *, case when country = 'india' then 1 else 0 end as derived_country
from table) s order by s.derived_country desc, s.rank 

-- problem with running sum: make sure your order by combination is unique
select *, sum(cost) over(order by cost, product_id) as running_sum from TABLE
-- while cost has duplicate values, the combination of cost and product_id is unique

-- if we don't have additional col to make the combination unique, then we can
-- restrict the rolling sum till current row
select *, sum(cost) over(order by cost rows BETWEEN UNBOUNDED PRECEDING and CURRENT ROW) as running_sum from TABLE

-- count number of occurance of character 'c' or a word 'word' in a string column

select len(name) - len(replace(name, 'c', '')) as char_cnt from TABLE
select (len(name) - len(replace(name, 'word', '')))/len('word') as word_cnt from TABLE


-- aggregate using window function
select *, sum(amount) over(partition by salesperson_id) as salesperson_total from int_orders;

-- running sum in each salesperson group
select *, sum(amount) over(partition by salesperson_id order by order_date ) as rolling_sum from int_orders;

-- rolling sum
-- rolling 2 sum
select *, sum(amount) over(partition by salesperson_id order by order_date rows between 1 preceding and current row) as rolling_sum 
from int_orders;

-- lag
select *, sum(amount) over( order by order_date rows between 1 preceding and 1 PRECEDING) as lag 
from int_orders;

-- lead
select *, sum(amount) over( order by order_date rows between 1 FOLLOWING and 1 FOLLOWING) as lag 
from int_orders;

-- full outer join using union
select a.* , b.*
from table1 a
left join table2 b
on a.id = b.id
union ALL
select a.* , b.*
from table2 b
left join table1 a
on a.id = b.id
where a.id is NULL



-- Left outer Join

select * from emp e
left join dept d
on e.dept_id = d.dept_id
and d.dept_name = 'Analytics'

-- no of rows still dictaed by left table. Number of NULL cols from right table will increase


select * from emp e
left join dept d
on e.dept_id = d.dept_id
where d.dept_name = 'Analytics'

-- as same as inner join. number of op records will decease - do inner join instead

-- we can put where clause if the filtering is on left table
select * from emp e
left join dept d
on e.dept_id = d.dept_id
where e.emp_salary = '10000'

-- putting left table filter condition in a left join doen't make sense if you are truly looking for filter on left table
select * from emp e
left join dept d
on e.dept_id = d.dept_id
AND e.emp_salary = '10000'
-- above query populates null on all d attributes except for the ones where dept_id are same for emps having salary = 10000

-- find the process date of resolving tickets considering folks don't work on weekends and public holidays
create table tickets
(
ticket_id varchar(10),
create_date date,
resolved_date date
);
-- delete from tickets;
insert into tickets values
(1,'2022-08-01','2022-08-03')
,(2,'2022-08-01','2022-08-12')
,(3,'2022-08-01','2022-08-16');

select * from tickets;

create table holidays
(
holiday_date date
,reason varchar(100)
);
-- delete from holidays;
insert into holidays values
('2022-08-11','Rakhi'),('2022-08-15','Independence day');
ticket_id	create_date	resolved_date
1	        2022-08-01	2022-08-03
2	        2022-08-01	2022-08-12
3	        2022-08-01	2022-08-16
holiday_date	reason
2022-08-11	    Rakhi
2022-08-15	    Independence day
ticket_id	original_days	process_days
1	        2	            2
2	        11	            8
3	        15	            9

select xx.ticket_id,
    datediff(xx.resolved_date, xx.create_date) as original_days,
    datediff(xx.resolved_date, xx.create_date) - (weekofyear(xx.resolved_date) - weekofyear(xx.create_date)) * 2 - xx.number_of_holidays as process_days
from (select t.ticket_id, t.create_date, t.resolved_date, count(h.holiday_date) as number_of_holidays
from tickets t
left join holidays h
on h.holiday_date between t.create_date and t.resolved_date
AND weekday(h.holiday_date) not in (1,7) -- we don't need to consider a holiday if already falls on weekend
    group by t.ticket_id, t.create_date, t.resolved_date) xx;


-- group by and rank together

select category, product_id, sales_rank from (
select category, product_id, sum(sales) as total_sales,
rank() over(partition by category order by sum(sales) desc ) as sales_rank
from orders
group by category, product_id)
where sales_rank <= 5

-- string pattern matching
-- '%' : 0 or more characters
select bla from table where c like 'tgnd%'
-- '_' : match only one character
-- '[]' : any character between [] can match
select bla from table where c like 't[gb]nd%'

select bla from table where c like 't[^gb]nd%' -- second char can be anything except g and b.

select bla from table where c like 't[b-g]nd%' -- any char between the range b and g can match

-- rolling calculation - sum

with year_month_sales as (
select datepart(year, order_date) as order_year,
datepart(month, order_date) as order_month,
sum(sales) as total_sales from TABLE
group by datepart(year, order_date), datepart(month, order_date))
select order_year,
order_month,
sum(total_sales) over(order by order_year, order_month rows between 2 PRECEDING and current row) as rolling_three_sum from year_month_sales

-- merge statement

merge employee_target t
using employee_source s
on t.emp_id = s.emp_id
when matched 
	then update set t.salary = s.salary
	,   t.age = s.age
when not matched by TARGET
	then insert (emp_id, salary, age, gender, dept ) 
	values (s.emp_id, s.salary, s.age, s.gender, s.dept)
when not matched by SOURCE
	then delete;











