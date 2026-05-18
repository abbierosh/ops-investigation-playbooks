# Send Delay Triage Notes

## Situation

Reported issue: a campaign was marked as scheduled, but customer-facing teams believed sends were going out later than expected.

What makes this kind of issue tricky is that several different failure modes can look the same from the outside. A customer sees "it sent late" or "it did not send properly", but operationally that could mean queue delay, event lag, reporting delay, incomplete targeting, or an actual send problem.

## First questions I would ask

- Was the campaign actually activated on time?
- Did audience selection finish before the scheduled send?
- Are send events delayed, or is reporting delayed?
- Is this one campaign, one customer, or a wider pattern?

## First checks

1. Pull the campaign record and confirm scheduled time, activation time, and current status.
2. Compare expected audience size with actual send volume.
3. Check the first and last send event timestamps.
4. Look for a gap between campaign status updates and subscriber-level events.
5. Compare the same time window against a recent "normal" campaign.

## Why these checks matter

The purpose of the first pass is not to prove a root cause immediately.

It is to answer a more basic operational question first:

- are we looking at a real send issue?
- are we looking at delayed visibility?
- or are we looking at a normal process that is being interpreted as a failure?

That distinction drives everything that follows, including whether the next step is customer communication, engineering escalation, or simply waiting for processing to catch up.

## What usually matters most

The important distinction is whether the delay happened in:

- campaign setup
- audience generation
- message queueing
- downstream delivery logging
- reporting freshness

Those can look similar at a high level, but they lead to very different next actions.

## What I would try to rule out early

- a timezone misunderstanding between scheduled time and reported send time
- a campaign that was activated later than people realised
- reporting that is lagging behind actual processing
- a campaign with a genuinely smaller target audience than expected
- an issue isolated to one campaign being interpreted as a platform-wide problem

## Common failure patterns

### Pattern 1: send count is low, but rising steadily

Usually points to delayed processing, throttling, or a backlog rather than a complete send failure.

Decision this supports:
avoid calling it a failed send too early and instead monitor progression before escalating more widely.

### Pattern 2: campaign status says sent, but subscriber events are missing

Often worth checking whether the event pipeline is lagging or whether status is being updated before lower-level records finish landing.

Decision this supports:
separate product state from data state, because the customer-facing answer may need to acknowledge that system visibility is incomplete.

### Pattern 3: delivered events exist, but opens are missing across the board

Could be genuine low engagement, but if it appears suddenly across multiple campaigns it is more likely to be a tracking or ingestion issue.

Decision this supports:
do not frame it as a content-performance issue until tracking behaviour has been validated.

## Systems Thinking

This kind of issue usually means the platform is missing an operational layer between raw system state and user expectation.

Trade-off:

- it may be technically true that a campaign is deployed or sending
- but that does not mean the platform is giving users a trustworthy picture of progress

For users, that gap feels like unreliability even when the underlying process is still moving.

What could be improved:

- clearer send-progress visibility
- better distinction between queued, actively sending, and fully completed states
- monitoring for campaigns that are slow enough to create customer concern
- internal tooling so support does not need manual SQL to validate basic progression

## What I would document before closing the issue

- exact campaign IDs checked
- time window reviewed
- whether counts were still moving during the investigation
- what was confirmed vs what was inferred
- whether the issue was isolated, systemic, or unresolved pending more data
