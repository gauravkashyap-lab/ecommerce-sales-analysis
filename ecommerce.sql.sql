
--1.Find the total number of customers.

select COUNT(*) as total_number
from customers;

--2. Find the total number of orders.

select COUNT(*) as total_num_of_orders
from orders;

select top 5 * from customers;

select top 5 * from products;

select top 5 * from orders;

select top 5 * from order_items;

select top 5 * from payments;

--3. Calculate the total sales amount.

select 
     SUM(o.total_amount) as total_sales
from 
    order_items o
join payments p on p.order_id = o.order_id  
where 
     p.payment_status = 'Success';

--4. Count the number of unique cities.

select 
      COUNT(distinct city) as total_unique_city
from customers;

--5. Find the minimum and maximum product price.

select 
     MIN(price) as minimum_price,
     MAX(price) as maximum_price
from products;

--6. Find top 10 total number of orders for each customer.

select top 5 * from customers;
select top 5 * from orders;
select top 5 * from payments;
select top 5 * from order_items;

select 
     customer_id,
     COUNT(order_id) as total_orders
from orders
group by customer_id;  

--7. Calculate total spending for each customer.

select 
     o.customer_id,
     SUM(oi.total_amount) as total_spending
from order_items oi
join orders o on oi.order_id = o.order_id
group by 
        o.customer_id;

--8. Find city-wise total sales.

select 
     c.city,
     SUM(oi.total_amount) as total_sales_per_city
from orders o
join order_items oi 
    on o.order_id = oi.order_id
join customers c
    on o.customer_id = c.customer_id
join payments p
    on o.order_id = p.order_id
where p.payment_status = 'Success'
group by c.city;

--9. Calculate category-wise total revenue.

select top 5 * from customers;
select top 5 * from orders;
select top 5 * from payments;
select top 5 * from order_items;
select top 5 * from products;

select 
      p.category,
      SUM(oi.total_amount) as total_revenue
from order_items oi
join products p
    on oi.product_id = p.product_id
join payments ps
    on oi.order_id = ps.order_id
where payment_status = 'Success'
group by p.category; 

--10. Find the top 5 highest spending customers.

select top 5
           c.customer_id,
           c.customer_name,
           SUM(oi.total_amount) as high_spending_customer
from order_items oi
join orders o
    on oi.order_id = o.order_id
join customers c
    on o.customer_id = c.customer_id
join payments p
    on oi.order_id = p.order_id 
where payment_status = 'Success'
    group by c.customer_name,
             c.customer_id
    order by high_spending_customer 
desc;

--11. Calculate the average order value per customer.

select 
      customer_id,
      AVG(order_value) as average_ordervalue
FROM(
    select 
          o.customer_id,
          o.order_id,
          SUM(oi.total_amount) as order_value
    from orders o
    join order_items oi  
        on o.order_id = oi.order_id
        where o.order_id IN(
            select order_id
            from payments
            where LOWER(payment_status) = 'success'
        ) 
        group by o.customer_id,
                 o.order_id
) t 
group by customer_id;

--12. Find product-wise total quantity sold.


select 
      p.product_name,
      SUM(quantity) as product_wise_quantity_sold
from order_items oi
join orders o
    on oi.order_id = o.order_id
join products p
    on oi.product_id = p.product_id
join payments ps
    on oi.order_id = ps.order_id
where o.order_id IN(
    select 
          order_id
    from payments 
    where LOWER(payment_status) = 'success'
) group by p.product_name;

--13. Generate a month-wise sales report

select top 2 * from customers;
select top 2 * from products;
select top 2 * from orders;
select top 2 * from order_items;
select top 2 * from payments;

select
      YEAR(o.order_date) as yearcount, 
      MONTH(o.order_date) as month_count,
      DATENAME(MONTH,o.order_date) as monthname,
      SUM(oi.total_amount) as total_sales_per_month
from orders o
    JOIN order_items oi
        on o.order_id = oi.order_id
    join payments p  
        on oi.order_id = p.order_id
    where o.order_id IN(
        select 
              order_id
        from payments
        where 
             LOWER(payment_status) = 'success'
    )
group by 
        YEAR(o.order_date),
        month(o.order_date),
        DATENAME(month,o.order_date)
order by yearcount;

--14. Count total orders based on payment mode.

select 
      payment_mode,
      COUNT(*) as total_orders_payment_based
from orders 
group by payment_mode;
      
--15. Compare failed vs successful payments.

SELECT 
      payment_status,
      COUNT(*) as comparing 
from payments
group by payment_status;

--Find the top 10 customers based on total spending.

select top 10
      c.customer_id,
      c.customer_name,
      SUM(total_amount) as total_spending
