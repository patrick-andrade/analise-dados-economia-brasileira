# ============================================================
# Economia brasileira: análise de dados (Laboratório)
# PARTE 1 — Estabilização econômica e regime monetário
#
# AULA 2 (2h): Dinâmica macro integrada
# Tema: Inflação (IPCA), juros (Selic) e atividade (IBC-Br) — 1999–2025
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

# Se você já instalou na Aula 1, não precisa rodar o install de novo
# Apenas o library() precisa rodar toda vez que abrir o R.
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

ipca  <- rbcb::get_series(c(ipca_mensal = 433),   start_date = "1999-01-01", end_date = "2025-12-31")
ibc   <- rbcb::get_series(c(ibc_br = 24363), start_date = "1999-01-01", end_date = "2025-12-31")

# NOTA TÉCNICA — por que não usamos rbcb::get_series() para a Selic?
# O comando abaixo é a forma "natural" de baixar a série 432 (Selic meta):
# selic <- rbcb::get_series(c(selic_meta = 432),
#                              start_date = "2003-01-01", end_date = "2025-12-31")
#
# Em certas versões do rbcb / ambientes de rede, o SGS retorna HTTP 406
# (Not Acceptable) porque o pacote envia headers incompatíveis com o servidor.
# Para não travar a aula nesse detalhe técnico, usamos o CSV exportado
# diretamente do SGS como workaround.
#
# ANTES DE RODAR: baixe o CSV da série 432 em:
#   https://www3.bcb.gov.br/sgspub/
#   → pesquise "432" → clique na série "Taxa de juros - Selic" → Exportar → CSV
#   Salve como:  data/raw/selic_meta.csv

# Etapa 1: leitura do arquivo bruto
selic <- readr::read_csv2("data/raw/aula2_selic_meta.csv",
                           skip = 1, col_names = c("date", "selic_meta"),
                           show_col_types = FALSE)

glimpse(selic) # date é <chr> "DD/MM/YYYY" e selic_meta é <chr> "45,00" — precisam de ajuste

# Etapa 2: adequação dos tipos (mesma lógica aplicada a ipca e ibc)
# - dmy() converte "DD/MM/YYYY" → Date
# - gsub() troca a vírgula decimal por ponto antes de as.numeric()
# - filter() recorta o período de interesse
selic_1 <- selic |>
  mutate(date       = lubridate::dmy(date),
         selic_meta = as.numeric(gsub(",", ".", selic_meta))) |>
  filter(date >= as.Date("2003-01-01"), date <= as.Date("2025-12-31"))

glimpse(selic_1) # já com tipos corretos — mas ainda diária (note o nrow)

# Etapa 3: agregação para frequência mensal
# Problema: selic_1 tem ~5.500 linhas (uma por dia útil), enquanto ipca e ibc
# têm ~240 linhas (uma por mês). Um join direto por "date" não casaria as datas.
#
# Solução: truncar a data para o 1º dia do mês com floor_date() e depois
# resumir os dias de cada mês em uma única linha.
#
# Por que last() e não mean()?
# A Selic meta é uma taxa de política — ela não oscila diariamente como
# preços de mercado. O valor ao final do mês representa a decisão vigente
# do COPOM naquele período, o que é mais adequado para comparar com o IPCA
# e o IBC-Br, que também são medidas de fim/fechamento de mês.
# Passo 1 — mutate() + floor_date()
#   floor_date(..., "month") "arredonda para baixo" qualquer data até o
#   1º dia do mês (ex.: 2015-03-25 → 2015-03-01).
#   Isso cria um "rótulo de mês" idêntico para todos os dias do mesmo mês,
#   permitindo agrupá-los na próxima etapa.
#   ATENÇÃO: floor_date NÃO escolhe o último dia — ele sempre vai para o
#   primeiro. A data resultante (2015-03-01) é apenas um identificador do mês.
# O floor_date só criou um "rótulo comum" para os dias do mesmo mês, mas ainda temos várias linhas por mês. O próximo passo é agrupar essas linhas para poder resumir a série mensal.
#
# Passo 2 — group_by(date)
#   Após o mutate, todas as linhas que pertenciam ao mesmo mês agora têm
#   exatamente a mesma data (o 1º do mês). group_by() agrupa essas linhas que ganharam o mesmo rótulo.
#
# Passo 3 — summarise() + last()
#   Para cada grupo (= cada mês), last() retorna o ÚLTIMO valor de selic_meta
#   dentro daquele grupo — ou seja, a taxa vigente no último dia com registro
#   naquele mês, que corresponde à decisão mais recente do COPOM no período.
#   Resultado: uma única linha por mês com a taxa de fechamento do mês.
#
# Resumindo o truque: floor_date agrupa os dias pelo mês; last() escolhe o
# valor do último dia dentro do grupo. A data final (1º do mês) é apenas
# o rótulo do período — não representa o dia em que a taxa foi observada.
selic_meta <- selic_1 |>
  mutate(date = lubridate::floor_date(date, "month")) |>
  group_by(date) |>
  summarise(selic_meta = last(selic_meta), .groups = "drop")

