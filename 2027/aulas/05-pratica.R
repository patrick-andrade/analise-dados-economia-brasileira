# Contas públicas brasileiras
# Primário, juros e nominal contam a mesma história fiscal?
# Executar na raiz do projeto; sem rede, instalação ou setwd pessoal.
source("R/comum.R", encoding="UTF-8")
iniciar_aula()

bcb <- ler_base("bcb") |> mutate(data=as.Date(data))
fiscal <- bcb |> filter(codigo %in% c(5793,5760,5727), periodicidade=="mensal") |>
  select(data,codigo,valor) |> mutate(codigo=as.character(codigo)) |>
  pivot_wider(names_from=codigo,values_from=valor,names_prefix="sgs_") |>
  mutate(residuo=sgs_5727-sgs_5793-sgs_5760,
         saldo_primario_superavit_positivo=-sgs_5793)
chave_unica(fiscal,"data")
# Arredondamento a 0,01% PIB admite resíduo de até 0,02 ponto percentual.
stopifnot(max(abs(fiscal$residuo),na.rm=TRUE)<=0.02)
fluxos <- bcb |> filter(codigo %in% c(5793,5760,5727))
divida <- bcb |> filter(codigo %in% c(13762,4513))
g1 <- ggplot(fluxos,aes(data,valor,colour=indicador)) + geom_line() +
  labs(title="NFSP: fluxos acumulados em 12 meses",x=NULL,y="% PIB; déficit positivo",colour=NULL,
       caption="BCB/SGS. Não somar as 12 observações mensais: as janelas se sobrepõem.")
g2 <- ggplot(divida,aes(data,valor,colour=indicador)) + geom_line() +
  labs(title="Dívida bruta e líquida",x=NULL,y="Estoque em % PIB",colour=NULL,
       caption="BCB/SGS 13762 e 4513; conceitos e abrangências distintos.")
graficos <- list(g1,g2); tabelas <- list(tail(fiscal,6))

# Produtos calculados pelo mesmo script usado pelo roteiro Quarto.
for (i in seq_along(graficos)) salvar_figura(graficos[[i]], paste0("aula-05-",i))
for (i in seq_along(tabelas)) salvar_tabela(tabelas[[i]], paste0("aula-05-",i))
