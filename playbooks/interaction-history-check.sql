-- Investigation: interaction history check
--
-- Typical use:
-- A team member says a contact "never received anything" or "has no activity",
-- and the first job is to check whether the platform has actually recorded any
-- meaningful interaction history for that person.
--
-- Investigation goal:
-- 1. Confirm whether matching events exist
-- 2. Separate delivery activity from engagement activity
-- 3. Check the time range so we know whether the profile is inactive or just recent
--
-- Notes:
-- - Replace the sample ref_ids with the identifiers relevant to your case
-- - Keep the event list intentionally narrow at first; broaden it only if needed
-- - In practice this check is often paired with audience, suppression, or campaign-level validation

WITH scoped_events AS (
    SELECT
        se.ref_id,
        se.event_ref,
        se.event_timestamp,
        se.campaign_id
    FROM subscriber_event se
    WHERE se.ref_id IN ('REF001', 'REF002', 'REF003')
      AND se.event_ref IN ('sent', 'delivered', 'open', 'click', 'bounce', 'unsubscribe')
),
event_summary AS (
    SELECT
        ref_id,
        COUNT(*) AS total_events,
        MIN(event_timestamp) AS first_event_at,
        MAX(event_timestamp) AS last_event_at,
        COUNT(*) FILTER (WHERE event_ref IN ('sent', 'delivered')) AS delivery_events,
        COUNT(*) FILTER (WHERE event_ref IN ('open', 'click')) AS engagement_events,
        COUNT(*) FILTER (WHERE event_ref = 'bounce') AS bounce_events,
        COUNT(*) FILTER (WHERE event_ref = 'unsubscribe') AS unsubscribe_events
    FROM scoped_events
    GROUP BY ref_id
)
SELECT
    ref_id,
    total_events,
    delivery_events,
    engagement_events,
    bounce_events,
    unsubscribe_events,
    first_event_at,
    last_event_at,
    CASE
        WHEN total_events = 0 THEN 'No recorded history'
        WHEN delivery_events > 0 AND engagement_events = 0 THEN 'Delivered but no engagement'
        WHEN delivery_events = 0 AND bounce_events > 0 THEN 'Failed at delivery stage'
        ELSE 'Has interaction history'
    END AS investigation_note
FROM event_summary
ORDER BY last_event_at DESC NULLS LAST;

-- Why this is useful:
-- This query is not trying to tell the whole story. It is the first pass.
-- If there is no history, that points you toward ingestion, audience membership,
-- identifier mismatch, or send eligibility issues. If there is history, you can
-- move into campaign-level or timeline-level analysis next.
--
-- What decision this helps drive:
-- - If no events exist, do not spend time analysing engagement yet
-- - If delivery exists without engagement, the issue may be content, audience fit,
--   or simply lack of interaction rather than a send failure
-- - If bounce events exist without delivery, the next step is usually deliverability
--   or subscriber-status validation
--
-- What this helps rule out:
-- - "Nothing happened at all" when the system actually did record activity
-- - "The platform never sent" when the real issue is post-send behaviour
-- - premature escalation before basic profile-level history is confirmed
--
-- Systems thinking:
-- One recurring lesson from checks like this is that internal teams often need a
-- simpler way to see subscriber history without reaching for SQL. If a case depends
-- on manual validation every time, that is usually a tooling gap, not just an ops task.
