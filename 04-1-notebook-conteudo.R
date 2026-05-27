# ============================================================
# Economia brasileira: análise de dados (Laboratório)
# PARTE 2 — Setor externo, fiscal e estrutura produtiva
#
# NOTEBOOK 4: Condições fiscais e mercado de trabalho
# Tema: Dívida pública, resultado primário, gasto público,
#        desemprego — Brasil × Colômbia (2000–2025)
# Foco: (A) nova fonte de dados (FMI/WEO via imfapi)
#        (B) dinâmica da dívida como decomposição contábil
#        (C) template para o Trabalho 1
# Extra (nível acima): introdução ao Quarto Reveal.js para
#        produzir apresentações reprodutíveis a partir do R
#
# Produto ao final:
# - 4 gráficos: (1) dívida bruta comparativa; (2) resultado
#   primário comparativo; (3) decomposição da variação da dívida
#   no Brasil; (4) decomposição do PIB pela ótica da demanda
# - 1 tabela comparativa por subperíodos de 5 anos
# - 1 arquivo .qmd de exemplo para apresentação em slides
# - 3–5 frases interpretativas citando números e anos
# ============================================================
#
# Conexão com os notebooks anteriores:
# - Notebook 1: fundamentos do R, IPCA.
# - Notebook 2: integração de inflação, juros e atividade do
#   Brasil; tabela por regimes; Regra de Taylor didática.
# - Notebook 3: setor externo, comparação internacional com
#   wbstats, Paridade do Poder de Compra.
#
# Neste notebook, ampliamos novamente o repertório:
# - De fontes: além do BCB (rbcb) e do Banco Mundial (wbstats),
#   adicionamos o Fundo Monetário Internacional (imfapi).
# - De temas: entramos em finanças públicas e mercado de trabalho.
# - De modelos aplicados: aplicamos a equação da dinâmica da
#   dívida, no mesmo espírito da Taylor (Notebook 2) e da PPP
#   (Notebook 3) — sempre como decomposição descritiva, não causal.
# - De método: a segunda metade do notebook foi pensada como
#   um treino para o Trabalho 1, espelhando a estrutura pedida.
# ============================================================

