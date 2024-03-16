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

with amenity_idx as (
SELECT rental_id ,
dense_rank() over(order by amenity) as idx
from rental_amenities ra ),
total_amenities as (
select rental_id, sum(idx) as total_idx
from amenity_idx group by rental_id )
select a1.rental_id,a2.rental_id
from total_amenities a1
join total_amenities a2
on a1.rental_id < a2.rental_id and 
a1.total_idx = a2.total_idx



-- write a query to provide the date for nth occurance of sunday in future from given date

declare @today_date date;
declare @n int;
set @today_date = '2022-01-01';
set @n = 3;

select dateadd(week, @n - 1, dateadd(day, 8 - datepart(weekday, @today_date), @today_date))


-- Pareto Principle (80/20 rule)
select * from orders o 

with sales_details as (
SELECT Product_ID , sum(sales) as prod_sales,
sum(sum(sales)) over(order by sum(sales) desc) as rolling_prod_sum,
0.8 * sum(sum(sales)) over() as total_sales
from orders o
group by Product_ID )
select * from sales_details where rolling_prod_sum <= total_sales

-- trips and users
Create table  Trips (id int, client_id int, driver_id int, city_id int, status varchar(50), request_at varchar(50));
Create table Users (users_id int, banned varchar(50), role varchar(50));

