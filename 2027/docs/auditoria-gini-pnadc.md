# Verificação do estudo Gini e PNADC

Fonte: estudo público `estudo-gini-pnadc-sintese.qmd` do repositório da disciplina, blob `98f1a9a850a67e3ba6c0f2e91d270b397f5f7980`, lido integralmente em 03/10/2026. O original remoto permanece preservado.

## Uso em 2027

O encontro 11 usa um exemplo ponderado controlado e o Gini oficial do SIDRA. A demonstração docente reaproveita a ideia do estudo (Lorenz, ponderação e distinção entre renda oficial e reconstrução), sem afirmar reprodução nacional ainda não executada nesta edição.

## Pontos a corrigir antes da extensão nacional

- `deflator=TRUE` em `get_pnadc()` adiciona deflatores; não transforma `VD5008` automaticamente. Comparar Lorenz generalizada entre anos exige preços de referência comuns.
- Verificar onze decis não prova dominância em todos os pontos. Vetores vazios ou apenas NA não podem produzir coincidência por `all(..., na.rm=TRUE)`.
- A reconstrução precisa definir moradores do núcleo, numerador e denominador pelo dicionário de `V2005`. Excluir renda mantendo moradores pode alterar o conceito.
- Rendimento ausente não é automaticamente zero. Documentar não aplicabilidade e não resposta separadamente.
- Cache de variáveis reconstruídas precisa identificadores e hash da base, não só comprimento.
- A afirmação de que objetos `survey.design` não podem ser serializados em RDS é excessiva: um round-trip pequeno local preservou a média ponderada.
- A validação contra SIDRA deve salvar os valores, registrar conceito/ano e aplicar tolerância explícita. A fonte QMD sozinha não comprova execução bem-sucedida.

## Estimador didático verificado

A função de área trapezoidal de `R/comum.R` calcula o Gini pontual da distribuição ponderada. Testes conferem igualdade perfeita (0), rendas 0/100/200 com pesos 1/2/1 (0,375), invariância ao multiplicar todos os pesos e igualdade com replicação por pesos inteiros.

Na instalação local, `convey` 1.0.1 não passou os mesmos testes quando os pesos mudaram de escala. O reteste em sessão limpa gerou 0,5 com pesos 1/2/1 e 0,725 com pesos 10/20/10, contra 0,375 da distribuição expandida. Isso é evidência limitada a essa versão/instalação e não valida nem invalida uma execução remota diferente. Por isso não é usado como referência numérica do exemplo. A função didática não estima erros-padrão do desenho complexo; estimativas nacionais requerem pesos, estratos, UPA, domínio e validação próprios.
