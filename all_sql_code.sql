-- 3. combine all .csv files into one
CREATE TABLE 'all_divvy_tripdata' AS 
SELECT * FROM '202112-divvy-tripdata' 
UNION ALL
SELECT * FROM '202201-divvy-tripdata'
UNION ALL
SELECT * FROM '202202-divvy-tripdata'
UNION ALL
SELECT * FROM '202203-divvy-tripdata'
UNION ALL
SELECT * FROM '202204-divvy-tripdata'
UNION ALL
SELECT * FROM '202205-divvy-tripdata'
UNION ALL
SELECT * FROM '202206-divvy-tripdata'
UNION ALL
SELECT * FROM '202207-divvy-tripdata'
UNION ALL
SELECT * FROM '202208-divvy-tripdata'
UNION ALL
SELECT * FROM '202209-divvy-tripdata'
UNION ALL
SELECT * FROM '202210-divvy-tripdata'
UNION ALL
SELECT * FROM '202211-divvy-tripdata'

-- 4. checking duplicate/null/inconsistent primary key (ride_id)
-- Find Null value
SELECT
	ride_id
FROM
	all_divvy_tripdata
WHERE
	ride_id is NULL;
-- Result: 0 rows returned in 4661ms

-- Find duplicate value
SELECT
	count(ride_id)
FROM
	all_divvy_tripdata
GROUP by
	ride_id
HAVING
	count(ride_id) > 1;
-- Result: 0 rows returned in 22585ms

-- check length of ride_id no more than 16 characters
SELECT
	ride_id
FROM
	all_divvy_tripdata
WHERE
	length(ride_id)>16;
-- Result: 0 rows returned in 4961ms

-- 5. understand rideable_type column
-- found the distribution of rideable_type
SELECT
	rideable_type,
	count(rideable_type) AS no_of_time_use
FROM
	all_divvy_tripdata
GROUP by
	rideable_type;

-- delete docked_bike from rideable_id column
DELETE FROM
	all_divvy_tripdata
WHERE
	rideable_type = 'docked_bike';
-- Result: query executed successfully. Took 3071ms, 180477 rows affected

-- 6. Add ride_lenght into table
-- a. Add ride_length into the table
ALTER TABLE all_divvy_tripdata ADD COLUMN ride_length INTEGER;

-- b. calculate & check the ride length
SELECT
	ride_id,
	round((julianday(ended_at) - julianday(started_at)) * 1440) as ride_length
FROM
	all_divvy_tripdata

-- c. update all_divvy_tripdata table with ride_length
UPDATE 
	all_divvy_tripdata
SET
	ride_length = round(1440*(julianday(ended_at) - julianday(started_at)));

-- d. delete ride_length ≤ 1
DELETE FROM 
	all_divvy_tripdata
WHERE
	ride_length <= 1
-- Result: query executed successfully. Took 1554ms, 159335 rows affected

-- 7. Add hour_of_day into table
-- 1. convert and check strftime function
SELECT
	ride_id,
	strftime('%H',started_at) as hour_of_day
FROM
	all_divvy_tripdata;
-- 2. create hour_of_day column into table
ALTER TABLE all_divvy_tripdata ADD COLUMN hour_of_day INTEGER;
-- 3. update hour_of_day column
UPDATE
	all_divvy_tripdata
SET hour_of_day = strftime('%H',started_at);
-- Result: query executed successfully. Took 8612ms, 5393639 rows affected

-- 8. Find favour routes
-- 1. check the query
SELECT
	start_station_name || ' --- ' || end_station_name as route
FROM
	all_divvy_tripdata;
-- 2. add new route column 
ALTER TABLE all_divvy_tripdata ADD COLUMN route TEXT;
-- 3. update route into main table
UPDATE 
	all_divvy_tripdata
SET route = start_station_name || ' --- ' || end_station_name;
--Result: query executed successfully. Took 14983ms, 5393639 rows affected