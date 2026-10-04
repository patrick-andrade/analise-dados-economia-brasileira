# Aquisição opcional e explícita: nunca chamada pelos roteiros ao renderizar.
# Não é necessário pacote "FMI", "RAIS" ou "CAGED" homônimo à fonte.
consultar_fmi <- function(indicador, arquivo_destino) {
  stopifnot(grepl("^[A-Z_]+$", indicador), length(arquivo_destino) == 1)
  url <- paste0("https://www.imf.org/external/datamapper/api/v2/", indicador)
  resposta <- httr2::request(url) |> httr2::req_timeout(60) |> httr2::req_perform()
  bruto <- httr2::resp_body_string(resposta)
  conteudo <- jsonlite::fromJSON(bruto, simplifyVector = FALSE)
  if (is.null(conteudo$values[[indicador]])) stop("Resposta FMI sem indicador esperado.")
  writeLines(bruto, arquivo_destino, useBytes = TRUE)
  invisible(arquivo_destino)
}
ler_fmi_json <- function(arquivo, indicador, paises = c("COL", "USA")) {
  bruto <- jsonlite::fromJSON(arquivo, simplifyVector = FALSE)$values[[indicador]]
  purrr::map_dfr(paises, function(iso) {
    serie <- bruto[[iso]]
    if (is.null(serie)) return(tibble::tibble(iso3=character(),ano=integer(),indicador=character(),valor=double()))
    tibble::tibble(iso3=iso, ano=as.integer(names(serie)), indicador=indicador,
                  valor=vapply(serie, function(x) if(is.null(x)) NA_real_ else as.numeric(x), numeric(1)))
  })
}
