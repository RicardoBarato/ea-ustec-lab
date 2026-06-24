# Results

These figures are historical Strategy Tester backtests, not live, demo, paper, signal, or real-account performance. The public summary covers USTEC/Nasdaq CFD research with M5 execution context unless a row states otherwise. Initial deposit is not included in the sanitized public summary; treat net profit and drawdown as research evidence only, not as transferable account expectations. Results can change with broker, spread, commission, slippage, session, contract specification, and historical data source.

| Candidate | Window | Net | PF | DD | Trades | Read |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| v0_4_safety | 2025 | +US$1,120.04 | 1.13 | 10.23% | 235 | positive but thin |
| v0_4_safety | 2021-2025 | -US$4,801.03 | 0.83 | 59.15% | n/a | failed long-horizon robustness |
| v0_4_safety | 2016-2025 | -US$6,321.53 | 0.82 | 70.12% | n/a | failed long-horizon robustness |
| session_entry_quality | 2025 | +US$1,652.00 | 1.22 | 8.00% | 203 | best recent window |
| session_entry_quality | 2021-2025 | -US$4,713.09 | 0.81 | 60.09% | n/a | failed long-horizon robustness |
| session_entry_quality | 2016-2025 | -US$6,086.20 | 0.81 | 69.23% | n/a | failed long-horizon robustness |

## Risk Expansion Attempts

| Candidate | Positive observation | Negative observation | Decision |
| --- | --- | --- | --- |
| Risk 1% / 5R / 8R | Q2 was promising in the session candidate | Q3 failed; 1y/5y/10y were not executed by gate | rejected_at_smoke |
| Risk 2% / 5R / 8R | Q2 showed nominal gain | Q3 equity DD reached 44.82% in v0_4/safety and 38.43% in session; safety gate interrupted continuation | rejected_catastrophic_drawdown |

These are backtest metrics, not live results. No method here has operational approval.
