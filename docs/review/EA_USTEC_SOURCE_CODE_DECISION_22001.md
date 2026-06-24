# EA USTEC Source Code Decision 22001

## Decision Summary

EA USTEC source publication is not ready as-is. The public candidate is documentation-safe, but the trading EA source requires sanitization and human approval before inclusion.

## File Classification

| Candidate source | Classification | Reason |
| --- | --- | --- |
| USTEC_TrendRunner_v0_4_safety.mq5 | INCLUDE_AFTER_SANITIZATION | Trading EA with private candidate wording, hardcoded symbol guard, magic number, operational inputs, order execution and internal comments. Publish only after a dedicated public-source review. |
| USTEC_TrendRunner_v0_4_safety_session_entry_quality_pilot.mq5 | INCONCLUSIVE | Not found in the authorized source tree during this review. Results can remain documented, but source cannot be approved without locating and reviewing the file. |
| USTEC_ExportRatesToJson.mq5 | INCLUDE_PUBLIC | Script/exporter, not an EA. Review found file output, symbol/date inputs, and manifest writing, but no trade execution, no network request, no DLL import, and no sensitive account export. |
| Generic Python parsers | INCLUDE_AFTER_SANITIZATION | Can be public if they are data-format utilities only and contain no private paths, datasets, broker artifacts, or strategy internals. |
| Validators | INCLUDE_PUBLIC | Publication guards and tests are safe after 22001 hardening. |
| Probability/risk/robustness tools | DOCUMENT_ONLY | Publish methodology first. Code should stay private unless proven free of private data, strategy leakage, and internal run artifacts. |
| Tests and synthetic fixtures | INCLUDE_PUBLIC | Safe when synthetic-only and guard-covered. |

## MQL5 Review Findings

- Symbol guard exists and is tied to the USTEC/Nasdaq research instrument.
- Trading EA uses CTrade and position/order handling, so it is not a neutral educational script.
- Trading EA contains operational defaults, including risk, spread, session, indicator, target, and magic-number inputs.
- Trading EA uses AccountInfoDouble for equity-based sizing; this is not a leak by itself but confirms operational behavior.
- No WebRequest, DLL import, or external service integration was found in the reviewed MQL5 files.
- Exporter writes local JSONL/manifest files through FileOpen and declares that trade/account data is not exported.

## Required Before Publishing Trading Source

1. Create a clean public-source branch or candidate copy.
2. Remove private wording and internal candidate identifiers.
3. Decide whether magic number and operational defaults are public-safe.
4. Add a clear non-operational disclaimer in source header.
5. Run a dedicated MQL5 security/source review before including the file.

## Decision

NEEDS_SOURCE_CODE_CHANGES.
