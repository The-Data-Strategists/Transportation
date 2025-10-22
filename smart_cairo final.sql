--
 -- data cleaning
-- 1 detecting null values for customer table
-- 2 detecting duplicates in customer table
-- there is no null in data
-- 3 detecting outliers using Compute IQR bounds using percentile rank (robust to outliers) to detect outliers for non nomal distrubution data in customer table
-- no outliers was detected
-- after using both IQR & std no outliers in this data
-- data cleaning gor driver table
-- 1 detecting duplicate values
-- no duplicate data found
-- 2 detecting null values in driver table
-- no null values in this data
-- 3 detecting outliers using IQR and empircal rule
-- modifiying types of ID in each table to be primary key so that can be used as forigen key in trips fact 
-- to add fuel price id as a primary key as it wasnot existed to use it in relations
-- to change type of customer id from in to foregin key to be used in relatio
-- to change type of driver id from in to foregin key to be used in relations
-- this code to fill null values of fuelprice_id and joining both date of trips and fuelprice (dates are adjacent together)
-- make copy to can return back for each table
-- to update fuelprice & determine which car model & year used which type of fuel
-- updates fares according to new fuel prices
 -- data cleaning for trips table
 -- 1 remove dupilcates
-- 2 detecting Null values
-- 3 detecting outliers for distance , duration & fare_egp using IQR amd emprical rule

-- Most Active day and Hour by Total Trip duration
    -- Most Active day and Hour by Total distance_km
      -- Most Active day and Hour by Total Trip num 
   -- Most Active day by Total Trip number
-- What are the most used payment methods in trips?
   -- Most Used Payment Methods During active Hour
 -- Number of Trips per Car model 
 -- Trip Count by Car Model and Fuel Type  
 --  Which Fuel Type Was Used Most in Trips?  
    -- number of trips for driver 
    -- add new column rating category
  -- Top 3 Car Models by Driver Rating and Trip Count  
  -- Which Car Models Generated the Most Revenue and Trips? 
--



 -- data cleaning
-- 1 detecting null values for customer table
use smart_mobilty;
select * from customer
where customer_id or age or gender or city_area or signup_date is null;
select * from customer
where customer_id  is null;
select * from customer
where age  is null;
select * from customer
where gender  is null;
select * from customer
where city_area  is null;
select * from customer
where signup_date  is null;
-- there is no null in data
-- 2 detecting duplicates in customer table
select distinct customer_id , age, gender ,city_area, signup_date from customer ;
-- no dupicate in data
-- 3 detecting outliers using Compute IQR bounds using percentile rank (robust to outliers) to detect outliers for non nomal distrubution data in customer table
WITH ranked AS (
  SELECT 
    age,
    PERCENT_RANK() OVER (ORDER BY age) AS pr
  FROM customer
  WHERE age IS NOT NULL
),
quartiles AS (
  SELECT
    MAX(CASE WHEN pr <= 0.25 THEN age END) AS q1,
    MAX(CASE WHEN pr <= 0.75 THEN age END) AS q3
  FROM ranked
),
bounds AS (
  SELECT
    q1, q3,
    (q3 - q1) AS iqr,
    (q1 - 1.5*(q3 - q1)) AS lower_bound,
    (q3 + 1.5*(q3 - q1)) AS upper_bound
  FROM quartiles
)
SELECT age
FROM customer
JOIN bounds b
  ON age IS NOT NULL
WHERE age < b.lower_bound OR age > b.upper_bound;
-- to detect outliers 
select * from customer where age > (select avg(age) + 3 * stddev(age) from customer)
or age < (select avg(age) - 3 * stddev(age) from customer);
-- after using both IQR & std no outliers in this data

-- data cleaning gor driver table
select * from driver;
-- 1 detecting duplicate values
select distinct driver_id , car_model , car_year, rating,join_date from driver;
-- no duplicate data found
-- 2 detecting null values in driver table
select * from driver 
where driver_id or car_model or car_year or rating or join_date is null; 
-- no null values in this data
-- 3 detecting outliers using IQR and empircal rule

WITH ranked AS (
  SELECT 
    rating,
    PERCENT_RANK() OVER (ORDER BY rating) AS pr
  FROM driver
  WHERE rating IS NOT NULL
),
quartiles AS (
  SELECT
    MAX(CASE WHEN pr <= 0.25 THEN rating END) AS q1,
    MAX(CASE WHEN pr <= 0.75 THEN rating END) AS q3
  FROM ranked
),
bounds AS (
  SELECT
    q1, q3,
    (q3 - q1) AS iqr,
    (q1 - 1.5*(q3 - q1)) AS lower_bound,
    (q3 + 1.5*(q3 - q1)) AS upper_bound
  FROM quartiles
)
SELECT rating
FROM driver
JOIN bounds b
  ON rating IS NOT NULL