# ------------------------------------------------------------
# 0) Setup (pastas, pacotes, opções)
# ------------------------------------------------------------
dir.create("data/raw",       recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/figs",   recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

# Pacotes novos deste notebook:
# - {imfapi}   : acesso aos datasets do FMI via SDMX 3.0 (WEO, BoP, GFS…)
# - {webshot2} : necessário para salvar tabelas {gt} como imagens PNG/PDF.
#                Usa o Chrome instalado no sistema para renderizar HTML → PNG.
#                Se o Chrome não estiver instalado, instale-o antes de rodar.
#
# Pacotes já conhecidos:
# - {tidyverse}, {wbstats}, {patchwork}, {gt} — todos dos notebooks anteriores.
# - {scales} faz parte do tidyverse e é útil para formatação de eixos.
#
# Instalar UMA vez no console, se ainda não tiver:
# install.packages(c("tidyverse", "wbstats", "imfapi", "patchwork", "gt", "webshot2"))

library(tidyverse)
library(wbstats)
library(imfapi)      # NOVIDADE deste notebook
library(patchwork)
library(gt)
library(scales)
library(webshot2)    # NOVIDADE: renderiza tabelas {gt} como PNG via Chrome

options(scipen = 999)


# ============================================================
# SAIBA MAIS — O ecossistema EconDataverse
# ============================================================
# O pacote {imfapi} não é uma iniciativa isolada. Ele faz parte
# do EconDataverse, um esforço coordenado entre quatro organizações
# (Tidy Intelligence, Teal Insights, ONE Campaign e Promptly
# Technologies) para padronizar o acesso a dados econômicos em R
# e Python.
#
# O problema que o EconDataverse resolve:
# Historicamente, cada fonte de dados econômicos (FMI, Banco
# Mundial, OCDE, UNESCO) tinha seu próprio pacote em R, com
# convenções de nomes diferentes, formatos de saída diferentes
# e mantenedores diferentes. Juntar dados de 3 fontes podia
# significar aprender 3 "dialetos". O EconDataverse padroniza
# essas interfaces.
#
# Princípios principais (úteis para vocês saberem):
# - Interface consistente: funções imf_get_* para descobrir dados
#   e imf_get() para baixar. Aprender uma é aprender o padrão.
# - Saídas em formato tidy por padrão (uma coluna por variável).
# - Compatibilidade R ↔ Python (mesma lógica nos dois lados).
# - Licença MIT, código aberto, manutenção ativa.
#
# Pacotes do ecossistema úteis para o curso e para o Trabalho 1:
# - {wbwdi}    : alternativa moderna ao {wbstats} para o Banco
#                Mundial. Continuamos usando {wbstats} no curso por
#                continuidade, mas {wbwdi} é uma boa opção a explorar.
# - {imfapi}   : acesso a todos os 193 datasets do FMI via SDMX 3.0
#                (WEO, BoP, GFS, IFS…) — usamos neste notebook.
# - {wbids}    : International Debt Statistics — útil para
#                aprofundar o tema dívida externa no Trabalho 2.
# - {owidapi}  : Our World in Data (indicadores sociais e
#                ambientais para comparação internacional).
# - {oecdoda}  : fluxos de cooperação internacional da OCDE.
# - {econid}   : padronização de códigos de país (ISO2, ISO3, etc.).
# - {econtools}: utilitários para combinar múltiplas fontes.
#
# Site oficial (vale visitar):
#   https://www.econdataverse.org/
#
# Como contexto: o {wbstats} que usamos nos Notebooks 3 e 4 NÃO
# faz parte do EconDataverse — é um pacote mais antigo, mantido
# por outra equipe. Ambos estão ativos no CRAN e funcionam bem.
# A menção aqui é para vocês saberem que existe um caminho
# alternativo, caso queiram explorar.
# ============================================================


# ============================================================
# PARTE A — Diagnóstico fiscal e do mercado de trabalho
#           Brasil × Colômbia (2000–2025)
# ============================================================
#
# Por que comparar Brasil com Colômbia?
#
# A escolha não é aleatória. A Colômbia oferece um ponto de
# comparação especialmente rico para o tema fiscal:
#
# - REGRA FISCAL: a Colômbia tem uma regra fiscal estrutural
#   desde 2011 (Ley 1473), uma das mais respeitadas da América
#   Latina. O Brasil, no mesmo período, viveu o desmonte do
#   superávit primário (2014–2016) e depois adotou o teto de
#   gastos (2016–2023). A comparação ajuda a discutir como
#   diferentes arranjos institucionais produzem trajetórias
#   distintas de dívida pública.
#
# - METAS DE INFLAÇÃO: ambos os países adotaram metas em 1999.
#   Trajetórias monetárias paralelas, com instituições parecidas.
#
# - MERCADO DE TRABALHO: ambos têm informalidade alta, mas em
#   proporções diferentes. A Colômbia historicamente tem
#   desemprego aberto mais elevado que o Brasil — é interessante
#   discutir por que economias com instituições parecidas têm
#   indicadores de trabalho tão diferentes.
#
# - COBERTURA DE DADOS: Brasil e Colômbia têm boa cobertura no
#   WEO/FMI para os indicadores fiscais e de mercado de trabalho
#   usados no diagnóstico central deste notebook.
#
# Referência sobre a regra fiscal colombiana:
#   Lozano-Espitia, I. & Julio, J. M. (2016). "Fiscal Rules
#   in a Volatile World: A Welfare-Based Approach."
#   Borradores de Economía No. 936, Banco de la República.
#   https://www.banrep.gov.co/es/borrador-936


# ------------------------------------------------------------
# 1) Subperíodos de análise (espelhando o Trabalho 1)
# ------------------------------------------------------------
# O Trabalho 1 padroniza a divisão em subperíodos de 5 anos:
#   2000–2004 : crise de 2002, início Lula, ajuste externo
#   2005–2009 : boom de commodities, crise financeira global
#   2010–2014 : pós-crise, crescimento moderado
#   2015–2019 : recessão, ajuste fiscal, recuperação lenta
#   2020–2025 : pandemia, choque inflacionário, ajuste monetário
#
# Vamos criar uma FUNÇÃO que aplica essa divisão. Construir uma
# função pequena agora poupa retrabalho depois — você reutilizará
# o mesmo padrão em todos os módulos do Trabalho 1.

classificar_subperiodo <- function(ano) {
  case_when(
    ano <= 2004 ~ "2000-2004",
    ano <= 2009 ~ "2005-2009",
    ano <= 2014 ~ "2010-2014",
    ano <= 2019 ~ "2015-2019",
    TRUE        ~ "2020-2025"
  )
}

# Teste rápido para garantir que funciona:
classificar_subperiodo(c(2001, 2008, 2014, 2017, 2023))
# Esperado: "2000-2004" "2005-2009" "2010-2014" "2015-2019" "2020-2025"

# Por que uma função e não só um case_when() inline?
# (1) Reutilização: você usará isso 5+ vezes ao longo do Trabalho.
# (2) Manutenção: se decidir mudar a granularidade (ex.: 3 anos
#     em vez de 5), muda em um lugar só.
# (3) Testabilidade: dá para verificar com poucos valores se está
#     funcionando, como acabamos de fazer.
# Essa é uma prática profissional de organização de código.


# ------------------------------------------------------------
# 2) Conhecendo o pacote {imfapi}
# ------------------------------------------------------------
# A lógica do {imfapi} é parecida com a do {wbstats}, mas com
# algumas diferenças importantes:
#
# {wbstats}:                    {imfapi}:
# - wb_search() busca           - imf_get_dataflows() lista todos os
#   indicadores por texto         ~193 datasets disponíveis no FMI
# - wb_data() baixa por         - imf_get() baixa filtrando por
#   código e país                 dataset, país e indicador
# - Múltiplos indicadores       - Múltiplos indicadores de uma vez:
#   por chamada                   INDICATOR = c("CODE1", "CODE2")
# - Códigos ISO2 ou ISO3        - APENAS códigos ISO3 (BRA, COL...)
# - Banco Mundial (WDI)         - FMI (WEO, BoP, GFS, IFS e outros)
#
# O {imfapi} usa a API SDMX 3.0 do FMI — acesso direto via REST,
# sem download de arquivo. Isso o torna mais rápido e confiável.
#
# Fluxo de trabalho padrão (4 passos):
# 1. imf_get_dataflows()         → descobrir datasets disponíveis
# 2. imf_get_datastructure(id)   → ver as dimensões do dataset
# 3. imf_get_codelists(dims)     → listar códigos válidos por dimensão
# 4. imf_get(id, dimensions, …)  → baixar os dados
#
# Vamos percorrer esse fluxo para o dataset WEO.

# Passo 1: quais datasets estão disponíveis no FMI?
todos_datasets <- imf_get_dataflows()
glimpse(todos_datasets)

# Filtrar os relacionados ao WEO:
todos_datasets |>
  filter(str_detect(name, regex("economic outlook|WEO", ignore_case = TRUE)))

# Passo 2: quais dimensões o dataset "WEO" possui?
dims_weo <- imf_get_datastructure("WEO")
dims_weo
# Retorna: COUNTRY, INDICATOR, FREQUENCY

# Passo 3: quais códigos são válidos para cada dimensão?
# imf_get_codelists() recebe o vetor de IDs de dimensão + o nome do dataset:
codigos_weo <- imf_get_codelists(dims_weo$dimension_id, dataflow_id = "WEO")
glimpse(codigos_weo)

# Ver indicadores disponíveis no WEO (filtro por tema fiscal/PIB):
codigos_weo |>
  filter(dimension_id == "INDICATOR") |>
  filter(str_detect(name, regex("government|debt|primary|GDP growth",
                                ignore_case = TRUE))) |>
  print(n = 20)

# Ver países disponíveis (alguns exemplos):
codigos_weo |>
  filter(dimension_id == "COUNTRY") |>
  filter(str_detect(name, regex("brazil|colombia",
                                ignore_case = TRUE)))

# Você usará essa lógica de exploração com frequência no Trabalho 1.
# Sempre vale conferir os códigos antes de baixar — permitem descobrir
# séries que você não sabia que existiam.

# Observação importante: estimativas de anos passados podem mudar
# entre os releases do WEO (abril e outubro de cada ano), por conta
# de revisões metodológicas. Dados macroeconômicos NÃO são imutáveis
# — esse é um conceito central para quem trabalha com séries temporais.


# ------------------------------------------------------------
# 3) Baixando dados macro do WEO/FMI via {imfapi}
# ------------------------------------------------------------
# Séries que vamos usar. A vantagem de concentrar este bloco no WEO
# é manter uma única fonte para o diagnóstico fiscal e do mercado de
# trabalho, com códigos de país e calendário já padronizados.
#
#   GGXONLB_NGDP : Resultado primário do governo geral
#                  (general government primary net lending/borrowing)
#                  Positivo = superávit primário; negativo = déficit.
#
#   GGXWDG_NGDP  : Dívida bruta do governo geral
#                  (general government gross debt)
#
#   NGDP_RPCH    : Crescimento do PIB real (% a.a.)
#                  Necessário para a equação de dinâmica da dívida.
#
#   LUR          : Taxa de desemprego (% da força de trabalho)
#
#   GGX_NGDP     : Despesa total do governo geral (% do PIB)
#
# A sintaxe é direta: informamos o dataset (WEO) e as dimensões
# (país, indicador e frequência anual). O {imfapi} cuida do
# resto — monta a requisição SDMX e retorna um tibble limpo.

dados_macro_weo <- imf_get(
  dataflow_id = "WEO",
  dimensions  = list(
    COUNTRY   = c("BRA", "COL"),
    INDICATOR = c("GGXONLB_NGDP", "GGXWDG_NGDP", "NGDP_RPCH",
                  "LUR", "GGX_NGDP"),
    FREQUENCY = "A"
  )
)

# Inspeção inicial — sempre confira a estrutura antes de prosseguir:
glimpse(dados_macro_weo)

# Note a estrutura: cada linha é uma combinação país × indicador × ano.
# Esse é o formato "longo" (long format), comum em painéis.
# As colunas retornadas são: COUNTRY, INDICATOR, FREQUENCY,
# TIME_PERIOD (caractere, ex.: "2020") e OBS_VALUE (numérico).
# O WEO inclui projeções — vamos filtrar para 2000–2025 na seção 4.

# Salvar localmente (mesma boa prática dos notebooks anteriores):
write_csv(dados_macro_weo, "data/raw/notebook4_weo_macro_brasil_colombia.csv")


# ------------------------------------------------------------
# 4) Transformando o formato longo em largo
# ------------------------------------------------------------
# Para construir gráficos comparativos, tabelas e a equação da dívida,
# precisamos das séries em colunas separadas. Vamos usar
# pivot_wider() — a mesma função que apareceu no Notebook 3
# para o cálculo de PPP.
#
# Adicionalmente: convertemos TIME_PERIOD (caractere) para ano
# numérico e filtramos para o período de análise 2000–2025.

macro_fiscal <- dados_macro_weo |>
  select(COUNTRY, INDICATOR, TIME_PERIOD, OBS_VALUE) |>
  mutate(ano = as.integer(TIME_PERIOD)) |>
  filter(ano >= 2000, ano <= 2025) |>
  pivot_wider(
    id_cols     = c(COUNTRY, ano),
    names_from  = INDICATOR,
    values_from = OBS_VALUE
  ) |>
  rename(
    iso3             = COUNTRY,
    primario_pct_pib = GGXONLB_NGDP,
    divida_pct_pib   = GGXWDG_NGDP,
    crescimento_real = NGDP_RPCH,
    desemprego_pct   = LUR,
    gasto_pct_pib    = GGX_NGDP
  ) |>
  mutate(pais = case_when(iso3 == "BRA" ~ "Brazil",
                           iso3 == "COL" ~ "Colombia")) |>
  select(iso3, pais, ano, primario_pct_pib, divida_pct_pib,
         crescimento_real, desemprego_pct, gasto_pct_pib) |>
  arrange(iso3, ano)

glimpse(macro_fiscal)
# Esperado: 26 anos × 2 países = 52 linhas, 8 colunas.


# ------------------------------------------------------------
# 5) Checando cobertura, NAs e salvando a base final
# ------------------------------------------------------------
# Antes, este notebook baixava mercado de trabalho no WDI/Banco
# Mundial e depois juntava as bases. Ao testar a cobertura, o WEO
# retornou séries mais completas para gasto público e também cobre
# desemprego. Por isso, todos os indicadores centrais passam a vir
# da mesma chamada ao FMI.
#
# Boas práticas: depois de baixar e transformar os dados, fazemos
# uma checagem curta e explícita antes de seguir para gráficos e
# tabelas. Aqui verificamos:
# - número de linhas por país;
# - cobertura de cada variável;
# - presença de NAs relevantes.
# Isso ajuda a detectar mudanças de cobertura quando o WEO é
# atualizado em novos releases.

macro_fiscal |>
  count(iso3, pais)

# Conferindo cobertura de cada variável por país:
macro_fiscal |>
  group_by(pais) |>
  summarise(
    n_anos              = n(),
    com_primario        = sum(!is.na(primario_pct_pib)),
    com_divida          = sum(!is.na(divida_pct_pib)),
    com_crescimento     = sum(!is.na(crescimento_real)),
    com_desemprego      = sum(!is.na(desemprego_pct)),
    com_gasto           = sum(!is.na(gasto_pct_pib)),
    .groups = "drop"
  )

# Lembre-se da advertência do Notebook 3: em dados internacionais
# é normal haver NAs nos anos mais recentes (dados publicados
# com defasagem) ou em séries específicas que não cobrem todo
# o período. Não é erro — é parte do trabalho com dados reais.
# Neste caso, a principal lacuna esperada é gasto público do
# Brasil em 2000; a cobertura melhora bastante em relação ao WDI.

write_csv(macro_fiscal, "data/processed/notebook4_macro_fiscal.csv")


# ------------------------------------------------------------
# 6) Gráfico 1: Dívida pública bruta — Brasil × Colômbia
# ------------------------------------------------------------
# Primeiro gráfico comparativo. Estratégia: duas linhas no
# mesmo painel (unidades comparáveis, ambas em % do PIB).

p_divida <- macro_fiscal |>
  filter(!is.na(divida_pct_pib)) |>
  ggplot(aes(x = ano, y = divida_pct_pib, color = pais)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.5) +
  scale_color_manual(values = c("Brazil" = "steelblue",
                                 "Colombia" = "firebrick")) +
  scale_x_continuous(breaks = seq(2000, 2025, by = 5)) +
  scale_y_continuous(labels = label_number(suffix = "%"),
                     breaks = seq(0, 100, by = 10)) +
  labs(
    title    = "Dívida bruta do governo geral (% do PIB)",
    subtitle = "Brasil × Colômbia, 2000–2025",
    x        = NULL,
    y        = "% do PIB",
    color    = "País",
    caption  = "Fonte: FMI/WEO via {imfapi}. Série GGXWDG_NGDP."
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(color = "grey40"),
    plot.caption    = element_text(color = "grey50", size = 9),
    legend.position = "bottom"
  )

p_divida
ggsave("outputs/figs/notebook4_divida_brasil_colombia.png",
       p_divida, width = 9, height = 5)


# ------------------------------------------------------------
# 7) Gráfico 2: Resultado primário comparativo
# ------------------------------------------------------------
# O resultado primário é a diferença entre receitas e despesas
# do governo EXCLUINDO o pagamento de juros sobre a dívida.
#
# Por que excluir os juros?
# Os juros são consequência da dívida acumulada no passado —
# são (até certo ponto) fora do controle imediato do governo.
# O primário mede o "esforço fiscal corrente": o quanto o
# governo consegue arrecadar a mais do que gasta nas atividades
# correntes (excluindo serviço da dívida).
#
# Interpretação:
# - primário > 0 (superávit): o esforço fiscal corrente está
#   reduzindo a dívida (ou contribuindo para isso).
# - primário < 0 (déficit): o esforço fiscal corrente está
#   aumentando a dívida (mesmo sem contar juros).
#
# A relevância disso ficará clara na seção 9 (dinâmica da dívida).

p_primario <- macro_fiscal |>
  filter(!is.na(primario_pct_pib)) |>
  ggplot(aes(x = ano, y = primario_pct_pib, fill = pais)) +
  geom_col(position = "dodge", alpha = 0.85) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.4) +
  scale_fill_manual(values = c("Brazil" = "steelblue",
                                "Colombia" = "firebrick")) +
  scale_x_continuous(breaks = seq(2000, 2025, by = 5)) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  labs(
    title    = "Resultado primário do governo geral (% do PIB)",
    subtitle = "Brasil × Colômbia, 2000–2025 | Positivo = superávit primário",
    x        = NULL,
    y        = "% do PIB",
    fill     = "País",
    caption  = "Fonte: FMI/WEO via {imfapi}. Série GGXONLB_NGDP."
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(color = "grey40"),
    plot.caption    = element_text(color = "grey50", size = 9),
    legend.position = "bottom"
  )

