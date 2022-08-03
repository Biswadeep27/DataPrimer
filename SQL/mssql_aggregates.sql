CREATE TABLE [dbo].[int_orders](
 [order_number] [int] NOT NULL,
 [order_date] [date] NOT NULL,
 [cust_id] [int] NOT NULL,
 [salesperson_id] [int] NOT NULL,
 [amount] [float] NOT NULL
) ON [PRIMARY]
GO
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (30, CAST(N'1995-07-14' AS Date), 9, 1, 460)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (10, CAST(N'1996-08-02' AS Date), 4, 2, 540)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (40, CAST(N'1998-01-29' AS Date), 7, 2, 2400)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (50, CAST(N'1998-02-03' AS Date), 6, 7, 600)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (60, CAST(N'1998-03-02' AS Date), 6, 7, 720)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (70, CAST(N'1998-05-06' AS Date), 9, 7, 150)
INSERT [dbo].[int_orders] ([order_number], [order_date], [cust_id], [salesperson_id], [amount]) VALUES (20, CAST(N'1999-01-30' AS Date), 4, 8, 1800);

SELECT * FROM int_orders io ;


SELECT
	salesperson_id,
	order_date,
	order_number,
	amount,
	sum(amount) over(PARTITION BY salesperson_id) as sum_amount
FROM
	int_orders io ;


SELECT
	salesperson_id,
	order_date,
	order_number,
	amount,
	sum(amount) over(ORDER BY order_date) as sum_amount
FROM
	int_orders io ;


SELECT
	salesperson_id,
	order_date,
	order_number,
	amount,
	sum(amount) over(PARTITION BY salesperson_id ORDER BY order_date) as sum_amount
FROM
	int_orders io ;


-- rolling sum

SELECT
	salesperson_id,
	order_date,
	order_number,
	amount,
	sum(amount) over(ORDER BY order_date ROWS BETWEEN 2 PRECEDING and CURRENT ROW) as sum_amount
FROM
	int_orders io ;

SELECT
	salesperson_id,
	order_date,
	order_number,
	amount,
	sum(amount) over(ORDER BY order_date ROWS BETWEEN 3 PRECEDING and 1 PRECEDING) as sum_amount
FROM
	int_orders io ;


SELECT
	salesperson_id,
	order_date,
	order_number,
	amount,
	sum(amount) over(ORDER BY order_date ROWS BETWEEN 1 PRECEDING and 1 FOLLOWING) as sum_amount
FROM
	int_orders io ;

SELECT
	salesperson_id,
	order_date,
	order_number,
	amount,
	sum(amount) over(ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING and CURRENT ROW) as sum_amount
FROM
	int_orders io ;


SELECT
	salesperson_id,
	order_date,
	order_number,
	amount,
	sum(amount) over(PARTITION BY salesperson_id ORDER BY order_date ROWS BETWEEN 1 PRECEDING and CURRENT ROW) as sum_amount
FROM
	int_orders io ;


--lag & lead
SELECT
	salesperson_id,
	order_date,
	order_number,
	amount,
	sum(amount) over(ORDER BY order_date ROWS BETWEEN 1 PRECEDING and 1 PRECEDING) as sum_amount
FROM
	int_orders io ;