Truncate table Trips;
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('1', '1', '10', '1', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('2', '2', '11', '1', 'cancelled_by_driver', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('3', '3', '12', '6', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('4', '4', '13', '6', 'cancelled_by_client', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('5', '1', '10', '1', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('6', '2', '11', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('7', '3', '12', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('8', '2', '12', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('9', '3', '10', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('10', '4', '13', '12', 'cancelled_by_driver', '2013-10-03');
Truncate table Users;
insert into Users (users_id, banned, role) values ('1', 'No', 'client');
insert into Users (users_id, banned, role) values ('2', 'Yes', 'client');
insert into Users (users_id, banned, role) values ('3', 'No', 'client');
insert into Users (users_id, banned, role) values ('4', 'No', 'client');
insert into Users (users_id, banned, role) values ('10', 'No', 'driver');
insert into Users (users_id, banned, role) values ('11', 'No', 'driver');
insert into Users (users_id, banned, role) values ('12', 'No', 'driver');
insert into Users (users_id, banned, role) values ('13', 'No', 'driver');

select * from Trips t 
select * from Users u 


select 
request_at,
sum(1) total_trips,
sum(case when status = 'completed' then 0 else 1 end) as cancelled_trips,
100 * sum(case when status = 'completed' then 0 else 1 end) / sum(1) as cancellation_rate
from trips 
where client_id not in (select users_id from users where banned = 'Yes' and role = 'client')
and driver_id not in (select users_id from users where banned = 'Yes' and role = 'driver')
group by request_at
--and request_at between '2013-10-1' and '2013-10-03'


-- find total number of clocked hours:
create table clocked_hours(
empd_id int,
swipe time,
flag char
);

insert into clocked_hours values
(11114,'08:30','I'),
(11114,'10:30','O'),
(11114,'11:30','I'),
(11114,'15:30','O'),
(11115,'09:30','I'),
(11115,'17:30','O');

select * from clocked_hours ch 

with swipes as (
select *,
first_value(swipe) over(partition by empd_id order by swipe rows BETWEEN 1 FOLLOWING and 1 FOLLOWING) as next_swipe
from clocked_hours ch )
select empd_id ,
sum(case when flag = 'I' then datediff(hour, swipe, next_swipe) else 0 end) as clocked_hour
from swipes
group by empd_id 

-- aggr events
create table tasks (
date_value date,
state varchar(10)
);

insert into tasks  values ('2019-01-01','success'),('2019-01-02','success'),('2019-01-03','success'),('2019-01-04','fail')
,('2019-01-05','fail'),('2019-01-06','success')

with events as (
select *, 
first_value(state) over(order by date_value rows between 1 preceding and 1 preceding) as next_state
from tasks),
event_changes as (
select *,
sum(case when state != next_state then 1 else 0 end) over(order by date_value) as event_chnage_flg
from events)
select min(date_value) as start_date,
max(date_value) as end_date,
min(state) as state from event_changes
group by event_chnage_flg

with all_dates as
(
select *,
row_number() over(partition by state order by date_value) as rn,
DATEADD(day, -1*row_number() over(partition by state order by date_value), date_value) as group_date
from tasks
)
select min(date_value) as start_date,
max(date_value) as end_date,
state
from all_dates
group by group_date, state 
order by start_date




/* User purchase platform.
-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop 
and a mobile application.
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only 
and both mobile and desktop together for each date.
*/

create table spending 
(
user_id int,
spend_date date,
platform varchar(10),
amount int
);

insert into spending values(1,'2019-07-01','mobile',100),(1,'2019-07-01','desktop',100),(2,'2019-07-01','mobile',100)
,(2,'2019-07-02','mobile',100),(3,'2019-07-01','desktop',100),(3,'2019-07-02','desktop',100);


select * from spending
order by spend_date

with all_spending as (
select spend_date, user_id,
max(platform) as platform,
sum(amount) as amount
from spending
group by spend_date, user_id having count(distinct platform) = 1
union ALL 
select spend_date, user_id,
'both' as platform,
sum(amount) as amount
from spending
group by spend_date, user_id having count(distinct platform) = 2
UNION all
select spend_date, null as user_id, 'both' as platform, 0 as amount
from spending group by spend_date
)
select spend_date, platform,
count(user_id) as num_users,
sum(amount) as total_amount
from all_spending
group by spend_date, platform
order by spend_date



-- total sales by year - using recursive CTE

SELECT * from sales s 




with dates as (
select min(period_start) as date_seq, max(period_end) as max_date from
sales
union all
select DATEADD(day,1, date_seq) as date_seq, max_date from dates
where date_seq < max_date
)

select product_id, DATEPART(year, d.date_seq) as sale_year, sum(average_daily_sales) as total_sales 
from sales s
join dates d
on d.date_seq between s.period_start and s.period_end 
group by product_id, DATEPART(year, d.date_seq)
order by product_id, sale_year
option(maxrecursion 1000);



-- recommendation - product pairs most commonly purchased together

create table orders1
(
order_id int,
customer_id int,
product_id int,
);

insert into orders1 VALUES 
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(2, 2, 1),
(2, 2, 2),
(2, 2, 4),
(3, 1, 5);

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


SELECT * from orders1 o ;

with product_trx as (
select o.order_id,
p.name
from orders1 o 
join
products p 
on o.product_id = p.id 
)
select concat(t1.name, ' ', t2.name) as prod_pair,
count(*) as purchase_freq
from product_trx t1
join product_trx t2
on t1.order_id = t2.order_id
and t1.name < t2.name
group by concat(t1.name, ' ', t2.name)


-- prime subscription rate by product action

create table users1
(
user_id integer,
name varchar(20),
join_date date
);
insert into users1
values (1, 'Jon', CAST('2-14-20' AS date)), 
(2, 'Jane', CAST('2-14-20' AS date)), 
(3, 'Jill', CAST('2-15-20' AS date)), 
(4, 'Josh', CAST('2-15-20' AS date)), 
(5, 'Jean', CAST('2-16-20' AS date)), 
(6, 'Justin', CAST('2-17-20' AS date)),
(7, 'Jeremy', CAST('2-18-20' AS date));

create table events
(
user_id integer,
type varchar(10),
access_date date
);

insert into events values
(1, 'Pay', CAST('3-1-20' AS date)), 
(2, 'Music', CAST('3-2-20' AS date)), 
(2, 'P', CAST('3-12-20' AS date)),
(3, 'Music', CAST('3-15-20' AS date)), 
(4, 'Music', CAST('3-15-20' AS date)), 
(1, 'P', CAST('3-16-20' AS date)), 
(3, 'P', CAST('3-22-20' AS date));

select * from users1 u ;
select * from events e ;

select 
--u.*,e.*
count(distinct u.user_id) as total_count,
count(distinct case when datediff(day, join_date, access_date)<= 30 then u.user_id end) as prime_users
from users1 u 
left join events e 
on u.user_id = e.user_id and type = 'P'
where u.user_id in (
select user_id from events e2 where TYPE = 'Music'
)



---
CREATE TABLE [emp1](
 [emp_id] [int] NULL,
 [emp_name] [varchar](50) NULL,
 [salary] [int] NULL,
 [manager_id] [int] NULL,
 [emp_age] [int] NULL,
 [dep_id] [int] NULL,
 [dep_name] [varchar](20) NULL,
 [gender] [varchar](10) NULL
) ;
insert into emp1 values(1,'Ankit',14300,4,39,100,'Analytics','Female')
insert into emp1 values(2,'Mohit',14000,5,48,200,'IT','Male')
insert into emp1 values(3,'Vikas',12100,4,37,100,'Analytics','Female')
insert into emp1 values(4,'Rohit',7260,2,16,100,'Analytics','Female')
insert into emp1 values(5,'Mudit',15000,6,55,200,'IT','Male')
insert into emp1 values(6,'Agam',15600,2,14,200,'IT','Male')
insert into emp1 values(7,'Sanjay',12000,2,13,200,'IT','Male')
insert into emp1 values(8,'Ashish',7200,2,12,200,'IT','Male')
insert into emp1 values(9,'Mukesh',7000,6,51,300,'HR','Male')
insert into emp1 values(10,'Rakesh',8000,6,50,300,'HR','Male')
insert into emp1 values(11,'Akhil',4000,1,31,500,'Ops','Male')

with cte as (
select *,
rank() over(partition by dep_id order by salary desc) as rnk,
count(1) over(partition by dep_id) as cnt
from
emp1)
select * from cte
where rnk = 3 or (cnt < 3 and cnt = rnk)


--
create table business_city (
business_date date,
city_id int
);
delete from business_city;
insert into business_city
values(cast('2020-01-02' as date),3),(cast('2020-07-01' as date),7),(cast('2021-01-01' as date),3),(cast('2021-02-03' as date),19)
,(cast('2022-12-01' as date),3),(cast('2022-12-15' as date),3),(cast('2022-02-28' as date),12);

with cte as (
select DATEPART(year, business_date) as b_year, city_id  from business_city b1)
select c2.b_year, count(distinct case when c1.city_id is null then c2.city_id end) as num_new_cities
from cte c1
right join cte c2 
on c1.b_year < c2.b_year and c1.city_id = c2.city_id
group by c2.b_year


select b_year, count(*) as cnt from (
select min(datepart(year, business_date)) as b_year, city_id
from business_city bc 
group by city_id ) x
group by b_year


-- consecutive empty seats
create table movie(
seat varchar(50),occupancy int
);
insert into movie values('a1',1),('a2',1),('a3',0),('a4',0),('a5',0),('a6',0),('a7',1),('a8',1),('a9',0),('a10',0),
('b1',0),('b2',0),('b3',0),('b4',1),('b5',1),('b6',1),('b7',1),('b8',0),('b9',0),('b10',0),
('c1',0),('c2',1),('c3',0),('c4',1),('c5',1),('c6',0),('c7',1),('c8',0),('c9',0),('c10',1);

select * from movie

with all_seats as (
select seat,
occupancy,
SUBSTRING(seat,1,1) as row_id,
cast(substring(seat,2,len(seat) - 1) as int) as seat_id,
sum(occupancy) over(partition by SUBSTRING(seat,1,1) order by cast(substring(seat,2,len(seat) - 1) as int) rows between current row and 3 following) as is_four_conse_empty,
count(occupancy) over(partition by SUBSTRING(seat,1,1) order by cast(substring(seat,2,len(seat) - 1) as int) rows between current row and 3 following) as is_four_seats
from movie ),
empty_seats as (
select * from all_seats
where is_four_conse_empty = 0 and is_four_seats = 4)
select c1.* from
all_seats c1
join empty_seats c2
on c1.row_id = c2.row_id
and c1.seat_id between c2.seat_id and c2.seat_id + 3

-- phone numbers with incoming and outgoing facilities
create table call_details  (
call_type varchar(10),
call_number varchar(12),
call_duration int
);

insert into call_details
values ('OUT','181868',13),('OUT','2159010',8)
,('OUT','2159010',178),('SMS','4153810',1),('OUT','2159010',152),('OUT','9140152',18),('SMS','4162672',1)
,('SMS','9168204',1),('OUT','9168204',576),('INC','2159010',5),('INC','2159010',4),('SMS','2159010',1)
,('SMS','4535614',1),('OUT','181868',20),('INC','181868',54),('INC','218748',20),('INC','2159010',9)
,('INC','197432',66),('SMS','2159010',1),('SMS','4535614',1);

select * from call_details;

select 
call_number,
sum(case when call_type = 'INC' then call_duration else 0 end) as total_inc_hrs,
sum(case when call_type = 'OUT' then call_duration else 0 end) as total_out_hrs,
count(distinct call_type) as type_cnt
from call_details cd 
where call_type in ('INC','OUT')
group by call_number 
having count(distinct call_type) = 2
and sum(case when call_type = 'OUT' then call_duration else 0 end) >= sum(case when call_type = 'INC' then call_duration else 0 end)

--
create table brands 
(
category varchar(20),
brand_name varchar(20)
);
insert into brands values
('chocolates','5-star')
,(null,'dairy milk')
,(null,'perk')
,(null,'eclair')
,('Biscuits','britannia')
,(null,'good day')
,(null,'boost');

with cte1 as (
select *,
row_number() over(order by (select null)) as row_id
from brands b ),
cte2 as (
select * ,
first_value(row_id) over(order by row_id rows between 1 FOLLOWING and 1 FOLLOWING) as next_row_id
from cte1 where category is not null)
select c2.category, c1.brand_name from cte1 c1
inner join cte2 c2
on c1.row_id >= c2.row_id and (c1.row_id < c2.next_row_id or c2.next_row_id is null)

--

create table students1
(
student_id int,
student_name varchar(20)
);
insert into students1 values
(1,'Daniel'),(2,'Jade'),(3,'Stella'),(4,'Jonathan'),(5,'Will');

create table exams
(
exam_id int,
student_id int,
score int);

insert into exams values
(10,1,70),(10,2,80),(10,3,90),(20,1,80),(30,1,70),(30,3,80),(30,4,90),(40,1,60)
,(40,2,70),(40,4,80);


select * from students1 s 
select * from exams e 

with cte1 as (
select *,
max(score) over(partition by exam_id) as max_score,
min(score) over(partition by exam_id) as min_score
from exams e )
select c.student_id,
s.student_name 
from cte1 c
join students1 s
on c.student_id =  s.student_id 
group by c.student_id, s.student_name having max(case when c.score = c.max_score or c.score = c.min_score then 1 else 0 end) = 0

--
create table phonelog(
    Callerid int, 
    Recipientid int,
    Datecalled datetime
);

insert into phonelog(Callerid, Recipientid, Datecalled)
values(1, 2, '2019-01-01 09:00:00.000'),
       (1, 3, '2019-01-01 17:00:00.000'),
       (1, 4, '2019-01-01 23:00:00.000'),
       (2, 5, '2019-07-05 09:00:00.000'),
       (2, 3, '2019-07-05 17:00:00.000'),
       (2, 3, '2019-07-05 17:20:00.000'),
       (2, 5, '2019-07-05 23:00:00.000'),
       (2, 3, '2019-08-01 09:00:00.000'),
       (2, 3, '2019-08-01 17:00:00.000'),
       (2, 5, '2019-08-01 19:30:00.000'),
       (2, 4, '2019-08-02 09:00:00.000'),
       (2, 5, '2019-08-02 10:00:00.000'),
       (2, 5, '2019-08-02 10:45:00.000'),
       (2, 4, '2019-08-02 11:00:00.000');
      

with cte as (
select *,
CONVERT(date, Datecalled) as date_called,
first_value(Recipientid) over(partition by Callerid, CONVERT(date, Datecalled) order by Datecalled) as first_receipt,
first_value(Recipientid) over(partition by Callerid, CONVERT(date, Datecalled) order by Datecalled desc) as last_receipt
from phonelog p)

select callerid, date_called, min(first_receipt) as receipt_id
from cte where first_receipt = last_receipt
group by callerid, date_called


--

create table candidates1 (
emp_id int,
experience varchar(20),
salary int
);
delete from candidates1;
insert into candidates1 values
(1,'Junior',10000),(2,'Junior',15000),(3,'Junior',40000),(4,'Senior',16000),(5,'Senior',20000),(6,'Senior',50000);

with seniors as (
select c.*,
sum(salary) over(order by salary) as budget_spent
from candidates1 c 
where experience = 'Senior'),
seniors_selected as (
select * from seniors where budget_spent < 75000),
juniors as (
select c.*,
sum(salary) over(order by salary) as budget_spent
from candidates1 c 
where experience = 'Junior')
select * from seniors_selected
union
select * from juniors where budget_spent <= (
select 75000 - max(budget_spent) from  seniors_selected 
)


with budgets as (
select *,
sum(salary) over(partition by experience order by salary rows between unbounded preceding and current row) as budget_needed
from candidates1 c )
,seniors as (
select * from budgets 
where experience = 'Senior' and budget_needed <= 70000)
select * from seniors
union
select * from budgets 
where experience = 'Junior' and budget_needed <= 70000 - (select max(budget_needed) from seniors)

--
select 
e1.emp_id , e1.emp_name , e2.emp_name as manager, e3.emp_name  as sr_manager
from emp e1 
join emp e2
on e1.manager_id = e2.emp_id 
join emp e3
on e2.manager_id = e3.emp_id 


create table brands2 (
price_year int,
name varchar(20),
price int
);
delete from brands2;
insert into brands2 values
(2018,'Visa',100),(2019,'Visa',110),(2020,'Visa',120),(2018,'Amex',100),(2019,'Amex',120),(2020,'Amex',110),(2018,'MC',100),(2019,'MC',100),(2020,'MC',110);


select * from brands2 b 

with cte as (
select *, first_value(price) over(partition by name order by price_year rows between 1 PRECEDING and 1 PRECEDING) as prev_price
from brands2)
select * from (
select count(case when price > prev_price then 1 end) as cond_count , count(*) - 1 as total_cnt, name from cte group by name) x
where cond_count = total_cnt

