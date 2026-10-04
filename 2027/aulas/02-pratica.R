# Atividade econômica e IBGE/SIDRA
# PIB e setores produtivos cresceram no mesmo ritmo?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

atividade <- ler_base("pib_volume") |>
  mutate(ano = periodo %/% 100, trimestre = periodo %% 100) |>
  arrange(categoria, periodo) |>
  group_by(categoria) |>
  mutate(crescimento_interanual = 100 * (valor / lag(valor, 4) - 1)) |>
  ungroup()
chave_unica(atividade, c("periodo", "categoria"))
stopifnot(all(atividade$trimestre %in% 1:4))
# Índices de volume dos setores não são parcelas aditivas do PIB.
grafico <- ggplot(atividade, aes(ano + (trimestre-1)/4, crescimento_interanual,
                               colour=categoria)) + geom_line(na.rm=TRUE) +
  geom_hline(yintercept=0, colour="grey60") +
  labs(x="Ano e trimestre", y="Variação contra igual trimestre anterior (%)",
       colour=NULL, title="PIB e setores: ritmos de crescimento",
       caption="IBGE/SIDRA 1620/583; índice encadeado, média 1995=100.")
resumo <- atividade |> group_by(categoria, ano) |>
  summarise(trimestres=n(), media_indice=mean(valor), .groups="drop")
graficos <- list(grafico); tabelas <- list(resumo)

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-02-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-02-",i))