WHERE rating < b.lower_bound OR rating > b.upper_bound;
-- to detect outliers 

select * from driver where rating > (select avg(rating) + 3 * stddev(rating) from driver)
or rating < (select avg(rating) - 3 * stddev(rating) from driver);
-- no outliers in driver table

-- data cleaning for fuel price table
-- 1 removing duplicates
select distinct fuelprice_id, month , octane92_price,octane95_price , diesel_price from fuelprice;
-- 2 detecting null values
select * from fuelprice
where fuelprice_id is null;
delete from fuelprice where fuelprice_id is null;
select * from fuelprice
where month or octane92_price or octane95_price or diesel_price is null;
-- no null values
-- 3 detecting outliers using IQR & emprical rule for fuel prices
-- for octane 92 price
WITH ranked AS (
  SELECT 
    octane92_price,
    PERCENT_RANK() OVER (ORDER BY octane92_price) AS pr
  FROM fuelprice
  WHERE  octane92_price IS NOT NULL
),
quartiles AS (
  SELECT
    MAX(CASE WHEN pr <= 0.25 THEN octane92_price END) AS q1,
    MAX(CASE WHEN pr <= 0.75 THEN octane92_price END) AS q3
  FROM ranked
),
bounds AS (
  SELECT
    q1, q3,
    (q3 - q1) AS iqr,
    (q1 - 1.5*(q3 - q1)) AS lower_bound,
    (q3 + 1.5*(q3 - q1)) AS upper_bound
  FROM quartiles
)
SELECT  octane92_price
FROM fuelprice
JOIN bounds b
  ON  octane92_price IS NOT NULL
WHERE  octane92_price < b.lower_bound OR  octane92_price > b.upper_bound;

select * from fuelprice where  octane92_price > (select avg( octane92_price) + 3 * stddev( octane92_price) from fuelprice)
or  octane92_price < (select avg( octane92_price) - 3 * stddev( octane92_price) from fuelprice);

-- for octane 95 price
WITH ranked AS (
  SELECT 
    octane95_price,
    PERCENT_RANK() OVER (ORDER BY octane95_price) AS pr
  FROM fuelprice
  WHERE  octane95_price IS NOT NULL
),
quartiles AS (
  SELECT
    MAX(CASE WHEN pr <= 0.25 THEN octane95_price END) AS q1,
    MAX(CASE WHEN pr <= 0.75 THEN octane95_price END) AS q3
  FROM ranked
),
bounds AS (
  SELECT
    q1, q3,
    (q3 - q1) AS iqr,
    (q1 - 1.5*(q3 - q1)) AS lower_bound,
    (q3 + 1.5*(q3 - q1)) AS upper_bound
  FROM quartiles
)
SELECT  octane95_price
FROM fuelprice
JOIN bounds b
  ON  octane95_price IS NOT NULL
WHERE  octane95_price < b.lower_bound OR  octane95_price > b.upper_bound;

select * from fuelprice where  octane95_price > (select avg( octane95_price) + 3 * stddev( octane95_price) from fuelprice)
or  octane95_price < (select avg( octane95_price) - 3 * stddev( octane95_price) from fuelprice);

-- for disel price
WITH ranked AS (
  SELECT 
    diesel_price,
    PERCENT_RANK() OVER (ORDER BY diesel_price) AS pr
  FROM fuelprice
  WHERE  diesel_price IS NOT NULL
),
quartiles AS (
  SELECT
    MAX(CASE WHEN pr <= 0.25 THEN diesel_price END) AS q1,
    MAX(CASE WHEN pr <= 0.75 THEN diesel_price END) AS q3
  FROM ranked
),
bounds AS (
  SELECT
    q1, q3,
    (q3 - q1) AS iqr,
    (q1 - 1.5*(q3 - q1)) AS lower_bound,
    (q3 + 1.5*(q3 - q1)) AS upper_bound
  FROM quartiles
)
SELECT  diesel_price
FROM fuelprice
JOIN bounds b
  ON  diesel_price IS NOT NULL
WHERE  diesel_price < b.lower_bound OR  diesel_price > b.upper_bound;

select * from fuelprice where  diesel_price > (select avg( diesel_price) + 3 * stddev( diesel_price) from fuelprice)
or diesel_price < (select avg( diesel_price) - 3 * stddev( diesel_price) from fuelprice);
-- no outliers was detected

create table if not exists  customer (
customer_id int primary key auto_increment not null,
age int not null,
gender varchar (30) not null,
city_area varchar (40) not null,
signup_data date
);

