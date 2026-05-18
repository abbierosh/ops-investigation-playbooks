# Payload Validation Checklist

When an issue is blamed on an API or integration, I usually try to slow the diagnosis down first.

A lot of "API issues" are actually one of these:

- bad assumptions about the payload shape
- missing required fields
- unexpected null or empty values
- identifier mismatches
- downstream logic behaving differently from what the sender expects

## What I check first

1. Was the payload received at all?
2. Did it contain the fields the downstream workflow expects?
3. Were key identifiers present, valid, and correctly mapped?
4. Was the timestamp or ordering reasonable?
5. Did the payload pass validation but fail later in the workflow?

## Common things worth checking

- record identifiers
- event type or action name
- required custom fields
- timezone and timestamp format
- boolean values passed as strings
- empty strings being treated as real values
- nested objects missing expected keys

## What I try to rule out early

- blaming the API before checking downstream workflow logic
- assuming a payload was rejected when it was actually accepted but mishandled later
- treating one malformed payload as proof of a broader integration failure

## What makes a payload issue operationally important

Payload issues are rarely just technical formatting problems.

They usually affect:

- whether a user enters the right workflow
- whether reporting and segmentation stay trustworthy
- whether internal teams can explain what happened confidently

## Analyst / Operations Angle

If the same payload mistakes keep appearing, the problem is probably bigger than one bad request.

It may point to:

- weak validation rules
- poor field definitions
- unclear integration documentation
- missing internal visibility into rejected or malformed events
