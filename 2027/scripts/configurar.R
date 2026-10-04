# Execute uma vez, conscientemente, com rede disponível. Aulas não instalam nada.
pacotes <- c("tidyverse", "lubridate", "knitr", "rmarkdown", "readxl", "jsonlite", "httr2", "sidrar", "rbcb", "wbstats")
faltam <- pacotes[!vapply(pacotes, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltam)) install.packages(faltam, repos = "https://cloud.r-project.org")
message("Ambiente pronto. PNADcIBGE e survey são extensões docentes; convey exige validação do estimador.")
