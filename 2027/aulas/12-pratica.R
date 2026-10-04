# Laboratório integrador do Projeto 2
# Como uma nova fonte aprofunda a comparação sem criar uma junção enganosa?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

fmi <- ler_base("fmi_paises") |> filter(iso3 %in% c("COL","USA"),
  indicador=="NGDP_RPCH",ano<=2025) |> select(iso3,pais,ano,crescimento_pct=valor)
wdi <- ler_base("wdi_complemento") |> filter(iso3 %in% c("COL","USA"),
  indicador=="SL.UEM.TOTL.ZS",ano>=2000,ano<=2025) |>
  select(iso3,ano,desemprego_modelado_pct=valor)
chave_unica(fmi,c("iso3","ano"));chave_unica(wdi,c("iso3","ano"))
integrado <- left_join(fmi,wdi,by=c("iso3","ano"),relationship="one-to-one")
stopifnot(nrow(integrado)==nrow(fmi))
cobertura <- integrado |> group_by(pais) |>
  summarise(anos=n(),pares_completos=sum(complete.cases(crescimento_pct,desemprego_modelado_pct)),
            ausentes_desemprego=sum(is.na(desemprego_modelado_pct)),.groups="drop")
grafico <- ggplot(integrado,aes(crescimento_pct,desemprego_modelado_pct,colour=pais)) +
  geom_point(na.rm=TRUE) + labs(title="Crescimento e desemprego: associação descritiva",
  x="Crescimento real do PIB (%)",y="Desemprego modelado OIT (%)",colour=NULL,
  caption="FMI WEO abril/2026 e Banco Mundial WDI. Associação não identifica causalidade.")
graficos <- list(grafico); tabelas <- list(cobertura)

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-12-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-12-",i))
