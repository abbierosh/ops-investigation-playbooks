#!/usr/bin/env python3
"""Compare source records with reporting output.

This is a small version of the checks I would normally do in SQL.
It is useful when I have two extracts and want a quick read on missing,
duplicated, delayed, or mismatched records.
"""

from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from datetime import datetime, timedelta
from decimal import Decimal, InvalidOperation
from pathlib import Path


EXPECTED_SOURCE_COLUMNS = {
    "business_key",
    "source_status",
    "source_amount",
    "source_updated_at",
}

EXPECTED_REPORTING_COLUMNS = {
    "business_key",
    "report_status",
    "report_amount",
    "reporting_loaded_at",
}


def parse_time(value: str) -> datetime:
    return datetime.fromisoformat(value.strip())


def parse_amount(value: str) -> Decimal:
    try:
        return Decimal(value.strip())
    except InvalidOperation:
        return Decimal("NaN")


def read_csv(path: Path, expected_columns: set[str]) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        missing = expected_columns - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"{path} is missing columns: {', '.join(sorted(missing))}")
        return list(reader)


def latest_reporting_rows(rows: list[dict[str, str]]) -> dict[str, dict[str, object]]:
    grouped: dict[str, list[dict[str, str]]] = defaultdict(list)
    for row in rows:
        grouped[row["business_key"]].append(row)

    rollup = {}
    for business_key, items in grouped.items():
        latest = max(items, key=lambda row: parse_time(row["reporting_loaded_at"]))
        rollup[business_key] = {
            "row_count": len(items),
            "report_status": latest["report_status"],
            "report_amount": latest["report_amount"],
            "first_loaded_at": min(parse_time(row["reporting_loaded_at"]) for row in items),
            "last_loaded_at": parse_time(latest["reporting_loaded_at"]),
        }
    return rollup


def classify(source: dict[str, str], reporting: dict[str, object] | None, delay_hours: int) -> str:
    if reporting is None:
        return "missing_from_reporting"
    if reporting["row_count"] > 1:
        return "duplicate_reporting_rows"

    source_updated_at = parse_time(source["source_updated_at"])
    first_loaded_at = reporting["first_loaded_at"]
    if first_loaded_at > source_updated_at + timedelta(hours=delay_hours):
        return "delayed_reporting_load"

    if source["source_status"] != reporting["report_status"]:
        return "status_mismatch"

    if parse_amount(source["source_amount"]) != parse_amount(str(reporting["report_amount"])):
        return "amount_mismatch"

    return "reconciled"


def reconcile(
    source_rows: list[dict[str, str]],
    reporting_rows: list[dict[str, str]],
    delay_hours: int,
) -> list[dict[str, str]]:
    reporting_by_key = latest_reporting_rows(reporting_rows)
    results = []

    for source in source_rows:
        business_key = source["business_key"]
        reporting = reporting_by_key.get(business_key)
        status = classify(source, reporting, delay_hours)

        results.append(
            {
                "business_key": business_key,
                "source_status": source["source_status"],
                "report_status": str(reporting["report_status"]) if reporting else "",
                "source_amount": source["source_amount"],
                "report_amount": str(reporting["report_amount"]) if reporting else "",
                "source_updated_at": source["source_updated_at"],
                "first_loaded_at": reporting["first_loaded_at"].isoformat(sep=" ") if reporting else "",
                "last_loaded_at": reporting["last_loaded_at"].isoformat(sep=" ") if reporting else "",
                "reporting_row_count": str(reporting["row_count"]) if reporting else "0",
                "reconciliation_status": status,
            }
        )

    return results


def write_csv(path: Path, rows: list[dict[str, str]]) -> None:
    if not rows:
        return
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def print_summary(rows: list[dict[str, str]]) -> None:
    counts: dict[str, int] = defaultdict(int)
    for row in rows:
        counts[row["reconciliation_status"]] += 1

    print("Reconciliation summary")
    for status, count in sorted(counts.items()):
        print(f"- {status}: {count}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Compare source and reporting CSV extracts.")
    parser.add_argument("--source", required=True, type=Path, help="Source CSV path")
    parser.add_argument("--reporting", required=True, type=Path, help="Reporting CSV path")
    parser.add_argument("--output", required=True, type=Path, help="Output CSV path")
    parser.add_argument("--delay-hours", type=int, default=2, help="Delay threshold. Default: 2")
    args = parser.parse_args()

    source_rows = read_csv(args.source, EXPECTED_SOURCE_COLUMNS)
    reporting_rows = read_csv(args.reporting, EXPECTED_REPORTING_COLUMNS)
    results = reconcile(source_rows, reporting_rows, args.delay_hours)
    write_csv(args.output, results)
    print_summary(results)
    print(f"Output written to {args.output}")


if __name__ == "__main__":
    main()
