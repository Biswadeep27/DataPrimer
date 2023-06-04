create table emp(
emp_id int,
emp_name varchar(20),
dep_id int,
salary int,
manager_id int,
emp_age int);

insert into emp
values
(1, 'Ankit', 100,10000, 4, 39);
insert into emp
values (2, 'Mohit', 100, 15000, 5, 48);
insert into emp
values (3, 'Vikas', 100, 10000,4,37);
insert into emp
values (4, 'Rohit', 100, 5000, 2, 16);
insert into emp
values (5, 'Mudit', 200, 12000, 6,55);
insert into emp
values (6, 'Agam', 200, 12000,2, 14);
insert into emp
values (7, 'Sanjay', 200, 9000, 2,13);
insert into emp
values (8, 'Ashish', 200,5000,2,12);
insert into emp
values (9, 'Mukesh',300,6000,6,51);
insert into emp
values (10, 'Rakesh',500,7000,6,50);

SELECT * from dbo.emp e ;



CREATE table dept(
dep_id int,
dep_name varchar(50)
);

insert into dept values 
(100,'Analytics'),
(200,'IT'),
(300,'HR'),
(400,'Text Analytics');


-- left outer join
select * FROM emp e 
left join dept d 
on e.dep_id  = d.dep_id 
and d.dep_name = 'Analytics'

select * FROM emp e 
left join dept d 
on e.dep_id  = d.dep_id 
WHERE  d.dep_name = 'Analytics'
















