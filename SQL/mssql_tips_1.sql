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












