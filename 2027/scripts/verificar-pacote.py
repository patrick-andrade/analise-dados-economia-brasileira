"""Confere links locais, hashes e coerência documental. Sem rede."""
from pathlib import Path
import csv,json,re,hashlib,sys
ROOT=Path(__file__).resolve().parents[1]
failures=[]
def check(ok,what):
    if not ok: failures.append(what)
manifest=json.loads((ROOT/'data/inventario-bases.json').read_text(encoding='utf-8'))
for item in manifest:
    p=ROOT/item['arquivo']
    check(p.exists(),f"Arquivo inventariado ausente: {p.name}")
    if p.exists(): check(hashlib.sha256(p.read_bytes()).hexdigest()==item['sha256'],f"Hash diferente: {p.name}")
for folder in ['', 'aulas','modelos','projetos','exercicios','docs']:
    for p in (ROOT/folder).glob('*'):
        if p.suffix not in ['.md','.qmd']: continue
        content=p.read_text(encoding='utf-8')
        for target in re.findall(r'\]\(([^)]+)\)',content):
            target=target.split('#')[0].split('?')[0].strip('<>')
            if not target or '://' in target or target.startswith('mailto:'): continue
            check((p.parent/target).exists(),f"Link quebrado em {p.relative_to(ROOT)}: {target}")
calendar=json.loads((ROOT/'docs/curso.json').read_text(encoding='utf-8'))
for name in ['00-1-plano-ensino-oficial.md','00-2-plano-ensino-alunos.md']:
    s=(ROOT/name).read_text(encoding='utf-8')
    for token in ['40%','60%','34h','17','15','a confirmar']:check(token in s,f"{name}: falta {token}")
check(len(list((ROOT/'aulas').glob('*-roteiro.qmd')))==15,'Quantidade de roteiros deve ser 15')
check(len(list((ROOT/'aulas').glob('*-pratica.R')))==11,'Quantidade de práticas deve ser 11')
if (ROOT/'docentes').exists():
    check(len(list((ROOT/'docentes').glob('*-solucao.R')))==11,'Quantidade local de soluções deve ser 11')
for filename in ['ipca','desocupacao','rendimento_real']:
    rows=list(csv.DictReader((ROOT/f'data/processed/{filename}.csv').open(encoding='utf-8')))
    check(len(rows)==84,f"{filename}: são necessários 84 meses")
report=dict(hashes_conferidos=len(manifest),roteiros=15,praticas=11,
 solucoes_locais=len(list((ROOT/'docentes').glob('*-solucao.R'))),erros=failures)
(ROOT/'internal/validacao').mkdir(parents=True,exist_ok=True)
(ROOT/'internal/validacao/pacote.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
sys.exit(1 if failures else 0)
