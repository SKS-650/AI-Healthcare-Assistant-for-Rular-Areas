import ast

files = [
    'app/health_education/models.py',
    'app/health_education/schemas.py',
    'app/health_education/services.py',
    'app/health_education/routes.py',
    'app/main.py',
]

for f in files:
    try:
        src = open(f, encoding='utf-8').read()
        ast.parse(src)
        print(f'OK: {f}')
    except SyntaxError as e:
        print(f'SYNTAX ERROR in {f}: {e}')
    except Exception as e:
        print(f'ERROR in {f}: {e}')

print('Done.')
