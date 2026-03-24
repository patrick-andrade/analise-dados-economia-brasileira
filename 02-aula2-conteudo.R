# ============================================================
# Economia brasileira: análise de dados (Laboratório)
# PARTE 1 — Estabilização econômica e regime monetário
#
# AULA 2 (2h): Dinâmica macro integrada
# Tema: Inflação (IPCA), juros (Selic) e atividade (IBC-Br) — 1999–2018
# Foco: (A) transformações com dados reais + (B) visualização e interpretação
# Extra (nível acima): regressão simples (Taylor "na prática")
#
# Produto ao final:
# - 3 gráficos: (1) IPCA 12m x Selic; (2) Selic real ex-post; (3) Dispersão + reta
# - 1 tabela resumo por regimes/subperíodos
# - 3–5 frases interpretativas citando números e anos
# ============================================================


# ------------------------------------------------------------
# 0) Setup (pastas, pacotes, opções)
# ------------------------------------------------------------
dir.create("data/raw",       recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/figs",   recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

# Se você já instalou na Aula 1, não precisa rodar o install de novo —
# apenas o library() precisa rodar toda vez que abrir o R.
# install.packages(c("tidyverse", "lubridate", "rbcb", "slider", "broom"))

library(tidyverse)   # dplyr, ggplot2, tidyr, readr, etc.
library(lubridate)   # facilita trabalhar com datas (ymd, year, month...)
library(rbcb)        # acessa o SGS do Banco Central
library(slider)      # funções de janela móvel (rolling window)
library(broom)       # deixa resultados de modelos no formato tibble

options(scipen = 999) # desliga notação científica (ex: exibe 1000000 em vez de 1e+06)


# ------------------------------------------------------------
# 1) Baixando os dados do SGS/BCB com rbcb
# ------------------------------------------------------------
# Na Aula 1 já usamos get_series() para baixar o IPCA.
# Aqui repetimos o mesmo padrão para 3 séries:
#
# Códigos SGS/BCB (Sistema Gerenciador de Séries Temporais do Banco Central):
#   433   → IPCA: variação mensal (%)
#   432   → Selic meta (% a.a.)
#   24363 → IBC-Br: Índice de Atividade Econômica do Banco Central (índice)
#
# Para pesquisar outros códigos de séries disponíveis no SGS:
#   https://www3.bcb.gov.br/sgspub/
#
# A sintaxe c(nome = codigo) nomeia automaticamente a coluna de valores —
# exatamente como fizemos na Aula 1 com c(ipca = 433).
# A coluna de datas sempre se chama "date" (padrão do pacote rbcb).

ipca  <- rbcb::get_series(c(ipca_mensal = 433),   start_date = "1999-01-01", end_date = "2018-12-31")
selic <- rbcb::get_series(c(selic_meta = 432),   start_date = "1999-01-01", end_date = "2018-12-31")
ibc   <- rbcb::get_series(c(ibc_br = 24363), start_date = "1999-01-01", end_date = "2018-12-31")

# Verificando o resultado (sempre bom conferir após um download)
glimpse(ipca)
glimpse(selic)
glimpse(ibc)

# Salvando os dados brutos localmente (boa prática)
# Isso evita rebaixar toda vez que você abrir o script — e garante que você
# tem os dados mesmo se a internet ou o site do BCB estiverem fora do ar.
readr::write_csv(ipca,  "data/raw/ipca_mensal_1999_2018.csv")
readr::write_csv(selic, "data/raw/selic_meta_1999_2018.csv")
readr::write_csv(ibc,   "data/raw/ibc_br_1999_2018.csv")

# ------------------------------------------------------------
# 1.2) Juntando as três séries em uma única tabela
# ------------------------------------------------------------

macro <- ipca |>
  left_join(selic, by = "date") |>
  left_join(ibc,   by = "date") |>
  arrange(date)   # garante a ordem cronológica

# left_join() une duas tabelas usando uma coluna-chave (aqui: "date").
# O "left" significa: mantemos todas as linhas da tabela da esquerda (ipca)
# e buscamos os valores correspondentes nas tabelas da direita.
# Resultado: uma linha por mês, com as três séries lado a lado.
#
# Por que left_join() e não full_join()?
# Aqui as três séries foram baixadas com o mesmo recorte temporal (1999–2018),
# então a diferença prática é pequena. Mas em outros contextos, importa:
#
#   left_join()  → mantém APENAS as datas presentes na tabela da esquerda (ipca).
#                  Se selic ou ibc tiverem datas extras, elas são descartadas
#                  silenciosamente — sem aviso de erro.
#
#   full_join()  → mantém TODAS as datas de todas as tabelas.
#                  Onde falta valor, preenche com NA.
#                  Mais seguro quando as séries têm coberturas diferentes.
#
# Exemplo real: o IBC-Br (série 24363) só existe a partir de 2003.
# Se você fizesse left_join() com ibc como tabela da esquerda, perderia
# todos os meses anteriores a 2003 das outras séries.
# Com full_join(), esses meses seriam preservados (com NA no ibc_br).
#
# Regra prática:
#   - Séries com mesmo recorte temporal → left_join() é suficiente.
#   - Séries com recortes diferentes    → prefira full_join() para não
#     perder dados sem perceber.


# CHECKPOINT (2 min)
# - Quantas linhas tem macro? (dica: nrow(macro))
# - Quais são as colunas? Elas fazem sentido?
glimpse(macro)


# ------------------------------------------------------------
# 2) Transformações macroeconômicas
# ------------------------------------------------------------

# ····························································
# 2.1) IPCA acumulado em 12 meses (%)
# ····························································
# Por que 12 meses? O Banco Central e o mercado acompanham a inflação
# acumulada em 12 meses para avaliar se estamos convergindo para a meta
# anual. A variação mensal isolada tem muito "ruído".
#
# Por que taxa composta e não soma simples?
# Somar as variações mensais superestima levemente a inflação acumulada.
# O cálculo correto é o produto dos fatores:
#   (1 + r1/100) × (1 + r2/100) × ... × (1 + r12/100) − 1
#
# Para fazer isso em janelas móveis de 12 meses usamos slide_dbl() do
# pacote {slider}. Uma "janela móvel" (rolling window) percorre a série
# mês a mês, calculando sempre sobre os 12 meses mais recentes.
#
# Referência conceitual:
#   Banco Central do Brasil. Relatório de Inflação (publicação trimestral).
#   O BCB usa exatamente essa metodologia para divulgar o IPCA acumulado 12m.
#   Acesso: https://www.bcb.gov.br/publicacoes/ri
#
# Documentação do pacote {slider} (com exemplos de janelas móveis):
#   https://slider.r-lib.org
#
# Como ler slide_dbl():
#   .x        = coluna sobre a qual calcular
#   .f        = função a aplicar em cada janela (o "." representa o vetor da janela)
#   .before   = quantos meses anteriores incluir (11 → janela de 12: atual + 11 antes)
#   .complete = TRUE → só calcula quando a janela de 12 meses está completa
#               (evita resultados com janela incompleta no início da série)

macro <- macro |>
  mutate(
    ipca_12m = slide_dbl(
      .x        = ipca_mensal,
      .f        = ~ (prod(1 + .x / 100) - 1) * 100,
      .before   = 11,
      .complete = TRUE
    )
  )

# Explicação da fórmula:
# - .x é o vetor dos 12 meses (ex: c(0.5, 0.3, 0.4, ..., 0.6))
# - Para cada mês, somamos 1 e dividimos por 100 para converter de porcentagem para fator (ex: 1 + 0.5/100 = 1.005)
# - O produto desses fatores dá o crescimento total (ex: 1.005 × 1.003 × ... × 1.006 = 1.061)
# - Subtraímos 1 para voltar de fator para taxa (ex: 1.061 − 1 = 0.061)
# - Multiplicamos por 100 para converter de volta para porcentagem (ex: 0.061 × 100 = 6.1% de inflação acumulada em 12 meses)
# CHECKPOINT:
# - O que acontece com ipca_12m nos primeiros 11 meses da série?
# como checar:
# filter(macro, date < ymd("2000-01-01")) |> select(date, ipca_mensal, ipca_12m)
# explicação: eles ficam como NA porque a janela de 12 meses não está completa — isso é o comportamento esperado com .complete = TRUE.


# ····························································
# 2.2) Atividade: crescimento do IBC-Br em 12 meses (%)
# ····························································
# O IBC-Br é o indicador de atividade econômica do Banco Central.
# Ele antecipa o PIB oficial (divulgado pelo IBGE) e é acompanhado
# mês a mês como proxy do ritmo da economia.
#
# Referência metodológica:
#   Banco Central do Brasil (2010). Nota metodológica do IBC-Br.
#   Acesso: https://www.bcb.gov.br/publicacoes/notastecnicas
#   (buscar por "IBC-Br" na listagem de notas técnicas)
#
# lag(x, 12) pega o valor da coluna x com 12 períodos de defasagem.
# Já usamos lag() na Aula 1 (dif_cambio). Aqui aplicamos o mesmo conceito
# para calcular a variação percentual em relação ao mesmo mês do ano anterior:
#   variação = (valor_atual / valor_12_meses_atrás − 1) × 100

macro <- macro |>
  mutate(
    ibc_yoy = (ibc_br / lag(ibc_br, 12) - 1) * 100
  )

# ····························································
# 2.3) Selic real ex-post (aproximação)
# ····························································
# "Taxa real de juros" é a taxa nominal descontada a inflação.
# A distinção entre taxa nominal e real é central em macroeconomia:
# o que importa para as decisões de poupança e investimento é o
# rendimento acima da inflação, não o rendimento bruto.
#
# Fórmula exata (equação de Fisher):
#   (1 + r_real) = (1 + r_nominal) / (1 + inflação)  →  r_real ≈ r_nominal − inflação
#
# Aqui usamos a aproximação (diferença simples), adequada para fins didáticos.
# "Ex-post" significa que usamos a inflação que de fato ocorreu (e não a esperada).
#
# Referência clássica:
#   Fisher, I. (1930). The Theory of Interest. Macmillan.
#   (A equação de Fisher é apresentada em qualquer manual de macroeconomia;
#    ver p. ex. Blanchard, O. Macroeconomia. 7ª ed., cap. 14)
#
# Leitura complementar acessível sobre taxa real de juros no Brasil:
#   Nakane, M.I. & Koyama, S.M. (2003). "O spread bancário no Brasil."
#   BCB Notas Técnicas n. 18. Acesso: https://www.bcb.gov.br/pec/notastecnicas/port/2003nt18p.pdf
#   (contextualiza juros nominais vs. reais no sistema financeiro brasileiro)

macro <- macro |>
  mutate(
    selic_real_expost = selic_meta - ipca_12m
  )

# ····························································
# 2.4) Gap de inflação (desvio em relação à meta)
# ····························································
# No regime de metas de inflação, o Banco Central reage principalmente
# ao desvio da inflação em relação à meta — não ao nível absoluto.
# Esse desvio (inflação_gap) é um dos ingredientes centrais da Regra de Taylor.
#
# Usamos meta_inflacao_aprox = 4,5% como simplificação pedagógica.
# Na realidade, a meta variou ao longo do período (ex.: 3,25% em 2017).
# Consulte o histórico em: https://www.bcb.gov.br/monetariainflacao/metas

macro <- macro |>
  mutate(
    meta_inflacao_aprox = 4.5,
    inflacao_gap        = ipca_12m - meta_inflacao_aprox
  )

# CHECKPOINT (3 min)
# - O que você espera para selic_real_expost em períodos de inflação muito alta?
# - Em geral, ipca_12m e selic_meta sobem e caem juntos? Por quê?


# ------------------------------------------------------------
# 3) Gráfico 1: IPCA 12m x Selic (comparação temporal com facets)
# ------------------------------------------------------------
# Para comparar as duas séries num mesmo gráfico, precisamos primeiro
# reorganizar os dados: de "formato largo" (duas colunas separadas)
# para "formato longo" (uma coluna com os valores e outra com o rótulo).
#
# Isso se chama "pivotar para o formato longo" — pivot_longer().
# É o padrão "tidy data" (dados arrumados): cada linha é uma observação,
# cada coluna é uma variável.
#
# Referência sobre tidy data:
#   Wickham, H. (2014). "Tidy Data." Journal of Statistical Software, 59(10), 1–23.
#   Acesso aberto (open access): https://doi.org/10.18637/jss.v059.i10
#
# Documentação de pivot_longer() com exemplos visuais:
#   https://tidyr.tidyverse.org/reference/pivot_longer.html
#
# Como ler pivot_longer():
#   cols      = quais colunas transformar em linhas
#   names_to  = nome da nova coluna que vai guardar o rótulo (ex: "serie")
#   values_to = nome da nova coluna que vai guardar o valor numérico

macro_long <- macro |>
  select(date, ipca_12m, selic_meta) |>
  pivot_longer(
    cols      = c(ipca_12m, selic_meta),
    names_to  = "serie",
    values_to = "valor"
  ) |>
  # recode() troca os valores de uma coluna por rótulos mais legíveis
  mutate(
    serie = recode(serie,
                   ipca_12m   = "IPCA (12m, %)",
                   selic_meta = "Selic meta (% a.a.)")
  )

# facet_wrap() divide o gráfico em painéis separados por categoria.
# Aqui usamos scales = "free_y" porque IPCA e Selic têm escalas diferentes.
# Sem isso, um painel ficaria "achatado" pela escala do outro.

p_inflacao_selic <- ggplot(macro_long, aes(x = date, y = valor)) +
  geom_line() +
  facet_wrap(~ serie, ncol = 1, scales = "free_y") +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  labs(
    title   = "Inflação (12m) e juros (Selic) no Brasil — 1999–2018",
    x       = NULL,
    y       = NULL,
    caption = "Fonte: BCB/SGS via rbcb. IPCA 12m calculado por taxa composta mensal."
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p_inflacao_selic
ggsave("outputs/figs/aula2_ipca12m_selic_1999_2018.png",
       p_inflacao_selic, width = 8, height = 6)

# CHECKPOINT (interpretação):
# - Em quais períodos a Selic sobe junto com a inflação? (pistas: 2002–03 e 2015–16)
# - Você enxerga períodos de desinflação (queda persistente do IPCA 12m)?


# ------------------------------------------------------------
# 4) Gráfico 2: Selic real ex-post (aproximação)
# ------------------------------------------------------------
# geom_hline() adiciona uma linha horizontal de referência.
# Aqui a linha em yintercept = 0 é o limite: abaixo dela, o juro real é negativo.

p_selic_real <- ggplot(macro, aes(x = date, y = selic_real_expost)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_line() +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  labs(
    title   = "Juro real ex-post (Selic − IPCA 12m) — aproximação",
    x       = NULL,
    y       = "p.p.",
    caption = "Medida ex-post e aproximada (diferença de taxas anuais)."
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p_selic_real
ggsave("outputs/figs/aula2_selic_real_expost_1999_2018.png",
       p_selic_real, width = 8, height = 4)

# CHECKPOINT:
# - Quando o juro real fica muito alto? O que isso sugere sobre a postura monetária?
# - O juro real ficou negativo em algum período? O que isso significa?


# ------------------------------------------------------------
# 5) Regimes / subperíodos para resumir a história
# ------------------------------------------------------------
# Uma prática comum em macroeconomia é dividir a série em subperíodos
# ("regimes") que correspondem a fases distintas da política econômica.
# Isso facilita comparações e ajuda a identificar padrões estruturais.
#
# Referência sobre regimes de política monetária no Brasil:
#   Bogdanski, J., Tombini, A., & Werlang, S.R. (2000).
#   "Implementing Inflation Targeting in Brazil."
#   BCB Working Paper No. 1.
#   Acesso: https://www.bcb.gov.br/pec/wps/ingl/wps01.pdf
#   (Artigo fundacional que descreve a implantação do regime de metas no Brasil)
#
#   Mishkin, F.S. (2000). "Inflation Targeting in Emerging-Market Countries."
#   American Economic Review, 90(2), 105–109.
#   Acesso via Google Scholar: buscar por "Mishkin 2000 Inflation Targeting Emerging"
#   (Contexto internacional do regime de metas para países emergentes)
#
# case_when() é uma versão vetorizada do "se/senão" (if/else) do R.
# Funciona assim: avalia cada condição em ordem e atribui o valor
# correspondente à primeira que for verdadeira. O TRUE no final
# funciona como o "else" — pega tudo que não caiu nas condições anteriores.
# Documentação de case_when(): https://dplyr.tidyverse.org/reference/case_when.html
#
# ymd() do pacote lubridate converte uma string "AAAA-MM-DD" em objeto Date.
# É equivalente a as.Date(), mas com sintaxe mais compacta e legível.
# Documentação do pacote {lubridate}: https://lubridate.tidyverse.org

macro <- macro |>
  mutate(
    regime = case_when(
      date < ymd("2003-01-01") ~ "1999–2002: transição/credibilidade",
      date < ymd("2011-01-01") ~ "2003–2010: metas consolidadas",
      date < ymd("2015-01-01") ~ "2011–2014: juros em queda/expansão",
      TRUE                     ~ "2015–2018: ajuste/desinflação"
    )
  )

# Tabela-resumo por regime
# group_by() + summarise() já vimos na Aula 1.
# sd() calcula o desvio padrão — uma medida de dispersão/volatilidade.
# n() conta o número de observações (meses) em cada grupo.

tab_regimes <- macro |>
  filter(!is.na(ipca_12m), !is.na(ibc_yoy)) |>
  group_by(regime) |>
  summarise(
    inflacao_media = mean(ipca_12m),
    inflacao_dp    = sd(ipca_12m),
    selic_media    = mean(selic_meta),
    juro_real_med  = mean(selic_real_expost),
    ibc_yoy_media  = mean(ibc_yoy),
    n              = n(),
    .groups        = "drop"
  ) |>
  arrange(regime)

tab_regimes
readr::write_csv(tab_regimes, "outputs/tables/aula2_resumo_regimes.csv")

# CHECKPOINT:
# - Qual regime tem maior inflação média? E maior juro real médio?
# - Compare inflacao_media com a meta de 4,5%: em quais regimes o BC ficou
#   consistentemente acima ou abaixo da meta?


# ------------------------------------------------------------
# 6) Regressão simples: uma "Taylor" didática
# ------------------------------------------------------------
# A Regra de Taylor (1993) descreve como os bancos centrais tendem a
# ajustar a taxa de juros em resposta à inflação e ao hiato do produto.
# Na versão original:
#
#   i_t = r* + π* + α(π_t − π*) + β(y_t − y*)
#
# onde i = taxa de juros, r* = juro natural, π* = meta de inflação,
# (π − π*) = desvio da inflação em relação à meta,
# (y − y*) = hiato do produto (atividade acima/abaixo do potencial).
#
# Referência original:
#   Taylor, J.B. (1993). "Discretion versus policy rules in practice."
#   Carnegie-Rochester Conference Series on Public Policy, 39, 195–214.
#   Acesso: https://doi.org/10.1016/0167-2231(93)90009-L
#
# Aplicação ao Brasil:
#   Moreira, T.B.S., Souza, G.S., & Almeida, C.L. (2007).
#   "A Regra de Taylor e a Política Monetária Brasileira."
#   Revista de Economia Política, 27(2), 247–267.
#   Acesso via Scielo: https://www.scielo.br/j/rep/
#
# Modelo estimado aqui (versão simplificada e didática):
#   Selic_t = a + b × IPCA12m_t + c × CrescimentoIBC_t + erro_t
#
# ATENÇÃO — Três avisos importantes:
# 1) Isso NÃO prova causalidade. É uma regressão descritiva.
# 2) Há endogeneidade: a Selic afeta a inflação futura, e a inflação
#    afeta a Selic atual — as variáveis se influenciam mutuamente.
# 3) O objetivo aqui é aprender a ler coeficientes e sinais.
#    OLS completo virá em outras disciplinas.

dados_modelo <- macro |>
  select(date, selic_meta, ipca_12m, ibc_yoy, inflacao_gap, regime) |>
  filter(!is.na(ipca_12m), !is.na(ibc_yoy)) |>
  filter(date >= ymd("2003-01-01"))  # início mais estável do regime de metas

# lm() estima o modelo de regressão linear (Ordinary Least Squares — OLS).
# Fórmula: variável_dependente ~ variavel_1 + variavel_2
# summary() exibe os coeficientes, erros padrão e estatísticas do modelo.

m1 <- lm(selic_meta ~ ipca_12m + ibc_yoy, data = dados_modelo)
summary(m1)

# broom::tidy() transforma o resultado do lm() em um tibble organizado,
# facilitando a leitura e exportação dos coeficientes.
# conf.int = TRUE adiciona o intervalo de confiança de 95%.
# Documentação do pacote {broom}: https://broom.tidymodels.org

coef_m1 <- broom::tidy(m1, conf.int = TRUE)
coef_m1
readr::write_csv(coef_m1, "outputs/tables/aula2_regressao_m1_coef.csv")

# Gráfico 3: dispersão Selic x IPCA 12m com reta de regressão
# geom_smooth(method = "lm") adiciona automaticamente a reta OLS com
# a faixa de incerteza (intervalo de confiança) em cinza ao redor dela.

p_dispersao <- ggplot(dados_modelo, aes(x = ipca_12m, y = selic_meta)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title   = "Selic vs Inflação (12m) — regressão simples (2003–2018)",
    x       = "IPCA 12m (%)",
    y       = "Selic meta (% a.a.)",
    caption = "Dispersão + reta OLS. Não implica causalidade."
  ) +
  theme_minimal()

p_dispersao
ggsave("outputs/figs/aula2_selic_vs_ipca_regressao.png",
       p_dispersao, width = 7, height = 5)

# CHECKPOINT (interpretação do modelo):
# - O sinal do coeficiente de ipca_12m é positivo? Isso faz sentido econômico?
#   Dica: compare com o que a Regra de Taylor prevê.
# - Se b ≈ 1,0: +1 p.p. de inflação → +1 p.p. na Selic, na média.
# - O coeficiente de ibc_yoy é positivo? Faz sentido pela lógica Taylor?
#   Ele é estatisticamente significativo (p-valor < 0.05)?

# Extensão (se sobrar tempo): dummies de regime mostram se o BC reagiu
# de forma diferente em cada subperíodo.
m2 <- lm(selic_meta ~ ipca_12m + ibc_yoy + regime, data = dados_modelo)
broom::tidy(m2, conf.int = TRUE)


# ------------------------------------------------------------
# 7) Fechamento: escrever evidência em 3–5 frases
# ------------------------------------------------------------
# TAREFA FINAL (em texto, não em código):
# 1) Escolha 2 regimes da tabela tab_regimes e compare inflacao_media e
#    juro_real_med entre eles. Use números concretos.
# 2) O coeficiente de ipca_12m na regressão é positivo ou negativo?
#    O que isso sugere sobre o comportamento do BC em relação à Regra de Taylor?
# 3) Cite pelo menos 1 ano específico em que inflação e Selic subiram juntas
#    (use o gráfico p_inflacao_selic como referência).
