# Regras fiscais e dinâmica da dívida
# Como crescimento, juros e primário alteram uma razão dívida/PIB?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

# d_t = d_(t-1)*(1+r)/(1+g) - s_t + ajuste_t.
# d e s em pontos percentuais do PIB; r e g entram como frações.
# Nesta simulação, r=4% real e ajuste=0 são hipóteses, não estimativas históricas.
cenarios <- tidyr::expand_grid(crescimento_pct=c(0,2,4),superavit_pct=c(0,2)) |>
  mutate(divida_inicial=80,juros_reais_pct=4,
         bola_neve=componente_divida(divida_inicial,juros_reais_pct,crescimento_pct),
         divida_final=divida_inicial+bola_neve-superavit_pct)
trajetorias <- purrr::map_dfr(c(0,2,4),function(g) {
  d <- numeric(11);d[1] <- 80
  for(t in 2:11) d[t] <- d[t-1]+componente_divida(d[t-1],4,g)-2
  tibble::tibble(ano=0:10,divida_pct=d,crescimento_pct=factor(g))
})
grafico <- ggplot(trajetorias,aes(ano,divida_pct,colour=crescimento_pct)) + geom_line() +
  labs(title="Dívida/PIB: cenários simulados",y="% PIB",x="Anos após condição inicial",
       colour="Crescimento real (%)",caption="Hipóteses: dívida inicial 80% PIB; juros reais 4%; superávit 2% PIB; ajuste zero.")
graficos <- list(grafico); tabelas <- list(cenarios)

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-08-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-08-",i))
