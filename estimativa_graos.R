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

arquivo <- arquivo |>
  dplyr::mutate(n_levantamento = as.integer(stringr::str_trim(id_levantamento)),
                mes = dplyr::case_when(
                  n_levantamento == 1  ~ 10,
                  n_levantamento == 2  ~ 11,
                  n_levantamento == 3  ~ 12,
                  n_levantamento == 4  ~ 1,
                  n_levantamento == 5  ~ 2,
                  n_levantamento == 6  ~ 3,
                  n_levantamento == 7  ~ 4,
                  n_levantamento == 8  ~ 5,
                  n_levantamento == 9  ~ 6,
                  n_levantamento == 10 ~ 7,
                  n_levantamento == 11 ~ 8,
                  n_levantamento == 12 ~ 9,
                  n_levantamento == 99 ~ 1     # para criar data vai ter que inflacionar um mês
                ),
                ano_levantamento = ifelse(n_levantamento <= 3,
                                          lubridate::year(ano_referencia) - 1,
                                          lubridate::year(ano_referencia)),
                data_levantamento = lubridate::make_date(
                  ano_levantamento, mes, 1)) |>
  dplyr::select(!c(mes, ano_levantamento))

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
