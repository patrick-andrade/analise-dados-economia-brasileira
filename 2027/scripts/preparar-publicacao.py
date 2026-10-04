"""Seleciona materiais públicos. Não envia arquivos nem modifica o GitHub."""
from pathlib import Path
import json,base64,zipfile,hashlib
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'internal/publicacao';OUT.mkdir(parents=True,exist_ok=True)
SKIP={'internal','docentes','outputs','.quarto','.git','.Rproj.user','_site','__pycache__'}
EXCLUDED={'scripts/gerar-aulas.py','scripts/gerar-documentos.py'} # contêm material de preparação docente
selected=[]
for p in sorted(ROOT.rglob('*')):
    if not p.is_file():continue
    rel=p.relative_to(ROOT)
    if any(x in SKIP for x in rel.parts) or rel.as_posix() in EXCLUDED:continue
    if p.suffix in ['.html','.png','.tmp'] or p.name.endswith('.knit.md') or p.name in ['.RData','.Rhistory']:continue
    selected.append(p)
assert not any('docentes' in p.parts for p in selected)
entries=[];binary=[]
for p in selected:
    rel=p.relative_to(ROOT).as_posix()
    # read_text normaliza CRLF: isso invalidaria hashes dos snapshots CSV/JSON.
    try:content=p.read_bytes().decode('utf-8')
    except UnicodeDecodeError:
        blobpath=OUT/(p.name+'.b64');blobpath.write_text(base64.b64encode(p.read_bytes()).decode('ascii'),encoding='ascii')
        binary.append(dict(path='2027/'+rel,arquivo_base64=blobpath.relative_to(ROOT).as_posix(),chars=blobpath.stat().st_size));continue
    entries.append(dict(path='2027/'+rel,mode='100644',type='blob',content=content))
readme='''# analise-dados-economia-brasileira

Repositórios de scripts de exemplo para uso na disciplina "Economia brasileira: análise de dados" na PUCSP

Prof. Dr. Patrick Rodrigues Andrade

## Edições

- **[2027 — programa, projetos, práticas em R e relatórios Quarto](2027/README.md)**: 17 semanas, 15 encontros efetivos e avaliações 40/60. [Baixar o pacote discente com HTML para uso sem rede](2027/materiais-2027.zip); extrair a pasta e abrir `2027/_site/index.html`.
- **[Acervo de 2026](https://github.com/patrick-andrade/analise-dados-economia-brasileira/tree/001084755da0f5feba2f6636de61737b6019ceb3)**: os arquivos históricos permanecem nas posições anteriores. O link aponta para a versão publicada antes da edição nova.

As aplicações de 2027 enfatizam finanças públicas, trabalho e desigualdade. As aulas usam dados locais documentados; os projetos comparam um país escolhido aos EUA. Soluções docentes e registros de avaliação não integram o pacote público.
'''
entries.append(dict(path='README.md',mode='100644',type='blob',content=readme))
(OUT/'tree-entries.json').write_text(json.dumps(entries,ensure_ascii=True),encoding='ascii')
archive=OUT/'materiais-2027.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
    for p in selected:z.write(p,'2027/'+p.relative_to(ROOT).as_posix())
    for p in sorted((ROOT/'_site').rglob('*')):
        if p.is_file() and 'docentes' not in p.relative_to(ROOT/'_site').parts:
            z.write(p,'2027/'+p.relative_to(ROOT).as_posix())
    z.writestr('COMECAR.txt','Extrair todas as pastas. Abrir 2027/_site/index.html para os roteiros ou 2027/README.md para configuração. Fontes e dados locais também estão incluídos. Soluções docentes não fazem parte deste pacote.\n')
with zipfile.ZipFile(archive) as z:
    assert not any('/docentes/' in x or x.endswith('gerar-aulas.py') for x in z.namelist())
    assert len([x for x in z.namelist() if x.endswith('.html')])>=39
blobpath=OUT/'materiais-2027.zip.b64';blobpath.write_text(base64.b64encode(archive.read_bytes()).decode('ascii'),encoding='ascii')
binary.append(dict(path='2027/materiais-2027.zip',arquivo_base64=blobpath.relative_to(ROOT).as_posix(),chars=blobpath.stat().st_size))
report=dict(arquivos_fonte=len(selected),entries_chars=(OUT/'tree-entries.json').stat().st_size,
 arquivos_binarios=binary,zip_bytes=archive.stat().st_size,zip_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),
 excluidos=['docentes/','internal/','outputs/','geradores docentes'],commit_base='001084755da0f5feba2f6636de61737b6019ceb3',tree_base='40742ae1523751f1759f66ad86480d045a885c34')
(OUT/'manifesto.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
