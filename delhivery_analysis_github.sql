-- Delhivery Logistics Analytics
-- PostgreSQL Analysis Queries
-- Curated from the project's original SQL analysis
-- Dataset table: delivery_raw / delivery_clean


-- ============================================================
-- 1. DATASET EXPLORATION
-- ============================================================

-- Check the total number of records
SELECT COUNT(*) AS total_rows
FROM delivery_raw;

-- Count total rows and key populated fields
SELECT
    COUNT(*) AS total_rows,
    COUNT(data) AS data_filled,
    COUNT(trip_uuid) AS trip_uuid_filled,
    COUNT(source_center) AS source_filled,
    COUNT(destination_center) AS destination_filled,
    COUNT(actual_time) AS actual_time_filled,
    COUNT(osrm_time) AS osrm_time_filled
FROM delivery_raw;

-- Count unique trips
SELECT
    COUNT(DISTINCT trip_uuid) AS unique_trips
FROM delivery_raw;

-- Count records by route type
SELECT
    route_type,
    COUNT(*) AS record_count
FROM delivery_raw
GROUP BY route_type
ORDER BY record_count DESC;

-- Count unique trips by route type
SELECT
    route_type,
    COUNT(DISTINCT trip_uuid) AS unique_trips
FROM delivery_raw
GROUP BY route_type
ORDER BY unique_trips DESC;


-- ============================================================
-- 2. SOURCE & DESTINATION ANALYSIS
-- ============================================================

-- Count unique source centers
SELECT
    COUNT(DISTINCT source_center) AS unique_source_centers
FROM delivery_raw;

-- Count unique destination centers
SELECT
    COUNT(DISTINCT destination_center) AS unique_destination_centers
FROM delivery_raw;

-- Top 10 source centers by record volume
SELECT
    source_center,
    COUNT(source_center) AS record_count
FROM delivery_raw
GROUP BY source_center
ORDER BY record_count DESC
LIMIT 10;

-- Top 10 routes by unique trips
SELECT
    source_center,
    destination_center,
    COUNT(DISTINCT trip_uuid) AS unique_trips
FROM delivery_raw
GROUP BY source_center, destination_center
ORDER BY unique_trips DESC
LIMIT 10;


-- ============================================================
-- 3. ACTUAL TIME VS OSRM ESTIMATED TIME
-- ============================================================

-- Average actual time by route type
SELECT
    route_type,
    AVG(actual_time) AS avg_actual_time
FROM delivery_raw
GROUP BY route_type;

-- Average OSRM estimated time by route type
SELECT
    route_type,
    AVG(osrm_time) AS avg_osrm_time
FROM delivery_raw
GROUP BY route_type;

-- Compare average actual time and OSRM estimated time
SELECT
    route_type,
    AVG(osrm_time) AS avg_osrm_time,
    AVG(actual_time) AS avg_actual_time
FROM delivery_raw
GROUP BY route_type;

-- Average time deviation by route type
SELECT
    route_type,
    AVG(actual_time - osrm_time) AS avg_deviation
FROM delivery_raw
GROUP BY route_type;

-- Average deviation percentage by route type
SELECT
    route_type,
    AVG((actual_time - osrm_time) / NULLIF(osrm_time, 0) * 100)
        AS avg_deviation_percentage
FROM delivery_raw
GROUP BY route_type;


-- ============================================================
-- 4. ROUTE PERFORMANCE ANALYSIS
-- ============================================================

-- Top 10 routes by average actual time
SELECT
    source_center,
    destination_center,
    AVG(actual_time) AS avg_actual_time
FROM delivery_raw
GROUP BY source_center, destination_center
ORDER BY avg_actual_time DESC
LIMIT 10;

-- Routes where average actual time exceeds average OSRM time
SELECT
    source_center,
    destination_center,
    AVG(actual_time) AS avg_actual_time,
    AVG(osrm_time) AS avg_osrm_time
FROM delivery_raw
GROUP BY source_center, destination_center
HAVING AVG(actual_time) > AVG(osrm_time);

-- Top 10 routes with the highest average time deviation
SELECT
    source_center,
    destination_center,
    AVG(actual_time - osrm_time) AS avg_time_deviation
FROM delivery_raw
GROUP BY source_center, destination_center
ORDER BY avg_time_deviation DESC
LIMIT 10;

