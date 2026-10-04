# Verificação da edição 2027

## Estado

Edição verificada em 03/10/2026. As 23 sessões R passaram, assim como a conferência de 28 hashes, os links locais dos documentos e a inspeção de 39 HTML com 20 figuras. A inspeção em Edge sem rede não encontrou figuras ausentes, links locais quebrados nem mensagens de falha de execução. Foram examinadas também capturas dos planos, das aulas de inflação, contas públicas, RAIS/CAGED e desigualdade e dos dois modelos de projeto.

## Ambiente verificado

Windows, R 4.6.0 e Quarto 1.9.38. Tidyverse 2.0.0, dplyr 1.2.0, tidyr 1.3.2, ggplot2 4.0.2, sidrar 0.5.0, rbcb 0.1.14, PNADcIBGE 0.7.5, survey 4.5-1, convey 1.0.1. Versões são registro do teste, não imposição para a oferta de 2027. Algumas bibliotecas locais foram compiladas para R 4.6.1; as sessões avaliadas passaram.

## Conferências realizadas

- Inflação composta: duas taxas de 10% geram 21%; ausência ou ano incompleto não produz acumulado válido.
- Dívida: cenário 80% PIB, juros reais 4%, crescimento 2% e superávit 2% PIB confere com `80 × 1,04 / 1,02 − 2`.
- Gini: distribuição ponderada 0/100/200 com pesos 1/2/1 gera 0,375; igualdade perfeita gera zero; invariância de escala e replicação conferidas.
- Cobertura: IPCA e duas séries de trabalho com 84 meses contínuos; chaves únicas em séries, rubricas e junções país–ano.
- Fiscal: nominal = primário + juros na convenção SGS, com tolerância de 0,02 ponto percentual para arredondamento; receita menos despesa igual ao primário do RTN.
- CAGED: 414.914 registros reais agregados em 42 grupos, saldo preservado. RAIS: totais publicados e resíduos setoriais preservados.
- 11 scripts de prática, 11 soluções e script geral executados em 23 processos R separados, sem restauração de workspace e sem aquisição de dados.

Logs e capturas ficam em `internal/validacao/`, separados do pacote público. Rotinas: `scripts/verificar-sessoes.ps1`, `scripts/verificar-pacote.py` e `scripts/inspecionar-html.cjs`.

A demonstração docente de Gini também foi renderizada separadamente. A inspeção detectou e corrigiu recursos R ausentes na saída HTML e corte da legenda da fonte no gráfico fiscal. Na máquina de preparação, o cache Quarto usou `internal/quarto-cache` como `LOCALAPPDATA` apenas no processo de compilação; não houve alteração persistente de configuração do sistema.

## Limites e providências antes da oferta

Datas de 2027 e equivalência entre 34h institucionais e tempo operacional dos encontros permanecem a confirmar. Conferir regras fiscais vigentes e eventual reimpressão de 2021 do livro brasileiro de R4DS no exemplar utilizado.

O congelamento dos dados é de outubro/2026. Reaquisição para 2027 é explícita e precisa de nova conferência; não está embutida na renderização. CAGED tem procedência herdada, com revisão não revalidada. RAIS é tabela oficial transcrita. O estudo nacional por microdados PNADC não foi reproduzido nesta edição; a demonstração auditada usa distribuição controlada e série oficial SIDRA, com os limites registrados em documento próprio.
