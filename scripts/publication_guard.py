import pathlib
import sys

ROOT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else '.').resolve()
FORBIDDEN_EXT = {'.ex5','.set','.tst','.log','.html','.htm','.csv','.xlsx','.zip','.env'}
FORBIDDEN_TERM_PARTS = [
    ('PRIVATE', '_PROJECT', '_CODE', '_NAME', '_1'),
    ('PRIVATE', '_PROJECT', '_CODE', '_NAME', '_2'),
    ('PRIVATE', '_REPOSITORY', '_NAME', '_1'),
    ('PRIVATE', '_PRODUCT', '_DOMAIN', '_1'),
    ('private', ' project'),
    ('private', ' repository'),
    ('private', ' workspace'),
    ('internal', ' product'),
    ('unreleased', ' product'),
    ('private', ' domain'),
    ('private', ' root'),
    ('local', ' path'),
    ('C', ':\\'),
    ('E', ':\\'),
    ('account', '='),
    ('account', '_number'),
    ('account', '_id'),
    ('login', '='),
    ('server', '='),
    ('raw', '_reports'),
    ('raw', '-reports'),
    ('reports', '/raw'),
    ('data', '/raw'),
    ('credentials', '/'),
    ('sensitive', '_tokens'),
]
FORBIDDEN_TERMS = [''.join(parts) for parts in FORBIDDEN_TERM_PARTS]
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
