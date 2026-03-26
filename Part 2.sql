SELECT * 													--  data dictionary
FROM md_water_services.data_dictionary; 

SELECT *													-- 	Query brings up the employee table					
FROM md_water_services.employee;

SELECT														--  Query replace the space with a full stop and Makes employee_name all lower case
	employee_name,
    LOWER(REPLACE(employee_name, ' ', '.')) AS email_names
FROM md_water_services.employee;

SELECT														--  Query creates a column of emails
	employee_name,
    LOWER(REPLACE(employee_name, ' ', '.')) AS email_names,
    CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),'@ndogowater.gov') AS Emails
FROM md_water_services.employee;


UPDATE md_water_services.employee																	-- Query updates the employee table with the employees' emails
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),'@ndogowater.gov');

SELECT
	LENGTH(phone_number)
FROM employee;

SELECT
	TRIM(phone_number)
FROM employee;

UPDATE md_water_services.employee																	-- Query updates the employee table by removing any leading or trailing spaces from a string
SET phone_number = TRIM(phone_number);

SELECT
	LENGTH(phone_number)
FROM employee;

SELECT 															        						-- 	Query counts how many of our employees live in each town
       town_name,
       COUNT(town_name) 
FROM md_water_services.employee
GROUP BY town_name;

SELECT 														        						-- 	Query gets three field surveyors with the most location visits.
	assigned_employee_id,
    COUNT(visit_count) AS No_of_visits
FROM md_water_services.visits
GROUP BY assigned_employee_id
LIMIT 3;

SELECT 
	assigned_employee_id,
    employee_name,
    phone_number,
    email
FROM md_water_services.employee
WHERE assigned_employee_id IN (0,1,2);

SELECT 															-- query counts the number of records per town
	town_name,
    COUNT(town_name)
FROM md_water_services.location
GROUP BY town_name;


SELECT 															-- query counts the number of records per town
	province_name,
    COUNT(province_name)
FROM md_water_services.location
GROUP BY province_name;


SELECT 															-- query counts the number of records per province
	province_name,
    town_name,
    COUNT(town_name) AS records_per_town
FROM md_water_services.location
GROUP BY province_name, town_name
ORDER BY province_name DESC;

SELECT 															-- query counts the number of records for each location type
	location_type,
    COUNT(location_type)
FROM md_water_services.location
GROUP BY location_type;

SELECT 23740 / (15910 + 23740) * 100;							--  60% of all water sources in the data set are in rural communities

SELECT 														    -- How many people did we survey in total?
	SUM(number_of_people_served)
FROM md_water_services.water_source;

SELECT 														    -- How many wells, taps and rivers are there?
	type_of_water_source,
    COUNT(type_of_water_source) AS Count_per_type
FROM md_water_services.water_source
GROUP BY type_of_water_source;

SELECT 														    -- How many people share particular types of water sources on average?
	type_of_water_source,
    ROUND(AVG(number_of_people_served)) AS Avg_no_of_people_per_type
FROM md_water_services.water_source
GROUP BY type_of_water_source;

SELECT 														    -- How many people are getting water from each type of source?
	type_of_water_source,
    AVG(number_of_people_served) AS Avg_no_of_people_per_type
FROM md_water_services.water_source
GROUP BY type_of_water_source;

SELECT 														    -- How many people are getting water from each type of source?
	type_of_water_source,
    SUM(number_of_people_served) AS Sum_of_people_per_type
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY SUM(number_of_people_served) DESC;

SELECT 														    -- Percentage of how many people are getting water from each type of source?
	type_of_water_source,
    (SUM(number_of_people_served) / '27628140') * 100 AS Sum_of_people_per_type
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY SUM(number_of_people_served) DESC;

SELECT 														    -- Percentage of how many people are getting water from each type of source rounded off to 0 decimals?
	type_of_water_source,
    ROUND((SUM(number_of_people_served) / '27628140') * 100, 0)AS Sum_of_people_per_type
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY SUM(number_of_people_served) DESC;
/* By adding tap_in_home and tap_in_home_broken together, we see that 31% of people have water infrastructure installed in their homes, but 45%
(14/31) of these taps are not working! This isn't the tap itself that is broken, but rather the infrastructure like treatment plants, reservoirs, pipes, and
pumps that serve these homes that are broken.
18% of people are using wells. But only 4916 out of 17383 are clean = 28% (from last week). */

SELECT 														    -- a query that ranks each type of source based on how many people in total use it.
	type_of_water_source,
    SUM(number_of_people_served) AS people_served, 
    RANK() OVER(ORDER BY SUM(number_of_people_served) DESC) AS Rank_of_people_per_type
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY SUM(number_of_people_served) DESC;


SELECT 														    -- A query that ranks sources within each type of water source
	source_id,
	type_of_water_source,
    number_of_people_served AS people_served,
    RANK() OVER(ORDER BY number_of_people_served) 
FROM md_water_services.water_source
ORDER BY number_of_people_served ;

SELECT 															-- How long did the survey take?
	MAX(time_of_record),
    MIN(time_of_record),
    DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS Survey_period
FROM md_water_services.visits;

SELECT 															--  how long people have to queue on average in Maji Ndogo
	SUM(time_in_queue),
    COUNT(time_in_queue),
    ROUND(AVG(time_in_queue)) AS Average_time_in_queue
FROM md_water_services.visits
WHERE time_in_queue != 0;