glimpse(selic_meta) # agora mensal — nrow compatível com ipca e ibc

# Verificando o resultado (sempre bom conferir)
glimpse(ipca)
glimpse(selic_meta)
glimpse(ibc)

# Salvando os dados brutos localmente (boa prática)
readr::write_csv(ipca,  "data/raw/ipca_mensal_1999_2025.csv")
readr::write_csv(selic_meta, "data/raw/selic_meta_2003_2025.csv")
readr::write_csv(ibc,   "data/raw/ibc_br_1999_2025.csv")

# ------------------------------------------------------------
# 1.2) Juntando as três séries em uma única tabela
# ------------------------------------------------------------

macro <- ipca |>
  left_join(selic_meta, by = "date") |>
  left_join(ibc,        by = "date") |>
  arrange(date)   # garante a ordem cronológica

# left_join() une duas tabelas usando uma coluna-chave (aqui: "date").
# O "left" significa: mantemos todas as linhas da tabela da esquerda (ipca)
# e buscamos os valores correspondentes nas tabelas da direita.
# Resultado: uma linha por mês, com as três séries lado a lado.
#
# Atenção: as séries têm coberturas temporais diferentes neste notebook:
#   ipca      → 1999–2025 (tabela da esquerda — âncora do join)
#   ibc_br    → 1999–2025 no download, mas o IBC-Br só existe a partir de 2003
#   selic_meta → filtrada para 2003–2025 na etapa de limpeza (selic_1)
#
# Por isso, o left_join() com ipca como tabela da esquerda preserva todas as
# datas de 1999 a 2025, mas os meses de 1999–2002 ficarão com NA nas colunas
# selic_meta e ibc_yoy — o que é o comportamento correto e esperado.
# Esses NAs são tratados depois com filter(!is.na(...)) nas seções 5 e 6.
#
#   left_join()  → mantém APENAS as datas presentes na tabela da esquerda (ipca).
#                  Datas presentes só em selic_meta ou ibc seriam descartadas,
#                  mas isso não ocorre aqui pois ambas cobrem subconjuntos de ipca.
#
#   full_join()  → mantém TODAS as datas de todas as tabelas.
#                  Onde falta valor, preenche com NA.
#                  Alternativa mais segura se houvesse datas em selic/ibc
#                  fora do intervalo de ipca.
#
# Regra prática:
#   - A série mais longa (ou âncora do período de análise) deve ser a
#     tabela da esquerda no left_join().
#   - Séries com recortes que extrapolam a tabela esquerda → use full_join()
#     para não perder datas sem perceber.
#
# ------------------------------------------------------------
# 2) Transformações macroeconômicas
# ------------------------------------------------------------
# 
# ····························································
# 2.1) IPCA acumulado em 12 meses (%)
# ····························································
# Por que 12 meses? O Banco Central e o mercado acompanham a inflação
# acumulada em 12 meses para avaliar se estamos convergindo para a meta
# anual. A variação mensal isolada tem muito "ruído".
#
# Por que taxa composta e não soma simples?
# Somar as variações mensais (ex.: 0,5 + 0,3 + ... ao longo de 12 meses)
# superestima levemente a inflação acumulada. O problema é que somar ignora
# o efeito de "juros sobre juros": se um bem custa R$100 e sobe 1% no mês 1,
# ele passa a custar R$101 — e o 1% do mês 2 incide sobre R$101, não sobre R$100.
#
# O cálculo correto converte cada variação mensal em um "fator de crescimento"
# e multiplica todos eles em sequência:
#
#   Passo 1 — converter % em fator:
#     Uma inflação de 0,5% ao mês equivale a multiplicar o preço por 1,005
#     (ou seja: 1 + 0,5/100). O "1" representa o valor original; o "0,005"
#     representa o acréscimo.
#
#   Passo 2 — encadear os 12 meses:
#     fator_acumulado = (1 + r1/100) × (1 + r2/100) × ... × (1 + r12/100)
#     Isso é o equivalente a aplicar cada mês de inflação sobre o resultado
#     do mês anterior — exatamente como funciona na realidade.
#
#   Passo 3 — converter de volta para %:
#     ipca_12m = (fator_acumulado − 1) × 100
#     Subtraímos 1 para eliminar o "valor original" e ficamos só com o
#     crescimento líquido; multiplicamos por 100 para expressar em percentual.
#
# Exemplo numérico simplificado (3 meses de 2%):
#   Soma simples:   2 + 2 + 2 = 6,00%  ← incorreto
#   Taxa composta:  (1,02 × 1,02 × 1,02 − 1) × 100 = 6,12%  ← correto
#
# Para fazer isso em janelas móveis de 12 meses usamos slide_dbl() do
# pacote {slider}. Uma "janela móvel" (rolling window) percorre a série
# mês a mês, calculando sempre sobre os 12 meses mais recentes — como
# se você "deslizasse" uma régua de 12 posições ao longo da série.
#
# Referência conceitual:
#   IBGE. O que é inflação? (página explicativa oficial).
#   O IBGE é o responsável pelo cálculo e divulgação do IPCA; o BCB replica
#   o índice em seus relatórios, mas a metodologia é do IBGE.
#   Acesso: https://www.ibge.gov.br/explica/inflacao.php
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

