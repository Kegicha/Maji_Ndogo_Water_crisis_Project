SELECT  DISTINCT
	type_of_water_source
FROM 
	md_water_services.water_source;  				/*the unique types of water sources we're dealing with*/
    
Select *
FROM md_water_services.visits
WHERE visit_count >= 5;  							--  locations visited more than a 5 number of times

Select *
FROM md_water_services.water_quality
WHERE subjective_quality_score BETWEEN 3 AND 5 
	AND visit_count > 2; 							 -- records where the subjective_quality_score is within a 3 - 5 range and the visit_count is above 2 threshold
    
Select *
FROM md_water_services.well_pollution
WHERE results <> 'clean';  --  water sources where the pollution_tests result came back as 'dirty' or 'biologically contaminated'.
    
SHOW TABLES;  -- This will give you a list of all the tables in the database.

SELECT *
FROM md_water_services.location
LIMIT 10;   										-- location table

Select *
FROM md_water_services.visits
LIMIT 5;											-- visits table

SELECT 
    *
FROM
    md_water_services.water_source
LIMIT 5;											-- water_source table
    
    
SELECT *
FROM md_water_services.data_dictionary;    			-- data_dictionary table
    
SELECT  DISTINCT
	type_of_water_source
FROM 
	md_water_services.water_source;  				/*the unique types of water sources we're dealing with*/

Select *
FROM md_water_services.visits
WHERE time_in_queue > 500;							-- records from visits table where the time_in_queue is more than 500 min.

SELECT *
FROM md_water_services.water_source
WHERE source_id IN (
	'AkKi00881224',
	'SoRu37635224',
	'SoRu36096224'
); 												-- Some of the water sources (type) with longer queue time.  

SELECT *
FROM md_water_services.water_quality
WHERE subjective_quality_score = 10
AND visit_count = 2;							--  records where the subject_quality_score is 10-- only looking for home taps-- and where the source was visited a second time. 

SELECT *
FROM md_water_services.well_pollution
LIMIT 5;											-- well_pollution table 

SELECT *
FROM md_water_services.well_pollution
WHERE biological > 0.01
AND results = 'Clean';								 -- query that checks if the results is Clean but the biological column is > 0.01

SELECT *
FROM md_water_services.well_pollution
WHERE biological > 0.01
AND description LIKE 'Clean%';						 -- results that have a value greater than 0.01 in the biological column and have been set to Clean in the results column.

-- SET SQL_SAFE_UPDATES = 0;

CREATE TABLE well_pollution_copy 
as (
SELECT * 
FROM md_water_services.well_pollution
	);												-- We will get a copy of well_pollution called well_pollution_copy.
    

/* Case 1a: Update descriptions that mistakenly mention `Clean Bacteria: E. coli` to `Bacteria: E. coli` */
UPDATE
	well_pollution_copy									 /*Update well_pollution table */
SET
	description	= 'Bacteria: E. coli'			     /*Change description to'Bacteria: E. coli' */
WHERE
	description	= `Clean Bacteria: E. coli`;        /*Where the description is `Clean Bacteria: E. coli` */

/* −− Case 1b: Update the descriptions that mistakenly mention `Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia */
UPDATE
	well_pollution_copy									             /*Update well_pollution table */
SET
	description	= 'Bacteria: Giardia Lamblia'			         /*Change description to' Bacteria: Giardia Lamblia' */
WHERE
	description	= 'Clean Bacteria: Giardia Lamblia';									
										
/* Case 2: Update the `result` to `Contaminated: Biological` where `biological` is greater than 0.01 plus current results is `Clean` */
UPDATE
	well_pollution_copy									             /*Update well_pollution table */
SET
	results	= 'Contaminated: Biological'			             /*Change description to'Bacteria: E. coli' */
WHERE
	results	= 'Clean'                                            /*Where the description is `Clean Bacteria: E. coli` */
AND
	biological > 0.01;

SELECT
*
FROM
well_pollution_copy
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);				--  checks if our errors are fixed

DROP TABLE md_water_services.well_pollution_copy;  			--  deletion of the well_pollution_copy table.

SELECT * 
FROM well_pollution_copy
WHERE description
IN ('Parasite: Cryptosporidium', 'biologically contaminated')
OR (results = 'Clean' AND biological > 0.01);

/*Question Section:
 You have been given a task to correct the phone number for the employee named 'Bello Azibo'. The correct number is +99643864786. Write the SQL query to accomplish this.
Note: Running these queries on the employee table may create issues later, so use the knowledge you have learned to avoid that. */

SELECT * 
FROM md_water_services.employee;

CREATE TABLE employee_copy
AS (
SELECT *
FROM md_water_services.employee
	);
    
UPDATE employee_copy
SET phone_number = '+99643864786'
WHERE employee_name =  'Bello Azibo';

SELECT *
FROM md_water_services.employee_copy
WHERE employee_name =  'Bello Azibo';


/*  Create a query to identify potentially suspicious field workers based on an anonymous tip. This is the description we are given:
-The employee’s phone number contained the digits 86 or 11. 
-The employee’s last name started with either an A or an M. 
-The employee was a Field Surveyor. */

SELECT *
FROM md_water_services.employee_copy
WHERE (employee_name LIKE  '%A%'
OR employee_name LIKE  '%M%')
AND position = 'Field Surveyor'
AND (phone_number LIKE '%86%'
OR phone_number LIKE '%11%');

/* Which SQL query returns records of employees who are Civil Engineers residing in Dahabu or living on an
avenue? */

SELECT *
FROM md_water_services.employee_copy
WHERE position = 'Civil Engineer'
AND (town_name = 'Dahabu'
OR	address LIKE '%Avenue');

/* What is the population of Maji Ndogo?  Hint: Start by searching the data_dictionary table for the word 'population'. */
SELECT *
FROM data_dictionary 
WHERE 
	description LIKE '%population%';
    
SELECT * 
FROM global_water_access 
WHERE name = 'Maji Ndogo';

/* What is the source_id of the water source shared by the most number of people? */

SELECT * 
FROM md_water_services.water_source
ORDER BY number_of_people_served DESC;
 
SELECT *
FROM md_water_services.water_source
WHERE number_of_people_served > 3997;

-- What is the name and phone number of our Microbiologist?

SELECT 
	employee_name,
    phone_number
FROM md_water_services.employee
WHERE position = 'Micro Biologist';

-- What is the address of Bello Azibo?
SELECT address
FROM md_water_services.employee
WHERE employee_name = 'Bello Azibo';



