##################################### CONAB Estimativa Grãos ###################

arquivo <- readr::read_delim(paste0("https://portaldeinformacoes.conab.gov.br/",
                                    "downloads/arquivos/LevantamentoGraos.txt"),
                             delim = ";",
                             locale = readr::locale(encoding = "Latin1"))

arquivo <- arquivo |>
  dplyr::mutate(ano_referencia =
                  ifelse(stringr::str_detect(ano_agricola, "/"),
                         as.integer(stringr::str_extract(ano_agricola,
                                                         "^\\d{4}")) + 1,
                         ano_agricola)) |>
  dplyr::mutate(
    ano_referencia = lubridate::make_date(ano_referencia)
  )

arquivo <- arquivo |>
  dplyr::mutate(
    area_plantada_ha = area_plantada_mil_ha * 1000,
    producao_t = producao_mil_t * 1000
  )

source("X:/POWER BI/NOVOCAGED/conexao.R")

RPostgres::dbListTables(conexao)

schema_name <- "conab"

table_name <- "estimativa_graos"

DBI::dbSendQuery(conexao, paste0("CREATE SCHEMA IF NOT EXISTS ", schema_name))

RPostgres::dbWriteTable(conexao,
                        name = DBI::Id(schema = schema_name,
                                       table = table_name),
                        value = arquivo,
                        row.names = FALSE, overwrite = TRUE)

RPostgres::dbDisconnect(conexao)