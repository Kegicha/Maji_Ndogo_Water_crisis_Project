DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);


SELECT																				-- A  join of the visits table to the auditor_report table
	ar.location_id,
	ar.true_water_source_score,
    v.location_id,
    v.record_id
FROM md_water_services.auditor_report AS ar
JOIN visits AS v
ON v.location_id = ar.location_id;


SELECT																				-- A  join of the visits table to the auditor_report table and water_quality table
	ar.location_id,
	ar.true_water_source_score AS auditor_score,
    v.record_id,
    w.subjective_quality_score AS surveyor_score
FROM md_water_services.auditor_report AS ar
JOIN visits AS v
ON v.location_id = ar.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
WHERE ar.true_water_source_score <> w.subjective_quality_score            -- Change = to <> to get the  records that are incorrect
AND v.visit_count = 1
LIMIT 10000;


SELECT																				-- A  join of the visits table to the auditor_report table and water_quality table, we've added water_source.
	ar.location_id,
	ws.type_of_water_source AS survey_source,
	ar.type_of_water_source AS auditor_source,
	ar.true_water_source_score AS auditor_score,
	v.record_id,
	w.subjective_quality_score AS surveyor_score
FROM md_water_services.auditor_report AS ar
JOIN visits AS v
ON v.location_id = ar.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN md_water_services.water_source AS ws
ON ws.type_of_water_source = ar.type_of_water_source
WHERE ar.true_water_source_score <> w.subjective_quality_score            -- Change = to <> to get the  records that are incorrect
AND v.visit_count = 1
LIMIT 10000;
    
WITH																					-- A CTE join of the visits table to the auditor_report table and water_quality table along with employees table
	Incorrect_records AS (
	SELECT																				
		ar.location_id,
        e.assigned_employee_id,
        e.employee_name,
		ar.true_water_source_score AS auditor_score,
		v.record_id,
		w.subjective_quality_score AS surveyor_score
	FROM md_water_services.auditor_report AS ar
	JOIN visits AS v
	ON v.location_id = ar.location_id
	JOIN water_quality AS w
	ON v.record_id = w.record_id
    JOIN employee AS e
	ON e.assigned_employee_id = v.assigned_employee_id
	WHERE ar.true_water_source_score <> w.subjective_quality_score            -- Change = to <> to get the  records that are incorrect
	AND v.visit_count = 1
	LIMIT 10000
)
SELECT *
FROM Incorrect_records;

WITH Incorrect_records AS (
    SELECT                                                                                
        ar.location_id,
        e.assigned_employee_id,
        e.employee_name,
        ar.true_water_source_score AS auditor_score,
        v.record_id,
        w.subjective_quality_score AS surveyor_score
    FROM md_water_services.auditor_report AS ar
    JOIN visits AS v
        ON v.location_id = ar.location_id
    JOIN water_quality AS w
        ON v.record_id = w.record_id
    JOIN employee AS e
        ON e.assigned_employee_id = v.assigned_employee_id
    WHERE ar.true_water_source_score <> w.subjective_quality_score
      AND v.visit_count = 1
)

SELECT DISTINCT 
    employee_name,
    count(employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name
ORDER BY count(employee_name) DESC;


WITH error_count AS (
    SELECT                                                                                
        ar.location_id,
        e.assigned_employee_id,
        e.employee_name,
        ar.true_water_source_score AS auditor_score,
        v.record_id,
        w.subjective_quality_score AS surveyor_score
    FROM md_water_services.auditor_report AS ar
    JOIN visits AS v
        ON v.location_id = ar.location_id
    JOIN water_quality AS w
        ON v.record_id = w.record_id
    JOIN employee AS e
        ON e.assigned_employee_id = v.assigned_employee_id
    WHERE ar.true_water_source_score <> w.subjective_quality_score
      AND v.visit_count = 1
)
SELECT 
    COUNT(employee_name) / COUNT(DISTINCT employee_name) AS avg_error_count_per_empl
FROM error_count;

CREATE VIEW Incorrect_records AS (													-- We've converted the Incorrect_records CTE to a View table.
    SELECT                                                                                
        ar.location_id,
        e.assigned_employee_id,
        e.employee_name,
        ar.true_water_source_score AS auditor_score,
        v.record_id,
        w.subjective_quality_score AS surveyor_score
    FROM md_water_services.auditor_report AS ar
    JOIN visits AS v
        ON v.location_id = ar.location_id
    JOIN water_quality AS w
        ON v.record_id = w.record_id
    JOIN employee AS e
        ON e.assigned_employee_id = v.assigned_employee_id
    WHERE ar.true_water_source_score <> w.subjective_quality_score
      AND v.visit_count = 1
);

 SELECT * 
 FROM Incorrect_records;
 
 WITH error_count AS (                                                          -- This CTE calculates the number of mistakes each employee made
SELECT
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name)
SELECT * 
FROM error_count;
 
 WITH error_count AS (															-- average of the number_of_mistakes in error_count
SELECT
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name)
SELECT AVG(number_of_mistakes)
FROM error_count;

WITH suspect_list AS (                                                          -- This CTE gets the employees whose number of mistakes were above avarage.
SELECT
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name)
SELECT * 
FROM suspect_list
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM suspect_list);

WITH																					-- A CTE join of the visits table to the auditor_report table and water_quality table along with employees table
	Incorrect_records AS (
	SELECT																				
		ar.location_id,
        e.assigned_employee_id,
        e.employee_name,
		ar.true_water_source_score AS auditor_score,
		v.record_id,
		w.subjective_quality_score AS surveyor_score,
        ar.statements
	FROM md_water_services.auditor_report AS ar
	JOIN visits AS v
	ON v.location_id = ar.location_id
	JOIN water_quality AS w
	ON v.record_id = w.record_id
    JOIN employee AS e
	ON e.assigned_employee_id = v.assigned_employee_id
	WHERE ar.true_water_source_score <> w.subjective_quality_score            -- Change = to <> to get the  records that are incorrect
	AND v.visit_count = 1
	LIMIT 10000
)
SELECT *
FROM Incorrect_records
WHERE employee_name IN ('Bello Azibo', 'Zuriel Matembo', 'Malachi Mavuso', 'Lalitha Kaburi');

