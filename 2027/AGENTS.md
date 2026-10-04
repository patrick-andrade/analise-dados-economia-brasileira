# Edição 2027

Preserve a pasta de 2026 e os arquivos históricos publicados na raiz do repositório remoto. O programa e as decisões da edição nova estão em `docs/plano-atualizacao.md` e `docs/decisoes.md`.

Ao alterar uma aula, confira seus exercícios, solução docente, fontes e roteiro Quarto. Cálculos ficam em R; comunicação e interpretação ficam nos QMD. Use a raiz do projeto, nunca caminhos da máquina do professor.

Dados didáticos reais precisam de procedência registrada em `data/README.md` e no inventário de bases. Dados construídos para demonstrar uma identidade precisam ser explicitamente identificados como simulação; não podem sustentar conclusões sobre o Brasil.

Aquisição usa rede; aulas e renderizações usam os arquivos locais. Não instale pacotes nem baixe bases ao carregar uma aula. Respeite unidades, convenções de sinal, abrangência institucional e desenho amostral.

Depois de modificar cálculos, execute `Rscript scripts/verificar.R`. Depois de modificar conteúdo ou configuração de Quarto, renderize pela raiz e confira os resultados. Soluções docentes e dados auxiliares do professor não integram o pacote público para alunos.