SELECT 															--  A query that  aggregated the days of the week.
	DAYNAME(time_of_record) AS day_of_the_week
FROM md_water_services.visits
GROUP BY DAYNAME(time_of_record);

SELECT 															--  A query that calculate the average queue time, grouped by day of the week
	DAYNAME(time_of_record), 
    Round(AVG(time_in_queue))
FROM md_water_services.visits
WHERE time_in_queue != 0
GROUP BY DAYNAME(time_of_record);

SELECT 															--  A query that A query that aggregated the hours of the day.
    HOUR(time_of_record) AS Hour_of_the_day
FROM md_water_services.visits
GROUP BY HOUR(time_of_record);

SELECT 															--  A query that A query that aggregated the data to hours of the day.
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS Hour_of_the_day,
    Round(AVG(time_in_queue))
FROM md_water_services.visits
WHERE time_in_queue != 0
GROUP BY TIME_FORMAT(TIME(time_of_record), '%H:00')
Order by TIME_FORMAT(TIME(time_of_record), '%H:00') asc;

/* To filter a row we use WHERE, but using CASE() in SELECT can filter columns. We can use a CASE() function for each day to separate the queue
time column into a column for each day. Let’s begin by only focusing on Sunday. So, when a row's DAYNAME(time_of_record) is Sunday, we
make that value equal to time_in_queue, and NULL for any days. */
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
visits
WHERE
time_in_queue != 0;-- this exludes other sources with 0 queue times.


SELECT																					-- queue times for each day, hour by hour
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue ELSE NULL END),0) AS Sunday, -- Sunday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue ELSE NULL END ),0) AS Monday, -- Monday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue ELSE NULL END),0) AS Tuesday,  -- Tuesday 
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue ELSE NULL END),0) AS Wednesday, -- Wednesday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue ELSE NULL END),0) AS Thursday, -- Thursday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue ELSE NULL END),0) AS Friday, -- Friday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue ELSE NULL END), 0) AS Saturday -- Saturday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY hour_of_day
ORDER BY hour_of_day; 

/* Water Accessibility and infrastructure summary report
This survey aimed to identify the water sources people use and determine both the total and average number of users for each source.
Additionally, it examined the duration citizens typically spend in queues to access water.

Insights
16:51
1. Most water sources are rural.
2. 43% of our people are using shared taps. 2000 people often share one tap.
3. 31% of our population has water infrastructure in their homes, but within that group, 45% face non-functional systems due to issues with pipes,
pumps, and reservoirs.
4. 18% of our people are using wells of which, but within that, only 28% are clean..
5. Our citizens often face long wait times for water, averaging more than 120 minutes.
6. In terms of queues:- Queues are very long on Saturdays.- Queues are longer in the mornings and evenings.- Wednesdays and Sundays have the shortest queues. */

 -- AOB 
SELECT 																	-- SQL query will produce the date format "DD Month YYYY" from the time_of_record column in the visits table
	CONCAT(day(time_of_record), " ", monthname(time_of_record), " ", year(time_of_record)) 
FROM visits;

SELECT																	-- an SQL query designed to calculate the Annual Rate of Change (ARC) for basic rural water services
	name,
	wat_bas_r - LAG(wat_bas_r) OVER (PARTITION BY (name) ORDER BY (year)) AS 'Annual Rate of Change'
FROM  global_water_access
Where 'Annual Rate of Change' IS NOT NULL
ORDER BY name;

SELECT													 -- an SQL query designed to FIND the names of the two worst-performing employees who visited the fewest sites, and how many sites did the worst-performing employee visit
	assigned_employee_id,
    COUNT(visit_count)
FROM md_water_services.visits
GROUP BY assigned_employee_id
ORDER BY COUNT(visit_count) ASC;

SELECT 													 
	assigned_employee_id,
    employee_name
FROM md_water_services.employee
WHERE assigned_employee_id IN (20, 22);

SELECT 														-- The query computes an average queue time for shared taps visited more than once, which is updated each time a source is visited.
	location_id,
	time_in_queue,
	AVG(time_in_queue) OVER (PARTITION BY location_id ORDER BY visit_count) AS total_avg_queue_time
FROM visits
WHERE visit_count > 1 -- Only shared taps were visited > 1
ORDER BY location_id, time_of_record;

SELECT														-- No. of employees per town they reside at.
	town_name,
    province_name,
	COUNT(employee_name)
    
FROM md_water_services.employee
GROUP BY town_name, province_name;


SELECT 													 -- How many people are getting water from each type of source?
	type_of_water_source,
    ROUND(avg(number_of_people_served))
FROM md_water_services.water_source
GROUP BY type_of_water_source;

SELECT													--  total number of people using some sort of tap
SUM(number_of_people_served) AS population_served
FROM
water_source
WHERE type_of_water_source LIKE "%tap%"
ORDER BY 
population_served;


SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue END),0) AS Saturday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue END),0) AS Tuesday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue END),0) AS Sunday
FROM visits
WHERE time_in_queue != 0
AND (
        (DAYNAME(time_of_record) = 'Saturday' AND HOUR(time_of_record) IN ('12:00', '13:00'))
     OR (DAYNAME(time_of_record) = 'Tuesday' AND HOUR(time_of_record) IN ('18:00', '19:00'))
     OR (DAYNAME(time_of_record) = 'Sunday' AND HOUR(time_of_record) IN ('09:00', '10:00'))
    )
GROUP BY hour_of_day
ORDER BY hour_of_day;