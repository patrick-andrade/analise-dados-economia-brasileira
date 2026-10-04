# Inflação, poder de compra e renda real
# Somar taxas mensais mede corretamente a inflação anual?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

precos <- ler_base("ipca") |> arrange(periodo) |>
  mutate(data=as.Date(paste0(periodo,"01"), "%Y%m%d"), ano=periodo %/% 100,
         indice=100*cumprod(1+valor/100))
chave_unica(precos, "periodo")
stopifnot(!anyNA(precos$valor), nrow(precos)==84)
anual <- precos |> group_by(ano) |>
  summarise(meses=n(), inflacao_pct=inflacao_acumulada(valor,12),
            soma_incorreta=sum(valor), .groups="drop")
# Simulação didática explícita: salário fixo R$ 3.000, não série salarial observada.
# Preços de dez/2025: renda_real = renda_nominal * índice_base / índice_t.
exemplo <- precos |> mutate(renda_nominal_simulada=3000,
  renda_real_dez2025=3000*last(indice)/indice)
grafico <- ggplot(exemplo, aes(data, renda_real_dez2025)) + geom_line() +
  labs(title="Poder de compra de salário nominal fixo — simulação",
       y="R$ a preços de dezembro/2025", x=NULL,
       caption="IPCA/IBGE. Salário de R$ 3.000 é hipótese, não dado de renda.")
graficos <- list(grafico); tabelas <- list(anual)

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-03-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-03-",i))
