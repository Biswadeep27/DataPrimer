CREATE TABLE [dbo].[orders](
order_id varchar(5) NOT NULL,
item varchar(5),
qty int
);

INSERT INTO orders values ('O4','A5',0);
values ('O1','A1',5),
	   ('O2','A2',1),
	   ('O3','A3',3);
	   
	  
SELECT * from orders o ;

with cte_orders as (
SELECT order_id , item , 1 as qty, 1 as increm, qty as max_qty
from orders o where qty > 0 
UNION ALL 
SELECT order_id , item , 1 as qty , increm + 1 as increm , max_qty
from cte_orders where increm < max_qty 

)
select order_id , item , qty 
from cte_orders 
order by order_id, item , qty ;