p_primario
ggsave("outputs/figs/notebook4_primario_brasil_colombia.png",
       p_primario, width = 9, height = 5)


# CHECKPOINT 1 (gráficos 1 e 2):
# - Compare a trajetória da dívida brasileira e colombiana.
#   A Colômbia tem dívida mais ou menos volátil? Mais alta
#   em nível?
# - Em quais anos o Brasil teve resultado primário positivo?
#   E negativo? O que isso revela sobre o esforço fiscal
#   ao longo do período?
# - O choque da pandemia (2020) aparece nos dois indicadores.
#   Em qual deles o impacto é mais visível?


# ------------------------------------------------------------
# 8) Gráfico 3: Mercado de trabalho — taxa de desemprego
# ------------------------------------------------------------
# Mesma lógica do gráfico de dívida: duas linhas, painel único.

p_desemprego <- macro_fiscal |>
  filter(!is.na(desemprego_pct)) |>
  ggplot(aes(x = ano, y = desemprego_pct, color = pais)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.5) +
  scale_color_manual(values = c("Brazil" = "steelblue",
                                 "Colombia" = "firebrick")) +
  scale_x_continuous(breaks = seq(2000, 2025, by = 5)) +
  scale_y_continuous(labels = label_number(suffix = "%"),
                     breaks = seq(0, 25, by = 2)) +
  labs(
    title    = "Taxa de desemprego (% da força de trabalho)",
    subtitle = "Brasil × Colômbia, 2000–2025",
    x        = NULL,
    y        = "% força de trabalho",
    color    = "País",
    caption  = "Fonte: FMI/WEO via {imfapi}. Indicador LUR."
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(color = "grey40"),
    plot.caption    = element_text(color = "grey50", size = 9),
    legend.position = "bottom"
  )

