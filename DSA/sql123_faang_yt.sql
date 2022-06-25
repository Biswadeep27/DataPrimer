create table entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));

select * from entries ;

insert into entries 
values ('A','Bangalore','A@gmail.com',1,'CPU'),('A','Bangalore','A1@gmail.com',1,'CPU'),('A','Bangalore','A2@gmail.com',2,'DESKTOP')
,('B','Bangalore','B@gmail.com',2,'DESKTOP'),('B','Bangalore','B1@gmail.com',2,'DESKTOP'),('B','Bangalore','B2@gmail.com',1,'MONITOR');


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
SELECT name, resources
FROM entries GROUP BY name, resources) dr

SELECT tv.name, 
tv.total_visits,
mf.most_visited_floor,
 
FROM most_floor mf
JOIN (SELECT name, count(1) as total_visits 
FROM entries 
GROUP BY name ) tv
ON mf.name = tv.name 

select name, string_agg(resources,',') as resources_used 
from entries group by name


select * from orders;

DECLARE
    quantity integer := 30;
   
 select version()
 
 DECLARE
        quantity int := 80;
    BEGIN
        RAISE NOTICE 'Quantity here is %', quantity;  -- Prints 80
        RAISE NOTICE 'Outer quantity here is %', outerblock.quantity;  -- Prints 50
    END;


DO $$
DECLARE v_List TEXT;
BEGIN
  v_List := 'foobar' ;
  SELECT version(;
  -- ...
END $$;



DECLARE _accountid INT := 1;

