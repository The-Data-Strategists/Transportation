select *from customer
order by age desc;


SELECT 
    HOUR(signup_date) AS hour_of_day,
    COUNT(*) AS total_signups
FROM customer
GROUP BY HOUR(signup_date)
ORDER BY total_signups DESC; 


-- Which Day of the Week Has the Most Customer Signups?

SELECT 
    DAYNAME(signup_date) AS day_of_week,
    COUNT(*) AS total_signups
FROM customer
GROUP BY DAYNAME(signup_date)
ORDER BY total_signups DESC; 

SET SQL_SAFE_UPDATES = 0; 
alter table customer
add column age_category varchar(30);

UPDATE customer
SET age_category = 
    CASE 
    WHEN age BETWEEN 18 AND 24 THEN 'Young_Adult'
    WHEN age BETWEEN 25 AND 39 THEN 'Adult'
    WHEN age BETWEEN 40 AND 59 THEN 'Middel_age-Adult'
    WHEN age BETWEEN 60 AND 64 THEN 'Older_Adult'
    ELSE 'Out of range'
END; 

-- number of customer by age_gategory


SELECT 
    age_category,
    COUNT(*) AS total_customers
FROM customer
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM trips
)
GROUP BY age_category
ORDER BY total_customers DESC;   

-- Trip Count by Customer Age Category

SELECT 
    customer.age_category,
    COUNT(trips.trip_id) AS total_trips
FROM customer 
JOIN trips  ON customer.customer_id = trips.customer_id
GROUP BY  customer.age_category
ORDER BY total_trips DESC; 


-- Customer Count by Age_category and City Area

SELECT 
    age_category,
    city_area,
    count(*) as total_customer
FROM customer
group by age_category,city_area;

 
 -- Peak Hour Trip Count by Age Category
 
SELECT 
    customer.age_category AS customer_category,
    COUNT(trips.trip_id) AS total_trips
FROM 
    trips 
JOIN 
    customer  ON trips.customer_id = customer.customer_id
WHERE 
    HOUR(trips.date_time) BETWEEN 6 AND 7
GROUP BY 
    customer.age_category
ORDER BY 
    total_trips DESC; 
    
    
   
   ---------------------------------------
   SELECT 
    customer.age_category,
    COUNT(trips.trip_id) AS total_trips
FROM customer 
JOIN trips  ON customer.customer_id = trips.customer_id
GROUP BY  customer.age_category
ORDER BY total_trips DESC; 

SELECT 
    age_category,
    city_area,
    count(*) as total_customer
FROM customer
group by age_category,city_area;


SELECT 
    customer.age_category AS customer_category,
    COUNT(trips.trip_id) AS total_trips
FROM 
    trips 
JOIN 
    customer  ON trips.customer_id = customer.customer_id
WHERE 
    HOUR(trips.date_time) BETWEEN 6 AND 7
GROUP BY 
    customer.age_category
ORDER BY 
    total_trips DESC;  
    
    
    ------------------------------------
    -- Trip Count by City Area During Peak Hour
    
    
    SELECT 
    customer.city_area  AS customer_area,
    COUNT(trips.trip_id) AS total_trips
FROM 
    trips 
JOIN 
    customer  ON trips.customer_id = customer.customer_id
WHERE 
    HOUR(trips.date_time) BETWEEN 6 AND 7
GROUP BY 
    customer.city_area
ORDER BY 
    total_trips DESC;  
    
    ----------------------------------------
   SELECT 
    trips.start_location as trip_location,
    COUNT(trips.trip_id) AS total_trips
FROM 
    trips 
WHERE 
    HOUR(trips.date_time) BETWEEN 6 AND 7
GROUP BY 
    trips.start_location
ORDER BY 
    total_trips DESC;  
    
    
-----------------------------
  SELECT 
    trips.end_location as trip_location,
    COUNT(trips.trip_id) AS total_trips
FROM 
    trips 
WHERE 
    HOUR(trips.date_time) BETWEEN 6 AND 7
GROUP BY 
    trips.end_location
ORDER BY 
    total_trips DESC;    
    
    ------------------------------
    -- trips year
   SELECT 
    DATE(trips.date_time) AS trip_date,
    fuelprice.octane92_price,
    fuelprice.octane95_price,
    COUNT(trips.trip_id) AS total_trips
FROM 
    trips 
JOIN 
    fuelprice ON DATE(trips.date_time) = fuelprice.octane92_price,fuelprice.octane95_price
GROUP BY 
    trip_date, fuelprice
ORDER BY 
    trip_date; 
    
    
    
SELECT 
    YEAR(date_time) AS trip_year,
    COUNT(*) AS total_trips
FROM 
    trips
GROUP BY 
    YEAR(date_time)
ORDER BY 
    trip_year; 
    
    
    
    SELECT 
    YEAR(date_time) AS trip_year,
    COUNT(*) AS total_trips,
    ROUND(AVG(fare_egp), 2) AS average_fare
FROM 
    trips
GROUP BY 
    YEAR(date_time)
ORDER BY 
    trip_year; 
    
    SELECT 
    YEAR(date_time) AS trip_year,
    COUNT(*) AS total_trips,
    ROUND(sum(fare_egp), 2) AS sum_fare
FROM 
    trips
GROUP BY 
    YEAR(date_time)
ORDER BY 
    trip_year; 
    
    SELECT 
    YEAR(date_time) AS trip_year,
    COUNT(*) AS total_trips,
    ROUND(AVG(fare_egp), 2) AS average_fare
FROM 
    trips
GROUP BY 
    YEAR(date_time)
ORDER BY 
    trip_year; 
    
   
   -- Did Trip Count and Average Fare Change with Fuel Prices Over the Years?
   
    SELECT 
    YEAR(trips.date_time) AS trip_year,
    COUNT(DISTINCT trips.trip_id) AS total_trips,
    ROUND(AVG(trips.fare_egp), 2) AS average_fare,
    ROUND(AVG(fuelprice.octane92_price), 2) AS avg_octane92_price,
    ROUND(AVG(fuelprice.octane95_price), 2) AS avg_octane95_price
FROM 
    trips
JOIN 
    fuelprice ON YEAR(trips.date_time) = fuelprice.month
GROUP BY 
    YEAR(trips.date_time)
ORDER BY 
    trip_year;  
    
    -- Which Age Categories Used the Service in 2024 but Not in 2025?
    
SELECT 
    customer.age_category,
    COUNT(*) AS customers
FROM (
    SELECT DISTINCT trips.customer_id
    FROM trips 
    WHERE YEAR(trips.date_time) = 2024
      AND trips.customer_id NOT IN (
          SELECT DISTINCT customer_id
          FROM trips
          WHERE YEAR(date_time) = 2025
      )
) AS customers
JOIN customer  ON customers.customer_id = customer.customer_id
GROUP BY 
    customer.age_category
ORDER BY 
    customers DESC;   
    
    
    -- Trip Comparison by Age Category in 2024 vs 2025
    
    SELECT 
    c.age_category,
    SUM(CASE WHEN YEAR(t.date_time) = 2024 THEN 1 ELSE 0 END) AS trips_2024,
    SUM(CASE WHEN YEAR(t.date_time) = 2025 THEN 1 ELSE 0 END) AS trips_2025
FROM 
    trips t
JOIN 
    customer c ON t.customer_id = c.customer_id
WHERE 
    YEAR(t.date_time) IN (2024, 2025)
GROUP BY 
    c.age_category
ORDER BY 
    trips_2024 DESC;