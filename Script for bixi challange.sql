/*

Ariyan Nooshazar
2022-10-02
[Ariyan.nooshazar@gmail.com

*/
USE `bixi-data`;

-- Getting familiar with DATA
SELECT *
FROM stations;

SELECT *
FROM stations
LIMIT 20;

-- Getting familiar with DATA

SELECT *
FROM trips;

SELECT *
FROM trips
LIMIT 20;

-- The total number of trips for the year of 2016

SELECT COUNT(*) AS Trips, YEAR(start_date) AS year
FROM trips
WHERE YEAR(start_date) = 2016;

-- The total number of trips for the year of 2017

SELECT COUNT(*) AS Trips, YEAR(start_date) AS year
FROM trips
WHERE YEAR(start_date) = 2017;

-- The total number of trips for the year of 2016 broken down by month.

SELECT YEAR(start_date) AS year, MONTH(start_date) Month,
COUNT(*) AS TripsInMonth
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY MONTH(start_date);

-- The total number of trips for the year of 2017 broken down by month.

SELECT YEAR(start_date) AS year, MONTH(start_date) Month,
COUNT(*) AS TripsInMonth
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY MONTH(start_date);

-- The average number of trips a day for each year-month

SELECT
YEAR(start_date) AS Year,
MONTH(start_date) AS Month,
COUNT(*) AS total_trips_of_month,
COUNT(DISTINCT DAY(start_date)) AS days_having_trips_that_month,
COUNT(*) / (COUNT(DISTINCT DATE(start_date))) AS avg_trips_per_day
FROM
trips
GROUP BY Year , Month
ORDER BY Year , Month;

-- Creating working_table1  

CREATE TABLE working_table1 AS
SELECT
YEAR(start_date) AS Year,
MONTH(start_date) AS Month,
COUNT(*) AS total_trips_of_month,
COUNT(DISTINCT DAY(start_date)) AS days_having_trips_that_month,
COUNT(*) / (COUNT(DISTINCT DATE(start_date))) AS avg_trips_per_day
FROM
trips
GROUP BY Year, Month
ORDER BY Year, Month;

-- the total number of trips in the year 2017 broken down by membership status (member/non-member). 
-- Number 1 in Membership Colum on below Query means member and 0 Non member

SELECT 
    YEAR(start_date) AS year,
    MONTH(start_date) AS month,
    COUNT(*) AS trips,
    is_member AS Membership
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY month , is_member
ORDER BY month ASC;

-- Join two queries to get percentage per month of total trips by members for the year 2017 broken down by month.


SELECT 
    month,
    m_trips,
    m_trips * 100 / trips AS Percentage_of_members_total_trips
FROM
    (SELECT 
        YEAR(start_date) AS year,
            MONTH(start_date) AS month,
            COUNT(*) AS m_trips
    FROM trips
    WHERE
        YEAR(start_date) = 2017
            AND is_member = 1
    GROUP BY month
    ORDER BY month ASC) AS Member_trips_per_month
        JOIN
    (SELECT 
        YEAR(start_date) AS year,
            MONTH(start_date) AS mo,
            COUNT(*) AS trips
    FROM trips
    WHERE YEAR(start_date) = 2017
    GROUP BY mo
    ORDER BY mo ASC) Total_trips_per_month
GROUP BY month;


-- The demand for Bixi bikes at its peak
-- used this query to get graph to show which months have the highest pick

SELECT YEAR(start_date) AS year,
MONTH(start_date) AS month,
COUNT(*)
FROM trips
GROUP BY year, month
ORDER BY year, month ASC;

-- 5 most popular starting stations

SELECT S.name,
    T.start_station_code,
    COUNT(T.start_station_code) AS Popular
FROM stations AS S
        INNER JOIN
    trips AS T ON s.code = T.start_station_code
GROUP BY S.name , T.start_station_code
ORDER BY popular DESC
LIMIT 5;

-- Mackay / de Maisonneuve
-- Métro Mont-Royal (Rivard / du Mont-Royal)
-- Métro Place-des-Arts (de Maisonneuve / de Bleury)
-- Métro Laurier (Rivard / Laurier)
-- Métro Peel (de Maisonneuve / Stanley)

-- the 5 most popular starting stations using subquery to get the results
SELECT name, code, trips
FROM
    (SELECT 
        COUNT(start_station_code) AS trips, start_station_code
    FROM trips
    GROUP BY start_station_code) AS Trips_per_station
        INNER JOIN
    stations ON code = start_station_code
ORDER BY Trips DESC
LIMIT 5;
 
 -- Explaination for Question 4.2 : Yes there is diffrence in query run time On our first query run time  is  5.890 SEC and while we use 
 -- subquery its ONLY 1.953, subquery is faster the reason is we filter the data then exctract the info we want.

-- Trips started at station Mackay / de Maisonneuve throughout the day 

SELECT Start_station_code, End_station_code, name, COUNT(*) AS Trips,
CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
END AS "time_of_day"
FROM trips AS t
Inner Join stations AS s ON s.code = t.start_station_code
WHERE name ='Mackay / de Maisonneuve'
group by time_of_day;

