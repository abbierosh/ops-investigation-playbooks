-- Investigation: source-to-reporting reconciliation check
--
-- Typical use:
-- A report does not match what teams expect from the source system, and we need
-- to understand whether records are missing, delayed, duplicated, or mismatched.
--
-- Investigation goal:
-- 1. Compare source records with reporting output for the same business key
-- 2. Flag missing, delayed, duplicated, or value-mismatched records
-- 3. Produce a clear validation status that can be explained to non-technical teams
--
-- Notes:
-- - Table and column names are generic placeholders
-- - This is a validation pattern, not a finance-specific example
-- - In real use, the business key should be the most stable shared identifier

WITH source_records AS (
    SELECT
        sr.record_id,
        sr.account_id,
        sr.business_key,
        sr.source_status,
        sr.source_amount,
        sr.created_at AS source_created_at,
        sr.updated_at AS source_updated_at
    FROM source_transaction sr
    WHERE sr.created_at >= TIMESTAMP '2026-04-01 00:00:00'
      AND sr.created_at < TIMESTAMP '2026-04-08 00:00:00'
),
reporting_records AS (
    SELECT
        rr.report_record_id,
        rr.business_key,
        rr.report_status,
        rr.report_amount,
        rr.loaded_at AS reporting_loaded_at
    FROM reporting_transaction rr
    WHERE rr.loaded_at >= TIMESTAMP '2026-04-01 00:00:00'
      AND rr.loaded_at < TIMESTAMP '2026-04-09 00:00:00'
),
reporting_rollup AS (
    SELECT
        business_key,
        COUNT(*) AS reporting_row_count,
        MIN(reporting_loaded_at) AS first_loaded_at,
        MAX(reporting_loaded_at) AS last_loaded_at,
        MAX(report_status) AS report_status,
        MAX(report_amount) AS report_amount
    FROM reporting_records
    GROUP BY business_key
)
SELECT
    sr.business_key,
    sr.account_id,
    sr.source_status,
    rr.report_status,
    sr.source_amount,
    rr.report_amount,
    sr.source_updated_at,
    rr.first_loaded_at,
    rr.last_loaded_at,
    COALESCE(rr.reporting_row_count, 0) AS reporting_row_count,
    CASE
        WHEN rr.business_key IS NULL THEN 'Missing from reporting output'
        WHEN rr.reporting_row_count > 1 THEN 'Duplicate reporting rows'
        WHEN rr.first_loaded_at > sr.source_updated_at + INTERVAL '2 hours' THEN 'Delayed reporting load'
        WHEN rr.report_status <> sr.source_status THEN 'Status mismatch'
        WHEN rr.report_amount <> sr.source_amount THEN 'Amount mismatch'
        ELSE 'Reconciled'
    END AS reconciliation_status
FROM source_records sr
LEFT JOIN reporting_rollup rr
    ON sr.business_key = rr.business_key
ORDER BY
    CASE
        WHEN rr.business_key IS NULL THEN 1
        WHEN rr.reporting_row_count > 1 THEN 2
        WHEN rr.first_loaded_at > sr.source_updated_at + INTERVAL '2 hours' THEN 3
        WHEN rr.report_status <> sr.source_status THEN 4
        WHEN rr.report_amount <> sr.source_amount THEN 5
        ELSE 6
    END,
    sr.source_updated_at DESC;

-- Why this is useful:
-- This pattern helps separate a real operational issue from a reporting issue.
-- It gives teams a quick way to see whether the source record exists, whether it
-- reached reporting, and whether the reported values still match the source.
--
-- What decision this helps drive:
-- - whether a report can be trusted for the current period
-- - whether the issue is missing data, delayed loading, duplication, or mismatch
-- - whether the next step belongs with data operations, systems, or process owners
