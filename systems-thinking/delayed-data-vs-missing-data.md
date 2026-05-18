# Delayed Data vs Missing Data

One of the easiest ways to misread a platform issue is to confuse delayed data with missing data.

They can look identical at first:

- counts are lower than expected
- events are absent from reporting
- a workflow appears incomplete

But they usually mean very different things.

## Delayed data

Delayed data means the expected record appears later than normal.

Operationally, this often points to:

- queueing delays
- downstream processing lag
- late-arriving event ingestion
- reporting layers catching up behind source records

## Missing data

Missing data means the expected record never appears at all.

That usually points more toward:

- a workflow not firing
- a bad eligibility or targeting condition
- an integration failure
- a payload or mapping issue
- a broken write into the next system stage

## Why this distinction matters

If delayed data is treated as missing data, teams escalate too early and can misdiagnose the issue.

If missing data is treated as delayed data, teams wait too long and the real failure persists.

## What I normally check

- are counts still moving?
- do source records exist even if reporting is incomplete?
- is this isolated to one event type or one stage of the workflow?
- do similar cases from the same time window show the same pattern?

## Analyst / Operations Angle

This is one of the most useful distinctions in operational work because it affects communication as much as diagnosis.

Customers and internal teams do not experience "delayed vs missing" as a technical nuance. They experience it as trust or uncertainty. Good operational visibility should help teams tell the difference earlier.