-- Trips ended at station Mackay / de Maisonneuve throughout the day

SELECT Start_station_code, End_station_code, name, COUNT(*) AS Trips,
CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
END AS "time_of_day"
FROM trips AS t
Inner Join stations AS s ON s.code = t.start_station_code
WHERE  END_station_code = 6100
group by time_of_day;


-- Total number of starting trips per station

SELECT name, COUNT(start_station_code)  AS Trips
FROM trips AS t
INNER JOIN stations AS s ON s.code = t.start_station_code
GROUP by start_station_code
ORDER by Trips desc;

-- Same results AS above But below query is Much FASTER and is more clear to understand the results
-- Total number of starting trips per station

SELECT Name, Code AS Station_Code, Trips_Per_Station
FROM (SELECT COUNT(*) AS Trips_Per_Station, start_station_code
FROM Trips 
GROUP by start_station_code) AS Trips_Per_Station
JOIN stations ON stations.code = Trips_Per_Station.start_station_code
order by Trips_Per_Station DESC;

-- Tottal trips for each station that have round trips

SELECT COUNT(*) AS Round_Trips, start_station_code, end_station_code
FROM trips
WHERE start_station_code = end_station_code
group by start_station_code;


-- Combining both queries for question 6.3

SELECT Name, station_code, Trips_Per_Station, Round_Trips
FROM
    (SELECT 
        Name, Code AS Station_Code, Trips_Per_Station
    FROM
        (SELECT 
        COUNT(*) AS Trips_Per_Station, start_station_code
    FROM
        Trips
    GROUP BY start_station_code) AS Trips_Per_Station
    JOIN stations ON stations.code = Trips_Per_Station.start_station_code
    ORDER BY Trips_Per_Station DESC) AS Trips
        JOIN
    (SELECT 
        COUNT(*) AS Round_Trips,
            start_station_code,
            end_station_code
    FROM trips
    WHERE start_station_code = end_station_code
    GROUP BY start_station_code) AS R_Trips 
    ON R_Trips.start_station_code = Trips.station_code
ORDER BY round_trips DESC;

-- Below queary is full picture of  trips per station, round trips and Fraction of Round trips for each station (Question6.3)

SELECT 
    Name,
    station_code,
    Trips_Per_Station,
    Round_Trips,
    Round_trips * 100 / Trips_Per_Station AS Fraction_of_Round_trips
FROM
    (SELECT 
        Name, Code AS Station_Code, Trips_Per_Station
    FROM
        (SELECT 
        COUNT(*) AS Trips_Per_Station, start_station_code
    FROM Trips
    GROUP BY start_station_code) AS Trips_Per_Station
    JOIN stations ON stations.code = Trips_Per_Station.start_station_code
    ORDER BY Trips_Per_Station DESC) AS Trips
        JOIN
    (SELECT 
        COUNT(*) AS Round_Trips,
            start_station_code,
            end_station_code
    FROM trips
    WHERE start_station_code = end_station_code
    GROUP BY start_station_code) AS R_Trips ON R_Trips.start_station_code = Trips.station_code
ORDER BY Fraction_of_Round_trips DESC;


-- QS 6.4: Stations with minimium of 500 trips originating from them and 
-- having at least 10% of their trips as round trips.

SELECT 
    Name,
    station_code,
    Trips_Per_Station,
    Round_Trips,
    Round_trips * 100 / Trips_Per_Station AS Fraction_of_Round_trips
FROM
    (SELECT 
        Name, Code AS Station_Code, Trips_Per_Station
    FROM
        (SELECT 
        COUNT(*) AS Trips_Per_Station, start_station_code
    FROM
        Trips
    GROUP BY start_station_code) AS Trips_Per_Station
    JOIN stations ON stations.code = Trips_Per_Station.start_station_code
    ORDER BY Trips_Per_Station DESC) AS Trips
        JOIN
    (SELECT 
        COUNT(*) AS Round_Trips,
            start_station_code,
            end_station_code
    FROM
        trips
    WHERE
        start_station_code = end_station_code
    GROUP BY start_station_code) AS R_Trips ON R_Trips.start_station_code = Trips.station_code
HAVING Trips_per_station > 500
    AND Fraction_of_round_trips >= 10
ORDER BY Fraction_of_Round_trips DESC;

    
    
-- Top 10 station with roundtrips
    
SELECT 
    name,
    COUNT(start_station_code) AS Trips,
    start_station_code,
    end_station_code
FROM trips AS t
        INNER JOIN
    stations AS s ON s.code = t.start_station_code
WHERE start_station_code = end_station_code
GROUP BY start_station_code
ORDER BY trips DESC
LIMIT 10;

-- use this to get Graph 
SELECT 
    YEAR(start_date) AS year,
    MONTH(start_date) Month,
    COUNT(*) AS TripsInMonth
FROM trips
GROUP BY year , MONTH(start_date)