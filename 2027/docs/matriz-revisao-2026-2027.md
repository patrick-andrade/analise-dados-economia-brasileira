# Matriz de revisão do acervo 2026 para 2027

Fonte de partida: pasta local de 2026 e repositório `patrick-andrade/analise-dados-economia-brasileira`. A edição histórica permanece preservada. As correções abaixo aplicam-se à edição nova.

| Material de 2026 | Destino em 2027 | Intervenção necessária |
|---|---|---|
| Plano oficial MD e DOCX | Plano oficial 2027 | Preservar ementa e obras institucionais; explicitar 17 semanas, 15 encontros, carga documental de 34h e avaliações 40/60. |
| Plano para alunos | Guia de aprendizagem | Comunicar competências, produtos, preparação e critérios de avaliação por encontro. |
| Configurações básicas | Guia de ambiente | RStudio e Positron equivalentes; Quarto desde o início; IA opcional sem dependência de licença paga. |
| Notebook 1 e exercícios | Encontros 1–3 | Dividir fundamentos; corrigir soma/cumsum da inflação para composição; retirar erro ativo `10 = x`, objeto gráfico ausente, instalação dentro da aula e caminhos pessoais. |
| Notebook 2 e exercícios | Encontros 3 e 5; extensão | Agregação coerente; janela de consulta de séries diárias até dez anos; conferir metas históricas. Taylor/OLS fica extensão descritiva, sem alegação de causalidade ou taxa neutra identificada. |
| Notebook 3 e exercícios | Encontro 4 e extensão | Comparação país–EUA, dados longos e junções; distinguir moedas, preços constantes e PPC. PPP/câmbio “justo” e mapas não integram núcleo obrigatório. |
| Notebook 4 | Encontros 5, 6, 8 e 12 | Separar objetivos. Corrigir fator 100 na dinâmica da dívida. Taxa real fixa é hipótese de simulação; não decomposição histórica estimada. |
| Dois QMD de relatório | Roteiros e modelos de Quarto | Corrigir referências a arquivos inexistentes e execução pela raiz. Identificar composição da demanda, não contribuição ao crescimento. |
| `bacen-dados-nfsp.R` | Encontro 5 | Preservar data/ano nas chaves; distinguir NFSP (necessidade de financiamento), saldo fiscal, estoque e fluxo acumulado. |
| `financas-publicas-brasil-tesouro-nacional.R` | Encontro 6 | Identificar rubricas e unidades por metadados; não afirmar deflação sem cálculo ou indicação explícita da fonte. |
| `ibge-sidra-dados.R` | Encontros 2 e 9 | Confirmar tabela/variável/população. Rendimento real do SIDRA já é deflacionado. |
| Scripts CAGED e RAIS | Encontro 10 | Preparação docente e recortes locais documentados; sem caminhos pessoais, SQL inválido, ID GCP fictício ou continuação após falha de aquisição. |
| Gini Banco Mundial | Encontros 4 e 11 | Verificar definição, escala 0–100 versus 0–1, população, cobertura e anos não coincidentes. Não interpolar faltantes silenciosamente. |
| Estudo Gini/PNADC do GitHub | Demonstração docente | Verificar estimador ponderado e desenho amostral; separar indicador oficial de reconstrução didática e explicitar suas diferenças. |
| Trabalho 1 DOCX | Projetos 1 e 2 | País escolhido versus EUA; núcleo + tema; Quarto e aprofundamento. Corrigir saldo de caixa chamado primário, moedas/unidades misturadas e interpretação de reservas. |
| Dados e figuras salvos de 2026 | Evidência histórica | Registrar origem herdada; não tratar figuras antigas ou arquivos com nomes divergentes como execução verificada do código novo. |

## Conferências prioritárias

1. Inflação: `(prod(1 + taxa / 100) - 1) * 100`; exigir janela completa para acumulado anual.
2. Dívida: com taxas em porcentagem, converter `r` e `g` para proporção antes da identidade; juros reais exatos usam `(1+i)/(1+pi)-1`.
3. PIB: parcelas em % do PIB descrevem composição; FBCF não inclui automaticamente variação de estoques.
4. FMI/WDI: cada código tem sua própria definição e abrangência de governo. Saldo global não é saldo primário.
5. Cobertura: faltantes permanecem visíveis; relatório informa quantidade de observações e intervalo por país/indicador.
6. Ambientes: aulas, soluções e HTML devem funcionar usando bases locais e sessão limpa.