p_desemprego
ggsave("outputs/figs/notebook4_desemprego_brasil_colombia.png",
       p_desemprego, width = 9, height = 5)

# Observação analítica relevante: o desemprego colombiano é
# persistentemente mais alto que o brasileiro durante quase
# todo o período. Esse é um dos grandes "puzzles" do mercado
# de trabalho latino-americano e tem motivado uma agenda
# extensa de pesquisa (rigidez do salário mínimo, custos de
# contratação formal, dualidade urbano-rural).


# ------------------------------------------------------------
# 9) Dinâmica da dívida — aplicação econômica central
# ------------------------------------------------------------
# Agora chegamos ao bloco aplicado mais importante do notebook.
# Vamos decompor a variação da dívida pública brasileira em
# dois componentes contábeis:
#
# (a) Efeito "snowball" (juros-crescimento): mostra como o
#     diferencial entre taxa de juros real e crescimento real
#     atua sobre o estoque de dívida pré-existente.
# (b) Esforço primário: o quanto o resultado primário do
#     período contribui (ou se opõe) à acumulação de dívida.
#
# Essa decomposição é amplamente usada em relatórios de
# sustentabilidade fiscal do FMI, do Tesouro Nacional, e
# de instituições como a IFI (Instituição Fiscal Independente).
#
# ── A equação ────────────────────────────────────────────────
#
# A equação canônica de evolução da dívida (em % do PIB) é:
#
#   d_t = d_{t-1} × (1 + r_t)/(1 + g_t)  −  pb_t
#
# Em que:
#   d_t   = dívida/PIB no ano t
#   d_{t-1} = dívida/PIB no ano t-1
#   r_t   = taxa de juros real implícita sobre a dívida (% a.a.)
#   g_t   = taxa de crescimento real do PIB (% a.a.)
#   pb_t  = resultado primário em % PIB (positivo = superávit)
#
# Reorganizando, a VARIAÇÃO da dívida pode ser escrita como:
#
#   Δd_t = d_{t-1} × (r_t − g_t)/(1 + g_t)  −  pb_t  +  resíduo
#         └──────────┬────────────┘    └──┬──┘
#         efeito juros-crescimento     esforço primário
#         (snowball)
#
# O "resíduo" captura tudo o mais que afeta a dívida:
# - Reconhecimento de passivos contingentes (skeletons fiscais)
# - Variação cambial sobre dívida em moeda estrangeira
# - Operações abaixo da linha (capitalização do BNDES, etc.)
# - Discrepâncias estatísticas
# Em economias com dívida majoritariamente em moeda local
# (como Brasil pós-2002), esse resíduo costuma ser pequeno —
# mas não é zero.
#
# IMPORTANTE — esta é uma decomposição CONTÁBIL, não preditiva:
# - Não estamos prevendo a dívida futura.
# - Não estamos provando causalidade.
# - Estamos decompondo a variação OBSERVADA em componentes
#   identificáveis. É uma identidade contábil retrospectiva.
#
# Referência:
#   IMF (2013). Staff Guidance Note for Public Debt Sustainability
#   Analysis in Market-Access Countries.
#   https://www.imf.org/external/np/pp/eng/2013/050913.pdf
#
# Para uma versão didática em português, ver:
#   Tesouro Nacional. Relatório Anual da Dívida Pública.
#   https://www.gov.br/tesouronacional/pt-br/divida-publica-federal/relatorios

# ── Aproximação importante: como obter r real implícito? ─────
#
# A taxa de juros REAL IMPLÍCITA sobre a dívida brasileira não
# está disponível diretamente como série pronta nas bases
# públicas. Há várias formas de aproximá-la:
#
# (1) Selic real ex-post (Notebook 2): Selic − IPCA 12m.
#     Vantagem: simples e direto.
#     Limitação: a dívida brasileira tem títulos variados
#     (Selic, prefixados, IPCA+) — a Selic é só um proxy.
#
# (2) Juro implícito = (juros pagos no ano) / (estoque médio
#     da dívida). Vantagem: mede o custo efetivo. Desvantagem:
#     requer dados detalhados que não estão prontamente
#     disponíveis no WEO.
#
# (3) Inferência a partir da identidade contábil. Se temos
#     d_t, d_{t-1}, g_t e pb_t, podemos calcular o "r implícito"
#     que torna a equação consistente — incluindo o resíduo.
#
# Para fins didáticos, vamos usar uma quarta abordagem,
# bastante usada em relatórios introdutórios:
#
# (4) Aproximação por juros reais ex-ante de mercado: usamos
#     a média histórica do juro real brasileiro como proxy.
#     No nosso caso, vamos usar a taxa Selic real ex-post
#     que calculamos no Notebook 2 — assumindo que ela é
#     uma aproximação razoável para o custo médio da dívida.
#
# Como o foco aqui é didático (mostrar o RACIOCÍNIO da
# decomposição), vamos fazer uma aproximação ainda mais
# simples: usar uma taxa de juros real CONSTANTE de 4% a.a.,
# que é próxima da média histórica do juro real estrutural
# brasileiro nos anos 2000–2020.
#
# Em um trabalho de fôlego, você refinaria essa estimativa.
# Para o objetivo pedagógico aqui, a aproximação basta para
# revelar quem dominou a dinâmica da dívida em cada período.

# ── Construindo a decomposição ───────────────────────────────

