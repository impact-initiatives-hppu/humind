#' #' WASH sectoral composite - add score and dummy for in need
#' #'
#' #' @param df A data frame.
#' #' @
#' #' @param drinking_
#' #' @param fc_phase_levels Levels of the food security phase.
#' #'
#' #' @export
#' comp_wash <- function(
#'     df,
#'     setting,
#'     setting_levels = c("rural", "urban", "camp"),
#'     drinking_water_quantity = "wash_drinking_water_quantity",
#'     drinking_water_quantity_levels = c("never", "rarely", "sometimes", "often", "always", "pnta", "dnk"),
#'     drinking_water_source_cat = "wash_drinking_water_source_cat",
#'     drinking_water_source_levels = c("improved", "unimproved", "surface_water", "undefined"),
#'     drinking_water_time_cat = "wash_drinking_water_time_cat",
#'     drinking_water_time_levels = c("premises", under_30_min", "30min_1hr", "more_than_1hr", "undefined"),
#'
#'
#' )
