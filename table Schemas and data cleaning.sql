Create database project_Taxi_dataset;
use project_Taxi_dataset;
-- creating the table with schemas and also normalizing the the tables. 
create table cities
(City varchar(30) primary key,
Population int,
Users int);

create table customers
(Customer_ID int primary key,
Gender varchar(10),
Age int,
Income_per_month int);

create table transactions
(Transaction_ID int primary key,
Customer_ID int,
Payment_Mode varchar(10),
constraint t_fk1 foreign key(Customer_ID) references customers(Customer_ID));

create table taxi
(Transaction_ID int,
Date_of_Travel varchar(30),
Company varchar(50),
City varchar(30),
Distance_Travelled double,
Price_Charged double,
Cost_of_Trip double,
constraint t1_fk1 foreign key(Transaction_ID) references transactions(Transaction_ID),
constraint t1_fk2 foreign key(City) references cities(City));

-- data cleaning for table "taxi" as the date of travel is in varchar format
Alter table taxi
add column New_DOT date;
set SQL_SAFE_UPDATEs=0;
Update taxi 
set new_DOT = str_to_date(Date_of_Travel,"%d-%m-%Y");