from order_items oi
    JOIN orders o
       on oi.order_id = o.order_id
    join customers c  
       on o.customer_id = c.customer_id
    JOIN payments p  
       on oi.order_id = p.order_id
    WHERE o.order_id IN(
        select 
              order_id
        from payments 
        where LOWER(payment_status) = 'success'
    )
group by c.customer_id,c.customer_name
order by total_spending
desc;

--17. Identify repeat customers (customers with multiple orders).

SELECT 
      c.customer_name,
      o.customer_id,
      COUNT(o.order_id) as repeatcustomers
from orders o  
    join customers c
        on o.customer_id = c.customer_id
group by 
        o.customer_id,
        c.customer_name
HAVING COUNT(o.order_id) > 1;

--18. Find customers whose orders do not have successful payments.

select 
      c.customer_name,
      o.order_id
from orders o  
    join customers c  
        on o.customer_id = c.customer_id
    join payments p  
        on o.order_id = p.order_id
WHERE o.order_id NOT IN(
    select 
          order_id
    from payments 
    where lower(payment_status) = 'success'
)
group by o.order_id,c.customer_name
order by o.order_id;

--Identify products that were never sold.

select 
     p.product_id,
     p.product_name
from products p
LEFT JOIN order_items oi  
         on p.product_id = oi.product_id
where oi.product_id is NULL;

--20. Analyze daily sales trends.

SELECT
      order_date,
      dailysales,
      LAG(dailysales) OVER(order by order_date) as previous_sale,
      dailysales - lag(dailysales) OVER(order by order_date) as DIFFERENCE, 

      CASE
          when dailysales > LAG(dailysales) OVER(order by order_date)
          THEN 'increase'
          when dailysales < LAG(dailysales) over (order by order_date)
          THEN 'decrease'
          else 'nochange'
      end as trends
FROM (
    select 
          o.order_date,
          SUM(total_amount) as dailysales
    from order_items oi  
       join orders o  
           on oi.order_id = o.order_id
        join payments p  
           on oi.order_id = p.order_id
        where o.order_id IN(
            select order_id
            from payments
            where LOWER(payment_status) = 'success'
        ) 
        group by o.order_date
) t;


--21. Calculate the running total of sales.

select 
      o.order_date,
      SUM(oi.total_amount) as total_amount,
      SUM(SUM(oi.total_amount)) OVER (order by o.order_date) as runningtotal
from order_items oi  
    join orders o  
        on oi.order_id = o.order_id
    where o.order_id IN(
        select 
              order_id
        from payments
        where LOWER(payment_status) = 'success'
    )
group by o.order_date
order by o.order_date;

--22. Calculate month-over-month growth using LAG function.

SELECT 
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    SUM(oi.total_amount) AS monthly_sales,
    
    LAG(SUM(oi.total_amount)) OVER (
        ORDER BY YEAR(o.order_date), MONTH(o.order_date)
    ) AS prev_month_sales,

    SUM(oi.total_amount) - LAG(SUM(oi.total_amount)) OVER (
        ORDER BY YEAR(o.order_date), MONTH(o.order_date)
    ) AS growth

FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY 
    YEAR(o.order_date),
    MONTH(o.order_date);

--23. Rank customers based on total spending.

select 
      c.customer_name,
      oi.order_id,
      SUM(oi.total_amount) as totalspend ,
      RANK() over (order by SUM(oi.total_amount) DESC) as ranking
from order_items oi  

    join orders o  
       on oi.order_id = o.order_id

    join customers c  
       on o.customer_id = c.customer_id

    where o.order_id IN(
        select 
              order_id
        from payments 
        where LOWER(payment_status) = 'success'
    )
group by c.customer_name,oi.order_id
order by ranking;

--Find the top product in each category.

select 
      category,
      product_name
FROM
    (
        SELECT
             p.category,
             p.product_name,
             RANK() OVER(partition by p.category  order by SUM(oi.quantity) DESC) as ranking
        from products p  
            join order_items oi  
                on p.product_id = oi.product_id
            where oi.order_id IN(
                select 
                      order_id
                from payments 
                WHERE LOWER(payment_status) = 'success'
            ) 
            group by 
                    p.category,
                    p.product_name
    )t
where ranking = 1;


--25. Identify the top 20% of customers contributing to 80% of total revenue (Pareto Analysis).

select * FROM(
    select 
          c.customer_id,
          c.customer_name,
          SUM(oi.total_amount) as total_sales,
          ROUND(
            SUM(SUM(oi.total_amount)) over (order by SUM(oi.total_amount) DESC)
            * 100.00 /
            SUM(SUM(oi.total_amount)) over () ,
            2) as cumulative 
    from order_items oi  
    join orders o on oi.order_id = o.order_id
    join customers c on o.customer_id = c.customer_id
    where o.order_id IN(
        select 
              order_id
              from payments 
              where LOWER(payment_status) = 'success'
    )
    group by c.customer_id,c.customer_name
)t
where cumulative <= 80;