dinamica_divida_br <- macro_fiscal |>
  filter(iso3 == "BRA",
         !is.na(divida_pct_pib),
         !is.na(crescimento_real),
         !is.na(primario_pct_pib)) |>
  arrange(ano) |>
  mutate(
    # Dívida defasada (lag = ano anterior):
    divida_lag = lag(divida_pct_pib),

    # Taxa de juros real implícita (aproximação didática):
    r_real_aprox = 4.0,

    # Componentes da decomposição:
    efeito_snowball = divida_lag * (r_real_aprox - crescimento_real) /
                                    (1 + crescimento_real / 100),

    # O primário entra com sinal NEGATIVO na variação da dívida:
    # superávit primário (pb > 0) reduz a dívida;
    # déficit primário (pb < 0) aumenta a dívida.
    contribuicao_primario = -primario_pct_pib,

    # Variação efetiva da dívida (observada):
    delta_divida_obs = divida_pct_pib - divida_lag,

    # Resíduo = tudo o que a decomposição contábil simples não
    # capta (passivos contingentes, câmbio, ajustes estatísticos):
    residuo = delta_divida_obs - efeito_snowball - contribuicao_primario
  )

# Verificando os componentes para os anos mais recentes:
dinamica_divida_br |>
  select(ano, divida_pct_pib, delta_divida_obs,
         efeito_snowball, contribuicao_primario, residuo) |>
  tail(10)


# ── Gráfico 4: Decomposição da variação da dívida brasileira ─

dinamica_long <- dinamica_divida_br |>
  filter(!is.na(efeito_snowball)) |>
  select(ano, efeito_snowball, contribuicao_primario, residuo) |>
  pivot_longer(
    cols      = c(efeito_snowball, contribuicao_primario, residuo),
    names_to  = "componente",
    values_to = "valor"
  ) |>
  mutate(
    componente = factor(
      componente,
      levels = c("efeito_snowball", "contribuicao_primario", "residuo"),
      labels = c("Efeito juros-crescimento",
                 "Esforço primário (com sinal invertido)",
                 "Resíduo")
    )
  )

p_decomp_divida <- ggplot(dinamica_long, aes(x = ano, y = valor, fill = componente)) +
  geom_col(position = "stack", alpha = 0.85) +
  geom_line(data = dinamica_divida_br |> filter(!is.na(delta_divida_obs)),
            aes(x = ano, y = delta_divida_obs),
            inherit.aes = FALSE,
            linewidth = 0.7, color = "black") +
  geom_point(data = dinamica_divida_br |> filter(!is.na(delta_divida_obs)),
             aes(x = ano, y = delta_divida_obs),
             inherit.aes = FALSE,
             size = 1.5, color = "black") +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.3) +
  scale_fill_manual(values = c(
    "Efeito juros-crescimento"               = "firebrick",
    "Esforço primário (com sinal invertido)" = "steelblue",
    "Resíduo"                                = "grey60"
  )) +
  scale_x_continuous(breaks = seq(2000, 2025, by = 5)) +
  scale_y_continuous(labels = label_number(suffix = " p.p.")) +
  labs(
    title    = "Decomposição da variação anual da dívida pública — Brasil",
    subtitle = "Linha preta = variação total observada | Barras = contribuição de cada componente",
    x        = NULL,
    y        = "Contribuição para Δ dívida (p.p. do PIB)",
    fill     = "Componente",
    caption  = "Fonte: FMI/WEO. r real aproximado por 4% a.a. (média histórica). Decomposição contábil retrospectiva."
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(color = "grey40", size = 10),
    plot.caption    = element_text(color = "grey50", size = 9),
    legend.position = "bottom"
  )

p_decomp_divida
ggsave("outputs/figs/notebook4_decomposicao_divida_brasil.png",
       p_decomp_divida, width = 10, height = 6)


# ── Como ler o gráfico ───────────────────────────────────────
#
# A LINHA PRETA mostra a variação anual efetiva da dívida em
# pontos percentuais do PIB. Quando a linha sobe, a dívida
# aumentou naquele ano; quando desce, diminuiu.
#
# As BARRAS mostram a decomposição:
#
# - Barra VERMELHA (efeito juros-crescimento): quando positiva,
#   significa que (r − g) > 0 atuando sobre a dívida pré-existente
#   empurrou a dívida para cima. O "snowball" trabalhando contra
#   o país. Quando negativa, o crescimento real ajudou a "diluir"
#   a dívida em relação ao PIB.
#
# - Barra AZUL (esforço primário com sinal invertido): valor
#   positivo significa déficit primário (aumentando a dívida);
#   valor negativo significa superávit primário (reduzindo).
#
# - Barra CINZA (resíduo): tudo que a aproximação contábil não
#   captou. Choques específicos, câmbio, passivos contingentes.
#
# Pontos de atenção interpretativa:
# - 2003–2008: crescimento alto (g elevado) ajudou o Brasil
#   a controlar a dívida apesar de juros reais altos.
# - 2014–2016: recessão (g muito baixo ou negativo) + déficit
#   primário transformaram a dinâmica da dívida.
# - 2020: choque pandêmico aparece como ano atípico.
#
# Os números exatos podem variar com a aproximação de r — para
# uso analítico sério, refine a estimativa de juros reais.


# CHECKPOINT 2 (decomposição da dívida):
# - Identifique 1 ano em que o "snowball" foi negativo (favorável):
#   quem dominou nesse ano, juros baixos ou crescimento alto?
# - Identifique 1 ano em que o esforço primário foi
#   contracionário (superávit alto). A dívida caiu?
# - Em 2015–2016, qual componente domina a explicação do
#   aumento da dívida?


# ------------------------------------------------------------
# 10) Tabela comparativa por subperíodo de 5 anos
# ------------------------------------------------------------
# Agora aplicamos a função `classificar_subperiodo()` que
# definimos na seção 1. Esse é o padrão exato que vocês
# usarão no Trabalho 1 — vale prestar atenção à estrutura.

tab_subperiodos <- macro_fiscal |>
  mutate(subperiodo = classificar_subperiodo(ano)) |>
  group_by(pais, subperiodo) |>
  summarise(
    divida_media       = mean(divida_pct_pib,   na.rm = TRUE),
    primario_medio     = mean(primario_pct_pib, na.rm = TRUE),
    gasto_medio        = mean(gasto_pct_pib,    na.rm = TRUE),
    desemprego_medio   = mean(desemprego_pct,   na.rm = TRUE),
    crescimento_medio  = mean(crescimento_real, na.rm = TRUE),
    n_anos             = n(),
    .groups            = "drop"
  ) |>
  arrange(pais, subperiodo)

tab_subperiodos

write_csv(tab_subperiodos, "outputs/tables/notebook4_resumo_subperiodos.csv")

# Versão formatada com {gt} — note como a tabela fica organizada
# por país (groupname_col), o que facilita a comparação visual.

tab_subperiodos_gt <- tab_subperiodos |>
  gt(groupname_col = "pais") |>
  tab_header(
    title    = "Diagnóstico fiscal e do mercado de trabalho",
    subtitle = "Brasil × Colômbia | Médias por subperíodo de 5 anos"
  ) |>
  cols_label(
    subperiodo        = "Subperíodo",
    divida_media      = "Dívida bruta (% PIB)",
    primario_medio    = "Primário (% PIB)",
    gasto_medio       = "Gasto público (% PIB)",
    desemprego_medio  = "Desemprego (%)",
    crescimento_medio = "PIB real (% a.a.)",
    n_anos            = "Anos"
  ) |>
  fmt_number(
    columns  = c(divida_media, primario_medio, gasto_medio,
                 desemprego_medio, crescimento_medio),
    decimals = 1
  ) |>
  tab_source_note(
    source_note = "Fonte: FMI/WEO via {imfapi}."
  )

