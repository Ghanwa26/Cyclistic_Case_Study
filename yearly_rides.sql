--Creating a new table "yearly_rides" through UNION of all individual tables.

SELECT *
INTO yearly_rides
FROM dbo.t1
UNION
SELECT *
FROM dbo.t2
UNION
SELECT *
FROM dbo.t3
UNION
SELECT *
FROM dbo.t4
UNION
SELECT *
FROM dbo.t5
UNION
SELECT *
FROM dbo.t6
UNION
SELECT *
FROM dbo.t7
UNION
SELECT *
FROM dbo.t8
UNION
SELECT *
FROM dbo.t9
UNION
SELECT *
FROM dbo.t10
UNION
SELECT *
FROM dbo.t11
UNION
SELECT *
FROM dbo.t12


--Viewing number of rows = 5667617

SELECT COUNT(*) FROM dbo.yearly_rides


--Viewing structure of table.

SELECT TOP 100* FROM dbo.yearly_rides
 

--Adding a new column "day_of_week" that represents daya of week as integers and where Sunday = 1.

ALTER TABLE yearly_rides
ADD day_of_week INT

UPDATE yearly_rides
SET day_of_week = DATEPART(dw, started_at)


--Adding a new column "month" by extracting month from started_at

ALTER TABLE yearly_rides
ADD month varchar(20)

UPDATE yearly_rides
SET month = DATENAME(month, started_at)


--Adding a new column "hour" by extracting hour from started_at

ALTER TABLE yearly_rides
ADD hour int

UPDATE yearly_rides
SET hour = DATEPART(hour, started_at)


--Changing the datatype of "started_at" and "ended_at" columns to datetime2(0), this will remove milliseconds.

ALTER TABLE yearly_rides
ALTER COLUMN started_at DATETIME2(0)


ALTER TABLE yearly_rides
ALTER COLUMN ended_at DATETIME2(0)


--Adding a new column "ride_length" which is represents time duration in HH:MM:SS format as required from us.

ALTER TABLE yearly_rides
ADD ride_length AS CAST(DATEADD(s, DATEDIFF(s, started_at, ended_at), 0) AS TIME(0))


--Selecting rows where difference between 'ended_at' and 'started_at' is less than zero i.e. time is negative. Returns 100 rows.

SELECT *
FROM yearly_rides
WHERE DATEDIFF(s, started_at, ended_at) < 0


--Deleting these 100 rows because negative ride duration means its bad data.

DELETE 
FROM yearly_rides
WHERE DATEDIFF(s, started_at, ended_at) < 0


--Following query gives 427,441 rows where start and end station ids and names are null. In ideal case we should confirm and fill the data if possible, but we will keep it as it is.

SELECT * FROM dbo.yearly_rides
WHERE start_station_name IS NULL AND start_station_id IS NULL AND end_station_id IS NULL AND end_station_name IS NULL


--Running the following queries to confirm if either one of station_id or station_name is missing, so that we can match the missing ids and names. Returns 0 rows so no action needed.

SELECT * FROM yearly_rides
WHERE start_station_name IS NULL AND start_station_id IS NOT NULL
OR start_station_id IS NULL AND start_station_name IS NOT NULL


SELECT * FROM yearly_rides
WHERE end_station_name IS NULL AND end_station_id IS NOT NULL
OR end_station_id IS NULL AND end_station_name IS NOT NULL


--Looking for duplicates, ride_id should be unique for each ride. This query returns 0 rows.

SELECT ride_id, COUNT(*)
FROM dbo.yearly_rides
GROUP BY ride_id 
HAVING COUNT(*) > 1


--Docked bikes need to be returned to an end station. Following query deletes rows where end station name and id are missing for docked bikes as this is bad data. 2616 rows removed.

DELETE
FROM yearly_rides
WHERE rideable_type = 'docked_bike' AND end_station_id IS NULL AND end_station_name IS NULL


--Following query returns minimum, maximum and average ride_length.

SELECT
       MIN(ride_length) AS min_ride_length,
	   MAX(ride_length) AS max_ride_length,
	   CONVERT(time(0), DATEADD(second, AVG(CAST(DATEDIFF(second, started_at, ended_at) AS bigint)), 0)) AS avg_ride_length
FROM yearly_rides
	   

--This single query will give us number of rides and average ride length in minutes for memebers and casuals by hour, day, month and rideable_type instead of writing multiple individual queries

SELECT month,
	   CASE day_of_week 
			WHEN 1 THEN 'Sunday'
			WHEN 2 THEN 'Monday'
			WHEN 3 THEN 'Tuesday'
			WHEN 4 THEN 'Wednesday'
			WHEN 5 THEN 'Thursday'
			WHEN 6 THEN 'Friday'
			WHEN 7 THEN 'Saturday'
			ELSE 'Unknown' 
		END AS week_day,
       hour, 
	   member_casual,
	   rideable_type,
	   COUNT(*) AS num_of_rides,
	   AVG(DATEDIFF(MINUTE, started_at, ended_at)) AS avg_ride_length
FROM yearly_rides
GROUP BY month, day_of_week, hour, member_casual, rideable_type, MONTH(started_at)
Order BY MONTH(started_at), day_of_week, hour, member_casual, rideable_type



