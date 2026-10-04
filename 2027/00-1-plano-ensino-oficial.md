# Economia brasileira e análise de dados

Plano de ensino — primeiro semestre de 2027

## Identificação

Ciências Econômicas, 7º período. Professor: Patrick Rodrigues Andrade. Faculdade de Economia, Administração, Contabilidade e Atuária; Departamento de Economia. Dois créditos. Carga institucional de referência: 34h, conforme plano de 2026; equivalência de horas-aula e calendário de 2027 a confirmar. Atividades extensionistas: não previstas, conforme referência de 2026.

## Ementa institucional preservada

Pressupostos do Plano Real. Política monetária e cambial. Estabilização e vulnerabilidade externa. Impactos do Plano Real sobre as contas públicas. O avanço das reformas e do processo de privatização. Crises externas e impactos sobre a economia brasileira. O Governo Lula e a continuidade da política econômica. Desafios da política econômica no século XXI. Perspectivas econômicas e sociais no governo Dilma.

A proposta de reformulação para apreciação institucional está em [documento separado](docs/proposta-ementa-2027.md); não substitui esta ementa.

## Objetivos gerais

Desenvolver a capacidade de analisar questões da economia brasileira com dados oficiais, situando-as no contexto histórico desde o Plano Real e nas mudanças posteriores a 2018. Capacitar o estudante a construir, interpretar e comunicar análises reprodutíveis em R, com atenção especial a finanças públicas, mercado de trabalho e desigualdade.

## Objetivos específicos

- Organizar projetos e trabalhar em RStudio ou Positron com objetos, scripts e relatórios Quarto.
- Importar dados locais e compreender aquisição por APIs do IBGE, BCB e FMI; identificar código, unidade, cobertura e edição dos indicadores.
- Transformar tabelas com tidyverse, tratar datas e valores ausentes, verificar chaves e integrar fontes compatíveis.
- Calcular inflação acumulada, distinguir nominal e real, estoque e fluxo, e interpretar indicadores fiscais e distributivos sem confundir conceitos.
- Produzir gráficos, tabelas e relatórios Quarto que sustentem uma pergunta econômica e explicitem limites das evidências.
- Comparar um país aos EUA e relacionar as competências dessa análise às aplicações brasileiras discutidas em aula.
- Validar código assistido por IA e demonstrar compreensão individual dos resultados.

## Metodologia

Laboratório de informática com aprendizagem pela prática. Nos encontros de conteúdo, 60 minutos de explicação e demonstração e 30 minutos de atividade supervisionada. Cada encontro explicita uma pergunta econômica, competências de R e um produto pequeno. Há leituras curtas preparatórias, exercícios formativos, orientação de projetos e devolutivas. RStudio e Positron são opções equivalentes. Bases locais documentadas permitem prática sem rede; a aquisição por API é ensinada em fluxo separado.

## Conteúdo programático e calendário

Dezessete semanas: onze encontros de conteúdo, duas avaliações, uma revisão, uma vista e duas reservas. A posição das reservas poderá mudar conforme feriados e calendário institucional, sem acrescentar conteúdo obrigatório. Datas a confirmar.

| Semana/encontro | Natureza | Conteúdo | Aprendizagem ou produto |
|---|---|---|---|
| 1 | conteúdo | Ambiente R e primeiro problema econômico | Objetos, projetos, primeiro gráfico e Quarto mínimo |
| 2 | conteúdo | Atividade econômica e IBGE/SIDRA | Importar, filtrar, transformar, agrupar e visualizar |
| 3 | conteúdo | Inflação, poder de compra e renda real | Datas, composição da inflação, índice e deflação |
| 4 | conteúdo | Comparação internacional e API do FMI | Formato longo, metadados, junções e início do Projeto 1 |
| 5 | conteúdo | Contas públicas brasileiras | Resultado primário, juros, nominal e dívida; unidades e sinais |
| 6 | conteúdo | Receitas, despesas e previdência | RTN, rubricas, composição e orientação do Projeto 1 |
| 7 | avaliação | Projeto 1 país–EUA | Entrega e defesa individual, peso 40% |
| 8 | conteúdo | Regras fiscais e dinâmica da dívida | Estoques, fluxos, unidades e simulações; extensão SICONFI |
| 9 | conteúdo | Mercado de trabalho brasileiro | PNADC/SIDRA, população coberta, taxas e rendimento real |
| 10 | conteúdo | RAIS e Novo CAGED | Registros administrativos, estoque, fluxos, categorias e agregação |
| 11 | conteúdo | Distribuição de renda e desigualdade | Gini, Lorenz, pesos e comparação entre conceitos |
| 12 | conteúdo | Laboratório integrador do Projeto 2 | Novas fontes, junções, cobertura e validação de código com IA |
| 13 | revisão | Revisão de competências | Dúvidas, diagnóstico de erros e preparação da entrega final |
| 14 | avaliação | Projeto 2 de aprofundamento | Entrega e defesa individual, peso 60% |
| 15 | vista | Vista e devolutiva | Discussão de resultados, critérios e correções |
| 16 | reserva | Reserva de calendário | Sem conteúdo obrigatório novo; data a confirmar |
| 17 | reserva | Reserva de calendário | Sem conteúdo obrigatório novo; data a confirmar |

