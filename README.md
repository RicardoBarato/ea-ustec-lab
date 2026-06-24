# EA USTEC Lab

Public research candidate for an educational USTEC/Nasdaq systematic trading archive.

The project found positive performance in specific periods, especially 2025, but no candidate demonstrated enough multi-year robustness for operational approval.

All metrics below are historical Strategy Tester backtests on USTEC/Nasdaq CFD research material, primarily on M5 execution context. They are not live, demo, paper, signal, or real-account results. Initial deposit is not included in this sanitized public summary, so net profit and drawdown should not be compared across brokers or account sizes without recreating the exact test setup.

## Status

- Research archive candidate.
- No live, demo, paper, signal, or real account approval.
- No financial advice.
- No promise of profit.
- No operational authorization for live or automated execution.
- Results can vary by broker, spread, commission, slippage, session, contract specification, and historical data source.

## Key conclusion

The current EA family is valuable as research evidence, but it did not pass robustness gates across longer horizons. The next research direction should be regime-first and should use explicit no-trade logic before entry timing.

## Results summary

| Version | Best observed result | 5 years | 10 years | Robustness conclusion |
| --- | --- | --- | --- | --- |
| v0_4_safety | 2025: +US$1,120.04; PF 1.13; DD 10.23%; 235 trades | -US$4,801.03; PF 0.83; DD 59.15% | -US$6,321.53; PF 0.82; DD 70.12% | Worked in 2025, did not generalize. |
| session_entry_quality | 2025: +US$1,652.00; PF 1.22; DD 8.00%; 203 trades | -US$4,713.09; PF 0.81; DD 60.09% | -US$6,086.20; PF 0.81; DD 69.23% | Best recent candidate, not robust. |
| Risk 1% / 5R / 8R | Q2 was promising in the session candidate, but Q3 failed | 1y/5y/10y not executed by gate | 1y/5y/10y not executed by gate | rejected_at_smoke. |
| Risk 2% / 5R / 8R | Nominal Q2 gain; Q3 equity DD 44.82% in v0_4/safety and 38.43% in session | Interrupted by safety gate | Interrupted by safety gate | rejected_catastrophic_drawdown. |

See `docs/RESULTS.md` and `docs/NEGATIVE_RESULTS.md`.
