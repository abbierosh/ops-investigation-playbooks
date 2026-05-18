# Investigation Framework

The basic flow I use:

1. Start with the symptom, not the assumed cause.
2. Define what should have happened.
3. Start narrow: one campaign, account, subscriber, event, or time window.
4. Follow the system path from source record to reporting.
5. Separate delayed data from missing data.
6. Compare counts across stages.
7. Treat anomalies as clues, not conclusions.
8. Write down what is confirmed, likely, and unknown.

## Checks I Usually Run

- source record exists
- record was eligible for the next step
- expected event happened
- timestamps make sense
- reporting received the same data
- counts still moving or stopped