# Por que prod() e não sum()?
# Inflação compõe: preços sobem sobre preços que já subiram.
# Somar as taxas mensais ignoraria esse efeito e subestimaria o acumulado.
# Ao converter cada taxa em fator (1 + t/100), multiplicá-los e depois
# subtrair 1, capturamos exatamente essa acumulação composta.
#
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
#   Fisher, I. (1930). The Theory of Interest.
#   (A equação de Fisher é apresentada em qualquer manual de macroeconomia;
#    ver p. ex. Blanchard, O. Macroeconomia. 7ª ed., cap. 14)
#
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
# Usamos meta_inflacao_aprox = 3% como simplificação pedagógica.
# Na realidade, a meta variou ao longo do período (ex.: 3,25% em 2017).
# Consulte o histórico em: https://www.bcb.gov.br/monetariainflacao/metas

macro <- macro |>
  mutate(
    meta_inflacao_aprox = 3,
    inflacao_gap = ipca_12m - meta_inflacao_aprox
  )

# ------------------------------------------------------------
# 3) Gráfico 1: IPCA 12m x Selic (séries sobrepostas)
# ------------------------------------------------------------
# IPCA 12m e Selic estão em unidades comparáveis (ambas em % a.a.) e o
# Brasil historicamente manteve a Selic acima do IPCA (juro real positivo).
# Um painel único com as duas linhas preserva a comparação direta de nível
# e permite ver quando a Selic reage às oscilações da inflação.

p_inflacao_selic <- ggplot(macro, aes(x = date)) +
  geom_line(aes(y = ipca_12m,   color = "IPCA (12m, %)"),        linewidth = 0.8) +
  geom_line(aes(y = selic_meta, color = "Selic meta (% a.a.)"), linewidth = 0.8) +
  scale_color_manual(values = c("IPCA (12m, %)"        = "steelblue",
                                "Selic meta (% a.a.)" = "firebrick")) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  scale_y_continuous(labels = scales::label_number(suffix = "%"), breaks = seq(0, 60, by = 2)) +
  labs(
    title    = "Inflação (IPCA 12m) e Selic — Brasil, 2003–2025",
    subtitle = "Selic historicamente acima do IPCA: juro real positivo é a norma no Brasil",
    x        = NULL,
    y        = "Taxa (% a.a.)",
    color    = NULL,
    caption  = "Fonte: BCB/SGS via rbcb. IPCA 12m calculado por taxa composta mensal."
  ) +
  theme_classic(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold", size = 14),
    plot.subtitle    = element_text(color = "grey40", size = 11),
    plot.caption     = element_text(color = "grey50", size = 9),
    legend.position  = "bottom",
    axis.text.x      = element_text(angle = 90, hjust = 1)
  )

p_inflacao_selic
ggsave("outputs/figs/aula2_ipca12m_selic_1999_2025.png",
       p_inflacao_selic, width = 8, height = 6)


# ------------------------------------------------------------
# 4) Gráfico 2: Selic real ex-post (aproximação)
# ------------------------------------------------------------
# geom_hline() adiciona uma linha horizontal de referência.
# Aqui a linha em yintercept = 0 é o limite: abaixo dela, o juro real é negativo.

