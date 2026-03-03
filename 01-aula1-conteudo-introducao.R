# ============================================================
# Economia brasileira: análise de dados (Laboratório)
# PARTE 1 — Introdução à análise e ciência de dados no R
# Aula 1: Economia, análise de dados e ambiente R
# ============================================================
#
# ============================================================ 
# Objetivos da aula:
# 1) entender notação do R (base)
# 2) trabalhar com uma tabela (base R)
# 3) migrar para tidyverse (dplyr + ggplot)
# 4) aplicar em um tema do curso: inflação (IPCA)
#
# Dicas para a turma:
# - Rode em blocos pequenos (Ctrl+Enter / Cmd+Enter)
# - Pare nos CHECKPOINTS: confirme que entendeu e consegue modificar algo.
# - Se algo quebrar: leia a mensagem de erro com calma e volte 1 passo.
# ============================================================
#
# ------------------------------------------------------------
# 0) Antes de tudo: projeto, pastas e caminhos
# ------------------------------------------------------------
# No laboratório, o mais importante é evitar o “não funciona no meu PC”
# Recomendação: padronizar um ambiente de trabalho organizado
# - uma pasta do curso (projeto)
# - subpastas para dados e saídas
#
# Onde o R acha que está?
getwd()
list.files()
#
# ------------------------------------------------------------
# 1) Linguagem R
# ------------------------------------------------------------
# No console, você pode testar comandos rápidos do R (como uma calculadora)
2 + 3
10 / 2
2^3
10 %% 3   # resto da divisão
# O que significa o resultado 1 do resto da divisão de 10 por 3?
# Dica: 3 cabe 3 vezes em 10 (3*3=9), sobra 1. O operador %% retorna essa sobra.
#
10 %/% 3  # divisão inteira
# Dica: 3 cabe 3 vezes em 10, então a divisão inteira é 3.
#
# Comentários começam com # e NÃO são executados.
# Use comentários para explicar o “porquê”, não só o “como”.
#
# ------------------------------------------------------------
# 2) Notação do R (base): objetos, atribuição, nomes
# ------------------------------------------------------------
# O R trabalha com OBJETOS. Você cria objetos com atribuição.
#
# Formas de atribuição (vamos padronizar o <-):
x = 10
10 = x # erro de atribuição
x <- 10
y <- 3
x + y
#
# Atalho importante (RStudio/Positron): Alt + -  (cria  <-  automaticamente)
#
# Nomes:
# - podem ter letras, números, _ e .
# - não podem começar com número
# - são case-sensitive: x != X
X <- 20
x
X
#
# Use nomes descritivos (sem acentos, preferir snake_case):
taxa_juros <- 0.12
taxa_juros
#
# CHECKPOINT:
# Crie um objeto chamado renda_mensal com valor 2500.
# Depois crie gasto_mensal com valor 1800.
# Calcule poupanca_mensal = renda_mensal - gasto_mensal
#
# ------------------------------------------------------------
# 3) Tipos, vetores e indexação (base R)
# ------------------------------------------------------------
# Tipos básicos:
numero <- 10.5
class(numero)
inteiro <- 10
class(inteiro)
inteiro2 <- 10L # o L indica que é um número inteiro (integer), sem casas decimais.
class(inteiro2)
texto <- "Brasil" # texto é um tipo de dado chamado character (caractere). No python, seria string.
class(texto)
logico <- TRUE
class(logico)
#
#
# Vetores: vários valores do mesmo tipo (quase sempre)
inflacao_exemplo <- c(0.4, 0.6, 0.3, 0.5)  # (% ao mês, exemplo didático)
inflacao_exemplo
# No python, isso seria uma lista ou um array. No R, é um vetor (vector)
#
length(inflacao_exemplo)
mean(inflacao_exemplo)
sum(inflacao_exemplo)
#
# Indexação: colchetes [ ]
inflacao_exemplo[1]
inflacao_exemplo[2:4]
#
# Valores faltantes (NA) aparecem MUITO em dados reais
v <- c(1, 2, NA, 4)
mean(v)                 # dá NA
mean(v, na.rm = TRUE)   # ignora NA
#
# CHECKPOINT:
# Crie um vetor chamado ipca_3meses com 3 valores (em %).
# (a) pegue apenas o 1º e o 3º valor
# (b) calcule a média
#
# ------------------------------------------------------------
# 4) Funções e ajuda: como “conversar” com o R
# ------------------------------------------------------------
# Funções têm parênteses: nome_funcao(...)
round(3.14159, 2)
#
# Ajuda:
?round
help("mean")
#
# Se der erro, você aprende a depurar.
# Exemplo: descomente e veja a mensagem.
# mean("abc")
#
# CHECKPOINT:
# Procure a ajuda de sum() e descubra o argumento na.rm.
# (Dica: ?sum)
?sum
#
# ------------------------------------------------------------
# 5) Tabelas no R: data.frame (base)
# ------------------------------------------------------------
# Economia é cheia de tabelas. O formato padrão no R é data.frame.
inflacao_exemplo <- data.frame(
  mes = c("2018-10-01", "2018-11-01", "2018-12-01"),
  ipca = c(0.45, 0.50, 0.15),
  cambio = c(3.70, 3.85, 3.90)
)
#
# Recentemente foi introduzida uma nova notação de tabela, o tibble, que é mais amigável.
# Vantagens do tibble:
# - melhor impressão no console
# - mensagens de erro mais claras
# - não converte strings em fatores (um tipo de dado problemático)
# - melhor integração com tidyverse
# Para criar um tibble, use tibble::tibble() ou readr::read_csv().
#
inflacao_exemplo
str(inflacao_exemplo)
# str significa “structure” e mostra a estrutura do objeto, incluindo tipos de dados e dimensões.
#
# Salvar e ler CSV (para praticar reprodutibilidade)
write.csv(inflacao_exemplo, "inflacao_exemplo.csv", row.names = FALSE)
#
inflacao_exemplo2 <- read.csv("inflacao_exemplo.csv")
inflacao_exemplo2
str(inflacao_exemplo2)
#
# CHECKPOINT:
# O que acontece se você salvar o CSV com outro nome?
# (Teste: mude "inflacao_exemplo.csv" para "inflacao_exemplo_v2.csv")
#
# ------------------------------------------------------------
# 6) Transição para tidyverse: leitura + transformação + gráfico
# ------------------------------------------------------------
# A partir de agora (no curso), o “modo padrão” será tidyverse:
# Principais pacotes:
# - readr para leitura de dados
# - dplyr para manipulação de dados
# - ggplot2 para gráficos
#
# Se você ainda não tem tidyverse instalado, faça UMA vez:
# install.packages("tidyverse")
#
# (No laboratório, idealmente isso foi feito antes da aula.)

