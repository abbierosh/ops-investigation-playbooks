-- Investigation: missing data / anomaly check
--
-- Compares recent event volume against a short baseline.

WITH daily_event_counts AS (
    SELECT
        CAST(se.event_timestamp AS DATE) AS event_date,
        COUNT(*) AS event_count
    FROM subscriber_event se
    WHERE se.event_timestamp >= CURRENT_DATE - INTERVAL '14 days'
      AND se.event_ref IN ('sent', 'delivered', 'open', 'click')
    GROUP BY CAST(se.event_timestamp AS DATE)
),
baseline AS (
    SELECT
        AVG(event_count) AS avg_event_count,
        MIN(event_count) AS min_event_count,
        MAX(event_count) AS max_event_count
    FROM daily_event_counts
    WHERE event_date >= CURRENT_DATE - INTERVAL '14 days'
      AND event_date < CURRENT_DATE - INTERVAL '3 days'
),
scored_days AS (
    SELECT
        dec.event_date,
        dec.event_count,
        b.avg_event_count,
        ROUND(100.0 * dec.event_count / NULLIF(b.avg_event_count, 0), 2) AS pct_of_baseline
    FROM daily_event_counts dec
    CROSS JOIN baseline b
)
SELECT
    event_date,
    event_count,
    avg_event_count,
    pct_of_baseline,
    CASE
        WHEN event_count = 0 THEN 'No events recorded'
        WHEN pct_of_baseline < 50 THEN 'Material drop vs baseline'
        WHEN pct_of_baseline > 150 THEN 'Material spike vs baseline'
        ELSE 'Within normal range'
    END AS anomaly_flag
FROM scored_days
ORDER BY event_date DESC;
