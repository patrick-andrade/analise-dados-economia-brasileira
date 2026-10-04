# Projeto 1 Diagnóstico comparado de um país e dos EUA

Peso: **40% da nota final**. Entrega e defesa: encontro 7, data a confirmar. Duplas, com um trio previsto para a turma de 25 alunos.

## Pergunta e recorte

Escolha um país diferente dos EUA. Compare suas trajetórias econômicas, sem pressupor que um país deva seguir o caminho do outro. Registre país, integrantes, tema e justificativa com o professor até o encontro 4. Países não se repetem entre grupos. O arquivo `data/processed/fmi_paises.csv` oferece 13 países além dos EUA, incluindo o Brasil; outros exigem cobertura aprovada e aquisição documentada.

Use 2000–2025 como janela de referência, respeitando a disponibilidade dos indicadores. A base contém também 2026 para ensinar projeções: qualquer uso desse ano precisa ser identificado como projeção. Histórico anterior a 2026 pode conter estimativas e revisões; não chame todos os valores de observações definitivas. Preserve a edição do WEO registrada nos metadados.

## Núcleo obrigatório e tema

Todos devem analisar crescimento real anual (`NGDP_RPCH`) e inflação média anual do IPC (`PCPIPCH`) pela API do FMI. Esta inflação não é, necessariamente, dezembro contra dezembro.

Escolha um tema com **dois indicadores adicionais**:

| Tema | Opções de indicadores e cuidado |
|---|---|
| Fiscal | Dívida bruta do governo geral `% PIB` (`GGXWDG_NGDP`) e saldo global (`GGXCNL_NGDP`). Saldo global não é primário. |
| Macro | Desemprego (`LUR`) e PIB per capita corrente em US$ (`NGDPDPC`). Este último não mede crescimento real nem PPC. |
| Externo | Conta corrente `% PIB` (`BCA_NGDPD`) e indicador oficial complementar de comércio ou reservas, com unidade compatível. |
| Desigualdade | Gini WDI (`SI.POV.GINI`) e indicador oficial de renda/pobreza aprovado. Gini do WDI está em 0–100 e pode não existir em todos os anos. |

Não substitua ausência de indicador por zero. Se a cobertura do tema for insuficiente, ajuste tema ou janela com o professor antes de interpretar. Bases adicionais precisam de metadados e arquivo local. Os scripts de aquisição, as respostas brutas e seus hashes documentam o uso da API; não é necessário uma conexão ao vivo na defesa.

## Produtos mínimos

- Script R executável e comentado; arquivo `.qmd` e seu HTML.
- Três figuras: crescimento, inflação e tema escolhido (pode ter dois painéis).
- Uma tabela de síntese por país, indicador e blocos 2000–2004, 2005–2009, 2010–2014, 2015–2019, 2020–2024 e 2025. O último bloco é parcial, não um quinquênio completo.
- A tabela informa média, número de valores válidos e anos cobertos. Não use `na.rm=TRUE` sem mostrar a cobertura; não alinhe anos diferentes como se fossem a mesma observação.
- Texto de aproximadamente 800–1200 palavras: pergunta/justificativa, dados, método, evidências e limitações. Cite números e anos concretos, evitando inferência causal baseada apenas em gráficos.
- Documentação de fontes e declaração de uso de IA.

## Organização da entrega

Entregue uma pasta com `analise.R`, `relatorio.qmd`, `relatorio.html`, bases locais e `README.md` com instruções. Caminhos relativos. Teste em sessão limpa. O [modelo guiado](../modelos/02-projeto-1.qmd) demonstra o fluxo com Colômbia/EUA; não é um trabalho autoral pronto para entregar.

## Defesa

Cinco minutos por grupo: síntese da pergunta e principal resultado, seguida de perguntas individuais sobre fonte, transformação e interpretação. Cada integrante deve conseguir explicar seu próprio trabalho.

## Avaliação

Projeto 1: **40%**. Projeto 2: **60%**. Formação de 11 duplas e um trio para uma turma aproximada de 25 alunos. As práticas e checkpoints são formativos, sem nota própria.

| Dimensão | Peso |
|---|---:|
| Fontes, conceitos, cobertura e unidades | 20% |
| Tratamento e cálculos | 20% |
| Reprodutibilidade do código | 10% |
| Visualizações e organização do relatório | 15% |
| Interpretação econômica e limitações | 15% |
| Compreensão na defesa individual | 20% |

Em cada projeto, o produto vale até 80 pontos compartilhados pelo grupo e a defesa até 20 pontos individuais. A nota de cada estudante, em escala 0–10, é `0,4 × nota individual do Projeto 1 + 0,6 × nota individual do Projeto 2`. Cada nota de projeto é `(pontos do produto + pontos da defesa individual) / 10`.

As defesas ocupam 60 minutos: 12 grupos × cinco minutos. Cada integrante responde, inclusive no trio. Os outros 30 minutos são destinados a organização e síntese. Não há 60 minutos de exposição de conteúdo novo nos encontros avaliativos.


## Uso de inteligência artificial

IA pode auxiliar explicação de código, depuração e revisão de texto. O grupo continua responsável por cada cálculo, fonte e afirmação. Registrar ferramenta, finalidade e trechos relevantes incorporados; explicar como o código e a informação foram conferidos. Não há obrigação de usar IA nem de adquirir assinatura. Na defesa, cada integrante deverá explicar uma transformação e interpretar um resultado, inclusive quando o código foi sugerido por IA.


## Ponte para o Projeto 2

Identifique desde agora uma questão fiscal, de trabalho ou desigualdade que possa ser aprofundada no mesmo par de países. Não é necessário cobrir cinco módulos completos nesta primeira entrega.