tab_subperiodos_gt

gtsave(tab_subperiodos_gt, "outputs/figs/notebook4_tab_subperiodos.png")


# CHECKPOINT 3 (tabela comparativa):
# - Em qual subperíodo a Colômbia teve sua melhor performance
#   fiscal (primário médio)? E o Brasil?
# - Compare a dívida média do Brasil em 2010-2014 vs 2020-2025.
#   Quanto a dívida cresceu, em pontos percentuais do PIB?
# - O desemprego colombiano permanece sistematicamente mais
#   alto que o brasileiro em TODOS os subperíodos?


# ============================================================
# PARTE B — Consolidação metodológica: template para o Trabalho 1
# ============================================================
# A segunda metade do notebook é mais "prática operacional" que
# "conteúdo econômico novo". O objetivo aqui é dar a vocês um
# template reutilizável para o Trabalho 1, cobrindo três pontos
# que aparecem em todos os módulos:
#
# (i)   Estrutura de script multi-módulo.
# (ii)  Como lidar com NAs em comparações cross-country.
# (iii) Decomposição do PIB pela ótica da demanda (Módulo 1 do
#       trabalho exige isso explicitamente — fazemos aqui o
#       primeiro exemplo).


# ------------------------------------------------------------
# 11) Estrutura de script multi-módulo
# ------------------------------------------------------------
# O Trabalho 1 pede um ÚNICO script .R organizado em 5 módulos.
# Recomenda-se a seguinte estrutura, que reproduz a lógica
# que vocês viram nos notebooks 1–4:
#
# ── Template sugerido ────────────────────────────────────────
#
# # ============================================================
# # Trabalho 1 — Brasil × [país escolhido]
# # Diagnóstico macroeconômico comparado, 2000–2025
# # Alunos: [nomes]
# # ============================================================
#
# # ----- Setup -----
# library(tidyverse)
# library(wbstats)
# library(imfapi)
# library(patchwork)
# library(gt)
#
# dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
# dir.create("outputs/figs", recursive = TRUE, showWarnings = FALSE)
# dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
#
# # Função auxiliar (use o mesmo padrão deste notebook):
# classificar_subperiodo <- function(ano) {
#   case_when(
#     ano <= 2004 ~ "2000-2004",
#     ano <= 2009 ~ "2005-2009",
#     ano <= 2014 ~ "2010-2014",
#     ano <= 2019 ~ "2015-2019",
#     TRUE        ~ "2020-2025"
#   )
# }
#
# # Lista de países que aparecem em TODOS os módulos:
# paises_iso2 <- c("BR", "[XX]")  # para wbstats
# paises_iso3 <- c("BRA", "[XXX]") # para imfapi
#
# # ----- Módulo 1: Crescimento e ciclo econômico -----
# # 1.1 Download dos indicadores
# # 1.2 Limpeza e transformação
# # 1.3 Gráficos
# # 1.4 Tabela por subperíodo
# # 1.5 Interpretação (como comentários no código + slides)
#
# # ----- Módulo 2: Investimento e poupança -----
# # ... (mesma estrutura)
#
# # ----- Módulo 3: Inflação e política monetária -----
# # ...
#
# # ----- Módulo 4: Setor externo e câmbio -----
# # ...
#
# # ----- Módulo 5: Condições fiscais e mercado de trabalho -----
# # (estrutura idêntica à Parte A deste notebook)
#
# ── Boas práticas adicionais ─────────────────────────────────
#
# - Use comentários de seção com hashes triplos ou linhas para
#   destacar a hierarquia. Isso permite navegar pelo "Document
#   Outline" do RStudio/Positron.
# - Nomeie objetos com sufixos consistentes:
#     [tema]_raw     → dados brutos baixados
#     [tema]_clean   → dados após limpeza
#     [tema]_long    → formato longo
#     [tema]_wide    → formato largo
#     tab_[tema]     → tabela final
#     p_[tema]       → gráfico final
# - Salve outputs intermediários em data/processed/ para evitar
#   re-download da API a cada execução.
# - Documente os códigos dos indicadores em comentário inline
#   ao lado de cada série baixada. Você agradecerá no Trabalho 2.


# ------------------------------------------------------------
# 12) Lidando com NAs em comparações cross-country
# ------------------------------------------------------------
# Em dados internacionais, NAs são fato da vida. As principais
# situações que vocês vão encontrar:
#
# (a) País não cobre o indicador no início da série:
#     Ex.: dados de gasto público do WDI começam em 2008 para
#     alguns países.
#
# (b) País não cobre os anos mais recentes:
#     Ex.: 2024–2025 ainda não tem dado definitivo em vários
#     indicadores do WDI.
#
# (c) Indicador descontinuado ou redefinido:
#     Ex.: definição de "desemprego" mudou em alguns países.
#
# Estratégias práticas:

# ESTRATÉGIA 1 — Sempre faça um "audit" inicial dos NAs:
macro_fiscal |>
  group_by(pais) |>
  summarise(
    across(c(divida_pct_pib, primario_pct_pib, gasto_pct_pib,
             desemprego_pct, crescimento_real),
           ~ sum(is.na(.x))),
    .groups = "drop"
  )

# ESTRATÉGIA 2 — Para gráficos, filtre NAs LOCALMENTE
# (sem alterar a base original):
#   ggplot(dados |> filter(!is.na(variavel)), aes(...))
# Isso evita que geom_line() conecte pontos artificialmente.

# ESTRATÉGIA 3 — Para tabelas com médias, use na.rm = TRUE,
# mas REPORTE quantos anos foram efetivamente considerados:
exemplo_audit <- macro_fiscal |>
  filter(pais == "Colombia") |>
  mutate(subperiodo = classificar_subperiodo(ano)) |>
  group_by(subperiodo) |>
  summarise(
    divida_media    = mean(divida_pct_pib, na.rm = TRUE),
    anos_validos    = sum(!is.na(divida_pct_pib)),
    anos_no_periodo = n(),
    .groups = "drop"
  )

exemplo_audit

# Se anos_validos < anos_no_periodo, ALERTE no slide:
# "Média baseada em N anos de M possíveis."

# ESTRATÉGIA 4 — Se um indicador estiver indisponível para o
# país escolhido, escolha um INDICADOR ALTERNATIVO e
# documente a escolha. NÃO oculte a limitação — torne-a
# transparente no script e no slide.


