-- =========================================================
-- LEVEL: INTERMEDIATE (JOINs, GROUP BY, HAVING, Aggregates)
-- =========================================================
USE ev_charging_network;

-- Q1: Total revenue generated so far
SELECT SUM(amount) AS total_revenue
FROM payments;

-- Q2: Total energy (kWh) consumed per station
SELECT s.station_name, SUM(cs.units_consumed_kwh) AS total_kwh
FROM charging_sessions cs
JOIN chargers c ON cs.charger_id = c.charger_id
JOIN stations s ON c.station_id = s.station_id
GROUP BY s.station_name
ORDER BY total_kwh DESC;

-- Q3: Average session duration per charger type (Fast vs Slow)
SELECT c.charger_type,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, cs.start_time, cs.end_time)), 1) AS avg_duration_minutes
FROM charging_sessions cs
JOIN chargers c ON cs.charger_id = c.charger_id
GROUP BY c.charger_type;

-- Q4: Revenue generated per city
SELECT s.city, SUM(p.amount) AS city_revenue
FROM payments p
JOIN charging_sessions cs ON p.session_id = cs.session_id
JOIN chargers c ON cs.charger_id = c.charger_id
JOIN stations s ON c.station_id = s.station_id
GROUP BY s.city
ORDER BY city_revenue DESC;

-- Q5: Stations with more than 1 maintenance incident (HAVING)
SELECT s.station_name, COUNT(m.log_id) AS maintenance_incidents
FROM maintenance_logs m
JOIN chargers c ON m.charger_id = c.charger_id
JOIN stations s ON c.station_id = s.station_id
GROUP BY s.station_name
HAVING maintenance_incidents > 1
ORDER BY maintenance_incidents DESC;

-- Q6: Peak charging hours — how many sessions started in each hour of the day
SELECT HOUR(start_time) AS hour_of_day, COUNT(*) AS num_sessions
FROM charging_sessions
GROUP BY hour_of_day
ORDER BY num_sessions DESC;

-- BONUS (domain-specific): number of sessions and average kWh by vehicle type
SELECT cu.vehicle_type,
       COUNT(cs.session_id) AS num_sessions,
       ROUND(AVG(cs.units_consumed_kwh), 2) AS avg_kwh
FROM charging_sessions cs
JOIN customers cu ON cs.customer_id = cu.customer_id
GROUP BY cu.vehicle_type;
