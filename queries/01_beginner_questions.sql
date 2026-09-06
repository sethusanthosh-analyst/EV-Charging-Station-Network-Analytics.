-- =========================================================
-- LEVEL: BEGINNER (SELECT, WHERE, ORDER BY, LIMIT)
-- =========================================================
USE ev_charging_network;

-- Q1: List all stations in a specific city (Kochi)
SELECT station_id, station_name, city, operator
FROM stations
WHERE city = 'Kochi';

-- Q2: Show all charging sessions placed in the last 30 days
SELECT session_id, charger_id, customer_id, start_time
FROM charging_sessions
WHERE start_time >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- Q3: Find the 5 longest charging sessions (by duration)
SELECT session_id, customer_id,
       TIMESTAMPDIFF(MINUTE, start_time, end_time) AS duration_minutes
FROM charging_sessions
ORDER BY duration_minutes DESC
LIMIT 5;

-- Q4: List all chargers currently under maintenance
SELECT charger_id, station_id, charger_type, status
FROM chargers
WHERE status = 'Under Maintenance';

-- Q5: Find customers who signed up in 2025
SELECT customer_id, customer_name, signup_date
FROM customers
WHERE YEAR(signup_date) = 2025;
