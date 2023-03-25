-- date functions

select date '2001-09-28' + interval '1 hour';

select date '2001-09-28' + interval '1 day';

select date '2022-06-18' + time '3:00';

select interval '1 day' * 21;

select timestamp '2022-06-18 3:00' - time '3:00'; 

select timestamp '2022-06-18 3:00' - interval  '1 hour';

select date_part('isodow', timestamp '2022-06-18 20:38:40');

select date_part('week', timestamp '2022-06-18 20:38:40');

select date_part('week', date '2022-06-18') - date_part('week', date '2022-06-09');

select extract('year' from date '2022-06-18');

-- for MS sqlserver - datepart('day' '<date-field>') , dateadd(interval,int increment,date field), datediff(interval,start-date,end-date)

-- given date := '2022-06-15'
-- 3nd Tuesday - Tue : 2




with first_tue as (
	select case when 2 - date_part('isodow', date '2022-06-15') > 0
		then 2 - date_part('isodow', date '2022-06-15')
		else 9 - date_part('isodow', date '2022-06-15') end as distance_from_tue
)
select cast(date '2022-06-15' + cast(distance_from_tue as int) + interval '2 week' as date) as nth_tue
from first_tue;




do $$ 
declare
   counter    integer := 1;
   first_name varchar(50) := 'John';
   last_name  varchar(50) := 'Doe';
   payment    numeric(11,2) := 20.5;
   given_date date := '2022-06-18';
begin 
   raise notice '% % % has been paid % USD', 
       counter, 
	   first_name, 
	   last_name, 
	   payment;
end $$;


do $$ 
declare
   given_date date := '2022-06-18';
begin 
   perform version();
end $$;