create table if not exists driver(
driver_id int primary key auto_increment not null,
car_model varchar (40) not null,
car_year year not null,
rating decimal (10,2) not null,
join_date date
);

-- modifiying types of ID in each table to be primary key so that can be used as forigen key in trips fact 
alter table customer
modify customer_id int primary key auto_increment not null;

alter table driver
modify driver_id int primary key auto_increment not null;

-- to add fuel price id as a primary key as it wasnot existed to use it in relations
alter table fuelprice
add column fuelprice_id int primary key auto_increment not null;

-- to add fuel price id as an ID  as it wasnot existed to use it in relations
alter table trips
add column fuelprice_id int not null;

alter table trips
modify trip_id int primary key auto_increment not null;

-- to change type of customer id from in to foregin key to be used in relations
alter table trips
add constraint customer_id
foreign key (customer_id) references customer(customer_id);

-- to change type of driver id from in to foregin key to be used in relations
alter table trips
add constraint driver_id
foreign key (driver_id) references driver(driver_id);

-- to change type of driver id from in to foregin key to be used in relations
alter table trips
add constraint fuelprice_id
foreign key (fuelprice_id) references fuelprice(fuelprice_id);

select * from trips;
-- this code to fill null values of fuelprice_id and joining both date of trips and fuelprice (dates are adjacent together)
update trips t
join (
    select t.trip_id, f.fuelprice_id
    from trips t
    join fuelprice f
      on f.month = (
        select max(month)
        from fuelprice
        where month <= date(t.date_time)
      )
) x on t.trip_id = x.trip_id
set t.fuelprice_id = x.fuelprice_id
where t.fuelprice_id is null;
---------------------------------------------
set sql_safe_updates=0;

-- make copy to can return back for each table
create table customer_copy
like customer;

create table driver_copy
like driver;

create table metro_copy
like metro;

create table trips_copy
like trips;

-- to update fuelprice & determine which car model & year used which type of fuel
alter table driver
add column fuel_type varchar(30);

update driver
set fuel_type=case 
when car_model in  ('Chevrolet', 'Nissan')  then '92'
when car_model in  ('Toyota','Hyundai','Kia') and car_year <= 2015 then '92'
when car_model in  ('Toyota','Hyundai','Kia') and car_year > 2015 then '95'
else '92'
end;

-- updates fares according to new fuel prices
update trips t
join driver d on t.driver_id = d.driver_id
join fuelprice f 
 on f.month <= date(t.date_time)
set t.fare_egp = 
    t.distance_km * (
    case
     when d.fuel_type = '92' then f.octane92_price
     when d.fuel_type = '95' then f.octane95_price
     else 0
     end)
where f.month = (
    select max(f2.month) 
    from fuelprice f2
    where f2.month <= date(t.date_time)
);

select * from trips;
alter table trips
modify fare_egp decimal (10,2) not null;
 -- data cleaning for trips table
 -- 1 remove dupilcates
 select distinct trip_id , customer_id , driver_id, start_location, end_location, distance_km , duration_min , fare_egp, payment_method,date_time, fuelprice_id from trips;
 -- 2 detecting Null values
 select * from trips
 where  trip_id or customer_id or driver_id or start_location or end_location or distance_km or duration_min or fare_egp or payment_method or date_time or fuelprice_id is null;

-- 3 detecting outliers for distance , duration & fare_egp using IQR amd emprical rule
WITH ranked AS (
  SELECT 
    distance_km ,
    PERCENT_RANK() OVER (ORDER BY distance_km) AS pr
  FROM trips
  WHERE distance_km IS NOT NULL
),
quartiles AS (
  SELECT
    MAX(CASE WHEN pr <= 0.25 THEN distance_km END) AS q1,
    MAX(CASE WHEN pr <= 0.75 THEN distance_km END) AS q3
  FROM ranked
),
bounds AS (
  SELECT
    q1, q3,
    (q3 - q1) AS iqr,
    (q1 - 1.5*(q3 - q1)) AS lower_bound,
    (q3 + 1.5*(q3 - q1)) AS upper_bound
  FROM quartiles
)
SELECT distance_km
FROM trips
JOIN bounds b
  ON distance_km IS NOT NULL
