# RAIS e Novo CAGED
# Por que estoque de vínculos e saldo de movimentações não são intercambiáveis?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

caged <- ler_base("caged_sp_202412")
stopifnot(all(caged$saldo==caged$admissoes-caged$desligamentos),
          sum(caged$movimentos_ausentes)==0)
setores <- caged |> group_by(setor) |>
  summarise(across(c(admissoes,desligamentos,saldo),sum),.groups="drop") |>
  arrange(saldo)
rais <- ler_base("rais_setores")
total <- rais |> filter(setor=="Total publicado")
classificados <- rais |> filter(setor!="Total publicado") |>
  group_by(ano) |> summarise(soma_classificados=sum(vinculos),.groups="drop")
conferencia <- left_join(total,classificados,by="ano",relationship="one-to-one") |>
  mutate(residuo=vinculos-soma_classificados)
grafico <- ggplot(setores,aes(reorder(setor,saldo),saldo)) + geom_col() + coord_flip() +
  labs(title="Novo CAGED: saldo em São Paulo, dezembro/2024",x="Seção CNAE (código)",
       y="Admissões menos desligamentos (vínculos)",
       caption="MTE; aquisição herdada de 2026, revisão não revalidada. Não é estoque de postos.")
graficos <- list(grafico); tabelas <- list(setores,conferencia)

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-10-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-10-",i))