# ------------------------------------------------------------
# 13) Decomposição do PIB pela ótica da demanda
# ------------------------------------------------------------
# O Módulo 1 do Trabalho 1 pede explicitamente um gráfico de
# barras empilhadas ou agrupadas com a decomposição do PIB
# pela ótica da demanda. Vamos fazer aqui um exemplo completo,
# para que vocês tenham o template pronto.
#
# Pela ótica da demanda:
#   PIB = C + G + I + (X − M)
# Onde:
#   C = Consumo das famílias
#   G = Consumo do governo
#   I = Investimento (Formação Bruta de Capital Fixo)
#   X − M = Exportações líquidas (saldo da balança comercial)
#
# No WDI temos esses componentes em % do PIB:
#   NE.CON.PRVT.ZS  : consumo privado
#   NE.CON.GOVT.ZS  : consumo do governo
#   NE.GDI.FTOT.ZS  : FBCF
#   NE.RSB.GNFS.ZS  : exportações líquidas (% PIB)
#
# Note: a soma teórica é 100%, mas pode haver pequena divergência
# por arredondamento ou pela conta de "variação de estoques",
# que não isolamos aqui. Para fins didáticos, isso não é problema.

dados_pib <- wb_data(
  indicator  = c(
    consumo_priv  = "NE.CON.PRVT.ZS",
    consumo_gov   = "NE.CON.GOVT.ZS",
    investimento  = "NE.GDI.FTOT.ZS",
    exp_liquidas  = "NE.RSB.GNFS.ZS"
  ),
  country    = c("BR", "CO"),
  start_date = 2000,
  end_date   = 2025
)

glimpse(dados_pib)

# Limpeza e transformação para formato longo (necessário para
# barras empilhadas):
pib_longo <- dados_pib |>
  select(iso3c, country, date,
         consumo_priv, consumo_gov, investimento, exp_liquidas) |>
  rename(
    iso3 = iso3c,
    pais = country,
    ano  = date
  ) |>
  pivot_longer(
    cols      = c(consumo_priv, consumo_gov, investimento, exp_liquidas),
    names_to  = "componente",
    values_to = "pct_pib"
  ) |>
  mutate(
    componente = factor(
      componente,
      levels = c("consumo_priv", "consumo_gov", "investimento", "exp_liquidas"),
      labels = c("Consumo das famílias",
                 "Consumo do governo",
                 "Investimento (FBCF)",
                 "Exportações líquidas")
    )
  )

glimpse(pib_longo)

# Gráfico 5: decomposição do PIB pela ótica da demanda
# Usamos facet_wrap para ter um painel por país, e
# geom_col(position = "stack") para empilhar os componentes.

p_pib_demanda <- pib_longo |>
  filter(!is.na(pct_pib)) |>
  ggplot(aes(x = ano, y = pct_pib, fill = componente)) +
  geom_col(position = "stack", alpha = 0.9, width = 0.85) +
  facet_wrap(~ pais, ncol = 1) +
  scale_fill_manual(values = c(
    "Consumo das famílias"  = "steelblue",
    "Consumo do governo"    = "darkgreen",
    "Investimento (FBCF)"   = "firebrick",
    "Exportações líquidas"  = "goldenrod"
  )) +
  scale_x_continuous(breaks = seq(2000, 2025, by = 5)) +
  scale_y_continuous(labels = label_number(suffix = "%")) +
  labs(
    title    = "PIB pela ótica da demanda — Brasil × Colômbia",
    subtitle = "Componentes em % do PIB | Soma teórica = 100% (pequenos desvios por estoques)",
    x        = NULL,
    y        = "% do PIB",
    fill     = "Componente",
    caption  = "Fonte: Banco Mundial/WDI via {wbstats}."
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title      = element_text(face = "bold"),
    plot.subtitle   = element_text(color = "grey40", size = 10),
    plot.caption    = element_text(color = "grey50", size = 9),
    legend.position = "bottom",
    strip.text      = element_text(face = "bold")
  )

p_pib_demanda
ggsave("outputs/figs/notebook4_pib_demanda_decomposicao.png",
       p_pib_demanda, width = 10, height = 8)

# Observação técnica: barras empilhadas funcionam bem para
# mostrar a COMPOSIÇÃO ao longo do tempo. Se você quiser
# enfatizar a COMPARAÇÃO entre os componentes, use
# position = "dodge" (barras lado a lado). Se quiser destacar
# a PROPORÇÃO, normalize para 100% com position = "fill".


# CHECKPOINT 4 (decomposição da demanda):
# - O consumo das famílias representa cerca de 60–70% do PIB
#   nos dois países. Isso é típico de economias emergentes
#   ou é uma particularidade?
# - Qual país tem maior peso de exportações líquidas?
# - O investimento (FBCF) costuma estar entre 15% e 25% do
#   PIB em economias em desenvolvimento. Brasil e Colômbia
#   estão dentro dessa faixa?


# ============================================================
# PARTE C — Introdução ao Quarto Reveal.js para apresentações
# ============================================================
# Esta seção é EXTRA. O Trabalho 1 NÃO exige Quarto — você
# pode entregar a apresentação em qualquer formato (PowerPoint,
# Google Slides, PDF). Mas se quiser explorar um caminho
# moderno e reprodutível, Quarto + Reveal.js é uma excelente
# opção.
#
# ── O que é Quarto? ──────────────────────────────────────────
#
# Quarto é o sucessor do R Markdown, desenvolvido pela Posit
# (mesma empresa do RStudio). Permite criar documentos que
# misturam texto, código R e visualizações em um único arquivo.
# Os formatos de saída incluem:
# - HTML (página web)
# - PDF (relatório formal)
# - DOCX (Word)
# - Reveal.js (apresentação de slides INTERATIVA no navegador)
# - Beamer (apresentação em LaTeX)
#
# Site oficial: https://quarto.org/
#
# Por que considerar Quarto para a apresentação do Trabalho 1?
# - Reprodutibilidade: os gráficos no slide são gerados pelo
#   próprio script — atualizou os dados, atualizou a apresentação.
# - Versionamento: o .qmd é um arquivo de texto, fácil de
#   manter em Git/GitHub (não é um binário como .pptx).
# - Apresentação na web: o Reveal.js gera HTML que roda em
#   qualquer navegador, sem precisar do PowerPoint instalado.
# - Estética: temas modernos prontos, com bom design tipográfico.
#
# Limitação: a curva de aprendizado inicial é maior que a do
# PowerPoint. Vale o esforço se você planeja seguir em
# Economia/Ciência de Dados — não vale se você só precisa
# entregar o Trabalho 1 e seguir em frente. Decida com calma.
#
# ── Instalação ───────────────────────────────────────────────
#
# Quarto NÃO faz parte do R. É um binário separado.
# Instale a partir de: https://quarto.org/docs/get-started/
#
# No Positron, o Quarto pode estar disponível por padrão.
# No RStudio versões recentes, idem.
#
# Para testar se está instalado, no terminal:
#   quarto --version
#
# IMPORTANTE: os computadores do laboratório PODEM NÃO TER
# Quarto instalado. Este notebook serve como referência —
# você pode replicar em casa.