WHERE distance_km < b.lower_bound OR distance_km > b.upper_bound;
-- to detect outliers 
select * from trips where distance_km > (select avg(distance_km) + 3 * stddev(distance_km) from trips)
or distance_km < (select avg(distance_km) - 3 * stddev(distance_km) from trips);
-- no outliers in distance km
-- for duartion
 WITH ranked AS (
  SELECT 
    duration_mi ,
    PERCENT_RANK() OVER (ORDER BY duration_min) AS pr
  FROM trips
  WHERE duration_min IS NOT NULL
),
quartiles AS (
  SELECT
    MAX(CASE WHEN pr <= 0.25 THEN duration_min END) AS q1,
    MAX(CASE WHEN pr <= 0.75 THEN duration_min END) AS q3
  FROM ranked
),
bounds AS (
  SELECT
    q1, q3,
    (q3 - q1) AS iqr,
    (q1 - 1.5*(q3 - q1)) AS lower_bound,
    (q3 + 1.5*(q3 - q1)) AS upper_bound
  FROM quartiles
)
SELECT duration_min
FROM trips
JOIN bounds b
  ON duration_min IS NOT NULL
WHERE duration_min < b.lower_bound OR duration_min > b.upper_bound;
-- to detect outliers 
select * from trips where duration_min > (select avg(duration_min) + 3 * stddev(duration_min) from trips)
or duration_min < (select avg(duration_min) - 3 * stddev(duration_min) from trips);
-- no outliers in duration
-- outliers for fares
 WITH ranked AS (
  SELECT 
    fare_EGP ,
    PERCENT_RANK() OVER (ORDER BY fare_EGP) AS pr
  FROM trips
  WHERE fare_EGP IS NOT NULL
),
quartiles AS (
  SELECT
    MAX(CASE WHEN pr <= 0.25 THEN fare_EGP END) AS q1,
    MAX(CASE WHEN pr <= 0.75 THEN fare_EGP END) AS q3
  FROM ranked
),
bounds AS (
  SELECT
    q1, q3,
    (q3 - q1) AS iqr,
    (q1 - 1.5*(q3 - q1)) AS lower_bound,
    (q3 + 1.5*(q3 - q1)) AS upper_bound
  FROM quartiles
)
SELECT fare_EGP
FROM trips
JOIN bounds b
  ON fare_EGP IS NOT NULL
WHERE fare_EGP< b.lower_bound OR fare_EGP > b.upper_bound;
-- to detect outliers 
select * from trips where fare_EGP > (select avg(fare_EGP) + 3 * stddev(fare_EGP) from trips)
or fare_EGP < (select avg(fare_EGP) - 3 * stddev(fare_EGP) from trips);
-- no outliers detected in fares
---------------------------------------
-- total sum of fare 

select *from trips;
select sum(fare_egp) as sum_fare
from trips; 
-- total number of trips 

select count(trip_id) as total_trips
from trips;

 -- gender and number of trips 
 
SELECT customer.gender, COUNT(trips.trip_id) AS trip_count
FROM customer
LEFT JOIN trips
ON customer.customer_id = trips.customer_id
GROUP BY customer.gender;
 
 -- customer city area and number of trips 
 
select customer.city_area,count(trips.trip_id) as trip_count
from customer
left join trips
on customer.customer_id = trips.customer_id
group by customer.city_area;


-- Most Active Hour by Total Trip duration 

SELECT 
    HOUR(date_time) AS trip_hour,
    SUM(duration_min) AS total_duration
FROM 
    trips
GROUP BY 
    HOUR(date_time)
ORDER BY 
    total_duration DESC
    limit 1 ;


-- Most Active Hour by Total Trip num

SELECT 
    HOUR(date_time) AS trip_hour,
    count(trip_id) AS total_trip
FROM 
    trips
GROUP BY 
    HOUR(date_time)
ORDER BY 
    total_trip desc
    limit 2;


-- Most Active day and Hour by Total Trip duration

SELECT 
    DAYNAME(date_time) AS trip_day,
    HOUR(date_time) AS trip_hour,
    SUM(duration_min) AS total_duration
FROM 
    trips
GROUP BY 
    DAYNAME(date_time), HOUR(date_time)
ORDER BY 
    total_duration DESC
    limit 2; 
    
    -- Most Active day and Hour by Total distance_km
    
   SELECT 
    DAYNAME(date_time) AS trip_day,
    HOUR(date_time) AS trip_hour,
    SUM(distance_km) AS total_distance
FROM 
    trips
GROUP BY 
    DAYNAME(date_time), HOUR(date_time)
ORDER BY 
    total_distance DESC
    limit 2;  
    
    
  -- Most Active day and Hour by Total Trip num 
    
    SELECT 
    DAYNAME(date_time) AS trip_day,
    HOUR(date_time) AS trip_hour,
    count(trip_id) AS total_trip
FROM 
    trips
GROUP BY 
    DAYNAME(date_time), HOUR(date_time)
