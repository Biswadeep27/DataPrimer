-- 1. print all employee names ans vacant positioon
create table job_positions (id  int,
                                             title varchar(100),
                                              groups varchar(10),
                                              levels varchar(10),     
                                               payscale int, 
                                               totalpost int );
                                               
                                              
                                              
insert into job_positions values (1, 'General manager', 'A', 'l-15', 10000, 1); 
insert into job_positions values (2, 'Manager', 'B', 'l-14', 9000, 5); 
insert into job_positions values (3, 'Asst. Manager', 'C', 'l-13', 8000, 10);  


create table job_employees ( id  int, 
                                                 name   varchar(100),     
                                                  position_id  int 
                                                );  
                                               


                                               
insert into job_employees values (1, 'John Smith', 1); 
insert into job_employees values (2, 'Jane Doe', 2);
 insert into job_employees values (3, 'Michael Brown', 2);
 insert into job_employees values (4, 'Emily Johnson', 2); 
insert into job_employees values (5, 'William Lee', 3); 
insert into job_employees values (6, 'Jessica Clark', 3); 
insert into job_employees values (7, 'Christopher Harris', 3);
 insert into job_employees values (8, 'Olivia Wilson', 3);
 insert into job_employees values (9, 'Daniel Martinez', 3);
 insert into job_employees values (10, 'Sophia Miller', 3) 
 
 SELECT * from job_employees je ;
 SELECT * from job_positions jp ;
 

with jobs as (select id, title, groups, levels, payscale, totalpost , 1 as row_num 
from job_positions jp  
union all 
select id, title, groups, levels, payscale, totalpost, row_num + 1 as row_num 
from jobs 
where  row_num < totalpost 
),
employees as (
	select name, position_id, row_number() over(partition by position_id order by id) as row_num
	from job_employees je 
)
select id, title, groups, levels, payscale, totalpost, COALESCE(name, 'vacant')  
from jobs j
left join employees e
on j.id = e.position_id
and j.row_num = e.row_num
order by j.id, j.row_num


-- 2. fill up junior and senior positions : total budget : 50000

Create table candidates(
id int primary key,
positions varchar(10) not null,
salary int not null);

delete from candidates;
-- test case 1:
insert into candidates values(1,'junior',5000);
insert into candidates values(2,'junior',7000);
insert into candidates values(3,'junior',7000);
insert into candidates values(4,'senior',10000);
insert into candidates values(5,'senior',30000);
insert into candidates values(6,'senior',20000);

-- test case 2:
insert into candidates values(20,'junior',10000);
insert into candidates values(30,'senior',15000);
insert into candidates values(40,'senior',30000);

-- test case 3:
insert into candidates values(1,'junior',15000);
insert into candidates values(2,'junior',15000);
insert into candidates values(3,'junior',20000);
insert into candidates values(4,'senior',60000);

-- test case 4:
insert into candidates values(10,'junior',10000);
insert into candidates values(40,'junior',10000);
insert into candidates values(20,'senior',15000);
insert into candidates values(30,'senior',30000);
insert into candidates values(50,'senior',15000);

select * from candidates c ;

with cte as (select id, positions, salary, 
row_number() over(partition by positions order by salary) as pos_cnt,
sum(salary) over(partition by positions order by salary rows between unbounded preceding and current row) as salary_spent
from candidates c ) ,
seniors as (
select 1 as join_idx, coalesce(max(salary_spent),0) as seniors_salary , coalesce(max(pos_cnt),0) as seniors from cte c1 where positions = 'senior' and salary_spent <= 50000
),
juniors as
(select 1 as join_idx, coalesce(max(pos_cnt),0) as juniors from cte where positions = 'junior' and salary_spent <= 50000 - (select seniors_salary from seniors))
select juniors, seniors from
seniors s
join juniors j
on s.join_idx = s.join_idx



-- 3. employee check in check out details

CREATE TABLE employee_checkin_details 
(
    employeeid	INT,
    entry_details	VARCHAR(512),
    timestamp_details	datetime
);

