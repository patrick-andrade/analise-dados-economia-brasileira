# Receitas, despesas e previdência
# Qual parcela da despesa do Governo Central corresponde à previdência?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

rtn <- ler_base("rtn") |> mutate(data=as.Date(data),ano=lubridate::year(data),
  item=case_when(str_detect(rubrica,"RECEITA L") ~ "receita",
                 str_detect(rubrica,"DESPESA TOTAL") ~ "despesa",
                 str_detect(rubrica,"Benefícios") ~ "beneficios",
                 str_detect(rubrica,"RESULTADO PRIM") ~ "primario"))
chave_unica(rtn,c("data","item"))
mensal <- rtn |> select(data,ano,item,valor) |> pivot_wider(names_from=item,values_from=valor)
stopifnot(max(abs(mensal$receita-mensal$despesa-mensal$primario))<1e-5)
anual <- mensal |> group_by(ano) |> summarise(meses=n(),
  across(c(receita,despesa,beneficios,primario), ~if(n()==12&&!anyNA(.x)) sum(.x) else NA_real_),
  .groups="drop") |> mutate(participacao_beneficios_pct=100*beneficios/despesa)
grafico <- ggplot(anual,aes(ano,participacao_beneficios_pct)) + geom_col() +
  labs(title="Benefícios previdenciários na despesa do Governo Central",x=NULL,
       y="Participação na despesa total (%)",caption="Tesouro/RTN; valores nominais mensais agregados; 12 meses por ano.")
graficos <- list(grafico); tabelas <- list(anual)

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-06-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-06-",i))
