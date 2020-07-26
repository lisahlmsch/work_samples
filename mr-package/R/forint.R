
#' Formatter function for Hungarian Forint
#' @param x numer
#' @return string
#' @export
#' @importFrom scales dollar
#' @examples
#' forint(100000)
#' forint(10.3232432)
forint <- function(x) {
  dollar(x, prefix = '', suffix = 'HUF')
}
