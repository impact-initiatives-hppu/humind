# Helper: generate the exhaustive input grid for add_sharing_sanitation_facility_n_ind().
# Exhaustive grid over every sharing category x a range of raw sharing counts.
# hh_size varies (weight stays 1) so mean_hh_size is not 1 and the sharing-count
# arithmetic in add_sharing_sanitation_facility_n_ind() is genuinely exercised.
# The raw counts are chosen so the derived counts land in every band.
generate_sharing_n_ind_df <- function() {
  sharing_cat_levels <- c("shared", "not_shared", "not_applicable", "undefined")
  tidyr::expand_grid(
    wash_sharing_sanitation_facility_cat = sharing_cat_levels,
    wash_sanitation_facility_sharing_n = c(1, 8, 20, 100),
    hh_size = c(1, 4, 8),
    weight = 1
  )
}
