-- Investigation: campaign performance validation
--
-- Typical use:
-- A campaign looks unusually weak or unusually strong in reporting, and we need
-- to validate whether the result reflects real behaviour or incomplete event data.
--
-- Investigation goal:
-- 1. Compare audience size to actual sends
-- 2. Check whether downstream events exist in believable proportions
-- 3. Flag campaigns where the numbers suggest timing issues or data loss
--
-- Notes:
-- - This is intentionally framed as a validation query, not a reporting query
-- - Use a narrow date range during active investigations to avoid mixing in old noise
-- - In real use, I would usually pair this with campaign status, revision, or queue checks

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

-- Why this is useful:
-- This query helps answer a common operational question:
-- "Is the campaign actually underperforming, or are the underlying numbers incomplete?"
--
-- It also gives you a quick way to spot broken event relationships, which is often
-- more useful during triage than looking at percentages alone.
--
-- What decision this helps drive:
-- - whether to trust reported campaign performance
-- - whether to escalate as a delivery / event issue
-- - whether internal teams can respond with confidence or need engineering input
--
-- What this helps rule out:
-- - a performance issue that is actually a data completeness problem
-- - a missing-send concern when sends are present but downstream events are delayed
-- - bad campaign content being blamed for what is really broken event flow
--
-- Systems thinking:
-- The trade-off here is that summary metrics are quick to consume but can create
-- false confidence when event timing is incomplete. From a user perspective, a
-- dashboard that looks final before the data has settled is worse than one that is
-- explicitly marked as still processing.
--
-- What could be improved in the system:
-- - clearer freshness indicators on campaign reporting
-- - better visibility into event processing stages
-- - guardrails when counts break expected relationships
