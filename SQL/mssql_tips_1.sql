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













