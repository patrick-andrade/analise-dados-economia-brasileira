# Comparação internacional e API do FMI
# Como comparar trajetórias de um país e dos EUA sem misturar indicadores?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

fmi <- ler_base("fmi_paises") |> filter(iso3 %in% c("COL","USA"), ano<=2025,
  indicador %in% c("NGDP_RPCH","PCPIPCH","GGXWDG_NGDP","GGXCNL_NGDP"))
chave_unica(fmi,c("iso3","ano","indicador"))
cobertura <- resumir_cobertura(fmi)
longa <- fmi |> select(iso3,pais,ano,indicador,valor)
larga <- longa |> pivot_wider(names_from=indicador, values_from=valor)
chave_unica(larga,c("iso3","ano"))
# Exemplo de junção: país-ano do crescimento com inflação. Não juntar só pelo ano.
crescimento <- longa |> filter(indicador=="NGDP_RPCH") |>
  select(iso3,ano,crescimento_pct=valor)
inflacao <- longa |> filter(indicador=="PCPIPCH") |>
  select(iso3,ano,inflacao_media_pct=valor)
comparacao <- left_join(crescimento,inflacao,by=c("iso3","ano"),relationship="one-to-one")
grafico <- ggplot(fmi |> filter(indicador %in% c("NGDP_RPCH","PCPIPCH")),
  aes(ano,valor,colour=pais)) + geom_line(na.rm=TRUE) + facet_wrap(~indicador,scales="free_y") +
  labs(title="Colômbia e EUA: crescimento e inflação média anual",x=NULL,y="%",colour=NULL,
       caption="FMI/DataMapper; WEO abril/2026; histórico pode conter estimativas.")
graficos <- list(grafico); tabelas <- list(cobertura)

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-04-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-04-",i))