ORDER BY 
    total_trip DESC
    limit 3;  
    
   -- Most Active day by Total Trip number
    SELECT 
    DAYNAME(date_time) AS trip_day,
    count(trip_id) AS total_trip
FROM 
    trips
GROUP BY 
    DAYNAME(date_time)
ORDER BY
    total_trip DESC
    limit 3; 
    
-- What are the most used payment methods in trips?   
    
    SELECT 
    payment_method AS trip_payment,
    COUNT(trip_id) AS total_trip
FROM 
    trips
GROUP BY 
    payment_method
ORDER BY
    total_trip DESC ; 
    
   -- Most Used Payment Methods During active Hour


    SELECT 
    payment_method,
    COUNT(trip_id) AS total_trips
FROM 
    trips
WHERE 
    HOUR(date_time) = (
        SELECT 
            HOUR(date_time)
        FROM 
            trips
        GROUP BY 
            HOUR(date_time)
        ORDER BY 
            COUNT(trip_id) DESC
        LIMIT 1
    )
GROUP BY 
    payment_method
ORDER BY 
    total_trips DESC;
 ----------------------------------------------------------- 
  
 -- Number of Trips per Car model 
  
 select driver.car_model,count(trips.trip_id) as trip_count
from driver
left join trips
on driver.driver_id = trips.driver_id
group by driver.car_model;
    
    
select*from driver;   
 
 -- Trip Count by Car Model and Fuel Type  
 
 
    SELECT 
    driver.car_model AS driver_car,
    driver.fuel_type AS driver_fuel,
    COUNT(trips.trip_id) AS total_trip
FROM 
    driver
LEFT JOIN 
    trips ON driver.driver_id = trips.driver_id
GROUP BY 
    driver.car_model, driver.fuel_type
ORDER BY 
    total_trip deSC
    limit 3; 
    
    
 --  Which Fuel Type Was Used Most in Trips?  
 
    SELECT 
    driver.fuel_type, 
    COUNT(trips.trip_id) AS total_trips
FROM 
    driver
JOIN 
    trips ON driver.driver_id = trips.driver_id
GROUP BY 
    driver.fuel_type;
    
    -- number of trips for driver 
    select
    driver_id,count(*) as total_trips
    from trips
    group by driver_id
    order by total_trips desc
    limit 1;  
    
    
    select *from driver; 
    
    SELECT 
   driver.driver_id,
   driver.rating,
    CASE 
        WHEN rating >= 4.5 THEN 'excellant'
        WHEN rating >= 3.5 THEN ' very good'
        WHEN rating >= 2.5 THEN 'good'
        ELSE 'boor'
    END AS rating_category
FROM 
    driver; 
    -- add new column rating category
    
    ALTER TABLE driver
ADD COLUMN rating_category VARCHAR(20); 
-------------------------------

SET SQL_SAFE_UPDATES = 0; 


UPDATE driver
SET rating_category = 
    CASE 
        WHEN rating between 4.5 and 5 THEN 'Excellent'
        WHEN rating between 3.9 and 4.45  THEN 'Very good'
        WHEN rating between 3.5 and 3.88 THEN 'Good'
    END
    where driver_id is not null; 
    
    select*from driver; 
    
  -- Top 3 Car Models by Driver Rating and Trip Count  
  
  
  SELECT 
    driver.car_model,
    driver.rating_category AS driver_rating,
    COUNT(trips.trip_id) AS total_trips
FROM 
    driver 
LEFT JOIN 
    trips  ON driver.driver_id = trips.driver_id
GROUP BY 
    driver.car_model, driver.rating_category
ORDER BY 
    driver_rating desc,
    total_trips DESC
    limit 3;  
    
    
    SELECT 
    driver.rating_category AS driver_rating,
    driver.car_year, driver.car_model,
    COUNT(trips.trip_id) AS total_trips
FROM 
    driver 
LEFT JOIN 
    trips  ON driver.driver_id = trips.driver_id
GROUP BY 
    driver.car_model,driver.car_year, driver.rating_category
ORDER BY 
    driver_rating desc,
    total_trips DESC
    limit 5;   
    
  -- Which Car Models Generated the Most Revenue and Trips? 
    
    SELECT 
    driver.car_model AS driver_car,
    driver.car_year as car_year,
    driver.fuel_type AS driver_fuel,
    sum(fare_egp) as total_fare,
    COUNT(trips.trip_id) AS total_trip
FROM 
    driver
LEFT JOIN 
    trips ON driver.driver_id = trips.driver_id
GROUP BY 
    driver.car_model,driver.car_year, driver.fuel_type
ORDER BY 
total_fare desc,
    total_trip deSC
    limit 2; 