INSERT INTO employee_checkin_details (employeeid, entry_details, timestamp_details) VALUES ('1000', 'login', '2023-06-16 01:00:15.34');
INSERT INTO employee_checkin_details (employeeid, entry_details, timestamp_details) VALUES ('1000', 'login', '2023-06-16 02:00:15.34');
INSERT INTO employee_checkin_details (employeeid, entry_details, timestamp_details) VALUES ('1000', 'login', '2023-06-16 03:00:15.34');
INSERT INTO employee_checkin_details (employeeid, entry_details, timestamp_details) VALUES ('1000', 'logout', '2023-06-16 12:00:15.34');
INSERT INTO employee_checkin_details (employeeid, entry_details, timestamp_details) VALUES ('1001', 'login', '2023-06-16 01:00:15.34');
INSERT INTO employee_checkin_details (employeeid, entry_details, timestamp_details) VALUES ('1001', 'login', '2023-06-16 02:00:15.34');
INSERT INTO employee_checkin_details (employeeid, entry_details, timestamp_details) VALUES ('1001', 'login', '2023-06-16 03:00:15.34');
INSERT INTO employee_checkin_details (employeeid, entry_details, timestamp_details) VALUES ('1001', 'logout', '2023-06-16 12:00:15.34');



CREATE TABLE employee_details 
(
    employeeid	INT,
    phone_number	INT,
    isdefault	VARCHAR(512)
);

INSERT INTO employee_details (employeeid, phone_number, isdefault) VALUES ('1001', '9999', 'false');
INSERT INTO employee_details (employeeid, phone_number, isdefault) VALUES ('1001', '1111', 'false');
INSERT INTO employee_details (employeeid, phone_number, isdefault) VALUES ('1001', '2222', 'true');
INSERT INTO employee_details (employeeid, phone_number, isdefault) VALUES ('1003', '3333', 'false');


select * from employee_checkin_details ecd 
select * from employee_details ed 

-- sol 1

select ecd.employeeid,
count(*) as total_entry,
count(case when entry_details = 'login' then timestamp_details  else null end ) as total_logins,
count(case when entry_details = 'logout' then timestamp_details  else null end ) as total_logouts,
max(case when entry_details = 'login' then timestamp_details  else null end) as latest_login,
max(case when entry_details = 'logout' then timestamp_details  else null end) as latest_logout,
ed.phone_number as default_phone_number
from employee_checkin_details ecd 
left join employee_details ed 
on ecd.employeeid = ed.employeeid and ed.isdefault = 'true'
group by ecd.employeeid, ed.phone_number 


drop table employee_details

CREATE TABLE employee_details 
(
    employeeid	INT,
    phone_number	INT,
    isdefault	VARCHAR(512),
    added_on	datetime
);

INSERT INTO employee_details (employeeid, phone_number, isdefault, added_on) VALUES ('1001', '9999', 'false', '2023-01-01');
INSERT INTO employee_details (employeeid, phone_number, isdefault, added_on) VALUES ('1001', '1111', 'false', '2023-01-02');
INSERT INTO employee_details (employeeid, phone_number, isdefault, added_on) VALUES ('1001', '2222', 'true', '2023-01-03');
INSERT INTO employee_details (employeeid, phone_number, isdefault, added_on) VALUES ('1000', '3333', 'false', '2023-01-01');
INSERT INTO employee_details (employeeid, phone_number, isdefault, added_on) VALUES ('1000', '4444', 'false', '2023-01-02');



select employeeid, max(case when isdefault = 'false' then phone_number else null end) as non_default_phone_number

from employee_details ed 
group by

select employeeid , isdefault , phone_number,

row_number() over(partition by employeeid  order by added_on desc ) as phone_number 
from employee_details ed 


select ecd.employeeid,
count(*) as total_entry,
count(case when entry_details = 'login' then timestamp_details  else null end ) as total_logins,
count(case when entry_details = 'logout' then timestamp_details  else null end ) as total_logouts,
max(case when entry_details = 'login' then timestamp_details  else null end) as latest_login,
max(case when entry_details = 'logout' then timestamp_details  else null end) as latest_logout,
ed.phone_number as default_phone_number,
ed.isdefault ,
ed.added_on
from employee_checkin_details ecd 
left join employee_details ed 
on ecd.employeeid = ed.employeeid -- and ed.isdefault = 'true'
group by ecd.employeeid, ed.phone_number, 
ed.isdefault ,
ed.added_on
order by ecd.employeeid , ed.added_on

select employeeid,  max(added_on) as latest_added from employee_details ed where isdefault = 'false'
group by employeeid 


SELECT * from employee_details ed 


(select employeeid, isdefault, phone_number, row_number() over(partition by employeeid order by added_on desc) as rnk
from employee_details )