Os episódios do Plano Real, crises cambiais e externas, governos Lula/Dilma, recessão de 2015–2016 e mudanças fiscais são contextualizados nas aplicações. Os dados recentes ampliam a análise sem substituir a discussão histórica.

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


Projeto 1: crescimento e inflação + um tema escolhido, país–EUA, com API do FMI obrigatória. Projeto 2: aprofundamento do mesmo par em finanças públicas, trabalho ou desigualdade, com fonte oficial adicional e análise nova. Enunciados em [Projeto 1](projetos/01-enunciado.md) e [Projeto 2](projetos/02-enunciado.md).

## Uso de inteligência artificial

IA pode auxiliar explicação de código, depuração e revisão de texto. O grupo continua responsável por cada cálculo, fonte e afirmação. Registrar ferramenta, finalidade e trechos relevantes incorporados; explicar como o código e a informação foram conferidos. Não há obrigação de usar IA nem de adquirir assinatura. Na defesa, cada integrante deverá explicar uma transformação e interpretar um resultado, inclusive quando o código foi sugerido por IA.


## Bibliografia

### Básica de economia brasileira

- FILGUEIRAS, Luiz; GONÇALVES, Reinaldo. *A economia política do Governo Lula*. Rio de Janeiro: Contraponto, 2007.
- CARLEIAL, Liana Maria da Frota. Política econômica, mercado de trabalho e democracia: o segundo governo Dilma Rousseff. *Estudos Avançados*, v. 29, n. 85, p. 201–214, 2015. [Registro da revista](https://revistas.usp.br/eav/article/view/108932).
- PINHEIRO, Armando Castelar; GIAMBIAGI, Fabio. *Rompendo o marasmo: a retomada do desenvolvimento no Brasil*. Rio de Janeiro: Elsevier, 2006.

### Complementar de economia brasileira

- MARQUES, Rosa Maria; FERREIRA, Mariana Ribeiro Jansen (org.). *O Brasil sob a nova ordem: a economia brasileira contemporânea — uma análise dos governos Collor a Lula*. São Paulo: Saraiva, 2010.
- PAULANI, Leda Maria. *Brasil delivery: servidão financeira e estado de emergência econômico*. São Paulo: Boitempo, 2008.
- CARNEIRO, Ricardo (org.). *A supremacia dos mercados e a política econômica do governo Lula*. São Paulo: Editora UNESP, 2006.
- SADER, Emir. *Governo Lula: decifrando o enigma*. São Paulo: Boitempo, 2004.

### Análise de dados e comunicação

- WICKHAM, Hadley; ÇETINKAYA-RUNDEL, Mine; GROLEMUND, Garrett. *R for Data Science*. 2. ed. O'Reilly, 2023. [Versão original](https://r4ds.hadley.nz/) e [tradução comunitária em português](https://pt.r4ds.hadley.nz/).
- WICKHAM, Hadley; GROLEMUND, Garrett. *R para Data Science: importe, arrume, transforme, visualize e modele dados*. 1. ed. Alta Books, 2019. ISBN 9788550803241. [Catálogo da editora](https://altabooks.com.br/produto/r-para-data-science/). Referência separada da segunda edição online; confirmar eventual reimpressão de 2021 no exemplar usado.
- LLAUDET, Elena; IMAI, Kosuke. *Data Analysis for Social Science: A Friendly and Practical Introduction*. Princeton University Press, 2023. [Recursos públicos por capítulo](https://ellaudet.github.io/dss_book/student_resources_by_chapter/) e [recursos docentes](https://press.princeton.edu/instructor-resources/data-analysis-for-social-science).
- QUARTO. *Documentação oficial*. [Uso com R](https://quarto.org/docs/computations/r.html).

As leituras são selecionadas por aula: R4DS sustenta o fluxo técnico, Llaudet/Imai apoia o raciocínio sobre evidências e a bibliografia econômica sustenta o contexto e as interpretações. Não é exigida a leitura integral dos livros de métodos nem uma licença paga de IA.
