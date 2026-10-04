# Distribuição de renda e desigualdade
# O que um Gini informa e o que a distribuição mostra além dele?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

oficial <- ler_base("gini_oficial") |> transmute(ano=periodo,gini=valor)
stopifnot(all(oficial$gini>=0 & oficial$gini<=1))
# Quatro pessoas equivalentes em três valores: exemplo SIMULADO, não PNADC.
exemplo <- tibble::tibble(renda=c(0,100,200),peso=c(1,2,1))
lorenz <- lorenz_ponderada(exemplo$renda,exemplo$peso)
gini_exemplo <- gini_ponderado(exemplo$renda,exemplo$peso)
stopifnot(abs(gini_exemplo-0.375)<1e-12)
g1 <- ggplot(oficial,aes(ano,gini)) + geom_line() + geom_point() +
  labs(title="Gini do rendimento domiciliar per capita — Brasil",y="Índice (0–1)",x=NULL,
       caption="IBGE/PNADC/SIDRA 7435/10681. Série oficial, não reprodução por microdados.")
g2 <- ggplot(lorenz,aes(p,L)) + geom_line() +
  geom_abline(slope=1,intercept=0,linetype=2) + coord_equal() +
  labs(title="Lorenz ponderada — exemplo simulado",x="Fração acumulada da população",
       y="Fração acumulada da renda",caption="Rendas 0,100,200; pesos 1,2,1. Gini=0,375. Sem erro-padrão survey.")
graficos <- list(g1,g2); tabelas <- list(exemplo,lorenz)

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-11-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-11-",i))