library(tidyverse)

# Pipe:
# - base R: |>
# - no tidyverse, você verá também: %>%
# O que o pipe faz? Ele pega o resultado do que está à esquerda e “passa” para a função à direita.
# Exemplo sem pipe:
sqrt(16)
# Exemplo com pipe:
16 |> sqrt()

# Ler o CSV com readr (retorna um tibble mais amigável)
inflacao_tidy <- readr::read_csv("inflacao_exemplo.csv", show_col_types = FALSE)

inflacao_tidy
glimpse(inflacao_tidy)

# Transformar com dplyr
inflacao_tidy2 <- inflacao_tidy |>
  mutate(
    ipca_acum = cumsum(ipca),
    dif_cambio = cambio - lag(cambio)
  )
# mutate adiciona novas colunas.
# cumsum calcula a soma acumulada de uma coluna.
# lag é uma função que pega o valor da linha anterior.
# ipca_acum calcula o IPCA acumulado desde o início da série.
# dif_cambio calcula a diferença do câmbio em relação ao mês anterior.
# O resultado é um novo tibble com as colunas originais mais as novas.

inflacao_tidy2

# Visualizar com ggplot
grafico1 <- ggplot(inflacao_tidy2, aes(x = mes, y = ipca)) +
  geom_line() +
  geom_point() +
  labs(
    title = "IPCA mensal — mini exemplo",
    x = NULL,
    y = "IPCA (%)"
  )
#
grafico1

ggsave("aula1_mini_ipca.png", p1, width = 7, height = 4)

# CHECKPOINT:
# 1) troque o gráfico para y = cambio
# 2) salve como aula1_mini_cambio.png


# ------------------------------------------------------------
# 7) Aplicação no tema do curso: inflação (IPCA)
# ------------------------------------------------------------
# Vamos trabalhar com dados reais
# Tarefa: baixar a série do IPCA mensal (BCB/SGS), recortar 1994–2018
# e fazer 2 análises simples: (1) gráfico; (2) resumo anual.
#
# Para baixar do BCB, usaremos o pacote rbcb, que tem uma função get_series() para acessar o SGS.
# 
install.packages("rbcb")
library(rbcb)
#
#
# IPCA (código 433) — IPCA variação mensal (%)
# Como usar a função get_series():
# ?get_series
# - primeiro argumento: código da série (identificador da série no SGS do Banco Central do Brasil, por exemplo, "433" para IPCA)
# - start_date e end_date: período desejado (formato "YYYY-MM-DD")
# Dica: o BCB tem centenas de séries, então é bom conferir o código e o nome antes de baixar.
# Dica 2: o BCB pode ter dados atualizados, então o período final pode variar. Ajuste conforme necessário.
# Vamos baixar o IPCA mensal de 1994-01-01 a 2018-12-31 (período pré-pandemia).  
#
# -----------------------------------------------------
# 7.1) Baixar os dados usando rbcb e transformar a base
## A sintaxe c(ipca = 433) já garante que a coluna de valores se chamará "ipca"
ipca <- get_series(c(ipca = 433), start_date = "1994-01-01", end_date = "2018-12-31")
#
# O rbcb retorna um tibble com as colunas 'date' (já em formato Date) e 'ipca'.
str(ipca)
glimpse(ipca)
#
ipca_1996_2018 <- ipca |> 
  rename(data = date) |>                  # Traduz o nome da coluna para português
  arrange(data) |>                        # Garante a ordem cronológica
  filter(data >= as.Date("1996-01-01"))   # Filtra os dados a partir de janeiro de 1996
