# Mercado de trabalho brasileiro
# Desocupação e rendimento real evoluem juntos?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

taxa <- ler_base("desocupacao") |> select(periodo,desocupacao_pct=valor)
renda <- ler_base("rendimento_real") |> select(periodo,rendimento_real_rs=valor)
chave_unica(taxa,"periodo"); chave_unica(renda,"periodo")
trabalho <- left_join(taxa,renda,by="periodo",relationship="one-to-one") |>
  mutate(data=as.Date(paste0(periodo,"01"),"%Y%m%d"))
stopifnot(nrow(trabalho)==84)
longa <- trabalho |> select(data,desocupacao_pct,rendimento_real_rs) |>
  pivot_longer(-data,names_to="indicador",values_to="valor")
grafico <- ggplot(longa,aes(data,valor)) + geom_line() +
  facet_wrap(~indicador,scales="free_y",ncol=1) +
  labs(title="Trabalho no Brasil: dois conceitos, duas unidades",x="Mês final do trimestre móvel",
       y="% (desocupação) ou R$ reais (rendimento)",
       caption="PNADC/SIDRA 6381 e 6389. Rendimento já deflacionado; janelas se sobrepõem.")
graficos <- list(grafico); tabelas <- list(tail(trabalho,12))

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-09-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-09-",i))
