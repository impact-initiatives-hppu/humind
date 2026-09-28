#' Dummy MSNA household (main) data
#'
#' Dummy household-level data modeled on the 2026 MSNA guidance, used to
#' illustrate the `humind` sector-by-sector MSNI pipeline in
#' `vignette("msni-workflow")`.
#'
#' @format A data frame with 5,408 rows and 148 variables, grouped by sector
#'   and prefix:
#'
#'   * `_uuid`: household unique identifier; join key for
#'     [humind_health_ind] and [humind_edu_ind] (via
#'     `_submission__uuid`).
#'   * `fsl_*`: food security items (FCS, HHS, rCSI, LCSI incl.
#'     `_host`/`_camp` variants) -- see [add_fcs()], [add_hhs()],
#'     [add_rcsi()], [add_lcsi()].
#'   * `wash_*`: WASH items (HWISE, drinking water, sanitation,
#'     handwashing) -- see [add_hwise()], [add_sanitation_facility_cat()].
#'   * `snfi_*`, `hlp_*`: shelter, damage, occupancy -- see
#'     [add_shelter_type_cat()], [add_occupancy_cat()].
#'   * `prot_needs_*`: protection movement/practices/rights items -- see
#'     [add_prot_score_movement()].
#'   * `admin1`: geography, for context only; unused by any `add_*()`.
#' @source Dummy data modeled on the 2026 MSNA guidance, for demonstration
#'   purposes only.
"humind_main"

#' Dummy MSNA health loop data
#'
#' Dummy individual-level health data modeled on the 2026 MSNA guidance, used
#' to illustrate the `humind` sector-by-sector MSNI pipeline in
#' `vignette("msni-workflow")`.
#'
#' @format A data frame with 30,300 rows and 3 variables:
#' \describe{
#'   \item{_submission__uuid}{Join key back to [humind_main]'s `_uuid`.}
#'   \item{health_ind_healthcare_needed}{Whether the individual needed
#'     healthcare.}
#'   \item{health_ind_healthcare_received}{Whether the individual received
#'     the healthcare they needed.}
#' }
#' @source Dummy data modeled on the 2026 MSNA guidance, for demonstration
#'   purposes only.
"humind_health_ind"

#' Dummy demo MSNA education loop data
#'
#' Dummy individual-level education data modeled on the 2026 MSNA guidance,
#' used to illustrate the `humind` sector-by-sector MSNI pipeline in
#' `vignette("msni-workflow")`.
#'
#' @format A data frame with 26,630 rows and 8 variables:
#' \describe{
#'   \item{_submission__uuid}{Join key back to [humind_main]'s `_uuid`.}
#'   \item{edu_ind_age}{Individual's age, in years.}
#'   \item{edu_access}{Whether the individual is currently attending
#'     education.}
#'   \item{edu_barrier}{Barriers to education access.}
#'   \item{edu_disrupted_attack, edu_disrupted_hazards,
#'     edu_disrupted_displaced, edu_disrupted_teacher}{Reasons education was
#'     disrupted.}
#' }
#' @source Dummy data modeled on the 2026 MSNA guidance, for demonstration
#'   purposes only.
"humind_edu_ind"
