-- Investigation: interaction history check
--
-- First pass for checking whether a profile has send, delivery, engagement,
-- bounce, or unsubscribe history.

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
