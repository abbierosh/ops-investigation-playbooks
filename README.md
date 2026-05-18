# Systems, Data & Operations Investigation Playbooks

I work across systems, data, and operations.

This repo shows how I investigate platform issues, validate data, and improve repeated workflows.

## What This Shows

- SQL checks
- Reporting validation
- Data quality checks
- Root cause analysis
- Workflow analysis
- Monitoring ideas
- Process improvement

## Folders

- `framework/`: investigation structure
- `playbooks/`: reusable SQL checks
- `reporting-validation/`: source vs reporting checks
- `data-quality-checks/`: missing, delayed, or duplicated data
- `event-and-reporting-analysis/`: event and reporting validation
- `incident-analysis-notes/`: triage notes
- `monitoring-logic/`: early warning signals
- `process-improvements/`: repeated issues into better process
- `case-studies/`: short examples
- `systems-thinking/`: repeated patterns
- `integration-analysis/`: payload and integration checks
- `tools/`: small Python checks that run locally
- `sample-data/`: fake CSV data for the Python example

## Relevant Skills

SQL, Python, Business Analysis, Operations Analysis, Reporting Validation, Data Quality Checks, Root Cause Analysis, Workflow Analysis, Process Improvement, Stakeholder Communication, Systems Thinking

## Notes

- Everything is generic and anonymised.
- No client names, internal systems, production data, or confidential details are included.
- The examples are based on SaaS platform operations and technical investigations.

## Good Starting Points

1. [`framework/investigation-framework.md`](framework/investigation-framework.md)
2. [`data-quality-checks/`](data-quality-checks/)
3. [`reporting-validation/reconciliation-check.sql`](reporting-validation/reconciliation-check.sql)
4. [`tools/reconcile_reporting.py`](tools/reconcile_reporting.py)
5. [`case-studies/reporting-gap-vs-real-incident.md`](case-studies/reporting-gap-vs-real-incident.md)

Run the Python example:

```bash
python3 tools/reconcile_reporting.py \
  --source sample-data/source_records.csv \
  --reporting sample-data/reporting_records.csv \
  --output sample-data/reconciliation_output.csv
```
