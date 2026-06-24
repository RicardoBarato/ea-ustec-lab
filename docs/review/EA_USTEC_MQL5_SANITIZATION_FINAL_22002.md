# EA USTEC MQL5 Sanitization Final 22002

## Files Included

- `src/mql5/USTEC_TrendRunner_v0_4_safety_public.mq5`
- `src/mql5/USTEC_ExportRatesToJson.mq5`

## Sanitization Actions

- Added educational public headers.
- Added no-advice and no-guarantee disclaimers.
- Removed private-release wording.
- Replaced internal candidate label with a public research strategy label.
- Kept symbol and timeframe guard configurable through inputs.
- Kept strategy logic unchanged for public transparency.
- Removed private output prefix from exporter and changed it to a generic local exports folder.
- Confirmed no `.ex5` was included.

## MQL5 Boundary Checks

| Check | Result |
| --- | --- |
| WebRequest | not found |
| DLL import | not found |
| Credential string | not found |
| Broker/server/account hardcode | not found |
| Absolute local paths | not found |
| Hidden code | not found by textual review |
| Compiled artifact | not included |

## Decision

MQL5 source is ready for clean local publication candidate review. It is not approved for live execution.
