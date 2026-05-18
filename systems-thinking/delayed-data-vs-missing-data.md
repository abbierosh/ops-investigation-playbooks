# Delayed Data vs Missing Data

Delayed and missing data can look the same:

- low counts
- missing reporting events
- incomplete workflow

## Delayed

The record appears later than expected.

Usually: queueing, processing lag, late ingestion, or reporting catching up.

## Missing

The record never appears.

Usually: workflow, eligibility, integration, payload, mapping, or write issue.

## Check

- are counts still moving?
- does the source record exist?
- is reporting behind the source?
- is this one event type or wider?
