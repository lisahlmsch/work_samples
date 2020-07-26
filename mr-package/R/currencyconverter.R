#' Function that queries historical exchange rates for any currency
#' @param base string
#' @param symbol string
#' @param days number
#' @return data.frame of historic exchange rates
#' @export
#' @importFrom httr GET
#' @importFrom data.table data.table
#' @examples
#' convert_currency(base = 'EUR', symbol = 'USD', days = 2)

convert_currency <- function(base = 'EUR', symbol = 'USD', days = 2) {

  rates <- GET(
    "https://api.exchangeratesapi.io/history",
    query = list(start_at = Sys.Date() - days,
                 end_at = Sys.Date(),
                 base = base,
                 symbols = symbol)
   )

  rates <- content(rates)$rates

  rates <- data.table(date = as.Date(names(rates)),
                       rate = unlist(rates))[order(date)]

  return(rates)
}
