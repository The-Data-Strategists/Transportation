select*from metro; 
SELECT count(distinct station) as station_number
from metro; 

select sum(passengers) as passengers_num
from metro; 

select  
metro.station as station_name,
sum(passengers) as total_passengers
from metro
group by 
station_name
order by total_passengers desc; 

select 
metro.station as station_name,
month(date) as date_type,
sum(passengers) as total_passenger
from metro
group by 
station_name,
month(date)
order by 
date_type desc,
total_passenger desc;   


SELECT 
    station,
    dayname(date) AS name_of_day,
    SUM(passengers) AS total_passengers
FROM metro
GROUP BY 
    station,
    dayname(date)
ORDER BY 
    station,
    total_passengers DESC;  
    
    
SELECT station, DAYNAME(date) AS day_name, SUM(passengers) AS total_passengers
FROM metro
GROUP BY station, DAYNAME(date)
HAVING SUM(passengers) = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(passengers) AS total
        FROM metro m2
        WHERE m2.station = metro.station
        GROUP BY DAYNAME(m2.date)
    ) AS sub
)
ORDER BY station; 


WITH daily_counts AS (
    SELECT 
        station,
        DAYNAME(date) AS day_name,
        SUM(passengers) AS total_passengers
    FROM metro
    GROUP BY station, DAYNAME(date)
),
peak_days AS (
    SELECT 
        station,
        day_name,
        total_passengers,
        RANK() OVER (PARTITION BY station ORDER BY total_passengers DESC) AS rnk
    FROM daily_counts
)
SELECT 
    station,
    day_name AS peak_day,
    total_passengers
FROM peak_days
WHERE rnk = 1
ORDER BY station; 




SELECT 
    YEAR(date_time) AS trip_year,
    payment_method,
    COUNT(trip_id) AS total_trips
FROM 
    trips
WHERE 
    YEAR(date_time) IN (2024, 2025)
GROUP BY 
    trip_year, payment_method
ORDER BY 
    trip_year, total_trips DESC;