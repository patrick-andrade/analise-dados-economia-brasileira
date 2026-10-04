# Ambiente para as aulas de 2027

Instale R, uma IDE e Quarto antes do primeiro encontro. R executa a análise, a IDE facilita o trabalho e Quarto gera o relatório. RStudio e Positron são alternativas equivalentes; escolha a que funciona melhor no seu computador.

## Instalação

1. [R pelo CRAN](https://cran.r-project.org/): instale a versão disponível para seu sistema.
2. [RStudio Desktop](https://posit.co/download/rstudio-desktop/) ou [Positron](https://positron.posit.co/download.html).
3. [Quarto](https://quarto.org/docs/get-started/): confira a disponibilidade com `quarto check`. RStudio pode incluir o CLI; em Positron confirme também o CLI, além da extensão.
4. Baixe a edição 2027 inteira. Abra `economia-brasileira-2027.Rproj` no RStudio ou a pasta em Positron. Evite abrir apenas um script isolado.
5. Execute `source("scripts/configurar.R")` uma vez com rede disponível. Não execute a instalação em todas as aulas.

## Primeiro teste

Na raiz do projeto, execute:

```r
source("R/comum.R")
iniciar_aula()
dados <- ler_base("ipca")
dplyr::glimpse(dados)
```

Abra `modelos/01-relatorio-minimo.qmd` e use Render/Preview. Ele deve produzir HTML sem baixar dados. Execute também `Rscript scripts/verificar.R` no terminal se quiser conferir o pacote completo.

## Organização e sessão limpa

Não restaure `.RData` automaticamente. Não salve o workspace ao sair. Os scripts precisam criar seus próprios objetos; os dados ficam em `data/`, e resultados em `outputs/`. Execute a partir da raiz do projeto, sem `setwd()` para caminhos pessoais. Use Ctrl+Enter para executar seleções e procure a primeira mensagem de erro antes de continuar.

## GitHub e IA

Uma conta GitHub pode ajudar a acompanhar o repositório e versionar seu trabalho. O [GitHub Education](https://education.github.com/pack) pode oferecer benefícios sujeitos a aprovação e às regras vigentes; acesso a Copilot não é requisito da disciplina.

Se usar assistente, siga as instruções oficiais para [RStudio](https://docs.posit.co/ide/user/ide/guide/tools/copilot.html) ou [Positron](https://positron.posit.co/assistant.html). Não é necessário configurar vários assistentes. A edição funciona sem IA e sem licença paga. Declare a ajuda usada, confira as fontes e entenda cada transformação.

## Problemas frequentes

| Situação | Como investigar |
|---|---|
| Pacote ausente | Execute a configuração uma vez; guarde a mensagem de instalação se houver falha. |
| Base local ausente | Confira se baixou a edição inteira e veja `data/README.md`; não crie valores para preencher a base. |
| Arquivo não encontrado | Abra o projeto completo e confira o caminho relativo. |
| API indisponível | Use o recorte local fornecido e anote a falha; não é necessário atualizar a base para acompanhar a aula. |
| Render falha | Confira o primeiro erro, a disponibilidade de R/Quarto e se o script roda em sessão limpa. |

As versões efetivamente usadas na verificação docente ficam em `docs/validacao.md`, não como exigência de usar a mesma versão futura de cada produto.