-- 4 : finding avg department salary less than avg (company - that dept) salary


create table emp(
emp_id int,
emp_name varchar(20),
department_id int,
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
values (10, 'Rakesh',300,7000,6,50);

select * from emp;


with departments as (
select department_id from emp
	group by department_id
)
select --m.department_id, -- avg(case when m.department_id = d.department_id then m.salary else 0 end) as dept_sal,
 avg(case when m.department_id != d.department_id then m.salary else 0 end) as company_sal
from emp m join (select department_id from emp group by department_id) d
on m.department_id = d.department_id
group by m.department_id


with cte as 
(select department_id, avg(salary) as dept_avg_salary, 
sum(salary) as dept_total_salary, 
sum(sum(salary)) over(order by department_id rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING) - sum(salary) as total_salary,
sum(count(emp_id)) over(order by department_id rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING) - count(emp_id) as total_emps
from emp
group by department_id)
select department_id , dept_avg_salary, total_salary / total_emps as company_avg_salary
from cte  where dept_avg_salary < (total_salary / total_emps)


-- 5: LeetCode hard SQL : Merge overlapping events 

create table hall_events
(
hall_id integer,
start_date date,
end_date date
);

insert into hall_events values 
(1,'2023-01-13','2023-01-14')
,(1,'2023-01-14','2023-01-17')
,(1,'2023-01-15','2023-01-17')
,(1,'2023-01-18','2023-01-25')
,(2,'2022-12-09','2022-12-23')
,(2,'2022-12-13','2022-12-17')
,(3,'2022-12-01','2023-01-30');


select * from hall_events he 


with cte as (
select hall_id, start_date, end_date,
first_value(end_date) over(partition by hall_id order by start_date rows between 1 PRECEDING  and 1 PRECEDING) as prev_end_date
from hall_events he )

select hall_id, min(start_date) as start_date , max(end_date) as end_date 
from cte where next_start_date is not null and end_date > next_start_date
group by hall_id
union 


with cte1 as (
SELECT *,
    CASE
      WHEN start_date <=
        MAX(end_date) OVER(PARTITION BY hall_id ORDER BY start_date, end_date
                            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
        THEN 0
        ELSE 1
      END AS isstart
  FROM hall_events),
 cte2 as (
 select *, 
 sum(isstart) over(partition by hall_id order by start_date, end_date rows between UNBOUNDED PRECEDING and current row)
 as merge_group from cte1)
 
 select hall_id, min(start_date) as start_date,
 max(end_date) as end_date from cte2
 group by hall_id, merge_group
 order by hall_id, start_date
 
 
 -- 6: case study : BookMyShow
 CREATE TABLE booking_table(
   Booking_id       VARCHAR(3) NOT NULL 
  ,Booking_date     date NOT NULL
  ,User_id          VARCHAR(2) NOT NULL
  ,Line_of_business VARCHAR(6) NOT NULL
);
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b1','2022-03-23','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b2','2022-03-27','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b3','2022-03-28','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b4','2022-03-31','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b5','2022-04-02','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b6','2022-04-02','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b7','2022-04-06','u5','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b8','2022-04-06','u6','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b9','2022-04-06','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b10','2022-04-10','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b11','2022-04-12','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b12','2022-04-16','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b13','2022-04-19','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b14','2022-04-20','u5','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b15','2022-04-22','u6','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b16','2022-04-26','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b17','2022-04-28','u2','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b18','2022-04-30','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b19','2022-05-04','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b20','2022-05-06','u1','Flight');
;
CREATE TABLE user_table(
   User_id VARCHAR(3) NOT NULL
  ,Segment VARCHAR(2) NOT NULL
);
INSERT INTO user_table(User_id,Segment) VALUES ('u1','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u2','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u3','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u4','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u5','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u6','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u7','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u8','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u9','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u10','s3');

select * from booking_table bt ;
select * from user_table ut ;

select bt.*, ut.* ,
case when bt.Line_of_business = 'Flight' then 1 else 0 end as flight_checks

from booking_table bt
join user_table ut
on bt.User_id = ut.User_id 


with bookings as (
select User_id  from booking_table
where DATEPART(year, Booking_date) = 2022 
and DATEPART(MONTH, Booking_date) = 4
and Line_of_business = 'Flight'
group by User_id )
select segment, COUNT(ut.user_id) as total_user_count , count(bt.user_id) as users_who_booked_flight_apr22
from user_table ut  
left join bookings bt
on ut.user_id = bt.user_id
group by segment

-- find users whose first booking was hotel

select * from (
select user_id, line_of_business, booking_date,
row_number() over(PARTITION by user_id order by booking_date asc) as booking_row_num
from booking_table bt ) cte 
where booking_row_num = 1 and Line_of_business = 'Hotel'



-- days between 1st and last booking for each user
select user_id, DATEDIFF(day,min(booking_date),max(booking_date))  as days_diff,
max(booking_date) as last_booking_date from booking_table bt 
group by User_id 


select segment , 
count(case when Line_of_business = 'hotel' then 1 else null end) as number_of_hotel_bookings,
count(case when Line_of_business = 'Flight' then 1 else null end) as number_of_hotel_bookings
from booking_table bt 
inner join user_table ut
on bt.User_id = ut.User_id
and DATEPART(year, Booking_date) = 2022 
group by segment


-- 7 : trading couple

Create Table Trade_tbl(
TRADE_ID varchar(20),
Trade_Timestamp time,
Trade_Stock varchar(20),
Quantity int,
Price Float
)

Insert into Trade_tbl Values('TRADE1','10:01:05','ITJunction4All',100,20)
Insert into Trade_tbl Values('TRADE2','10:01:06','ITJunction4All',20,15)
Insert into Trade_tbl Values('TRADE3','10:01:08','ITJunction4All',150,30)
Insert into Trade_tbl Values('TRADE4','10:01:09','ITJunction4All',300,32)
Insert into Trade_tbl Values('TRADE5','10:10:00','ITJunction4All',-100,19)
Insert into Trade_tbl Values('TRADE6','10:10:01','ITJunction4All',-300,19)


select * from Trade_tbl tt ;

select t1.TRADE_ID , t1.Trade_Timestamp , t1.Price ,
t2.TRADE_ID , t2.Trade_Timestamp , t2.Price
from Trade_tbl t1
join Trade_tbl t2
-- on t1.TRADE_ID != t2.TRADE_ID 
on t1.Trade_Timestamp < t2.Trade_Timestamp 
and DATEDIFF(SECOND, t1.Trade_Timestamp, t2.Trade_Timestamp) < 10
and abs(cast((t2.Price  - t1.Price) * 100 / t1.Price  as float)) > 10
order by t1.TRADE_ID 



-- marketing suceess : successful in-app purchase after marketing

CREATE TABLE [marketing_campaign](
 [user_id] [int] NULL,
 [created_at] [date] NULL,
 [product_id] [int] NULL,
 [quantity] [int] NULL,
 [price] [int] NULL
);


insert into marketing_campaign values (10,'2019-01-01',101,3,55),
(10,'2019-01-02',119,5,29),
(10,'2019-03-31',111,2,149),
(11,'2019-01-02',105,3,234),
(11,'2019-03-31',120,3,99),
(12,'2019-01-02',112,2,200),
(12,'2019-03-31',110,2,299),
(13,'2019-01-05',113,1,67),
(13,'2019-03-31',118,3,35),
(14,'2019-01-06',109,5,199),
(14,'2019-01-06',107,2,27),
(14,'2019-03-31',112,3,200),
(15,'2019-01-08',105,4,234),
(15,'2019-01-09',110,4,299),
(15,'2019-03-31',116,2,499),
(16,'2019-01-10',113,2,67),
(16,'2019-03-31',107,4,27),
(17,'2019-01-11',116,2,499),
(17,'2019-03-31',104,1,154),
(18,'2019-01-12',114,2,248),
(18,'2019-01-12',113,4,67),
(19,'2019-01-12',114,3,248),
(20,'2019-01-15',117,2,999),
(21,'2019-01-16',105,3,234),
(21,'2019-01-17',114,4,248),
(22,'2019-01-18',113,3,67),
(22,'2019-01-19',118,4,35),
(23,'2019-01-20',119,3,29),
(24,'2019-01-21',114,2,248),
(25,'2019-01-22',114,2,248),
(25,'2019-01-22',115,2,72),
(25,'2019-01-24',114,5,248),
(25,'2019-01-27',115,1,72),
(26,'2019-01-25',115,1,72),
(27,'2019-01-26',104,3,154),
(28,'2019-01-27',101,4,55),
(29,'2019-01-27',111,3,149),
(30,'2019-01-29',111,1,149),
(31,'2019-01-30',104,3,154),
(32,'2019-01-31',117,1,999),
(33,'2019-01-31',117,2,999),
(34,'2019-01-31',110,3,299),
(35,'2019-02-03',117,2,999),
(36,'2019-02-04',102,4,82),
(37,'2019-02-05',102,2,82),
(38,'2019-02-06',113,2,67),
(39,'2019-02-07',120,5,99),
(40,'2019-02-08',115,2,72),
(41,'2019-02-08',114,1,248),
(42,'2019-02-10',105,5,234),
(43,'2019-02-11',102,1,82),
(43,'2019-03-05',104,3,154),
(44,'2019-02-12',105,3,234),
(44,'2019-03-05',102,4,82),
(45,'2019-02-13',119,5,29),
(45,'2019-03-05',105,3,234),
(46,'2019-02-14',102,4,82),
(46,'2019-02-14',102,5,29),
(46,'2019-03-09',102,2,35),
(46,'2019-03-10',103,1,199),
(46,'2019-03-11',103,1,199),
(47,'2019-02-14',110,2,299),
(47,'2019-03-11',105,5,234),
(48,'2019-02-14',115,4,72),
(48,'2019-03-12',105,3,234),
(49,'2019-02-18',106,2,123),
(49,'2019-02-18',114,1,248),
(49,'2019-02-18',112,4,200),
(49,'2019-02-18',116,1,499),
(50,'2019-02-20',118,4,35),
(50,'2019-02-21',118,4,29),
(50,'2019-03-13',118,5,299),
(50,'2019-03-14',118,2,199),
(51,'2019-02-21',120,2,99),
(51,'2019-03-13',108,4,120),
(52,'2019-02-23',117,2,999),
(52,'2019-03-18',112,5,200),
(53,'2019-02-24',120,4,99),
(53,'2019-03-19',105,5,234),
(54,'2019-02-25',119,4,29),
(54,'2019-03-20',110,1,299),
(55,'2019-02-26',117,2,999),
(55,'2019-03-20',117,5,999),
(56,'2019-02-27',115,2,72),
(56,'2019-03-20',116,2,499),
(57,'2019-02-28',105,4,234),
(57,'2019-02-28',106,1,123),
(57,'2019-03-20',108,1,120),
(57,'2019-03-20',103,1,79),
(58,'2019-02-28',104,1,154),
(58,'2019-03-01',101,3,55),
(58,'2019-03-02',119,2,29),
(58,'2019-03-25',102,2,82),
(59,'2019-03-04',117,4,999),
(60,'2019-03-05',114,3,248),
(61,'2019-03-26',120,2,99),
(62,'2019-03-27',106,1,123),
(63,'2019-03-27',120,5,99),
(64,'2019-03-27',105,3,234),
(65,'2019-03-27',103,4,79),
(66,'2019-03-31',107,2,27),
(67,'2019-03-31',102,5,82)

SELECT * from marketing_campaign mc 

with cte as (
select user_id,
created_at,
product_id,
DENSE_RANK() over(PARTITION by user_id order by created_at) as purchase_order,
first_value(product_id) over(PARTITION by user_id order by created_at) as first_product
from marketing_campaign mc ),
first_purchase as (
select user_id, product_id  from cte where purchase_order = 1
)
select c.* from cte c
where c.product_id not in (select f.product_id from first_purchase f where f.user_id = c.user_id )


--
create table namaste_python (
file_name varchar(25),
content varchar(200)
);


insert into namaste_python values ('python bootcamp1.txt','python for data analytics 0 to hero bootcamp starting on Jan 6th')
,('python bootcamp2.txt','classes will be held on weekends from 11am to 1 pm for 5-6 weeks')
,('python bootcamp3.txt','use code NY2024 to get 33 percent off. You can register from namaste sql website. Link in pinned comment')


select * from namaste_python

with content_delims as (
	select content, 
	0 as prev_delim_pos,
	CHARINDEX(' ', content) as delim_pos
	from namaste_python
	
	union all
	
	SELECT content,
	delim_pos as prev_delim_pos,
	CHARINDEX(' ', content, delim_pos + 1) as delim_pos
	from content_delims
	where delim_pos > 0

),
word_rows as (
SELECT content,
case when delim_pos > 0 then substring(content, prev_delim_pos + 1, delim_pos - prev_delim_pos - 1)
	else substring(content, prev_delim_pos + 1, len(content) - prev_delim_pos - 1) end as words
from content_delims
)

select words from word_rows 
group by words having count(*) > 1

-- users who purchased different products on diffent days

create table purchase_history
(userid int
,productid int
,purchasedate datetime2
);

drop table purchase_history


delete from purchase_history

INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('1', '1', '2012-01-23');
INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('1', '2', '2012-01-23');
INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('1', '3', '2012-01-25');
INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('2', '1', '2012-01-23');
INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('2', '2', '2012-01-23');
INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('2', '2', '2012-01-25');
INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('2', '4', '2012-01-25');
INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('3', '4', '2012-01-23');
INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('3', '1', '2012-01-23');
INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('4', '1', '2012-01-23');
INSERT INTO purchase_history (userid , productid, purchasedate ) VALUES ('4', '2', '2012-01-25');

select * from purchase_history

select userid, productid, count(distinct purchasedate) as dis_purchase_days
from purchase_history ph 
group by userid, productid





-- profit ride for drivers

create table drivers(id varchar(10), start_time time, end_time time, start_loc varchar(10), end_loc varchar(10));
insert into drivers values('dri_1', '09:00', '09:30', 'a','b'),('dri_1', '09:30', '10:30', 'b','c'),('dri_1','11:00','11:30', 'd','e');
insert into drivers values('dri_1', '12:00', '12:30', 'f','g'),('dri_1', '13:30', '14:30', 'c','h');
insert into drivers values('dri_2', '12:15', '12:30', 'f','g'),('dri_2', '13:30', '14:30', 'c','h');

SELECT * from drivers d 

with rides as (
select id,
start_loc,
end_loc,
first_value(start_loc) over(partition by id order by start_time rows between 1 following and 1 FOLLOWING) as next_start_loc
from drivers)
select id,
count(id) as total_ride,
sum(case when end_loc = next_start_loc then 1 else 0 end) as profit_rides
from rides group by id


-- total charges as per billing rate

create table billings 
(
emp_name varchar(10),
bill_date date,
bill_rate int
);
delete from billings;
insert into billings values
('Sachin','01-JAN-1990',25)
,('Sehwag' ,'01-JAN-1989', 15)
,('Dhoni' ,'01-JAN-1989', 20)
,('Sachin' ,'05-Feb-1991', 30)
;

create table HoursWorked 
(
emp_name varchar(20),
work_date date,
bill_hrs int
);
insert into HoursWorked values
('Sachin', '01-JUL-1990' ,3)
,('Sachin', '01-AUG-1990', 5)
,('Sehwag','01-JUL-1990', 2)
,('Sachin','01-JUL-1991', 4)

select * from billings 

with cte as (
select b1.*, 
case when b2.bill_date is not null then dateadd(day,-1,b2.bill_date) else cast('9999-12-31' as DATE) end as bill_end_date
from billings b1 
left join billings b2 
on b1.emp_name = b2.emp_name 
and b1.bill_date < b2.bill_date )
select
c.emp_name,
sum(c.bill_rate * h.bill_hrs) as daily_charges
from
cte c
join hoursworked h
on c.emp_name = h.emp_name 
and h.work_date BETWEEN c.bill_date and c.bill_end_date
group by c.emp_name

-- order table delta capture
create table tbl_orders (
order_id integer,
order_date date
);
insert into tbl_orders
values (1,'2022-10-21'),(2,'2022-10-22'),
(3,'2022-10-25'),(4,'2022-10-25');

select * from tbl_orders 

select * into tbl_orders_copy from  tbl_orders;

insert into tbl_orders
values (5,'2022-10-26'),(6,'2022-10-26');
delete from tbl_orders where order_id=1;



select * from tbl_orders o 
select * from tbl_orders_copy oc 

select COALESCE (o.order_id , oc.order_id) as order_id ,
case when o.order_id is not null then 'I' else 'D' end as flag
from tbl_orders o
full join tbl_orders_copy oc
on o.order_id = oc.order_id
where o.order_id is null or oc.order_id is null

-- rental amenities

create table rental_amenities 
(
rental_id int,
amenity varchar(20),
);

insert into rental_amenities values
(123, 'pool')
,(123, 'kitchen')
,(234, 'hot tub')
,(234, 'fireplace')
,(345, 'kitchen')
,(345, 'pool')
,(456, 'pool')

SELECT * from rental_amenities ra 

SELECT *,
dense_rank()





