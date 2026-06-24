# Negative Results

Positive and negative observations are documented together. These are backtest or research observations, not live results.

| Experiment | Hypothesis | Positive observation | Negative result | Rejection reason | Learning |
| --- | --- | --- | --- | --- | --- |
| v0_4_safety 5y | 2025 behavior might generalize | 2025 was positive | 2021-2025: -US$4,801.03, PF 0.83, DD 59.15% | not robust | Recent edge did not survive longer validation. |
| v0_4_safety 10y | Long-horizon robustness | 2025 was positive | 2016-2025: -US$6,321.53, PF 0.82, DD 70.12% | not robust | Long horizon exposed regime dependency. |
| session_entry_quality 5y | Cleaner entry/session might generalize | 2025 improved to +US$1,652.00 | 2021-2025: -US$4,713.09, PF 0.81, DD 60.09% | not robust | Better recent fit did not solve structural fragility. |
| session_entry_quality 10y | Cleaner entry/session might survive 10y | 2025 was best observed result | 2016-2025: -US$6,086.20, PF 0.81, DD 69.23% | not robust | Same weakness persisted over broader history. |
| Regime stand-aside | Avoid bad higher-timeframe regimes | Intended to reduce Q3 damage | Q2 preservation failed and Q3 did not improve enough | rejected | Broad regime blocking can remove good trades without fixing bad ones. |
| Risk Governor V1/V2 | Active risk control would improve survival | Useful as governance concept | Did not establish robust improvement | rejected | Risk overlays need proof across regimes, not only local relief. |
| RR 2.2 / 2.5 / 3.2 | Target adjustment could thicken edge | Some windows improved locally | Robustness remained insufficient | rejected | Reward target tuning alone is not enough. |
| Cost/spread gate | Avoid high-cost entries | Useful diagnostic direction | Edge remained cost-sensitive and period-dependent | not promoted | Need clearer entry quality or regime edge before cost filters. |
| Hour 15 exclusion | Remove weak session hour | Reduced some exposure | Could remove good trades and did not solve long-horizon weakness | rejected | Time filters are fragile without regime explanation. |
| Risk 1% / 5R / 8R | Larger payoff could improve expectancy | Q2 was promising in session candidate | Q3 failed; 1y/5y/10y not executed by gate | rejected_at_smoke | Payoff expansion needs downside stability before long runs. |
| Risk 2% / 5R / 8R | Higher risk could amplify edge | Q2 showed nominal gain | Q3 equity DD reached 44.82% in v0_4/safety and 38.43% in session | rejected_catastrophic_drawdown | Higher risk exposed unacceptable drawdown. |
| Market Structure V0.2/V0.3 | Pattern discovery could identify large legs | V0.2 remained a research champion candidate | V0.3 was mixed and not promoted | research-only | Pattern research is promising but not execution-approved. |
| Structural labels | Better labels could improve research selection | Useful for offline study | Not approved for operational use | research-only | Labels need more data and validation before EA integration. |
| Trend/hybrid | Blend trend and structure signals | Generated useful hypotheses | No robust operational candidate approved | not promoted | Hybrid logic needs robust OOS validation. |
