-- =========================================================
-- PROJECT: EV Charging Station Network — SQL Analytics
-- FILE: create_tables.sql
-- PURPOSE: Defines the 6-table relational schema
-- =========================================================

CREATE DATABASE IF NOT EXISTS ev_charging_network;
USE ev_charging_network;

-- 1. STATIONS
CREATE TABLE stations (
    station_id      INT PRIMARY KEY,
    station_name    VARCHAR(100),
    city            VARCHAR(50),
    operator        VARCHAR(50),   -- e.g. Tata Power, Ather Grid, ChargeZone
    num_chargers    INT
);

-- 2. CHARGERS
CREATE TABLE chargers (
    charger_id      INT PRIMARY KEY,
    station_id      INT,
    charger_type    VARCHAR(20),   -- 'Fast' or 'Slow'
    status          VARCHAR(20),   -- 'Active', 'Under Maintenance', 'Offline'
    FOREIGN KEY (station_id) REFERENCES stations(station_id)
);

-- 3. CUSTOMERS
CREATE TABLE customers (
    customer_id     INT PRIMARY KEY,
    customer_name   VARCHAR(100),
    vehicle_type    VARCHAR(30),   -- e.g. 2-Wheeler, 4-Wheeler, Commercial
    city            VARCHAR(50),
    signup_date     DATE
);

-- 4. CHARGING_SESSIONS
CREATE TABLE charging_sessions (
    session_id          INT PRIMARY KEY,
    charger_id          INT,
    customer_id         INT,
    start_time          DATETIME,
    end_time            DATETIME,
    units_consumed_kwh  DECIMAL(6,2),
    FOREIGN KEY (charger_id) REFERENCES chargers(charger_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 5. PAYMENTS
CREATE TABLE payments (
    payment_id      INT PRIMARY KEY,
    session_id      INT,
    amount          DECIMAL(10,2),
    payment_mode    VARCHAR(20),   -- UPI, Card, Wallet
    payment_date    DATE,
    FOREIGN KEY (session_id) REFERENCES charging_sessions(session_id)
);

-- 6. MAINTENANCE_LOGS
CREATE TABLE maintenance_logs (
    log_id           INT PRIMARY KEY,
    charger_id       INT,
    issue_reported   VARCHAR(100),
    reported_date    DATE,
    resolved_date    DATE,
    downtime_hours   DECIMAL(6,2),
    FOREIGN KEY (charger_id) REFERENCES chargers(charger_id)
);