# ------------------------------------------------------------
# 14) Estrutura mínima de um Quarto Reveal.js (.qmd)
# ------------------------------------------------------------
# Um arquivo .qmd Reveal.js tem três partes:
#
# (1) YAML header (metadados): define formato, título, tema.
# (2) Slides separados por ##.
# (3) Conteúdo Markdown e/ou chunks de R.
#
# Exemplo mínimo (este código vai para um arquivo .qmd separado,
# não direto neste .R):
#
# ----------------------------------------
# ---
# title: "Trabalho 1 — Brasil × Colômbia"
# author: "Aluno X, Aluno Y"
# date: today
# format:
#   revealjs:
#     theme: simple
#     slide-number: true
#     transition: slide
#     incremental: false
# ---
#
# ## Por que comparar com a Colômbia?
#
# - Regra fiscal estrutural desde 2011
# - Metas de inflação adotadas em 1999 (igual ao Brasil)
# - Mercado de trabalho com características parecidas
# - Cobertura completa nos dados WDI e WEO
#
# ## Dívida bruta — Brasil × Colômbia
#
# ```{r}
# #| echo: false
# #| fig-width: 9
# #| fig-height: 5
# library(tidyverse)
# # ... código que produz o gráfico de dívida ...
# p_divida
# ```
#
# Os dois países seguiram trajetórias distintas após 2014.
# ----------------------------------------
#
# As partes mais importantes do YAML:
# - format: revealjs → indica que é apresentação interativa.
# - theme: simple → tema visual (outros: default, dark, sky,
#   beige, serif, simple, solarized).
# - slide-number: true → mostra numeração dos slides.
# - transition: slide → animação entre slides (none, fade,
#   slide, convex, concave, zoom).
#
# As partes mais importantes do conteúdo:
# - ## inicia um novo slide.
# - ### faz um subtítulo dentro do slide.
# - Listas com -, parágrafos com texto livre, código em chunks.
# - #| echo: false esconde o código do slide (mostra só o gráfico).
# - #| fig-width e #| fig-height controlam dimensões.


# ------------------------------------------------------------
# 15) Layouts úteis para apresentação de dados
# ------------------------------------------------------------
# Reveal.js suporta layouts em colunas, muito úteis para colocar
# um gráfico ao lado de interpretação. Exemplo:
#
# ----------------------------------------
# ## Dinâmica da dívida brasileira
#
# :::: {.columns}
#
# ::: {.column width="60%"}
# ```{r}
# #| echo: false
# p_decomp_divida
# ```
# :::
#
# ::: {.column width="40%"}
# **Observações principais:**
#
# - 2003–2008: snowball negativo (g > r)
# - 2014–2016: dominância do primário negativo
# - 2020: choque pandêmico atípico
# :::
#
# ::::
# ----------------------------------------
#
# Outras estruturas úteis:
# - {.smaller}: reduz fonte do slide (bom para tabelas longas).
# - {.scrollable}: torna o slide rolável (cuidado, geralmente
#   é melhor dividir em vários slides).
# - background-color: muda cor de fundo do slide.


# ------------------------------------------------------------
# 16) Renderizando o documento
# ------------------------------------------------------------
# Para gerar a apresentação:
#
# (1) Salve o arquivo como nome.qmd
# (2) No terminal (ou usando o botão "Render" do IDE):
#        quarto render nome.qmd
# (3) Será criado um nome.html — abra no navegador.
#
# Atalhos da apresentação no navegador:
# - Setas: navegar entre slides.
# - F: tela cheia.
# - S: speaker view (visualização do apresentador, com notas).
# - O: visão geral (overview de todos os slides).
# - ?: lista completa de atalhos.
#
# Para exportar como PDF (se você não quiser apresentar no
# navegador):
# - Abra a apresentação em modo print: nome.html?print-pdf
# - Imprima como PDF a partir do navegador.
#
# Mais detalhes em:
#   https://quarto.org/docs/presentations/revealjs/


# ------------------------------------------------------------
# 17) Recomendação prática para o Trabalho 1
# ------------------------------------------------------------
# Se decidir usar Quarto Reveal.js para o Trabalho 1:
#
# (1) Mantenha o script .R principal SEPARADO do arquivo .qmd.
#     O .R gera e salva os gráficos e tabelas em outputs/.
#     O .qmd lê esses arquivos prontos (com include_graphics
#     ou recriando o gráfico). Isso evita re-executar API calls
#     a cada renderização.
#
# (2) Faça um slide-modelo de cada TIPO de conteúdo que vai
#     repetir (gráfico comparativo, tabela, interpretação).
#     Depois replique a estrutura para cada módulo.
#
# (3) Aproveite o ":::: {.columns}" para combinar gráfico +
#     interpretação no mesmo slide. Apresentação fica mais
#     denso e analítica.
#
# (4) Não exagere em transições e efeitos. Para apresentação
#     acadêmica, simplicidade vence.
#
# Para quem não quiser usar Quarto, PowerPoint ou Google Slides
# funcionam perfeitamente. O importante é que a apresentação
# seja CLARA, com gráficos legíveis e interpretação bem escrita.


# ============================================================
# FECHAMENTO — Tarefa final e síntese
# ============================================================
# TAREFA FINAL (em texto, não em código):
#
# 1) Compare, com números, a dívida pública bruta de Brasil
#    e Colômbia em 2015 e 2025. Quem cresceu mais (em pontos
#    percentuais do PIB)? O que aconteceu em cada país?
#
# 2) Identifique 1 subperíodo em que o Brasil teve resultado
#    primário consistentemente positivo. Qual foi e por quê?
#    Use a tabela de subperíodos como referência.
#
# 3) Olhe o gráfico de decomposição da dívida (gráfico 4).
#    Em qual ano o "efeito snowball" foi mais favorável ao
#    Brasil? E em qual foi mais adverso? Cite os anos.
#
# 4) (Opcional) Pense em 1 fator que explicaria o desemprego
#    persistentemente mais alto da Colômbia. Quais dados
#    adicionais você gostaria de ter para investigar isso?
#
# ============================================================
# Resumo do que aprendemos neste notebook:
# ============================================================
# Novo pacote:
#   {imfapi} → imf_get_dataflows(), imf_get_codelists(), imf_get()
#              para descobrir e baixar dados do FMI.
#
# Ecossistema novo:
#   EconDataverse → padrão de pacotes econômicos em R/Python.
#   Pacotes irmãos: wbwdi, imfapi, wbids, owidapi, econid.
#
# Novas habilidades de dados:
#   - Uso do WEO/FMI em painel país × ano com múltiplos indicadores.
#   - Padronização via códigos ISO3.
#   - Função classificar_subperiodo() reutilizável.
#   - Audit sistemático de NAs em comparações cross-country.
#
# Conceitos econômicos:
#   - Resultado primário vs nominal (importância de excluir juros).
#   - Dinâmica da dívida: efeito snowball + esforço primário.
#   - Decomposição contábil retrospectiva (não preditiva).
#   - PIB pela ótica da demanda: C + G + I + (X−M).
#
# Conexões com notebooks anteriores:
#   - Notebook 2 (Selic real ex-post) → ingrediente para r real
#     na dinâmica da dívida.
#   - Notebook 2 (regimes) → o padrão de subperíodos retorna
#     com cortes diferentes, mais adequados ao Trabalho 1.
#   - Notebook 3 (wbstats, painel país × ano) → mesmo paradigma,
#     agora aplicado ao WEO/FMI via {imfapi}.
#
# Caminho para o Trabalho 1:
#   - A estrutura da Parte A espelha o Módulo 5 do trabalho.
#   - O template da Parte B serve para os outros módulos.
#   - O Quarto Reveal.js é uma OPÇÃO para a apresentação,
#     não uma exigência.
# ============================================================
