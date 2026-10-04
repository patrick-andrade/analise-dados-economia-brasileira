"""Converte XML oficial SGS e registra recorte RAIS transcrito. Sem rede."""
from pathlib import Path
import csv, json, hashlib, datetime, xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
def write(name, rows):
    with (ROOT/'data/processed'/name).open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0])); w.writeheader(); w.writerows(rows)
meta={432:('Meta Selic','% a.a.','diária'),13762:('DBGG','% PIB','mensal'),4513:('DLSP','% PIB','mensal'),5793:('NFSP primário acumulado 12 meses','% PIB','mensal'),5760:('Juros nominais acumulados 12 meses','% PIB','mensal'),5727:('NFSP nominal acumulado 12 meses','% PIB','mensal')}
rows=[]
for filename in ['bcb-diaria.xml','bcb-mensais.xml']:
    # SOAP anuncia ISO-8859-1, mas o arquivo foi salvo em UTF-8 após decodificação.
    root=ET.fromstring((ROOT/'data/raw'/filename).read_text(encoding='utf-8'))
    for serie in root.findall('SERIE'):
        code=int(serie.attrib['ID']); label,unit,freq=meta[code]
        for item in serie.findall('ITEM'):
            date=item.findtext('DATA'); val=item.findtext('VALOR')
            if not val or item.findtext('BLOQUEADO')=='true': value=''
            else: value=float(val.replace(',','.'))
            parts=date.split('/'); d,m,y=(int(x) for x in parts) if len(parts)==3 else (1,int(parts[0]),int(parts[1]))
            rows.append(dict(data=f'{y:04}-{m:02}-{d:02}',codigo=code,indicador=label,valor=value,unidade=unit,periodicidade=freq))
write('bcb.csv',rows)
raisurl='https://www.gov.br/trabalho-e-emprego/pt-br/acesso-a-informacao/acoes-e-programas/programas-projetos-acoes-obras-e-atividades/estatisticas-trabalho/rais/rais-2024/rais-2024-1/sumario-executivo_rais-2024-1.pdf'
values=[('Agropecuária',1769926,1782941),('Indústria',8567521,8863837),('Construção',2804565,2884807),('Comércio',10090434,10314045),('Serviços',32084085,33283281),('Total publicado',55316614,57132156)]
write('rais_setores.csv',[dict(ano=year,setor=sector,vinculos=count,unidade='vínculos ativos em 31/12',cobertura='Brasil; vínculos formais públicos e privados',pagina=8) for sector,a,b in values for year,count in [(2023,a),(2024,b)]])
(ROOT/'data/rais-procedencia.json').write_text(json.dumps(dict(fonte=raisurl,tabela=2,pagina=8,metodo='Tabela publicada transcrita e conferida com o PDF oficial',data_transcricao='2026-10-03',nota='Soma dos cinco setores difere do total publicado em 83 (2023) e 3245 (2024). Resíduo preservado, sem imputação de classificação.'),ensure_ascii=False,indent=2),encoding='utf-8')
manifest_path=ROOT/'data/inventario-bases.json'
manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
# O inventário de aquisição original é uma lista. Complementos mantêm a estrutura.
records=manifest if isinstance(manifest,list) else manifest.get('arquivos',[])
for name,url in [('bcb.csv','https://www3.bcb.gov.br/wssgs/services/FachadaWSSGS'),('rais_setores.csv',raisurl),('caged_sp_202412.csv','ftp://ftp.mtps.gov.br/pdet/microdados/NOVO%20CAGED/2024/202412/CAGEDMOV202412.7z')]:
    p=ROOT/'data/processed'/name
    if p.exists():
        rel=p.relative_to(ROOT).as_posix()
        records=[r for r in records if r.get('arquivo')!=rel and r.get('path')!=rel]
        records.append(dict(arquivo=rel,fonte=url,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size,extraido_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),metodo='ver data/*-procedencia.json'))
manifest_path.write_text(json.dumps(records,ensure_ascii=False,indent=2),encoding='utf-8')
print('SGS e RAIS prontos; inventário complementado.')
