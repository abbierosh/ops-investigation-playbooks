# Monitoring Improvement: Detecting Campaign Delays Earlier

## Problem

One of the more frustrating classes of issues is when a campaign looks "sent" from one part of the system, but subscriber-level events suggest sending is delayed, incomplete, or still catching up.

This creates a few problems at once:

- customer-facing teams lose confidence in the platform
- teams spend time manually checking whether counts are still moving
- engineering gets escalations before it is clear whether the issue is missing data or delayed processing

## Approach

I would treat this as a monitoring gap rather than just an investigation problem.

The improvement would be a lightweight health check that compares:

- scheduled or deployed send time
- expected audience size
- queue progression
- first send event timestamp
- latest send event timestamp
- whether send counts are still moving

The output does not need to be complicated. It just needs to answer:

- has sending started?
- is sending progressing normally?
- is this delayed enough to matter operationally?
- do we need a human to look at it?

## Reasoning

In live operations, timing issues are expensive mostly because they are ambiguous.

Without visibility, teams end up asking the same questions repeatedly:

- is it stuck?
- is it just slow?
- is reporting behind?
- should we message the customer yet?

A simple delay monitor reduces that ambiguity early. It also gives teams a more defensible answer before an issue becomes a bigger escalation.

## Impact

- faster triage for campaign delay issues
- fewer manual checks against event tables
- clearer internal communication during active incidents
- better separation between true send failures and temporary lag

## Analyst / Operations Lens

This is not just a technical alert.

It improves the customer experience indirectly by making the platform easier to explain and less dependent on ad hoc SQL checks when something feels off.
