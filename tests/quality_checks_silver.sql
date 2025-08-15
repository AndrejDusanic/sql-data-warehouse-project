-- 0) Šeme
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;

-- 1) Bez PRINT → koristi RAISE NOTICE
-- 2) Transakcija i error handling preko procedure + EXCEPTION

CREATE OR REPLACE PROCEDURE silver.etl_template()
LANGUAGE plpgsql
AS $$
DECLARE
  t0 timestamp := now();
  t  timestamp;
BEGIN
  RAISE NOTICE '--- ETL start ---';

  -- Primer: truncate + insert
  t := now();
  TRUNCATE TABLE silver.some_table;
  INSERT INTO silver.some_table (col1, col2, col3)
  SELECT
    col1,
    trim(col2),
    COALESCE(nullif(col3,''), 'n/a')
  FROM bronze.some_table;
  RAISE NOTICE 'some_table done in % s', (EXTRACT(EPOCH FROM (now()-t))::int);

  RAISE NOTICE '--- ETL done in % s ---', (EXTRACT(EPOCH FROM (now()-t0))::int);

EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'ERROR: % (SQLSTATE %)', SQLERRM, SQLSTATE;
END;
$$;

-- Pokretanje:
CALL silver.etl_template();
