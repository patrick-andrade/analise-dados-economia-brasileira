# Ambiente R e primeiro problema econômico
# Como a variação mensal dos preços aparece em um gráfico?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

# Objetos têm nomes; <- atribui um valor. Execute uma linha por vez no início.
ano_escolhido <- 2025
precos <- ler_base("ipca") |>
  mutate(ano = periodo %/% 100, mes = periodo %% 100) |>
  filter(ano == ano_escolhido) |>
  select(ano, mes, valor, unidade)
stopifnot(nrow(precos) == 12, !anyNA(precos$valor))
grafico <- ggplot(precos, aes(mes, valor)) + geom_line() + geom_point() +
  labs(title = "IPCA mensal — Brasil, 2025", x = "Mês", y = "Variação mensal (%)",
       caption = "Fonte: IBGE/SIDRA 1737; base local, extração 03/10/2026.")
graficos <- list(grafico); tabelas <- list(precos)

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-01-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-01-",i))
