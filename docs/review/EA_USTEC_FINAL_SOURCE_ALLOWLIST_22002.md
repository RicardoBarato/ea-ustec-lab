# EA USTEC Final Source Allowlist 22002

| Source | Origin | Decision | Reason |
| --- | --- | --- | --- |
| USTEC_TrendRunner_v0_4_safety.mq5 | authorized EA USTEC origin | INCLUDE_AFTER_SANITIZATION | Trading EA source can be published only with public header, public labels, no private wording, no private paths, no broker/server/account data, and explicit educational disclaimer. |
| USTEC_TrendRunner_v0_4_safety_public.mq5 | sanitized local candidate | INCLUDE_PUBLIC | Sanitized from the authorized source for transparent research review. Strategy logic was not optimized or improved. |
| USTEC_TrendRunner_v0_4_safety_session_entry_quality_pilot.mq5 | not found in authorized source tree | INCONCLUSIVE | Results remain documentable, but source cannot be published until the exact source file is located and reviewed. |
| USTEC_ExportRatesToJson.mq5 | authorized EA USTEC origin | INCLUDE_PUBLIC | Script/exporter only; uses CopyRates and FileOpen; no trading operations, no network request, no DLL import, no account export. |
| Publication guards | local candidate | INCLUDE_PUBLIC | Public-safe validators with encoded deny policy and tests. |
| Tests | local candidate | INCLUDE_PUBLIC | Synthetic/local tests only. |
| Private parsers/report tools | not copied | EXCLUDE_PRIVATE | Private report and data tooling is not required for public package. |
| Probability/risk/robustness tools | not copied | DOCUMENT_ONLY | Methodology can be documented; code stays private unless separately reviewed. |

## Authorship And License

Included source is treated as original project code under Apache-2.0, subject to final human legal review.
