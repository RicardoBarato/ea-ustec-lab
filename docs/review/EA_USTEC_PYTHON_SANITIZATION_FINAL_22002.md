# EA USTEC Python Sanitization Final 22002

## Included Python

- `scripts/publication_guard.py`
- `tests/test_ea_ustec_public_candidate_guard.py`

## Sanitization Actions

- No private parser or raw-report tool was copied.
- Guard policy strings use generic runtime-assembled terms so external-project names are not present as public text.
- Test suite validates both clean pass and controlled rejection.
- Inputs are local candidate roots, not hardcoded machine-specific directories.
- No private datasets, broker reports, account files, or market data are included.

## Decision

Python included in this candidate is limited to publication validation and test support. No private trading/data pipeline code is included.