-- Routes with at least 5 unique trips and their average deviation percentage
SELECT
    source_center,
    destination_center,
    COUNT(DISTINCT trip_uuid) AS unique_trips,
    AVG((actual_time - osrm_time) / NULLIF(osrm_time, 0) * 100)
        AS avg_deviation_pct
FROM delivery_raw
GROUP BY source_center, destination_center
HAVING COUNT(DISTINCT trip_uuid) >= 5
ORDER BY avg_deviation_pct DESC;


-- ============================================================
-- 5. PERFORMANCE COMPARISON
-- ============================================================

-- Count records where actual time exceeds OSRM estimated time
SELECT
    route_type,
    COUNT(route_type) AS actual_greater_than_osrm
FROM delivery_raw
WHERE actual_time > osrm_time
GROUP BY route_type;

-- Count records where actual time is below OSRM estimated time
SELECT
    route_type,
    COUNT(route_type) AS actual_less_than_osrm
FROM delivery_raw
WHERE actual_time < osrm_time
GROUP BY route_type;

-- Percentage of records where actual time exceeds OSRM time
SELECT
    route_type,
    COUNT(CASE WHEN actual_time > osrm_time THEN 1 END) * 100.0
        / COUNT(*) AS percentage
FROM delivery_raw
GROUP BY route_type;

-- Overall percentage of records with time deviation
SELECT
    COUNT(CASE WHEN actual_time <> osrm_time THEN 1 END) * 100.0
        / COUNT(*) AS deviation_percentage
FROM delivery_raw;


-- ============================================================
-- 6. DATA QUALITY CHECKS
-- ============================================================

-- Check NULL values in key columns
SELECT
    COUNT(*) FILTER (WHERE trip_uuid IS NULL) AS trip_uuid_null,
    COUNT(*) FILTER (WHERE source_center IS NULL) AS source_center_null,
    COUNT(*) FILTER (WHERE destination_center IS NULL) AS destination_center_null,
    COUNT(*) FILTER (WHERE actual_time IS NULL) AS actual_time_null,
    COUNT(*) FILTER (WHERE osrm_time IS NULL) AS osrm_time_null
FROM delivery_raw;

-- Check for non-positive actual time values
SELECT COUNT(*) AS invalid_actual_time_count
FROM delivery_raw
WHERE actual_time <= 0;

-- Check for non-positive OSRM time values
SELECT COUNT(*) AS invalid_osrm_time_count
FROM delivery_raw
WHERE osrm_time <= 0;

-- Check for duplicate complete rows
SELECT COUNT(*) AS duplicate_count
FROM (
    SELECT ROW(delivery_raw.*)
    FROM delivery_raw
    GROUP BY ROW(delivery_raw.*)
    HAVING COUNT(*) > 1
) d;


-- ============================================================
-- 7. WINDOW FUNCTION ANALYSIS
-- ============================================================

-- Rank source centers by average actual time
SELECT
    *,
    RANK() OVER (ORDER BY avg_actual_time) AS rank_actual_time
FROM (
    SELECT
        source_center,
        AVG(actual_time) AS avg_actual_time
    FROM delivery_raw
    GROUP BY source_center
) t;

-- Rank routes by average deviation within each route type
SELECT
    *,
    RANK() OVER (
        PARTITION BY route_type
        ORDER BY avg_deviation DESC
    ) AS route_rank
FROM (
    SELECT
        route_type,
        source_center,
        destination_center,
        AVG(actual_time - osrm_time) AS avg_deviation
    FROM delivery_raw
    GROUP BY route_type, source_center, destination_center
) t;


-- ============================================================
-- 8. FINAL BUSINESS ANALYSIS
-- ============================================================

-- Overall average time deviation
SELECT
    AVG(actual_time - osrm_time) AS avg_time_deviation
FROM delivery_raw;

-- Route type summary
SELECT
    route_type,
    COUNT(DISTINCT trip_uuid) AS total_trips,
    AVG(actual_time) AS avg_actual_time,
    AVG(osrm_time) AS avg_osrm_time,
    AVG(actual_time - osrm_time) AS avg_deviation
FROM delivery_raw
GROUP BY route_type;

