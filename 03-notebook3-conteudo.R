# ============================================================
# Economia brasileira: análise de dados (Laboratório)
# PARTE 2 — Setor externo e regime cambial
#
# AULA 3: Câmbio, reservas e o Brasil no cenário global
# Tema: Taxa de câmbio (R$/US$), reservas internacionais,
#        inflação Brasil vs EUA e comparação com emergentes
# Foco: (A) nova fonte de dados (Banco Mundial via wbstats)
#        (B) dados em painel (país × ano) + comparação internacional
# Extra (nível acima): Paridade do Poder de Compra (PPP) —
#        câmbio teórico vs observado
#
# Produto ao final:
# - 4 gráficos: (1) Câmbio + reservas; (2) Volatilidade cambial;
#                (3) Comparação internacional;
#                (4) Câmbio observado vs PPP teórica
# - 1 tabela comparativa de indicadores entre emergentes
# - 3–5 frases interpretativas citando números e anos
# ============================================================
#
# Conexão com as aulas anteriores:
# Aula 1: fundamentos do R e trabalho com o IPCA
# Aula 2: integração de inflação, juros e atividade usando o BCB (rbcb),
# construção de tabelas de regimes e estimação de Regra de Taylor didática.
#
# Nesta aula: ampliacação do escopo:
# - Geográfico: saímos do "Brasil apenas" para "Brasil + emergentes".
# - De fontes: saímos do BCB (rbcb) para o Banco Mundial (wbstats).
# - De estrutura: saímos de séries temporais (data × valor) para
#   dados em painel (país × ano × indicador).
#
# Essas transições são deliberadas: na prática de análise econômica,
# quase sempre precisamos combinar dados domésticos e internacionais.
# ============================================================

setwd("PROJETOS/202601-ANALISE-ECONOMIA-BR") # ajuste para o seu diretório
getwd()

