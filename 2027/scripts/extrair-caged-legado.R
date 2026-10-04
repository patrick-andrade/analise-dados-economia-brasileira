# Extrai dados reais do acervo 2026 sem alterar ou salvar o ambiente original.
# Arquivo fonte é argumento: Rscript scripts/extrair-caged-legado.R ../202601-ECO-BRAS-DADOS/.RData
source("R/comum.R", encoding = "UTF-8")
iniciar_aula()
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1, file.exists(args[[1]]))
origem <- new.env(parent = emptyenv())
load(args[[1]], envir = origem)
stopifnot(exists("dados_msp_202412", envir = origem), exists("url_caged", envir = origem))
dados <- get("dados_msp_202412", envir = origem)
# Nenhum identificador individual é distribuído. As aulas usam grupos e contagens.
agregado <- dados |>
  transmute(movimentacao = as.integer(.data[["saldomovimentação"]]),
            sexo = as.character(.data[["sexo"]]), setor = as.character(.data[["seção"]]),
            competencia = .data[["competênciamov"]], uf = .data[["uf"]],
            municipio = .data[["município"]]) |>
  group_by(competencia, uf, municipio, sexo, setor) |>
  summarise(admissoes = sum(movimentacao == 1, na.rm = TRUE),
            desligamentos = sum(movimentacao == -1, na.rm = TRUE),
            registros = n(), movimentos_ausentes = sum(is.na(movimentacao)), .groups = "drop") |>
  mutate(saldo = admissoes - desligamentos)
readr::write_csv(agregado, caminho("data", "processed", "caged_sp_202412.csv"))
meta <- list(fonte = get("url_caged", envir = origem), objeto = "dados_msp_202412",
  competencia = "202412", arquivo_fonte = basename(args[[1]]),
  nota = "Aquisição herdada de 2026; revisão do MTE não revalidada. Recorte municipal agregado, não estoque de emprego.",
  n_registros = nrow(dados), n_grupos = nrow(agregado))
jsonlite::write_json(meta, caminho("data", "caged-procedencia.json"), auto_unbox = TRUE, pretty = TRUE)
message("CAGED: ", nrow(agregado), " grupos agregados extraídos; fonte preservada.")
