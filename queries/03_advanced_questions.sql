-- =========================================================
-- LEVEL: ADVANCED (Subqueries, CTEs, Window Functions, Views, Stored Procedures)
-- REPLACEMENT SET — 5 new questions, different from the extra file
-- =========================================================
USE ev_charging_network;

-- Q1: Find each station's busiest day of the week
-- (window function: RANK within each station, ordered by session count per weekday)
WITH station_weekday_counts AS (
    SELECT
        s.station_name,
        DAYNAME(cs.start_time) AS weekday,
        COUNT(*) AS num_sessions,
        RANK() OVER (PARTITION BY s.station_name ORDER BY COUNT(*) DESC) AS weekday_rank
    FROM charging_sessions cs
    JOIN chargers c ON cs.charger_id = c.charger_id
    JOIN stations s ON c.station_id = s.station_id
    GROUP BY s.station_name, DAYNAME(cs.start_time)
)
SELECT station_name, weekday AS busiest_day, num_sessions
FROM station_weekday_counts
WHERE weekday_rank = 1
ORDER BY station_name;

-- Q2: Customers who have used BOTH Fast and Slow chargers
-- (subquery + HAVING with COUNT DISTINCT — shows customers with varied usage patterns)
SELECT cu.customer_id, cu.customer_name,
       COUNT(DISTINCT c.charger_type) AS charger_types_used
FROM charging_sessions cs
JOIN chargers c ON cs.charger_id = c.charger_id
JOIN customers cu ON cs.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.customer_name
HAVING COUNT(DISTINCT c.charger_type) = 2;

-- Q3: Compare each station's average revenue per session against its city's average
-- (CTE calculates the city average, then joins it back for comparison)
WITH station_avg AS (
    SELECT
        s.station_id,
        s.station_name,
        s.city,
        AVG(p.amount) AS station_avg_revenue
    FROM payments p
    JOIN charging_sessions cs ON p.session_id = cs.session_id
    JOIN chargers c ON cs.charger_id = c.charger_id
    JOIN stations s ON c.station_id = s.station_id
    GROUP BY s.station_id, s.station_name, s.city
),
city_avg AS (
    SELECT city, AVG(station_avg_revenue) AS city_avg_revenue
    FROM station_avg
    GROUP BY city
)
SELECT
    sa.station_name,
    sa.city,
    ROUND(sa.station_avg_revenue, 2) AS station_avg_revenue,
    ROUND(ca.city_avg_revenue, 2) AS city_avg_revenue,
    CASE
        WHEN sa.station_avg_revenue > ca.city_avg_revenue THEN 'Above City Average'
        ELSE 'Below City Average'
    END AS performance
FROM station_avg sa
JOIN city_avg ca ON sa.city = ca.city
ORDER BY sa.city, sa.station_avg_revenue DESC;

-- Q4: Create a view called customer_lifetime_value
-- summarizing each customer's full relationship with the network
CREATE OR REPLACE VIEW customer_lifetime_value AS
SELECT
    cu.customer_id,
    cu.customer_name,
    cu.city,
    COUNT(cs.session_id) AS total_sessions,
    ROUND(SUM(p.amount), 2) AS total_spent,
    MIN(cs.start_time) AS first_session,
    MAX(cs.start_time) AS most_recent_session
FROM customers cu
JOIN charging_sessions cs ON cu.customer_id = cs.customer_id
LEFT JOIN payments p ON cs.session_id = p.session_id
GROUP BY cu.customer_id, cu.customer_name, cu.city;

-- Use it like a table:
-- SELECT * FROM customer_lifetime_value ORDER BY total_spent DESC LIMIT 10;

-- Q5: Stored procedure — get_top_stations(limit_n)
-- returns the top N stations by revenue, with N passed in as a parameter
DELIMITER //

CREATE PROCEDURE get_top_stations(IN limit_n INT)
BEGIN
    SELECT
        s.station_name,
        s.city,
        SUM(p.amount) AS total_revenue,
        COUNT(DISTINCT cs.session_id) AS total_sessions
    FROM payments p
    JOIN charging_sessions cs ON p.session_id = cs.session_id
    JOIN chargers c ON cs.charger_id = c.charger_id
    JOIN stations s ON c.station_id = s.station_id
    GROUP BY s.station_name, s.city
    ORDER BY total_revenue DESC
    LIMIT limit_n;
END //

DELIMITER ;

-- Call it like this:
-- CALL get_top_stations(5);
