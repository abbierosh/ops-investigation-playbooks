# Send Delay Triage Notes

Reported issue: campaign sends looked later than expected.

## Check

1. Scheduled time, activation time, and status
2. Audience size vs send count
3. First and latest send event
4. Gap between campaign status and subscriber events
5. Whether counts are still moving
6. Whether other campaigns show the same pattern

## Read

- Low but rising send count: likely delayed processing
- Sent status but no subscriber events: check event lag
- Delivered events but no opens across campaigns: check tracking or ingestion

## Document

- IDs checked
- time window
- confirmed vs unknown
- isolated or wider
