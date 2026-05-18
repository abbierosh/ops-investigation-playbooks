-- Investigation: campaign performance validation
--
-- Used when reporting looks unusual and I need to check whether the event data
-- is complete enough to trust.

WITH campaign_scope AS (
    SELECT
        c.campaign_id,
        c.campaign_name,
        c.channel,
        c.scheduled_at,
        c.status,
        c.expected_audience_count
    FROM campaign c
    WHERE c.scheduled_at >= DATE '2026-04-01'
      AND c.scheduled_at < DATE '2026-04-08'
      AND c.status IN ('sent', 'completed')
),
event_rollup AS (
    SELECT
        se.campaign_id,
        COUNT(*) FILTER (WHERE se.event_ref = 'sent') AS sent_count,
        COUNT(*) FILTER (WHERE se.event_ref = 'delivered') AS delivered_count,
        COUNT(*) FILTER (WHERE se.event_ref = 'open') AS open_count,
        COUNT(*) FILTER (WHERE se.event_ref = 'click') AS click_count,
        COUNT(*) FILTER (WHERE se.event_ref = 'bounce') AS bounce_count,
        MIN(se.event_timestamp) AS first_event_at,
        MAX(se.event_timestamp) AS last_event_at
    FROM subscriber_event se
    WHERE se.event_timestamp >= TIMESTAMP '2026-04-01 00:00:00'
      AND se.event_timestamp < TIMESTAMP '2026-04-10 00:00:00'
    GROUP BY se.campaign_id
)
SELECT
    cs.campaign_id,
    cs.campaign_name,
    cs.channel,
    cs.status,
    cs.expected_audience_count,
    COALESCE(er.sent_count, 0) AS sent_count,
    COALESCE(er.delivered_count, 0) AS delivered_count,
    COALESCE(er.open_count, 0) AS open_count,
    COALESCE(er.click_count, 0) AS click_count,
    COALESCE(er.bounce_count, 0) AS bounce_count,
    ROUND(100.0 * COALESCE(er.sent_count, 0) / NULLIF(cs.expected_audience_count, 0), 2) AS send_vs_audience_pct,
    ROUND(100.0 * COALESCE(er.delivered_count, 0) / NULLIF(er.sent_count, 0), 2) AS delivery_rate_pct,
    ROUND(100.0 * COALESCE(er.open_count, 0) / NULLIF(er.delivered_count, 0), 2) AS open_rate_pct,
    ROUND(100.0 * COALESCE(er.click_count, 0) / NULLIF(er.delivered_count, 0), 2) AS click_rate_pct,
    er.first_event_at,
    er.last_event_at,
    CASE
        WHEN er.campaign_id IS NULL THEN 'No event stream found'
        WHEN COALESCE(er.sent_count, 0) < cs.expected_audience_count * 0.80 THEN 'Send volume below expectation'
        WHEN COALESCE(er.delivered_count, 0) > COALESCE(er.sent_count, 0) THEN 'Delivery count higher than send count'
        WHEN COALESCE(er.open_count, 0) > COALESCE(er.delivered_count, 0) THEN 'Open count higher than delivery count'
        WHEN er.last_event_at < cs.scheduled_at THEN 'Events appear earlier than scheduled send'
        ELSE 'Looks directionally consistent'
    END AS validation_flag
FROM campaign_scope cs
LEFT JOIN event_rollup er
    ON cs.campaign_id = er.campaign_id
ORDER BY cs.scheduled_at DESC, cs.campaign_id;
