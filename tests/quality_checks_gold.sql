/* ====================================================================
   Quality Checks – GOLD layer (PostgreSQL)
   Očekivanje: svi SELECT-i ispod treba da vrate 0 redova ili 0 brojčanih vrednosti
   ==================================================================== */

-- 1) Unikatnost surrogate ključa u gold.dim_customers
-- Očekivanje: 0 redova
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- 2) Unikatnost surrogate ključa u gold.dim_products
-- Očekivanje: 0 redova
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- 3) Referencijalni integritet u gold.fact_sales
-- Brzi “smoke test”: proveri null ključeve direktno u fact view-u
-- Očekivanje: 0
SELECT COUNT(*) AS fact_rows_with_null_keys
FROM gold.fact_sales
WHERE product_key IS NULL OR customer_key IS NULL;

-- (Detaljniji prikaz problematičnih redova – po potrebi)
-- Očekivanje: 0 redova (ograničeno na 100 za preglednost)
SELECT *
FROM gold.fact_sales
WHERE product_key IS NULL OR customer_key IS NULL
LIMIT 100;

-- (Alternativa: eksplicitni LEFT JOIN-ovi ako želiš i polja iz dimenzija)
-- Očekivanje: 0 redova
SELECT f.*, c.customer_id, p.product_id
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products  p ON p.product_key  = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;

/* ====================================================================
   (Opcionalno) Dodatne korisne provere
   ==================================================================== */

-- Duplikati po prirodnim ključevima (ako očekuješ 1:1 mapiranje)
-- Očekivanje: 0 redova
SELECT customer_id, COUNT(*) AS cnt
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_number, COUNT(*) AS cnt
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- Brza deskriptiva (korisno za sanity check)
SELECT 'dim_customers' AS obj, COUNT(*) AS rows FROM gold.dim_customers
UNION ALL
SELECT 'dim_products', COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM gold.fact_sales;
