# Seu percurso em economia brasileira e análise de dados

Primeiro semestre de 2027 — Professor Patrick Rodrigues Andrade

Você vai aprender a transformar uma pergunta econômica em uma análise que outra pessoa possa reproduzir. Trabalharemos com o Brasil em aula e com um país escolhido, comparado aos EUA, nos projetos. O curso começa do zero em R; não é necessário já saber programar.

## O que você deverá conseguir fazer

1. Abrir um projeto e executar scripts em RStudio ou Positron.
2. Ler dados, verificar unidades e cobertura, transformar tabelas e fazer gráficos com tidyverse.
3. Usar inflação e deflação corretamente, distinguir saldos e dívidas e reconhecer o que cada base de trabalho ou renda mede.
4. Integrar fontes sem duplicar observações ou esconder valores ausentes.
5. Produzir um relatório Quarto com pergunta, fontes, evidências e limites.
6. Explicar seu código e seus resultados, mesmo quando recebeu ajuda de IA.

## Como será cada encontro

São 90 minutos: 60 de explicação e demonstração e 30 de prática supervisionada. Chegue com o projeto aberto e acompanhe o roteiro. Você pode alternar execução e anotações durante a demonstração. Ao final, salve o pequeno produto da aula e registre uma dúvida. As práticas dão feedback e alimentam os projetos; não recebem nota separada.

## Percurso de aprendizagem

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

As duas semanas de reserva não contêm assuntos novos obrigatórios. Datas e feriados dependem do calendário institucional. A carga oficial registrada em 2026 é 34h; não confunda esse registro com a duração operacional de cada encontro.

## Preparação e recursos

Siga o [guia de configuração](00-3-configuracoes-basicas.md). Abra o arquivo `economia-brasileira-2027.Rproj` no RStudio ou a pasta do projeto no Positron. Use as bases fornecidas: a aula não exige conexão permanente, conta GCP ou instalação de pacotes durante a prática.

R4DS é a referência técnica, com [versão gratuita em português](https://pt.r4ds.hadley.nz/). Os roteiros indicam pequenos trechos por aula. Llaudet/Imai ajuda a pensar sobre dados e conclusões; a bibliografia econômica sustenta os debates. Os livros não precisam ser lidos integralmente durante o semestre.

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


## Entregas

**Projeto 1:** crescimento e inflação + dois indicadores de um tema, com dados do FMI, comparando seu país aos EUA. Entregar R, QMD, HTML, três figuras e uma tabela. Escolham um país com cobertura suficiente e diferente dos demais grupos; confirmem o registro com o professor.

**Projeto 2:** aprofundar o mesmo par numa pergunta fiscal, de trabalho ou desigualdade, usando uma fonte oficial adicional e uma análise nova. Uma conclusão negativa ou uma limitação bem documentada também pode ser um resultado válido.

## Antes de entregar

- Execute tudo numa sessão limpa, com as bases locais entregues junto ao projeto.
- Confira dados, unidades, fontes e anos; identifique estimativas e projeções.
- Inclua arquivos necessários e caminhos relativos; nunca dependa do seu Desktop ou de objetos da sessão.
- Em cada gráfico, informe indicador, unidade, países, período e fonte.
- Cada integrante deve explicar uma transformação e um resultado na defesa.

## Uso de inteligência artificial

IA pode auxiliar explicação de código, depuração e revisão de texto. O grupo continua responsável por cada cálculo, fonte e afirmação. Registrar ferramenta, finalidade e trechos relevantes incorporados; explicar como o código e a informação foram conferidos. Não há obrigação de usar IA nem de adquirir assinatura. Na defesa, cada integrante deverá explicar uma transformação e interpretar um resultado, inclusive quando o código foi sugerido por IA.


## Apoio ao estudo

Use `?nome_da_funcao`, a documentação dos pacotes, as leituras e os checkpoints. Ao pedir ajuda, mostre a mensagem de erro, a parte do código e o resultado esperado. A bibliografia completa está no [plano oficial](00-1-plano-ensino-oficial.md).
