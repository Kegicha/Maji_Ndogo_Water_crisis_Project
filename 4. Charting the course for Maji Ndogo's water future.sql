SELECT 
    v.location_id,
    l.province_name,
    l.town_name,
    v.visit_count,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM md_water_services.location AS l
JOIN md_water_services.visits AS v
ON l.location_id = v.location_id
JOIN md_water_services.water_source AS ws
ON ws.source_id = v.source_id
WHERE v.visit_count = 1 
LIMIT 100000;



CREATE VIEW combined_analysis_table AS
SELECT 
    l.province_name,
    l.town_name,
    ws.type_of_water_source,
    l.location_type,
    ws.number_of_people_served,
    v.time_in_queue,
    wp.results
FROM md_water_services.location AS l
JOIN md_water_services.visits AS v
ON l.location_id = v.location_id
JOIN md_water_services.water_source AS ws
ON ws.source_id = v.source_id
LEFT JOIN md_water_services.well_pollution AS wp
ON wp.source_id = v.source_id
WHERE v.visit_count = 1 
LIMIT 100000;



WITH province_totals AS (												-- This CTE calculates the population of each province
SELECT
province_name,
SUM(number_of_people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,														                     -- These case statements create columns for each type of source.The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN type_of_water_source = 'river' THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap' THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home' THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken' THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well' THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt 
ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;
/* 
-Look at the river column, Sokoto has the largest population of people drinking river water. We should send our drilling equipment to Sokoto
first, so people can drink safe filtered water from a well.
-The majority of water from Amanzi comes from taps, but half of these home taps don't work because the infrastructure is broken. We need to
send out engineering teams to look at the infrastructure in Amanzi first. Fixing a large pump, treatment plant or reservoir means that
thousands of people will have running water. This means they will also not have to queue for water, so we improve two things at once. */


CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (																	-- This CTE calculates the population of each town. Since there are two Harare towns, we have to group by province_name and town_name
SELECT 
	province_name, 
    town_name, 
    SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
	ct.province_name,
	ct.town_name,
ROUND((SUM(CASE WHEN type_of_water_source = 'river' THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap' THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home' THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken' THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well' THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN town_totals tt                                                                                              -- Since the town names are not unique, we have to join on a composite key
ON ct.province_name = tt.province_name 
AND ct.town_name = tt.town_name
GROUP BY  ct.province_name,  ct.town_name                                                                        -- We group by province first, then by town.
ORDER BY ct.town_name;

SELECT *
fROM town_aggregated_water_access;

SELECT
	province_name,
	town_name,
	ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM town_aggregated_water_access;

CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
/* Project_id −− Unique key for sources in case we visit the same
source more than once in the future.
*/
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
/* source_id −− Each of the sources we want to improve should exist,
and should refer to the source table. This ensures data integrity.
*/
Address VARCHAR(50),      -- Street address
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),   -- What the engineers should do at that place
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
/* Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
*/
Date_of_completion DATE,   -- Engineers will add this the day the source has been upgraded.
Comments TEXT              -- Engineers can leave comments. We use a TEXT type that has no limit on char length
);

SELECT *
FROM Project_progress;


SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
AND (well_pollution.results != 'Clean'
OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30))
LIMIT 100000;                                                    -- AND one of the following (OR) options must be true as well.


SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results,
CASE 
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue > 60 THEN CONCAT("Install ", FLOOR(visits.time_in_queue / 60), " taps nearby")   -- We only want to install a second tap if the queue is > 60 min.
        WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE 'Maintain'                                                                     -- Updates where queue is < 60 min.
    END AS Improvement
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
AND (well_pollution.results != 'Clean'
OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30))
LIMIT 100000;   

DROP TABLE IF EXISTS Project_progress;
CREATE TABLE Project_progress 
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results,
CASE 
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue > 60 THEN CONCAT("Install ", FLOOR(visits.time_in_queue / 60), " taps nearby")   -- We only want to install a second tap if the queue is > 60 min.
        WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
        ELSE 'Maintain'                                                                     -- Updates where queue is < 60 min.
    END AS Improvement
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
AND (well_pollution.results != 'Clean'
OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30))
LIMIT 100000;   