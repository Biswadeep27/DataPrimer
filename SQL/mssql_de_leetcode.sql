-- Leetcode problem state

-- 177. Nth Highest Salary
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
      # Write your MySQL query statement below.
       with CTE as (
       select distinct e1.salary as SecondHighestSalary from employee e1 
       where (N - 1) = (select count(distinct e2.salary) 
       from Employee e2 where e2.salary > e1.salary ) )
       SELECT case when count(*) = 1 then SecondHighestSalary end as SecondHighestSalary
from cte

  );
END




-- 180. Consecutive Numbers

with cte1 as (
select l.*,
first_value(num) over(order by id rows between 1 preceding and 1 preceding) as prev_num
from logs l),
cte2 as (
select id, num, prev_num,
sum(case when num = prev_num or prev_num = NULL then 0 else 1 end) over(order by id) as grp
from cte1)
select distinct num as ConsecutiveNums from cte2 group by grp, num having count(*) >= 3