p_selic_real <- ggplot(macro, aes(x = date, y = selic_real_expost)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_line(linewidth = 0.8) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year",
               limits = c(as.Date("2003-01-01"), as.Date("2025-12-31"))) +
  scale_y_continuous(labels = scales::label_number(suffix = "%"), breaks = seq(-20, 30, by = 2)) +
  labs(
    title    = "Juro real ex-post (Selic − IPCA 12m) — Brasil, 2003–2025",
    subtitle = "Aproximação pela diferença de taxas anuais; linha vermelha = juro real zero",
    x        = NULL,
    y        = "p.p.",
    caption  = "Fonte: BCB/SGS via rbcb. Medida ex-post e aproximada."
  ) +
  theme_classic(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "grey40", size = 11),
    plot.caption  = element_text(color = "grey50", size = 9),
    axis.text.x   = element_text(angle = 90, hjust = 1)
  )

p_selic_real
ggsave("outputs/figs/aula2_selic_real_expost_1999_2025.png",
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
# Bogdanski, J., Tombini, A., & Werlang, S.R. (2000).
# "Implementing Inflation Targeting in Brazil."
# BCB Working Paper No. 1.
# Acesso: https://www.bcb.gov.br/pec/wps/ingl/wps01.pdf
# (Artigo fundacional que descreve a implantação do regime de metas no Brasil)
#
# Mishkin, F.S. (2000). "Inflation Targeting in Emerging-Market Countries."
# American Economic Review, 90(2), 105–109.
# Acesso: https://www.nber.org/system/files/working_papers/w7618/w7618.pdf
# (Contexto internacional do regime de metas para países emergentes)

macro <- macro |>
  mutate(
    regime = case_when(
      date < ymd("2003-01-01") ~ "1999–2002: transição/credibilidade",
      date < ymd("2011-01-01") ~ "2003–2010: metas consolidadas",
      date < ymd("2015-01-01") ~ "2011–2014: juros em queda/expansão",
      date < ymd("2020-01-01") ~ "2015–2019: ajuste/desinflação",
      date < ymd("2022-01-01") ~ "2020–2021: pandemia COVID-19",
      TRUE                     ~ "2022–2025: pós-pandemia/ajuste"
    )
  )

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
#
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
# - Compare inflacao_media com a meta de inflação: em quais regimes o BC ficou
#   consistentemente acima ou abaixo da meta?
# - O regime pandemia (2020–21) se destaca em qual variável? E o pós-pandemia?
# NOTA: a meta de inflação variou ao longo do período — 4,5% de 2005 a 2018,
# depois foi sendo reduzida gradualmente: 4,25% (2019), 4,0% (2020), 3,75% (2021),
# 3,5% (2022), 3,25% (2023), 3,0% a partir de 2024.
# Consulte o histórico completo em: https://www.bcb.gov.br/controleinflacao/historicometas
# meta_inflacao_aprox = 3% é usada como simplificação pedagógica para todo o período.


# ------------------------------------------------------------
# 6) Regressão simples: uma "Taylor" didática
# ------------------------------------------------------------
# A Regra de Taylor (1993) descreve como os bancos centrais tendem a
# ajustar a taxa de juros em resposta à inflação e ao hiato do produto.
# Na versão original:
#
#   i_t = r* + π* + α(π_t − π*) + β(y_t − y*)
#
# Em que:
# i = taxa de juros,
# r* = juro natural,
# π* = meta de inflação,
# (π − π*) = desvio da inflação em relação à meta,
# (y − y*) = hiato do produto (atividade acima/abaixo do potencial).
#
# Referência original:
#   Taylor, J.B. (1993). "Discretion versus policy rules in practice."
#   Carnegie-Rochester Conference Series on Public Policy, 39, 195–214.
#   Acesso: https://doi.org/10.1016/0167-2231(93)90009-L
#
# Modelo estimado aqui (versão simplificada e didática):
#   Selic_t = a + b × IPCA12m_t + c × CrescimentoIBC_t + erro_t
#
# ATENÇÃO — Avisos importantes:
# 1) NÃO se pretende provar causalidade. Trata-se de uma regressão descritiva.
# 2) Há endogeneidade: a Selic afeta a inflação futura, e a inflação
#    afeta a Selic atual — as variáveis se influenciam mutuamente.
# 3) Objetivo aqui é ler os coeficientes e sinais.

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

# Considerando o resultado do modelo m1, tem-se:
#
# ── Como ler uma tabela OLS ──────────────────────────────────────────────────
# estimate  : o coeficiente estimado — quanto Y varia para +1 unidade em X,
#             mantendo as demais variáveis constantes (ceteris paribus).
# std.error : incerteza em torno do estimate. Quanto menor, mais precisa a estimativa.
# statistic : t = estimate / std.error. Mede em quantos erros-padrão o coeficiente
#             está afastado de zero. Valores |t| > 2 são um sinal informal de
#             significância com amostras grandes.
# p.value   : probabilidade de observar um t tão extremo se o coeficiente fosse
#             zero na população. Convenção usual: p < 0,05 → "estatisticamente
#             significativo" (rejeitamos a hipótese nula de coeficiente = 0).
# conf.low / conf.high : intervalo de confiança de 95%. Se o intervalo não cruzar
#             zero, o coeficiente é significativo ao nível de 5%.
#
# ── Interpretação dos coeficientes ──────────────────────────────────────────
#
# (Intercept) = 6,79 p.p. (p < 0,001)
#   Quando IPCA 12m = 0 e IBC-Br = 0, o modelo prevê Selic ≈ 6,8% a.a.
#   Esse valor pode ser interpretado como uma estimativa implícita da taxa
#   de juros neutra (r*) no período — o patamar de juros na ausência de
#   pressões inflacionárias ou de atividade.
#
# ipca_12m = 0,697 (IC 95%: 0,48 – 0,91; p < 0,001)
#   Cada +1 p.p. no IPCA 12m está associado, em média, a +0,70 p.p. na Selic.
#   O coeficiente é positivo e significativo — coerente com a Regra de Taylor.
#   ATENÇÃO: o "Princípio de Taylor" prevê que esse coeficiente deva ser > 1
#   para que a política monetária seja estabilizadora (juro real sobe quando
#   a inflação sobe). Aqui o coeficiente é < 1, o que sugere que, na média
#   do período 2003–2025, o BC reagiu à inflação, mas não o suficiente para
#   elevar o juro real. Isso pode refletir períodos de dominância fiscal ou
#   afrouxamento deliberado (ex.: 2011–2014 e 2020–2021).
#
# ibc_yoy = 0,170 (IC 95%: 0,06 – 0,28; p = 0,002)
#   Cada +1 p.p. no crescimento do IBC-Br está associado a +0,17 p.p. na Selic.
#   O sinal positivo faz sentido pela lógica Taylor: economia aquecida →
#   BC aperta juros. O coeficiente é menor do que o de inflação, indicando
#   que o BC reage mais à inflação do que à atividade — padrão esperado
#   num regime de metas de inflação.
#
# LEMBRETE: essa regressão é DESCRITIVA. Correlação ≠ causalidade.
#   Há endogeneidade: a Selic afeta inflação e atividade futuras, que por sua
#   vez afetam a Selic atual. OLS não resolve isso — é um ponto de partida.


# Gráfico 3: dispersão Selic x IPCA 12m com reta de regressão
# geom_smooth(method = "lm") adiciona automaticamente a reta OLS com
# a faixa de incerteza (intervalo de confiança) em cinza ao redor dela.

p_dispersao <- ggplot(dados_modelo, aes(x = ipca_12m, y = selic_meta)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title   = "Selic vs Inflação (12m) — regressão simples (2003–2025)",
    x       = "IPCA 12m (%)",
    y       = "Selic meta (% a.a.)",
    caption = "Dispersão + reta OLS. Não implica causalidade."
  ) +
  theme_minimal()

p_dispersao
ggsave("outputs/figs/aula2_selic_vs_ipca_regressao.png",
       p_dispersao, width = 7, height = 5)

# Considerando a dispersão dos pontos e a reta de regressão, tem-se:
# - A nuvem de pontos mostra que, em geral, meses com IPCA 12m mais alto tendem
#   a ter Selic mais alta, o que é consistente com a resposta do BC à inflação.
# - A reta de regressão (linha azul, cor padrão do geom_smooth) tem inclinação
#   positiva, refletindo a relação prevista pela Regra de Taylor.
# - A nuvem apresenta dispersão considerável: a relação não é determinística.
#   Pontos afastados da reta correspondem a períodos em que outros fatores
#   dominaram a decisão do BC — ex.: 2020–2021, quando a Selic foi reduzida
#   a 2% a.a. mesmo com IPCA em alta, por conta do choque pandêmico.


# E se utilizássemos cores para cada regime no gráfico de dispersão?
# A ideia é identificar os momentos acima e abaixo da meta de inflação por regime? A resposta do BC à inflação mudou ao longo dos subperíodos?

p_dispersao_regime <- ggplot(dados_modelo, aes(x = ipca_12m, y = selic_meta, color = regime)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title   = "Selic vs Inflação (12m) por Regime — regressão simples (2003–2025)",
    x       = "IPCA 12m (%)",
    y       = "Selic meta (% a.a.)",
    color   = "Regime",
    caption = "Dispersão + reta OLS por regime. Não implica causalidade."
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")
p_dispersao_regime


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
