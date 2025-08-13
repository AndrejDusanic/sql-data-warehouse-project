/*
=============================================================
Create Database and Schemas (PostgreSQL)
=============================================================
Script Purpose:
    This script creates a new database named 'datawarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, it sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'datawarehouse' database if it exists.
    All data will be permanently deleted. Proceed with caution and ensure backups are taken.
*/

-- 1) Poveži se na 'postgres' ili drugu administrativnu bazu
--    (u pgAdmin-u otvori Query Tool na 'postgres' bazi)

-- Drop database ako postoji


DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'datawarehouse') THEN
        -- Prekini sve konekcije ka toj bazi
        PERFORM pg_terminate_backend(pid)
        FROM pg_stat_activity
        WHERE datname = 'datawarehouse'
        AND pid <> pg_backend_pid();

        -- Obriši bazu
        EXECUTE 'DROP DATABASE datawarehouse';
    END IF;
END
$$;

-- Kreiraj novu bazu
CREATE DATABASE datawarehouse;

-- 2) Poveži se na 'datawarehouse' (u pgAdmin-u promeni konekciju)
--    ili u psql: \c datawarehouse

-- 3) Kreiraj šeme (ako ne postoje)
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
