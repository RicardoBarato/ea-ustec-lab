import base64
import pathlib
import sys

ROOT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else '.').resolve()
FORBIDDEN_EXT = {'.ex5','.set','.tst','.log','.html','.htm','.csv','.xlsx','.zip','.env'}
FORBIDDEN_TERMS_B64 = [
    'T05QTjEx',
    'UGF5b2ZmR3JpZA==',
    'cGF5b2ZmLWdyaWQ=',
    'ZmluYW5jaWFsLXBhbmVs',
    'cmItcmlzay1lbmdpbmU=',
    'VGhlIFJpc2sgRGlhcnk=',
    'UkIgVmVjdG9y',
    'UkIgT3Vybw==',
    'U2NhbHBlcg==',
    'WEFV',
    'Qzpc',
    'RTpc',
    'YWNjb3VudD0=',
    'YWNjb3VudF9udW1iZXI=',
    'YWNjb3VudF9pZA==',
    'bG9naW49',
    'c2VydmVyPQ==',
    'cmF3X3JlcG9ydHM=',
    'cmF3LXJlcG9ydHM=',
    'cmVwb3J0cy9yYXc=',
    'ZGF0YS9yYXc=',
    'Y3JlZGVudGlhbHMv',
    'c2VjcmV0cy8=',
]
FORBIDDEN_TERMS = [base64.b64decode(item).decode('utf-8') for item in FORBIDDEN_TERMS_B64]
errors=[]
for path in ROOT.rglob('*'):
    rel_parts = set(path.relative_to(ROOT).parts) if path != ROOT else set()
    if '.git' in path.parts or '__pycache__' in rel_parts or path.is_dir():
        continue
    if path.suffix.lower() in FORBIDDEN_EXT:
        errors.append(f'forbidden extension: {path.relative_to(ROOT)}')
    try:
        text = path.read_text(encoding='utf-8')
    except UnicodeDecodeError:
        errors.append(f'binary or non-utf8: {path.relative_to(ROOT)}')
        continue
    for term in FORBIDDEN_TERMS:
        if term.lower() in text.lower():
            errors.append(f'forbidden term {term}: {path.relative_to(ROOT)}')
if errors:
    print('\n'.join(errors))
    sys.exit(1)
print('publication_guard_passed')
