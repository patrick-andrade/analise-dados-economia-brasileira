# Bases locais para prática sem rede

As aulas e os modelos leem somente `processed/`. A aquisição ocorre separadamente, pelo docente. Os CSV são recortes de fontes reais; os exemplos de renda e dinâmica da dívida são simulações identificadas no código. `inventario-bases.json` registra origens e SHA-256. O congelamento ocorreu em 03/10/2026; antes da oferta de 2027, uma nova aquisição deverá ser validada e registrada, sem substituir silenciosamente esta edição.

| Base | Período e unidade | Cobertura e cuidados |
|---|---|---|
| `ipca.csv` | Jan/2019–dez/2025; variação mensal em % | IBGE/SIDRA 1737, variável 63, Brasil. Compor fatores, nunca somar taxas. |
| `pib_volume.csv` | 2019–2025; trimestre; índice de volume, média 1995=100 | SIDRA 1620/583. PIB a preços de mercado e três setores. `201901` significa trimestre 1, não janeiro. Índices setoriais não somam o PIB. |
| `desocupacao.csv` | 2019–2025; trimestre móvel mensal; % | SIDRA 6381/4099, PNADC, Brasil, pessoas de 14 anos ou mais na força de trabalho. Mês identifica fim do trimestre móvel; não somar nem tratar observações como independentes. |
| `rendimento_real.csv` | 2019–2025; trimestre móvel mensal; R$ reais | SIDRA 6389/5932, rendimento habitual do trabalho principal de ocupados de 14 anos ou mais com rendimento. Série já deflacionada pelo IBGE; consultar atualização dos preços de referência no JSON/metadados SIDRA. Não deflacionar novamente. |
| `gini_oficial.csv` | 2012–2024; índice 0–1 | SIDRA 7435/10681; rendimento domiciliar per capita, Brasil. Conceito diferente de salário formal, riqueza e renda declarada ao fisco. |
| `fmi_paises.csv` | 2000–2026; unidades por indicador | 14 países, 8 indicadores, WEO abril/2026 via DataMapper. 2026 é projeção da edição; anos anteriores podem ser estimativas. A API não fornece flag individual suficiente para declarar tudo observado. Ausências preservadas. |
| `fmi_metadados.csv` | Metadados da mesma extração | `PCPIPCH`: inflação média anual; `GGXCNL_NGDP`: saldo global do governo geral, não primário; `GGXWDG_NGDP`: dívida bruta do governo geral, distinta da DBGG brasileira. |
| `bcb.csv` | 2019–2025; mensal ou diária | SGS 13762 DBGG e 4513 DLSP: estoques % PIB; 5793 NFSP primário, 5760 juros, 5727 NFSP nominal: fluxos acumulados em 12 meses, % PIB, déficit positivo; 432 meta Selic diária % a.a. SOAP oficial usado por indisponibilidade do host REST neste ambiente. |
| `rtn.csv` | Jan/2019–dez/2025; R$ milhões correntes | Tesouro, planilha RTN de julho/2026, aba resumida mensal 1.1. Governo Central, metodologia acima da linha. Receita líquida, despesa, primário e benefícios previdenciários. Previdência já integra despesa: não somar novamente. |
| `wdi_complemento.csv` | 2000–2025; Gini 0–100 e desemprego % | Banco Mundial WDI, dados por país/ano. Gini tem cobertura esparsa; desemprego é estimativa modelada OIT. Não equivale automaticamente à PNADC brasileira ou à série do FMI. |
| `caged_sp_202412.csv` | Dez/2024; admissões, desligamentos e saldo em vínculos | Município de São Paulo, UF 35; agregação por sexo codificado e seção CNAE, extraída de objeto real preservado no `.RData` de 2026. Vintage/revisões não revalidados no MTE. Não é estoque; não representa toda ocupação. Sem identificadores individuais. |
| `rais_setores.csv` | 2023–2024; vínculos ativos em 31/12 | Brasil, vínculos formais públicos e privados. Tabela 2, p. 8 do Sumário Executivo RAIS 2024, transcrita do PDF oficial. Soma dos cinco setores difere do total publicado: manter resíduo, sem imputação. Não é recorte municipal nem microdado. |

## Reaquisição docente

Na raiz, executar conscientemente `python scripts/adquirir-dados.py --somente fmi` (ou `sidra`, `rtn`, `wdi`). Para SGS: PowerShell `./scripts/adquirir-bcb.ps1`, seguido de `python scripts/preparar-bases-complementares.py`. REST SGS permanece disponível como tentativa em `adquirir-dados.py`; a alternativa SOAP separa periodicidades. Instalar dependências antes; a prática não instala pacotes.

O recorte CAGED pode ser regenerado localmente pelo docente: `Rscript scripts/extrair-caged-legado.R ../202601-ECO-BRAS-DADOS/.RData`, em ambiente UTF-8. O arquivo original de 2026 não é distribuído. A procedência herdada e o hash desse arquivo são registrados separadamente. A tabela RAIS é uma transcrição revisável; confrontar com o PDF antes de mudar números.

URLs, códigos e nomes estão nos JSON de procedência e em `inventario-bases.json`. As datas e o significado econômico dos períodos são essenciais: um período numérico não informa sozinho se a frequência é mensal, trimestral fixa ou móvel. Conservar os arquivos brutos da aquisição para auditoria.

O rendimento real mensal usa preços do último trimestre móvel divulgado, segundo a [nota técnica de deflacionamento do IBGE](https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Mensal/Notas_tecnicas/nota_tecnica_02_pnadc_mensal.pdf). O recorte da API arquivado não informa explicitamente qual é esse último trimestre: não inferir que os preços de referência sejam dezembro/2025 só porque o CSV termina nesse mês. Essa referência deve ser identificada antes de comparar níveis de renda com outra extração ou fonte.
