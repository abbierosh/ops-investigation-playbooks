# Why Statuses Can Mislead Users

System status labels are useful, but they are often not as complete as users assume.

A status like:

- scheduled
- deployed
- sent
- completed

can be technically correct while still creating operational confusion.

## Why this happens

A single status often collapses multiple stages into one visible label.

For example, a campaign may be considered sent from a workflow perspective while:

- queue processing is still underway
- subscriber-level events are still landing
- reporting totals are still incomplete
- downstream engagement data has barely started

## What users see

Users usually interpret the label as a full answer.

If they see "sent", they assume the work is finished and the reporting should already be trustworthy.

That is where the gap starts.

## What this means operationally

A lot of investigation work is really about reconciling:

- platform state
- data state
- user expectation

Those are not always the same thing.

## Better ways to think about it

Instead of relying on a single status, it is often more useful to separate:

- configuration state
- processing state
- reporting freshness
- final completion

## Analyst / Operations Angle

Repeated confusion around statuses is rarely just a training problem. It often points to a system communication issue.

If a label is technically accurate but regularly leads teams to the wrong conclusion, then the system is still failing to communicate something important.
