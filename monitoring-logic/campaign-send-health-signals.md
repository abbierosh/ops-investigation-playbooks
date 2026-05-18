# Campaign Send Health Signals

When I think about campaign health, I do not start with one metric. I start with signals.

The point is to work out whether a campaign is progressing in a believable way, not just whether one number looks low and makes people nervous.

## Signals I would look at

- scheduled or activation time
- expected audience size
- queue start and queue end timing
- first send event timestamp
- most recent send event timestamp
- whether send counts are still moving
- relationship between send, deliver, bounce, and engagement events
- reporting freshness relative to the current time

## What these signals help answer

- did the campaign start when expected?
- is it stuck, slow, or still progressing normally?
- are events arriving in the right order?
- does the reporting layer look behind the source data?
- is this a single-campaign issue or something broader?

## Example warning patterns

- campaign status looks complete but send events are still sparse
- send counts are far below expected audience with no continued movement
- downstream event relationships stop making sense
- multiple campaigns in the same window show similar lag

## Why this is better than one dashboard number

Operationally, campaign issues are rarely binary.

The risk is not just missing a true failure. It is also overreacting to temporary lag or incomplete reporting.

Signal-based monitoring gives a much better early read on what kind of issue you are actually dealing with.

## Analyst / Operations Angle

The best monitoring is not just technically correct. It helps teams make better decisions faster.

A useful health signal should reduce ambiguity, improve escalation quality, and make it easier to explain what is happening to both internal teams and customers.
