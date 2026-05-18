# Systems, Data & Operations Investigation Playbooks

I work across systems, data, and operations, mostly in the space between what a platform was expected to do, what the data shows, and what teams need to understand next.

Most of my work starts with practical questions:

- what happened in the platform?
- why did it happen?
- who or what was affected?
- is the issue caused by data, timing, configuration, workflow, or expected behaviour?
- what should teams do next?

This repo contains generic and anonymised examples of how I approach that kind of work: investigation notes, SQL checks, validation playbooks, monitoring ideas, reporting checks, and process improvement examples.

The examples are based on SaaS platform operations and technical investigations. The thinking is relevant to analyst roles where systems, data quality, reporting, and operational process all connect.

## What This Repo Shows

- SQL-based investigation and validation
- Reporting and data quality checks
- Workflow and process analysis
- Root cause analysis
- Operational monitoring
- Turning repeated issues into clearer processes or documentation
- Translating technical findings into business-friendly explanations

## What This Repo Covers

- `playbooks/`: repeatable checks for common investigation patterns
- `reporting-validation/`: reconciliation checks for source records and reporting output
- `event-and-reporting-analysis/`: event and reporting validation work
- `data-quality-checks/`: checks for missing, delayed, duplicated, or suspicious data
- `incident-analysis-notes/`: how I frame, narrow, and document live issues
- `framework/`: the investigation mindset behind the queries
- `process-improvements/`: examples of how repeated issues can become clearer processes, monitoring, or handoff points
- `case-studies/`: short examples of working through operational questions
- `systems-thinking/`: notes on patterns behind repeated issues
- `monitoring-logic/`: signals that could help teams spot issues earlier
- `integration-analysis/`: payload and integration analysis notes

## How I Work

The query is rarely the starting point.

I usually start by trying to pin down three things:

- what the system was supposed to do
- what actually happened
- where the most reliable evidence sits

From there, SQL is one tool in a bigger workflow:

- validate whether the underlying records exist
- compare counts across stages of the system
- check timestamps, ordering, and completeness
- work out whether the issue is isolated or systemic
- separate confirmed facts from assumptions
- explain the finding clearly enough for the next team to act on it

Sometimes the next step is a fix. Sometimes it is better monitoring, clearer documentation, a process change, or a cleaner handoff between teams.

## Why I Enjoy This Work

I like work that starts messy and becomes clearer through evidence. Systems, data, and operations work is useful because it helps teams move from uncertainty to a practical next step.

## How This Translates To Analyst Work

- Investigation work becomes business analysis when it helps clarify what happened, who was affected, and what needs to change.
- SQL checks become reporting validation when they help confirm whether data is complete, delayed, duplicated, or incorrect.
- Troubleshooting becomes operations improvement when repeated issues turn into clearer processes, monitoring, documentation, or better handoff points.
- System understanding becomes stakeholder value when technical findings are translated into clear next steps.

## Relevant Skills

- SQL
- Business Analysis
- Operations Analysis
- Reporting Validation
- Data Quality Checks
- Root Cause Analysis
- Workflow Analysis
- Process Improvement
- Stakeholder Communication
- Systems Thinking

## Notes

- Everything here is generic and anonymised.
- The patterns are based on real operational work, but sensitive detail has been removed.
- No client names, internal systems, production data, or confidential details are included.
- The comments explain investigation intent and decision-making, not just SQL syntax.
- The goal is to show how I think through platform, data, and workflow issues.

## Good Starting Points

1. [`framework/investigation-framework.md`](framework/investigation-framework.md) - how I structure system and data investigations
2. [`data-quality-checks/`](data-quality-checks/) - examples of validation checks for missing, delayed, or duplicated data
3. [`monitoring-logic/`](monitoring-logic/) - how repeated issues can become earlier detection signals
4. [`case-studies/reporting-gap-vs-real-incident.md`](case-studies/reporting-gap-vs-real-incident.md) - how I separate real incidents from reporting gaps
5. [`process-improvements/`](process-improvements/) - examples of how investigation work can lead to better workflows