# ------------------------------------------------------------
# 0) Setup (pastas, pacotes, opções)
# ------------------------------------------------------------
dir.create("data/raw",       recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/figs",   recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

# Novos pacotes desta aula:
# - {wbstats}: acessa a API do Banco Mundial (World Development Indicators)
# - {patchwork}: combina múltiplos gráficos ggplot em uma única figura
# - {slider}: janelas móveis — usado via slider:: sem library()
#
# Se necessário, instale UMA vez (rode no console, não no script):
# install.packages(c("tidyverse", "rbcb", "wbstats", "patchwork", "gt", "broom", "slider"))
# {lubridate} faz parte do tidyverse 2.0+ e não precisa de instalação separada.

library(tidyverse)   # dplyr, ggplot2, tidyr, readr, stringr, etc.
library(lubridate)   # trabalhar com datas (parte do tidyverse 2.0+; explícito por clareza)
library(rbcb)        # SGS do Banco Central (câmbio e reservas domésticas)
library(wbstats)     # API do Banco Mundial — NOVIDADE desta aula
library(patchwork)   # combinar gráficos — NOVIDADE desta aula
library(gt)          # tabelas de apresentação (já usamos na Aula 2)
library(broom)       # resultados de modelos em tibble (para a extensão)

options(scipen = 999)


# ============================================================
# PARTE A — Dados domésticos: câmbio e reservas (rbcb)
# ============================================================
# Ainda usamos o rbcb aqui, mas de forma rápida — o objetivo é
# construir o contexto doméstico antes de abrir para a comparação
# internacional com wbstats.

# ------------------------------------------------------------
# 1) Baixar câmbio e reservas do SGS/BCB
# ------------------------------------------------------------
# Códigos SGS:
# 3698  → Taxa de câmbio comercial (R$/US$) — média mensal
# 3546  → Reservas internacionais (US$ milhões) — posição final do mês
#
# Estas séries complementam as que usamos na Aula 2 (IPCA 433, Selic 432,
# IBC-Br 24363). A lógica de download é idêntica.

cambio   <- rbcb::get_series(c(cambio_brl = 3698),
                              start_date = "1999-01-01",
                              end_date   = "2025-12-31")

reservas <- rbcb::get_series(c(reservas_usd = 3546),
                              start_date = "1999-01-01",
                              end_date   = "2025-12-31")

glimpse(cambio)
glimpse(reservas)

# Salvando localmente (mesma boa prática da Aula 2)
readr::write_csv(cambio,   "data/raw/cambio_brl_1999_2025.csv")
readr::write_csv(reservas, "data/raw/reservas_usd_1999_2025.csv")

# Juntar as duas séries por data
setor_externo <- cambio |>
  left_join(reservas, by = "date") |>
  arrange(date)

glimpse(setor_externo)


# ------------------------------------------------------------
# 2) Gráfico 1: Câmbio e Reservas — dois painéis
# ------------------------------------------------------------
# Usamos {patchwork} para combinar dois gráficos lado a lado (ou empilhados).
# Diferente da Aula 2, em que IPCA e Selic foram sobrepostos no mesmo painel
# por estarem em unidades comparáveis (% a.a.), aqui câmbio (R$/US$) e reservas
# (US$ bi) têm unidades muito diferentes, então painéis separados ficam mais legíveis.
# Já o facet_wrap(), usado mais adiante nesta própria aula na comparação entre
# países, funciona bem quando queremos repetir a mesma estrutura de gráfico
# para vários grupos.
#
# Documentação do {patchwork}: https://patchwork.data-imaginist.com
# Operadores:
#   p1 + p2    → lado a lado
#   p1 / p2    → empilhados (um sobre o outro)
#   (p1 + p2) / p3 → combinações mais complexas

p_cambio <- ggplot(setor_externo, aes(x = date, y = cambio_brl)) +
  geom_line(color = "steelblue", linewidth = 0.7) +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  labs(
    title = "Taxa de câmbio (R$/US$)",
    x     = NULL,
    y     = "R$/US$"
  ) +
  theme_linedraw(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

p_cambio

p_reservas <- ggplot(setor_externo, aes(x = date, y = reservas_usd / 1000)) +
  geom_line(color = "darkgreen", linewidth = 0.7) +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  labs(
    title = "Reservas internacionais",
    x     = NULL,
    y     = "US$ bilhões"
  ) +
  theme_linedraw(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

p_reservas

# {patchwork}: o operador "/" empilha os gráficos verticalmente
p_setor_externo <- p_cambio / p_reservas +
  plot_annotation(
    title   = "Câmbio e reservas internacionais — Brasil, 1999–2025",
    caption = "Fonte: BCB/SGS via rbcb. Reservas em posição de fim de mês."
  )

p_setor_externo
ggsave("outputs/figs/aula3_cambio_reservas_1999_2025.png",
       p_setor_externo, width = 9, height = 7)


# ------------------------------------------------------------
# 2.1) Gráfico extra: volatilidade cambial com janela móvel
# ------------------------------------------------------------
# O gráfico em nível mostra a tendência do câmbio, mas não separa bem
# tendência e turbulência. Para enxergar volatilidade, olhamos para as
# variações mensais do log do câmbio e resumimos essas oscilações pelo
# desvio-padrão móvel de 12 meses.
#
# Por que utilizar log para calcular variações?
# Lembrete matemático: o log transforma multiplicações em somas.
# Isso é útil porque muitas variáveis econômicas mudam de forma
# proporcional, e não em incrementos absolutos fixos.
#
# Exemplo:
# - se o câmbio vai de 2 para 3, a alta é de 50%;
# - se vai de 4 para 5, a alta é de 25%.
# Em ambos os casos, a diferença em nível é "1", mas a intensidade
# econômica da variação é diferente. O log ajuda a capturar essa
# ideia de mudança relativa.
#
# A propriedade central é:
# log(x_t) - log(x_{t-1}) = log(x_t / x_{t-1})
#
# Ou seja: a diferença entre logs é o log da razão entre dois períodos.
# Quando a variação é pequena, essa diferença aproxima muito bem a
# taxa de crescimento percentual. Por isso, em macroeconomia e finanças:
# diff(log(x)) ≈ variação percentual de x
#
# Aqui usamos essa transformação para medir a oscilação mensal do câmbio
# em termos comparáveis ao longo do tempo, e depois calculamos uma
# volatilidade móvel com base nessas variações.
# Interpretação:
# - valores mais altos = câmbio oscilando mais no período recente;
# - valores mais baixos = câmbio relativamente mais estável.

setor_externo <- setor_externo |>
  mutate(
    cambio_log = log(cambio_brl),
    cambio_ret_log = (cambio_log - lag(cambio_log)) * 100,
    vol_cambio_12m = slider::slide_dbl(
      cambio_ret_log,
      .f = ~ sd(.x, na.rm = TRUE),
      .before = 11,
      .complete = TRUE
    )
  )

p_vol_cambio <- ggplot(
  setor_externo |> filter(!is.na(vol_cambio_12m)),
  aes(x = date, y = vol_cambio_12m)
) +
  geom_line(color = "firebrick", linewidth = 0.7) +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  labs(
    title = "Volatilidade cambial móvel (12 meses)",
    subtitle = "Desvio-padrão das variações mensais do log da taxa de câmbio",
    x = NULL,
    y = "Desvio-padrão dos retornos (%)",
    caption = "Fonte: BCB/SGS via rbcb. Retornos calculados como diff(log(câmbio)) × 100."
  ) +
  theme_linedraw(base_size = 12) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

p_vol_cambio

# Por que o eixo Y está em "Desvio-padrão dos retornos (%)"?
# Porque a volatilidade foi calculada a partir das variações mensais de
# diff(log(câmbio)) × 100, que aproximam a taxa percentual de mudança do
# câmbio de um mês para o outro. Por isso, o eixo Y também fica em termos
# percentuais aproximados.
#
# Intuição econômica:
# o gráfico não mostra o nível do câmbio, mas o quanto ele costuma oscilar
# de um mês para o outro. Assim, ele resume a "intensidade típica" dessas
# oscilações no período recente.
#
# Significado estatístico:
# o desvio-padrão mede o grau de dispersão das variações mensais em torno
# da sua média. Se os valores mensais ficam próximos uns dos outros, o
# desvio-padrão é baixo; se eles se afastam bastante, o desvio-padrão é alto.
# Aqui, calculamos esse desvio-padrão usando uma janela móvel de 12 meses.
#
# Exemplo de leitura:
# - se o valor no eixo Y for 5, isso significa que, nos últimos 12 meses,
#   as variações mensais do câmbio oscilaram com intensidade típica de cerca
#   de 5%;
# - quanto maior esse número, maior foi a instabilidade cambial no período
#   recente;
# - picos no gráfico indicam episódios em que o câmbio ficou especialmente
#   turbulento.



p_vol_cambio
ggsave("outputs/figs/aula3_volatilidade_cambial_12m.png",
       p_vol_cambio, width = 9, height = 4.5)


# CHECKPOINT:
# - Identifique os picos de câmbio: 2002, 2015, 2020. O que aconteceu?
#   (Dica: crise de confiança eleitoral, recessão, pandemia)
# - As reservas crescem de forma quase contínua entre 2003 e 2012. Por quê?
#   (Dica: boom de commodities, superávit comercial, acumulação deliberada pelo BCB)
# - Após 2012, as reservas se estabilizam em torno de US$ 350–380 bi.
#   O que isso sugere sobre a estratégia cambial do BCB?
# - Compare o gráfico em nível com o gráfico de volatilidade móvel.
#   Em quais episódios a turbulência cambial realmente se concentra?
#
# Conexão com a Aula 2:
# A tabela de regimes que construímos na Aula 2 ajuda a interpretar
# este gráfico. Os regimes "1999–2002: transição/credibilidade" e
# "2003–2010: metas consolidadas" se conectam, respectivamente, a uma fase
# de instabilidade cambial mais aguda e a outra de acumulação de reservas
# com tendência de apreciação do real. Se quisermos isolar volatilidade
# cambial propriamente dita, o gráfico de janela móvel logo acima é a
# ferramenta mais adequada do que o gráfico em nível.


# ============================================================
# PARTE B — Dados internacionais: Banco Mundial (wbstats)
# ============================================================
# A partir daqui, entramos em um novo território.
# O pacote {wbstats} acessa a API do Banco Mundial, que tem milhares
# de indicadores para todos os países do mundo.
#
# A lógica é diferente do rbcb:
# - No rbcb: você sabe o código da série (ex: 433) e baixa direto.
# - No wbstats: você BUSCA indicadores por palavra-chave (wb_search),
#   depois baixa os dados com wb_data().
#
# Referência oficial:
#   World Bank Open Data: https://data.worldbank.org
#   Documentação da API: https://datahelpdesk.worldbank.org
#   Pacote wbstats: https://github.com/pachadotdev/wbstats

# ------------------------------------------------------------
# 3) Aprendendo a buscar indicadores: wb_search()
# ------------------------------------------------------------
# wb_search() faz uma busca textual (estilo grep) no catálogo de
# indicadores do Banco Mundial. Retorna um tibble com:
#   indicator_id : código do indicador (o que usamos no wb_data)
#   indicator    : nome legível
#   indicator_desc : descrição completa

# Exemplo: buscar indicadores relacionados a câmbio
wb_search("exchange rate") |> head(10)

# Exemplo: buscar indicadores de reservas
wb_search("reserves") |> head(10)

# Exemplo: buscar indicadores de inflação (CPI)
wb_search("consumer price|CPI|inflation") |> head(10)

# Dica: a busca é em inglês (a base do Banco Mundial é em inglês).
# O resultado mostra centenas de indicadores — o desafio é escolher o certo.
# Por isso, é útil já ter o código em mãos ou consultar:
#   https://data.worldbank.org/indicator
#
# CHECKPOINT:
# Rode wb_search("current account") e identifique o indicador de
# conta corrente como % do PIB. Qual é o código?
# (Resposta esperada: BN.CAB.XOKA.GD.ZS)


# ------------------------------------------------------------
# 4) Baixando dados do Banco Mundial: wb_data()
# ------------------------------------------------------------
# wb_data() é a função principal. Ela aceita:
#   indicator    = vetor nomeado c(nome_coluna = "codigo_indicador")
#   country      = vetor de códigos ISO (ex: c("BR", "MX", "TR"))
#   start_date   = ano inicial (numérico, ex: )
#   end_date     = ano final
#
# IMPORTANTE: o Banco Mundial trabalha com dados ANUAIS.
# Na Aula 2, trabalhamos com dados mensais do BCB. Agora estamos
# em frequência anual — cada linha é um país-ano.
#
# Vamos definir os países de comparação.
# A escolha não é aleatória: são economias emergentes de grande porte
# que compartilham desafios similares ao Brasil (inflação alta no passado,
# dependência de commodities, vulnerabilidade a choques externos).

paises <- c("BR", "MX", "TR", "ZA", "IN", "CL")
# BR = Brasil, MX = México, TR = Turquia, ZA = África do Sul,
# IN = Índia, CL = Chile

# Vamos baixar 4 indicadores de uma vez.
# A sintaxe c(nome = "codigo") é análoga ao que usamos no rbcb:
# c(ipca_mensal = 433) → c(reservas_pib = "FI.RES.TOTL.DT.ZS")
#
# Indicadores escolhidos:
# PA.NUS.FCRF    → Taxa de câmbio oficial (moeda local por US$, média do período)
# FP.CPI.TOTL.ZG → Inflação ao consumidor (CPI, % anual)
# BN.CAB.XOKA.GD.ZS → Conta corrente (% do PIB)
# FI.RES.TOTL.DT.ZS → Reservas totais (meses de importação)

indicadores_wb <- c(
  cambio_oficial  = "PA.NUS.FCRF",
  inflacao_cpi    = "FP.CPI.TOTL.ZG",
  conta_corrente  = "BN.CAB.XOKA.GD.ZS",
  reservas_meses  = "FI.RES.TOTL.DT.ZS"
)

wb_raw <- wb_data(
  indicator  = indicadores_wb,
  country    = paises,
  start_date = 1995,
  end_date   = 2023
)

glimpse(wb_raw)

# O que wb_data() retorna?
# Um tibble em formato "wide" (uma coluna por indicador), com colunas:
#   iso2c, iso3c  → códigos do país
#   country       → nome do país
#   date          → ano (numérico)
#  a coluna para cada indicador (com o nome que demos)
#
# Comparando com o rbcb:
#   rbcb → retorna data (Date) + valor. Dados mensais, 1 série por vez.
#   wbstats → retorna país + ano + N indicadores. Dados anuais, multi-país.
#
# Essa diferença de estrutura é fundamental:
# no rbcb, o "unit of observation" é mês;
# no wbstats, o "unit of observation" é país-ano.

# Salvar localmente
readr::write_csv(wb_raw, "data/raw/wb_emergentes_1995_2023.csv")


# ------------------------------------------------------------
# 5) Limpeza e exploração dos dados do Banco Mundial
# ------------------------------------------------------------
# Vamos selecionar apenas as colunas que interessam e padronizar.

wb_clean <- wb_raw |>
  select(iso3c, country, date, cambio_oficial, inflacao_cpi,
         conta_corrente, reservas_meses) |>
  arrange(iso3c, date)

# Verificando cobertura: quantos anos por país?
wb_clean |>
  group_by(country) |>
  summarise(
    anos       = n(),
    anos_com_cambio = sum(!is.na(cambio_oficial)),
    anos_com_cpi    = sum(!is.na(inflacao_cpi)),
    .groups = "drop"
  )

# Em dados do Banco Mundial, é comum ter NAs nos anos mais recentes
# (os dados são publicados com defasagem) e nos mais antigos para
# alguns países. Isso é normal — não é erro.
#
# Diferença em relação ao rbcb: no BCB, os dados do Brasil são quase
# sempre completos. No Banco Mundial, a cobertura varia por país e indicador.
# Lidar com essa irregularidade faz parte do trabalho com dados internacionais.


# ------------------------------------------------------------
# 6) Gráfico 2: Comparação de inflação entre emergentes
# ------------------------------------------------------------
# Usamos facet_wrap() para criar um painel por país — mesma técnica
# da Aula 2, mas agora com 6 países em vez de 2 séries.
#
# filter(!is.na(inflacao_cpi)) remove os anos sem dado, evitando
# que geom_line() "conecte" pontos separados por anos faltantes.

p_inflacao_comp <- ggplot(
  wb_clean |> filter(!is.na(inflacao_cpi)),
  aes(x = date, y = inflacao_cpi)
) +
  geom_line(color = "steelblue", linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  facet_wrap(~ country, ncol = 2, scales = "free_y") +
  scale_x_continuous(breaks = seq(1995, 2023, by = 5)) +
  labs(
    title    = "Inflação ao consumidor (CPI, % a.a.) — emergentes selecionados",
    subtitle = "Dados anuais do Banco Mundial (WDI)",
    x        = NULL,
    y        = "Inflação (% a.a.)",
    caption  = "Fonte: World Bank, World Development Indicators via wbstats."
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "grey40", size = 10),
    strip.text    = element_text(face = "bold")
  )

p_inflacao_comp

# Caso queira salvar a figura:
# ggsave("outputs/figs/aula3_inflacao_emergentes_1995_2023.png",
#       p_inflacao_comp, width = 10, height = 7)

# Observe que a escala do eixo Y é "free_y" — isso significa que cada painel tem sua própria escala.
# Isso é útil para comparar a dinâmica de inflação dentro de cada país,
# mas torna difícil comparar os níveis absolutos entre países.
# Por exemplo, o Chile tem uma escala Y que vai até 10%, enquanto a Turquia tem uma escala que chega a 100%.
# Isso reflete as diferenças de magnitude da inflação entre os países,
# mas pode dificultar a comparação direta dos níveis de inflação.


# CHECKPOINT:
# - Qual país tem o histórico de inflação mais parecido com o do Brasil?
# - A Turquia (Turkey) se destaca em algum período? O que aconteceu?
#   (Dica: hiperinflação nos anos 90, crise cambial em 2001, e novo surto
#    inflacionário a partir de 2018 ligado à política monetária heterodoxa)
# - O Chile tem inflação consistentemente mais baixa que o Brasil?
#   O que isso sugere sobre a condução da política monetária chilena?


# ------------------------------------------------------------
# 7) Tabela comparativa por país (média do período)
# ------------------------------------------------------------
# Vamos construir uma tabela que resume os 4 indicadores para cada país,
# calculando a média do período. Isso permite uma comparação "a olho"
# rápida entre os emergentes.
#
# Dividimos em dois subperíodos para capturar mudanças estruturais:
# 1995–2002 (período de crises e transição) e 2003–2023 (consolidação).

tab_comparativo <- wb_clean |>
  mutate(
    subperiodo = case_when(
      date <= 2002 ~ "1995–2002",
      TRUE         ~ "2003–2023"
    )
  ) |>
  group_by(country, subperiodo) |>
  summarise(
    inflacao_media    = mean(inflacao_cpi, na.rm = TRUE),
    conta_corr_media  = mean(conta_corrente, na.rm = TRUE),
    reservas_media    = mean(reservas_meses, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(subperiodo, country)

tab_comparativo

# O comando .groups = "drop" é importante para evitar mensagens de agrupamento
# (do contrário o resultado ficaria agrupado por subperiodo, o que pode causar confusão em operações futuras).
# Os valores negativos tiveram a saída do console em vermelho no RStudio.
# Essa formatação visual é uma convenção do RStudio para destacar valores negativos.


# Formatando com {gt} (mesma técnica da Aula 2)
tab_comparativo_gt <- tab_comparativo |>
  gt(groupname_col = "subperiodo") |>
  tab_header(
    title    = "Indicadores macroeconômicos — emergentes selecionados",
    subtitle = "Médias por subperíodo | Fonte: Banco Mundial (WDI)"
  ) |>
  cols_label(
    country          = "País",
    inflacao_media   = "Inflação (% a.a.)",
    conta_corr_media = "Conta corrente (% PIB)",
    reservas_media   = "Reservas (meses import.)"
  ) |>
  fmt_number(
    columns  = c(inflacao_media, conta_corr_media, reservas_media),
    decimals = 1
  )

tab_comparativo_gt
gtsave(tab_comparativo_gt, "outputs/figs/aula3_tab_comparativo_emergentes.png")
readr::write_csv(tab_comparativo, "outputs/tables/aula3_comparativo_emergentes.csv")

# A tabela de saída retornou que o valor de Reservas do Chile é NaN.
# Isso ocorre porque o Chile não tem dados disponíveis para o indicador de reservas em meses de importação (FI.RES.TOTL.DT.ZS)
# no período considerado.

# CHECKPOINT:
# - Compare as reservas (meses de importação) do Brasil nos dois subperíodos.
#   A mudança é grande? Isso reflete a acumulação que vimos no gráfico 1.
# - Qual país tem a pior posição de conta corrente na média 2003–2023?
# - A Turquia tem reservas comparáveis às do Brasil? O que isso implica
#   sobre vulnerabilidade a choques externos?


# ============================================================
# PARTE C — Economia aplicada: Paridade do Poder de Compra (PPP)
# ============================================================
# Na Aula 2, aplicamos a Regra de Taylor como modelo descritivo
# para a relação entre inflação e juros. Aqui, aplicamos outro
# conceito clássico de macroeconomia internacional:
# a Paridade do Poder de Compra (PPP, Purchasing Power Parity).
#
# A ideia central:
# Se dois países vendem os mesmos bens, a taxa de câmbio deveria
# ajustar-se para igualar os preços. Se a inflação no Brasil é maior
# que nos EUA, o real deveria se depreciar proporcionalmente.
#
# Fórmula da PPP relativa:
#   E_t = E_0 × (P_BR_t / P_BR_0) / (P_EUA_t / P_EUA_0)
#
# Em que:
#   E_t   = câmbio teórico (PPP) no período t
#   E_0   = câmbio no período base (aqui: 1999)
#   P_BR  = nível de preços do Brasil (índice CPI)
#   P_EUA = nível de preços dos EUA (índice CPI)
#
# A intuição é simples: se os preços no Brasil dobraram e nos EUA
# subiram 30%, o real deveria ter se depreciado na proporção 2,0 / 1,3.
#
# Referência teórica:
#   Rogoff, K. (1996). "The Purchasing Power Parity Puzzle."
#   Journal of Economic Literature, 34(2), 647–668.
#   (Artigo clássico que discute por que a PPP não vale no curto prazo
#    mas tende a valer no longo prazo — e os motivos dos desvios)
#
# Referência didática:
#   Krugman, P., Obstfeld, M. & Melitz, M. Economia Internacional.
#   Cap. 16: "Níveis de preços e a taxa de câmbio no longo prazo."
#
# Por que a PPP NÃO vale perfeitamente?
# - Bens não comercializáveis (serviços, aluguéis) não arbitram entre países
# - Custos de transporte e barreiras comerciais
# - Fluxos de capital (carry trade, investimento direto)
# - Termos de troca (preço de commodities)
# - Risco-país e credibilidade institucional
# Esses desvios são exatamente o que torna o gráfico PPP interessante:
# ele revela os períodos em que o câmbio "se descola" dos fundamentos.

# ------------------------------------------------------------
# 8) Construindo o câmbio PPP teórico
# ------------------------------------------------------------
# Precisamos de:
# (a) Índice de preços ao consumidor do Brasil e dos EUA (CPI, base=100)
# (b) Taxa de câmbio observada (R$/US$)
#
# Para o CPI, usamos o indicador do Banco Mundial:
# FP.CPI.TOTL → Consumer price index (2010 = 100)
# Esse indicador já é um ÍNDICE de nível de preços, não a variação %.
# É exatamente o que precisamos para o cálculo da PPP relativa.

cpi_indices <- wb_data(
  indicator  = c(cpi_index = "FP.CPI.TOTL"),
  country    = c("BR", "US"),
  start_date = 1995,
  end_date   = 2023
)

glimpse(cpi_indices)

# Separar Brasil e EUA em colunas distintas (pivot)
# Até agora, usamos dados em formato "wide" (uma coluna por indicador).
# Aqui precisamos reorganizar: queremos cpi_br e cpi_eua na mesma linha.
#
# Estratégia:
# 1) Selecionar colunas relevantes
# 2) pivot_wider() para ter uma coluna por país
# 3) Calcular o fator PPP

cpi_wide <- cpi_indices |>
  select(iso3c, date, cpi_index) |>
  pivot_wider(
    names_from  = iso3c,
    values_from = cpi_index,
    names_prefix = "cpi_"
  )

# pivot_wider() é o inverso de pivot_longer().
# Na Aula 2 usamos pivot_longer() para empilhar IPCA e Selic em uma
# coluna "serie". Aqui fazemos o oposto: cada país vira uma coluna.
#
# names_from  = iso3c → os valores de iso3c ("BRA", "USA") viram nomes de coluna
# values_from = cpi_index → os valores do CPI vão para essas novas colunas
# names_prefix = "cpi_" → adiciona prefixo para clareza (cpi_BRA, cpi_USA)
#
# Resultado: uma linha por ano, com cpi_BRA e cpi_USA lado a lado.
# Documentação: https://tidyr.tidyverse.org/reference/pivot_wider.html

glimpse(cpi_wide)

# Agora precisamos do câmbio observado anual.
# Já temos o câmbio mensal do BCB — vamos agregar para anual (média).
cambio_anual <- cambio |>
  mutate(ano = year(date)) |>
  group_by(ano) |>
  summarise(cambio_obs = mean(cambio_brl, na.rm = TRUE), .groups = "drop")

# Juntar CPI e câmbio por ano
ppp_dados <- cpi_wide |>
  rename(ano = date) |>
  left_join(cambio_anual, by = "ano") |>
  filter(!is.na(cpi_BRA), !is.na(cpi_USA), !is.na(cambio_obs))

glimpse(ppp_dados)

# Calcular o câmbio PPP teórico
# Escolhemos 1999 como ano-base (início do câmbio flutuante no Brasil).
# O câmbio PPP em cada ano = câmbio_base × (CPI_BR_t / CPI_BR_base) / (CPI_EUA_t / CPI_EUA_base)

ano_base <- 1999

ppp_base <- ppp_dados |> filter(ano == ano_base)

ppp_dados <- ppp_dados |>
  mutate(
    cambio_ppp = ppp_base$cambio_obs *
      (cpi_BRA / ppp_base$cpi_BRA) /
      (cpi_USA / ppp_base$cpi_USA),
    desvio_ppp = (cambio_obs / cambio_ppp - 1) * 100
  )

# cambio_ppp: taxa de câmbio "teórica" que manteria a PPP relativa
#             em relação ao ano-base.
# desvio_ppp: diferença percentual entre câmbio observado e PPP.
#   > 0: real mais DEPRECIADO que o previsto pela PPP (câmbio acima do "justo")
#   < 0: real mais APRECIADO que o previsto pela PPP (câmbio abaixo do "justo")

ppp_dados
readr::write_csv(ppp_dados, "outputs/tables/aula3_ppp_cambio_teorico.csv")


# ------------------------------------------------------------
# 9) Gráfico 3: Câmbio observado vs PPP teórica
# ------------------------------------------------------------
# Este é o gráfico central da aula. Ele mostra:
# - Linha azul: câmbio observado (o que de fato aconteceu)
# - Linha vermelha tracejada: câmbio PPP (o que "deveria" ser pela teoria)
# - Quando as linhas se afastam, algo além da inflação está movendo o câmbio.

p_ppp <- ggplot(ppp_dados, aes(x = ano)) +
  geom_line(aes(y = cambio_obs, color = "Câmbio observado"),
            linewidth = 0.9) +
  geom_line(aes(y = cambio_ppp, color = "Câmbio PPP teórico"),
            linewidth = 0.9, linetype = "dashed") +
  scale_color_manual(values = c("Câmbio observado"   = "steelblue",
                                "Câmbio PPP teórico" = "firebrick")) +
  scale_x_continuous(breaks = seq(1999, 2023, by = 2)) +
  labs(
    title    = "Câmbio observado vs PPP teórica — Brasil, 1999–2023",
    subtitle = "Base 1999 = R$ 1,81/US$. Desvios revelam fatores além da inflação.",
    x        = NULL,
    y        = "R$/US$",
    color    = NULL,
    caption  = "Fonte: BCB/SGS (câmbio) e Banco Mundial (CPI). PPP relativa, base 1999."
  ) +
  theme_classic(base_size = 13) +
  theme(
    plot.title      = element_text(face = "bold", size = 14),
    plot.subtitle   = element_text(color = "grey40", size = 11),
    plot.caption    = element_text(color = "grey50", size = 9),
    legend.position = "bottom"
  )

p_ppp
ggsave("outputs/figs/aula3_cambio_ppp_1999_2023.png",
       p_ppp, width = 9, height = 5)

# Gráfico complementar: desvio percentual da PPP
p_desvio <- ggplot(ppp_dados, aes(x = ano, y = desvio_ppp)) +
  geom_col(fill = "steelblue", alpha = 0.7) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  scale_x_continuous(breaks = seq(1999, 2023, by = 2)) +
  labs(
    title = "Desvio do câmbio em relação à PPP (%)",
    subtitle = "Positivo = real mais depreciado que o previsto; negativo = mais apreciado",
    x     = NULL,
    y     = "Desvio (%)",
    caption = "Desvio = (câmbio_obs / câmbio_ppp − 1) × 100"
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "grey40", size = 10)
  )

p_desvio
ggsave("outputs/figs/aula3_desvio_ppp_1999_2023.png",
       p_desvio, width = 9, height = 4)


# CHECKPOINT (interpretação — este é o exercício mais rico da aula):
#
# (a) Em 2002, o câmbio observado ficou MUITO acima da PPP. Por quê?
#     Dica: crise de confiança com a eleição, fuga de capitais, risco-país.
#     A PPP não captura esses fatores porque ela só olha para preços.
#
# (b) Entre 2005 e 2011, o câmbio observado ficou ABAIXO da PPP.
#     O que explica essa "sobrevalorização" do real?
#     Dica: boom de commodities, entrada de capitais, carry trade
#     (investidores internacionais atraídos pelos juros altos do Brasil).
#
# (c) A partir de 2015, o câmbio volta a ficar acima da PPP.
#     Quais fatores contribuíram?
#     Dica: recessão, crise fiscal, incerteza política.
#
# (d) A PPP é uma boa previsão de câmbio no curto prazo?
#     (Resposta curta: não. Rogoff (1996) mostra que os desvios da PPP
#      podem durar anos. A PPP funciona como "âncora de longo prazo",
#      não como ferramenta de previsão trimestral.)
#
# Conexão com a Aula 2:
# Na regressão Taylor, vimos que o BC reage à inflação elevando a Selic.
# O gráfico de PPP mostra o outro lado: juros altos atraem capitais,
# valorizam o câmbio, e criam "sobrevalorização" (câmbio abaixo da PPP).
# É o chamado "canal do câmbio" da política monetária.


# ------------------------------------------------------------
# 10) Gráfico extra: reservas em meses de importação (cross-country)
# ------------------------------------------------------------
# Voltando aos dados do Banco Mundial, podemos comparar a posição
# de reservas do Brasil com outros emergentes.
# Uma "regra de bolso" (Guidotti-Greenspan) sugere que um país deveria
# ter reservas suficientes para cobrir pelo menos 3 meses de importação.

p_reservas_comp <- ggplot(
  wb_clean |> filter(!is.na(reservas_meses)),
  aes(x = date, y = reservas_meses, color = country)
) +
  geom_line(linewidth = 0.7) +
  geom_hline(yintercept = 3, linetype = "dashed", color = "red", linewidth = 0.5) +
  annotate("text", x = 1997, y = 3.5, label = "Regra de 3 meses",
           color = "red", size = 3, hjust = 0) +
  scale_x_continuous(breaks = seq(1995, 2023, by = 4)) +
  labs(
    title    = "Reservas internacionais (meses de importação) — emergentes",
    subtitle = "Linha vermelha = piso de 3 meses (Guidotti-Greenspan)",
    x        = NULL,
    y        = "Meses de importação",
    color    = "País",
    caption  = "Fonte: Banco Mundial (WDI). Indicador FI.RES.TOTL.DT.ZS."
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold", size = 13),
    legend.position = "bottom"
  )

p_reservas_comp
ggsave("outputs/figs/aula3_reservas_meses_emergentes.png",
       p_reservas_comp, width = 9, height = 5)


# ============================================================
# EXTENSÃO OPCIONAL — Regressão: determinantes do câmbio
# ============================================================
# Se sobrar tempo, podemos estimar uma regressão simples com
# determinantes do câmbio, no mesmo espírito da Taylor da Aula 2.
#
# A ideia: o câmbio depende de fatores "reais" (termos de troca,
# conta corrente) e "financeiros" (diferencial de juros, risco).
#
# Modelo simplificado (anual, dados do Banco Mundial):
#   cambio_t = a + b × inflacao_t + c × conta_corrente_t + erro_t
#
# É um modelo muito simples (mesma ressalva da Aula 2: descritivo,
# não causal), mas permite praticar lm() com dados cross-section
# e interpretar os sinais dos coeficientes.
#
# ATENÇÃO — mesmos avisos da Aula 2:
# 1) NÃO se pretende provar causalidade.
# 2) Há endogeneidade: o câmbio afeta inflação e conta corrente,
#    que por sua vez afetam o câmbio.
# 3) O objetivo é ler os coeficientes e praticar o fluxo lm() → tidy().

# Preparar dados: apenas Brasil, período pós-flutuação
br_anual <- wb_clean |>
  filter(iso3c == "BRA", date >= 1999) |>
  left_join(cambio_anual, by = c("date" = "ano")) |>
  filter(!is.na(cambio_obs), !is.na(inflacao_cpi), !is.na(conta_corrente))

glimpse(br_anual)

# Regressão simples
m_cambio <- lm(cambio_obs ~ inflacao_cpi + conta_corrente, data = br_anual)
summary(m_cambio)

coef_cambio <- broom::tidy(m_cambio, conf.int = TRUE)
coef_cambio
readr::write_csv(coef_cambio, "outputs/tables/aula3_regressao_cambio_coef.csv")

# Interpretação esperada:
#
# inflacao_cpi (sinal esperado: POSITIVO)
#   Maior inflação → depreciação do câmbio (R$/US$ sobe).
#   É a lógica da PPP: se os preços sobem mais no Brasil,
#   o real perde valor em relação ao dólar.
#
# conta_corrente (sinal esperado: NEGATIVO)
#   Déficit maior em conta corrente → mais pressão de depreciação.
#   O país precisa de mais dólares para financiar o déficit,
#   o que pressiona a demanda por câmbio.
#
# LEMBRETE: essa regressão tem N pequeno (~24 observações) e
# problemas severos de endogeneidade. Use apenas como exercício
# de leitura de coeficientes — não como modelo de previsão.

# Gráfico: dispersão câmbio vs inflação (Brasil anual)
p_cambio_inflacao <- ggplot(br_anual, aes(x = inflacao_cpi, y = cambio_obs)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE) +
  geom_text(aes(label = date), size = 2.5, nudge_y = 0.1, check_overlap = TRUE) +
  labs(
    title   = "Câmbio vs inflação — Brasil (1999–2023)",
    x       = "Inflação CPI (% a.a.)",
    y       = "Câmbio (R$/US$)",
    caption = "Dispersão + reta OLS. Cada ponto é um ano. Não implica causalidade."
  ) +
  theme_minimal()

p_cambio_inflacao
ggsave("outputs/figs/aula3_dispersao_cambio_inflacao.png",
       p_cambio_inflacao, width = 7, height = 5)

# Extensão da extensão: incluir todos os países (dados em painel)
# Isso transforma a regressão de uma série temporal do Brasil
# em um modelo cross-country, aumentando o N e explorando a
# variação entre países.
m_painel <- lm(cambio_oficial ~ inflacao_cpi + conta_corrente,
               data = wb_clean |> filter(date >= 1999, !is.na(cambio_oficial)))
broom::tidy(m_painel, conf.int = TRUE)

# Nota: uma regressão de painel "séria" usaria efeitos fixos de país
# (para controlar as diferenças de nível entre moedas) e possivelmente
# efeitos fixos de ano. Isso está além do escopo desta aula,
# mas é o próximo passo natural para quem quiser se aprofundar.
# Pacote sugerido para efeitos fixos: {fixest} ou {plm}.


# ------------------------------------------------------------
# 11) Fechamento: escrever evidência em 3–5 frases
# ------------------------------------------------------------
# TAREFA FINAL (em texto, não em código):
#
# 1) Descreva, com números, a evolução das reservas internacionais
#    do Brasil entre 1999 e 2012. Use o gráfico de reservas.
#
# 2) Escolha 1 período em que o câmbio observado se desviou fortemente
#    da PPP teórica. Cite o ano e diga se o real estava sobrevalorizado
#    ou subvalorizado. Proponha 1 explicação.
#
# 3) Compare a posição de reservas (meses de importação) do Brasil
#    com a de outro emergente da tabela. Qual país parece mais
#    vulnerável a choques externos? Justifique.
#
# 4) (Opcional) O coeficiente de inflacao_cpi na regressão da extensão
#    é positivo? Isso é consistente com a teoria da PPP?

# ------------------------------------------------------------
# Resumo do que aprendemos nesta aula:
# ------------------------------------------------------------
# Novo pacote:
#   {wbstats} → wb_search() para buscar indicadores, wb_data() para baixar
#   {patchwork} → combinar gráficos com operadores + e /
#
# Novas habilidades de dados:
#   - Dados em painel (país × ano) vs série temporal (data × valor)
#   - pivot_wider() para reorganizar dados de formato long → wide
#   - Comparação cross-country com facet_wrap()
#
# Conceitos econômicos:
#   - Câmbio flutuante e acumulação de reservas
#   - Paridade do Poder de Compra (PPP): teoria vs realidade
#   - Regra de Guidotti-Greenspan para adequação de reservas
#   - Determinantes do câmbio (inflação, conta corrente)
#
# Conexões com aulas anteriores:
#   - Aula 1 (IPCA) → inflação doméstica é ingrediente da PPP
#   - Aula 2 (Taylor) → juros altos atraem capitais e valorizam o câmbio
#   - Aula 2 (regimes) → os regimes explicam os desvios da PPP