-- Final analysis:
-- Top 10 routes with at least 5 unique trips and the highest
-- average deviation, including actual time, OSRM time and
-- deviation percentage.
SELECT
    source_center,
    destination_center,
    COUNT(DISTINCT trip_uuid) AS unique_trips,
    AVG(actual_time) AS avg_actual_time,
    AVG(osrm_time) AS avg_osrm_time,
    AVG(actual_time - osrm_time) AS avg_deviation,
    AVG((actual_time - osrm_time) / NULLIF(osrm_time, 0) * 100)
        AS avg_deviation_pct
FROM delivery_raw
GROUP BY source_center, destination_center
HAVING COUNT(DISTINCT trip_uuid) >= 5
ORDER BY avg_deviation DESC
LIMIT 10;


-- ============================================================
-- 9. CLEAN DATA PREPARATION
-- ============================================================

-- Create the cleaned working table used for further analysis
CREATE TABLE delivery_clean AS
SELECT *
FROM delivery_raw;

-- Add actual-vs-estimated time deviation
ALTER TABLE delivery_clean
ADD COLUMN time_deviation NUMERIC;

UPDATE delivery_clean
SET time_deviation = actual_time - osrm_time;

-- Add deviation percentage
ALTER TABLE delivery_clean
ADD COLUMN deviation_percentage NUMERIC;

UPDATE delivery_clean
SET deviation_percentage =
    (actual_time - osrm_time) / NULLIF(osrm_time, 0) * 100;


-- ============================================================
-- 10. SOURCE & DESTINATION CITY / STATE EXTRACTION
-- ============================================================

-- Add city and state columns for source locations
ALTER TABLE delivery_clean
ADD COLUMN source_city VARCHAR(100);

ALTER TABLE delivery_clean
ADD COLUMN source_state VARCHAR(100);

-- Extract source city and state from source_name
UPDATE delivery_clean
SET
    source_city =
        CASE
            WHEN source_name IS NULL OR source_name = 'nan' THEN NULL
            ELSE split_part(source_name, '_', 1)
                 || ' ' ||
                 split_part(source_name, '_', 2)
        END,
    source_state =
        CASE
            WHEN source_name IS NULL OR source_name = 'nan' THEN NULL
            ELSE substring(source_name FROM '\(([^)]+)\)')
        END;

-- Add city and state columns for destination locations
ALTER TABLE delivery_clean
ADD COLUMN destination_city VARCHAR(100);

ALTER TABLE delivery_clean
ADD COLUMN destination_state VARCHAR(100);

-- Extract destination city and state from destination_name
UPDATE delivery_clean
SET
    destination_city =
        CASE
            WHEN destination_name IS NULL OR destination_name = 'nan' THEN NULL
            ELSE split_part(destination_name, '_', 1)
                 || ' ' ||
                 split_part(destination_name, '_', 2)
        END,
    destination_state =
        CASE
            WHEN destination_name IS NULL OR destination_name = 'nan' THEN NULL
            ELSE substring(destination_name FROM '\(([^)]+)\)')
        END;

-- Validate the extracted location fields
SELECT
    source_name,
    source_city,
    source_state,
    destination_name,
    destination_city,
    destination_state
FROM delivery_clean
LIMIT 20;

-- Check how many location fields were populated
SELECT
    COUNT(*) AS total_rows,
    COUNT(source_city) AS source_city_filled,
    COUNT(source_state) AS source_state_filled,
    COUNT(destination_city) AS destination_city_filled,
    COUNT(destination_state) AS destination_state_filled
FROM delivery_clean;

-- Analyze shipment segments by source and destination city
SELECT
    source_city,
    source_state,
    destination_city,
    destination_state,
    COUNT(*) AS shipment_segments
FROM delivery_clean
WHERE source_city IS NOT NULL
  AND destination_city IS NOT NULL
GROUP BY
    source_city,
    source_state,
    destination_city,
    destination_state
ORDER BY shipment_segments DESC
LIMIT 20;

-- Analyze shipment segments by source and destination state
SELECT
    source_state,
    destination_state,
    COUNT(*) AS shipment_segments
FROM delivery_clean
WHERE source_state IS NOT NULL
  AND destination_state IS NOT NULL
GROUP BY
    source_state,
    destination_state
ORDER BY shipment_segments DESC
LIMIT 20;
