generate_hwise_df <- function() {
  codes <- c("never", "rarely", "sometimes", "often", "always", "dnk", "pnta")
  tidyr::expand_grid(
    wash_hwise_drink = codes,
    wash_hwise_hands = codes,
    wash_hwise_plans = codes,
    wash_hwise_worry = codes
  )
}
