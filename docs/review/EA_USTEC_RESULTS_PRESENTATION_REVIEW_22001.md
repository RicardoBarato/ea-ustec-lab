# EA USTEC Results Presentation Review 22001

## Required Metrics Check

| Candidate | Window | Required values | Visible? |
| --- | --- | --- | --- |
| v0_4_safety | 2025 | +US$1,120.04, PF 1.13, DD 10.23%, 235 trades | yes |
| v0_4_safety | 2021-2025 | -US$4,801.03, PF 0.83, DD 59.15% | yes |
| v0_4_safety | 2016-2025 | -US$6,321.53, PF 0.82, DD 70.12% | yes |
| session_entry_quality | 2025 | +US$1,652.00, PF 1.22, DD 8.00%, 203 trades | yes |
| session_entry_quality | 2021-2025 | -US$4,713.09, PF 0.81, DD 60.09% | yes |
| session_entry_quality | 2016-2025 | -US$6,086.20, PF 0.81, DD 69.23% | yes |

## Risk Expansion Review

| Attempt | Positive result | Negative result | Decision |
| --- | --- | --- | --- |
| Risk 1% / 5R / 8R | Q2 was promising | Q3 failed; 1y/5y/10y were not executed by gate | rejected_at_smoke |
| Risk 2% / 5R / 8R | Q2 showed nominal gain | Q3 equity DD reached 44.82% in v0_4/safety and 38.43% in session; safety gate interrupted continuation | rejected_catastrophic_drawdown |

## Editorial Review

- Positive 2025 results are visible.
- Negative multi-year results are visible.
- Robustness conclusion is explicit.
- The candidate avoids profit promises and operational approval language.
- The 22001 pass expanded the public results tables so the negative and positive observations have equivalent prominence.

## Decision

Results presentation passes for human review, with the warning that all numbers remain backtest evidence and must not be marketed as live performance.
