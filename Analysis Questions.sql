use project_Taxi_dataset;

-- Analysis Questions 
-- 1.	Variation of income per month among different customer segments
with CTE1 as 
	(select *, case 
			when age between 0 and 10 then "0-10"
            when age between 11 and 20 then "11-20"
            when age between 21 and 30 then "21-30"
            when age between 31 and 40 then "31-40"
            when age between 41 and 50 then "41-50"
            when age between 51 and 60 then "51-60"
            when age between 61 and 70 then "61-70"
            else "Above 70"
            end as age_group
	from customers)
Select age_group, 
sum(if(gender="Male", Income_per_month,0))/sum(if(gender="Male", 1,0)) as Male,
sum(if(gender="Female", Income_per_month,0))/sum(if(gender="Female", 1,0)) as Female
from CTE1
group by age_group
order by age_group;

-- 2.	The most common payment mode used by customers
create view customers1 as 
	(select *, case 
			when age between 0 and 10 then "0-10"
            when age between 11 and 20 then "11-20"
            when age between 21 and 30 then "21-30"
            when age between 31 and 40 then "31-40"
            when age between 41 and 50 then "41-50"
            when age between 51 and 60 then "51-60"
            when age between 61 and 70 then "61-70"
            else "Above 70"
            end as age_group
	from customers); -- creating a view that consists age group. 

-- based on age group 
select c1.age_group, 
sum(if(t.payment_mode="cash",1,0))as cash, 
sum(if(t.payment_mode="card",1,0))as card
from customers1 as c1 inner join transactions as t
on c1.customer_ID = t.customer_ID
group by c1.age_group
order by c1.age_group;

-- based on gender
select c.gender, 
sum(if(t.payment_mode="cash",1,0))/count(*) as cash, 
sum(if(t.payment_mode="card",1,0))/count( *)as card
from customers as c inner join transactions as t
on c.customer_ID = t.customer_ID
group by c.gender;

-- 3.	Cities having the highest and lowest number of taxi transactions.
with CTE2 as 
	(select city, count(transaction_ID) as `transaction counts`
	from taxi
	group by city)
select city, `transaction counts`, 
rank() over (order by `transaction counts` desc) as ranking
from CTE2;

-- 4.	Finding trends or patterns in taxi usage across different cities.
-- Finding pattern in genders in top 5 taxi transaction countries
with CTE3 as 
	(select t1.city, sum(if(c.gender="male",1,0)) as Males, 
	sum(if(c.gender="female",1,0)) as Females, count(*) as total,
	rank() over (order by count(*) desc) as ranking
	from customers as c 
	inner join transactions as t on c.customer_ID = t.customer_ID
	inner join taxi as t1 on t.transaction_ID = t1.transaction_Id 
	group by t1.city)
select round(avg(Males/(Males+Females)),2) as Males, 
round(Avg(Females/(Males+Females)),2) as Females
from CTE3 
where ranking <=5;

-- Finding pattern in genders in bottom 5 taxi transaction countries
with CTE3 as 
	(select t1.city, sum(if(c.gender="male",1,0)) as Males, 
	sum(if(c.gender="female",1,0)) as Females, count(*) as total,
	rank() over (order by count(*) asc) as ranking
	from customers as c 
	inner join transactions as t on c.customer_ID = t.customer_ID
	inner join taxi as t1 on t.transaction_ID = t1.transaction_Id 
	group by t1.city)
select round(avg(Males/(Males+Females)),2) as Males, 
round(Avg(Females/(Males+Females)),2) as Females
from CTE3 
where ranking <=5;

-- finding pattern in income range.
create view customers2 as 
(select *, case 
			when Income_per_month between 0 and 10000 then "0-10000"
            when Income_per_month between 10001 and 20000 then "10001-20000"
            when Income_per_month between 20001 and 30000 then "20001-30000"
            when Income_per_month between 30001 and 40000 then "30001-40000"
            else "Above 40000"
            end as income_range
from customers); -- creating a view that consists income range

-- finding pattern in income range for the top 5 countries in taxi usage
with CTE4 as 
	(select city, count(*), rank() over (order by count(*) desc) as ranking
	from taxi
	group by city)
select C2.income_range, count(*) as transactions
from CTE4 as C1 inner join taxi as t1 on C1.city = t1.city
inner join transactions as t2 on t1.transaction_ID = t2.transaction_ID
inner join customers2 as C2 on t2.customer_ID = C2.customer_ID
where ranking <= 5
group by C2.income_range
order by C2.income_range;

-- finding pattern in income range for the bottom 5 countries in taxi usage
with CTE5 as 
	(select city, count(*), rank() over (order by count(*) asc) as ranking
	from taxi
	group by city)
select C2.income_range, count(*) as transactions
from CTE5 as C1 inner join taxi as t1 on C1.city = t1.city
inner join transactions as t2 on t1.transaction_ID = t2.transaction_ID
inner join customers2 as C2 on t2.customer_ID = C2.customer_ID
where ranking <= 5
group by C2.income_range
order by C2.income_range;


-- 5.	Variation of the price charged for taxi rides with distance travelled and city
create view taxi1 as 
(Select *, case 
				when Distance_travelled between 0 and 10 then "0-10"
				when Distance_travelled between 10.001 and 20 then "10-20"
				when Distance_travelled between 20.001 and 30 then "20-30"
				when Distance_travelled between 30.001 and 40 then "30-40"
				when Distance_travelled between 40.001 and 50 then "40-50"
				else "Above 50"
				end as distance_range
from taxi); -- creating a view that consists distance range

-- for top 5 countries based on average price charged
with CTE6 as 
	(select city, avg(price_charged), 
	rank() over (order by avg(price_charged) desc) as ranking
	from taxi 
	group by city)
select t.distance_range, round(avg(t.price_charged),2) as `avg price charged`
from CTE6 as C inner join taxi1 t 
on c.city = t.city 
where ranking <=5
group by t.distance_range
order by t.distance_range;

-- for bottom 5 countries based on average price charged
with CTE7 as 
	(select city, avg(price_charged), 
	rank() over (order by avg(price_charged) asc) as ranking
	from taxi 
	group by city)
select t.distance_range, round(avg(t.price_charged),2) as `avg price charged`
from CTE7 as C inner join taxi1 t 
on c.city = t.city 
where ranking <=5
group by t.distance_range
order by t.distance_range;

-- 6.	Identifying seasonal trends or patterns in taxi transactions
select month(New_DOT) as slno, monthname(New_DOT) as Months, 
sum(if(year(New_Dot)=2016,1,0)) as "2016",
sum(if(year(New_Dot)=2017,1,0)) as "2017",
sum(if(year(New_Dot)=2018,1,0)) as "2018"
from taxi 
group by monthname(New_DOT), month(New_DOT)
order by month(New_DOT);

-- 7.	Comparison of companies in terms of the number of transactions and revenue generated
select company, 
round(count(transaction_ID)/(select count(transaction_ID) from taxi),3) as `percentage of transactions`,
round(sum(Price_charged)/(select sum(Price_charged) from taxi),3) as  `percentage of average revenue generated` 
from taxi
group by company;

-- 8.	Identifying trends or patterns in revenue and profit over time.
select month(New_DOT) as slno, monthname(New_DOT) as Months, 
Round(sum(price_charged),2) as Revenue, round(sum(price_charged-cost_of_trip),2) as profit
from taxi 
group by monthname(New_DOT), month(New_DOT)
order by month(New_DOT);