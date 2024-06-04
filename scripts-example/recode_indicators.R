rm(list=ls())


# Load packages -----------------------------------------------------------

library(impactR.utils)
library(impactR.kobo)
library(impactR.analysis)
library(humind)
library(srvyr)
library(dplyr)
library(tidyr)

# Prepare datasets --------------------------------------------------------

loop <- left_joints_dup(list(
  loop = dummy_raw_data$roster,
  edu_ind = dummy_raw_data$edu_ind,
  health_ind = dummy_raw_data$health_ind,
  nut_ind = dummy_raw_data$nut_ind),
  person_id,
  uuid)

main <- dummy_raw_data$main |>
  mutate(weight = 1)


# Add indicators ----------------------------------------------------------

#------ Add to loop
loop <- loop |>
  add_age_cat("ind_age") |>
  add_age_18_cat("ind_age") |>
  add_loop_age_dummy("ind_age", 5, 18) |>
  # Education
  add_edu_access_d("edu_access") |>
  # Health
  add_loop_healthcare_needed_cat()


#------- Clean up food security indicators

# Clean hhs
main <- mutate(
  main,
  across(
    c("fsl_hhs_nofoodhh", "fsl_hhs_sleephungry", "fsl_hhs_alldaynight"),
    \(x) case_when(
      x %in% c("dnk", "pnta") ~ NA_character_,
      .default = x
    )
  )
)

# Add to main
main <- main |>
  # Demographics
  add_hoh_final() |>
  add_age_cat("resp_age") |>
  add_age_18_cat("resp_age") |>
  add_age_cat("hoh_age") |>
  add_age_18_cat("hoh_age") |>
  add_loop_age_dummy_to_main(loop, "ind_age_5_18") |>
  # Protection
  add_child_sep_cat() |>
  # Health
  add_loop_healthcare_needed_cat_main(loop) |>
  # WASH
  add_sanitation_facility_cat() |>
  add_sharing_sanitation_facility_cat() |>
  add_sharing_sanitation_facility_num_ind() |>
  add_drinking_water_source_cat() |>
  add_drinking_water_time_cat() |>
  add_drinking_water_time_threshold_cat() |>
  # SNFI
  add_shelter_type_cat() |>
  add_shelter_issue_cat() |>
  add_fds_cannot_cat() |>
  add_occupancy_cat() |>
  # Food security
  add_lcsi() |>
  add_hhs() |>
  add_fcs(cutoffs = "normal") |>
  add_rcsi() |>
  add_fcm_phase() |>
  # Cash & markets
  add_income_source_zero_to_sl() |>
  add_income_source_prop() |>
  add_income_source_cat() |>
  # AAP
  add_received_assistance()



# Add sectoral composites -------------------------------------------------

# Add to main
main <- main |>
  comp_foodsec() |>
  comp_snfi() |>
  comp_prot() |>
  comp_health() |>
  msni()