#
# função rename: permite renomear colunas específicas, usando o nome atual ou a posição
#
# -----------------------------------------------------
# 7.2) Visualizar a série de inflação com o ggplot
#  
# Gráfico do IPCA mensal de janeiro de 1995 a dezembro de 2018
grafico2 <- ggplot(ipca_1996_2018, aes(x = data, y = ipca)) +
  geom_line(color = "steelblue") +
  geom_point(color = "darkblue", size = 1) +
  # A função abaixo garante que a exibição no eixo X seja no formato brasileiro
  scale_x_date(date_labels = "%m/%Y", date_breaks = "2 years") + 
  labs(
    title = "IPCA mensal (1996–2018)",
    x = NULL,
    y = "IPCA (%)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Rotaciona a data para não sobrepor
#
grafico2
# Dica 1: para séries temporais, use geom_line() para mostrar a tendência e geom_point() para destacar os pontos mensais.
# Dica 2: para o eixo X, use scale_x_date() para formatar as datas de forma legível (ex: "01/1996").
# Dica 3: para evitar sobreposição de rótulos no eixo X, use theme() para rotacionar os textos.
#Salvar o gráfico:
ggsave("aula1_ipca_1994_2018.png", grafico2, width = 8, height = 4)
#
#
# Resumo anual (média do IPCA mensal por ano)
#
ipca_anual <- ipca |> 
  mutate(ano = lubridate::year(date)) |>  # Extrai o ano da coluna 'date' (lembre-se que não alteramos o nome da coluna 'date' do objeto "ipca")
  group_by(ano) |> # Agrupa por ano
  summarise(ipca_acumulado = sum(ipca)) # Calcula o IPCA acumulado para cada ano
#
ipca_anual
write.csv(ipca_anual, "outputs/tables/ipca_anual_1994_2018.csv", row.names = FALSE)
#
# CHECKPOINT (discussão rápida):
# (a) Em quais anos o IPCA anual foi mais alto?
# (b) O que aconteceu em 1999, 2002 e em 2015?
# Dica: para responder, olhe a tabela ipca_anual e o gráfico ipca_1996_2018. O gráfico mostra a série mensal, então é possível ver os picos que correspondem aos anos de alta inflação. A tabela ipca_anual mostra o IPCA acumulado por ano, então os anos com os maiores valores indicam os períodos de maior inflação anual. Em 1999, houve uma crise cambial que levou a um pico de inflação, e em 2015, o Brasil enfrentou uma recessão econômica que também resultou em alta inflação.
#
grafico3 <- ggplot(ipca_anual |> filter(ano > 1995), aes(x = factor(ano), y = ipca_acumulado)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "IPCA anual acumulado (1995–2018)",
    x = "Ano",
    y = "IPCA acumulado (%)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) # Rotaciona os anos para evitar sobreposição.
# hjust = 1 alinha o texto à direita, o que é útil quando os rótulos estão rotacionados em 90 graus.
#
grafico3
#
# ------------------------------------------------------------
# Fechamento
# ------------------------------------------------------------
# Aprendizado da aula:
# - Conceitos básicos de R.
# - Como criar e manipular objetos e vetores.
# - A importância de tabelas (data.frames e tibbles) para análise de dados.
# - Operações fundamentais com tidyverse: leitura, transformação e visualização de dados.
# - Como acessar dados reais do Banco Central usando o pacote rbcb.
# - Como utilizar gráficos para explorar e comunicar informações.
# - A aplicação prática desses conceitos no contexto da análise de inflação (IPCA).

# Questões para reflexão:
# 1) Você saberia explicar a utilidade da biblioteca tidyverse?
# 2) Você saberia explicar Qual a vantagem de usar o pipe |> em fluxos de análise?
# 3) Como você aplicaria as funções mutate() e summarise() em outro conjunto de dados?
# 4) O que os gráficos criados hoje revelam sobre os dados analisados?

