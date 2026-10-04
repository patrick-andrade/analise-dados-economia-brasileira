# Infraestrutura da edição 2027: nenhuma aquisição ou instalação ao carregar.
raiz_curso <- function(inicio = getwd()) {
  pasta <- normalizePath(inicio, winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(pasta, "economia-brasileira-2027.Rproj"))) return(pasta)
    pai <- dirname(pasta)
    if (identical(pai, pasta)) stop("Abra o projeto economia-brasileira-2027.Rproj antes de executar.")
    pasta <- pai
  }
}
caminho <- function(...) file.path(raiz_curso(), ...)
ler_base <- function(nome) {
  arq <- caminho("data", "processed", paste0(nome, ".csv"))
  if (!file.exists(arq)) stop("Base local ausente: ", nome, ". Consulte data/README.md e scripts/adquirir-dados.py.")
  readr::read_csv(arq, show_col_types = FALSE, na = c("", "NA", "..", "..."))
}
iniciar_aula <- function() {
  essenciais <- c("dplyr", "tidyr", "readr", "ggplot2", "lubridate", "knitr")
  faltam <- essenciais[!vapply(essenciais, requireNamespace, logical(1), quietly = TRUE)]
  if (length(faltam)) stop("Pacotes ausentes: ", paste(faltam, collapse = ", "), ". Execute scripts/configurar.R.")
  suppressPackageStartupMessages(library(tidyverse))
  ggplot2::theme_set(ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(plot.caption.position="plot", plot.caption=ggplot2::element_text(hjust=0,size=9)))
  invisible(raiz_curso())
}
salvar_figura <- function(grafico, nome) {
  dir.create(caminho("outputs", "figs"), recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(caminho("outputs", "figs", paste0(nome, ".png")), grafico,
                 width = 9, height = 5.2, dpi = 150, bg = "white")
  invisible(grafico)
}
salvar_tabela <- function(tabela, nome) {
  dir.create(caminho("outputs", "tables"), recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(tabela, caminho("outputs", "tables", paste0(nome, ".csv")))
  invisible(tabela)
}
chave_unica <- function(dados, colunas) {
  if (anyDuplicated(dados[colunas])) stop("Chave duplicada: ", paste(colunas, collapse = ", "))
  invisible(dados)
}
inflacao_acumulada <- function(taxas, n_esperado = length(taxas)) {
  if (length(taxas) != n_esperado || anyNA(taxas)) return(NA_real_)
  if (any(taxas <= -100)) stop("Taxa incompatível com índice de preços positivo.")
  100 * (prod(1 + taxas / 100) - 1)
}
componente_divida <- function(divida_anterior, juros_reais_pct, crescimento_real_pct) {
  r <- juros_reais_pct / 100
  g <- crescimento_real_pct / 100
  if (any(g <= -1, na.rm = TRUE)) stop("Crescimento precisa ser maior que -100%.")
  divida_anterior * (r - g) / (1 + g)
}
juros_reais <- function(juros_nominais_pct, inflacao_pct) {
  if (any(inflacao_pct <= -100, na.rm = TRUE)) stop("Inflação inválida.")
  100 * ((1 + juros_nominais_pct / 100) / (1 + inflacao_pct / 100) - 1)
}
lorenz_ponderada <- function(renda, peso = rep(1, length(renda))) {
  if (length(renda) != length(peso)) stop("Renda e peso precisam ter o mesmo comprimento.")
  if (anyNA(renda) || anyNA(peso)) stop("Trate e documente dados ausentes antes do cálculo.")
  if (any(!is.finite(renda)) || any(!is.finite(peso))) stop("Renda e pesos precisam ser finitos.")
  if (any(renda < 0) || any(peso <= 0)) stop("Este exemplo requer renda não negativa e pesos positivos.")
  if (!length(renda) || sum(renda * peso) <= 0) stop("Renda total ponderada precisa ser positiva.")
  ordem <- order(renda)
  renda <- renda[ordem]; peso <- peso[ordem]
  tibble::tibble(p = c(0, cumsum(peso) / sum(peso)),
                 L = c(0, cumsum(renda * peso) / sum(renda * peso)))
}
gini_ponderado <- function(renda, peso = rep(1, length(renda))) {
  curva <- lorenz_ponderada(renda, peso)
  1 - sum(diff(curva$p) * (head(curva$L, -1) + tail(curva$L, -1)))
}
# Estimador descritivo da distribuição ponderada. Não calcula erro-padrão survey.
bloco_cinco_anos <- function(ano) {
  inicio <- 2000 + 5 * ((ano - 2000) %/% 5)
  paste0(inicio, "–", inicio + 4)
}
resumir_cobertura <- function(dados) {
  dados |>
    dplyr::group_by(pais, indicador, unidade) |>
    dplyr::summarise(n_validos = sum(!is.na(valor)),
      primeiro_ano = if (all(is.na(valor))) NA_integer_ else min(ano[!is.na(valor)]),
      ultimo_ano = if (all(is.na(valor))) NA_integer_ else max(ano[!is.na(valor)]), .groups = "drop")
}
