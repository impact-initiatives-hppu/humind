# MSNI Workflow

## Setup

``` r

library(humind)
library(dplyr)

data(humind_main)
data(humind_health_ind)
data(humind_edu_ind)

id_col_main <- "_uuid"
id_col_loop <- "_submission__uuid"
```

## Food security

``` r

main_foodsec <- humind_main |>
  # This form splits 4 LCSI items into _host/_camp variants that are mutually exclusive
  # coalesce into the single columns add_lcsi() expects.
  mutate(
    fsl_lcsi_stress1 = coalesce(fsl_lcsi_stress1_host, fsl_lcsi_stress1_camp),
    fsl_lcsi_stress2 = coalesce(fsl_lcsi_stress2_host, fsl_lcsi_stress2_camp),
    fsl_lcsi_emergency2 = coalesce(fsl_lcsi_emergency2_host, fsl_lcsi_emergency2_camp),
    fsl_lcsi_emergency3 = coalesce(fsl_lcsi_emergency3_host, fsl_lcsi_emergency3_camp)
  ) |>
  add_fcs(cutoffs = "normal") |>
  add_hhs() |>
  add_rcsi() |>
  add_lcsi() |>
  add_fcm_phase() |>
  add_fclcm_phase(lcs_cat_var = "fsl_lcsi_cat") |>
  add_comp_foodsec()
```

## WASH

``` r

main_wash <- main_foodsec |>
  add_hwise() |>
  add_drinking_water_source_cat() |>
  add_drinking_water_time_cat() |>
  add_drinking_water_time_threshold_cat() |>
  add_drinking_water_quality_jmp_cat() |>
  add_sanitation_facility_cat() |>
  add_sharing_sanitation_facility_cat() |>
  # Form has no survey weight column.
  mutate(weight = 1) |>
  add_sharing_sanitation_facility_n_ind() |>
  add_sanitation_facility_jmp_cat() |>
  # Form has no modality question.
  mutate(survey_modality = "in_person") |>
  add_handwashing_facility_cat() |>
  add_comp_wash()
```

## SNFI / HLP

``` r

main_snfi <- main_wash |>
  add_shelter_type_cat() |>
  add_shelter_issue_cat() |>
  add_shelter_damage_cat() |>
  add_fds_cannot_cat() |>
  add_occupancy_cat() |>
  add_comp_snfi()
```

## Protection

``` r

main_prot <- main_snfi |>
  add_prot_score_movement() |>
  add_prot_score_practices() |>
  add_prot_score_rights() |>
  add_comp_prot()
#> Warning: Missing input scores detected
#> ℹ `comp_prot_score_prot_needs_2_activities`: 12 NA.
#> ℹ `comp_prot_score_prot_needs_2_social`: 5 NA.
#> ✖ 3 rows have both inputs NA; `comp_prot_score_practices` will be NA for these
#>   rows.
#> Warning: Missing input scores detected
#> ℹ `comp_prot_score_prot_needs_1_services`: 10 NA.
#> ℹ `comp_prot_score_prot_needs_1_justice`: 35 NA.
```

## Health

``` r

health_ind <- humind_health_ind |>
  add_loop_healthcare_needed_cat()

main_health <- main_prot |>
  add_loop_healthcare_needed_cat_to_main(
    loop = health_ind,
    id_col_main = id_col_main, id_col_loop = id_col_loop
  ) |>
  add_comp_health()
```

## Education

``` r

edu_ind <- humind_edu_ind |>
  add_loop_edu_ind_age_corrected(
    main = main_health,
    id_col_loop = id_col_loop, id_col_main = id_col_main,
    ind_age = "edu_ind_age"
  ) |>
  add_loop_edu_access_d() |>
  add_loop_edu_barrier_protection_d() |>
  add_loop_edu_disrupted_d()

edu_n_cols <- c(
  "edu_schooling_age_n", "edu_no_access_n", "edu_barrier_protection_n",
  "edu_disrupted_attack_n", "edu_disrupted_hazards_n",
  "edu_disrupted_displaced_n", "edu_disrupted_teacher_n"
)

main_edu <- main_health |>
  add_loop_edu_ind_schooling_age_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  ) |>
  add_loop_edu_access_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  ) |>
  add_loop_edu_barrier_protection_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  ) |>
  add_loop_edu_disrupted_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  ) |>
  # Households with no school-age child never get an edu_ind row, so the
  # joins above leave NA instead of 0 -- add_comp_edu() needs 0 for its
  # "no school-age children -> no need" branch.
  mutate(across(any_of(edu_n_cols), \(x) coalesce(x, 0))) |>
  add_comp_edu()
```

## MSNI

``` r

msni_output <- add_msni(main_edu)
msni_output |> head()
#>      _uuid      start fsl_fcs_cereal fsl_fcs_legumes fsl_fcs_veg fsl_fcs_fruit
#> 1 hh_00001 2026-06-01             NA              NA          NA            NA
#> 2 hh_00002 2026-06-01              5               3           2             6
#> 3 hh_00003 2026-06-01              3               3           3             3
#> 4 hh_00004 2026-06-01              5               3           0             5
#> 5 hh_00005 2026-06-01              5               7           5             4
#> 6 hh_00006 2026-06-01              5               3           0             0
#>   fsl_fcs_meat fsl_fcs_dairy fsl_fcs_sugar fsl_fcs_oil fsl_hhs_nofoodhh
#> 1           NA            NA            NA          NA             <NA>
#> 2            5             4             3           3              yes
#> 3            3             3             3           3               no
#> 4            5             7             7           5              yes
#> 5            7             7             7           7               no
#> 6            5             7             7           5              yes
#>   fsl_hhs_nofoodhh_freq fsl_hhs_sleephungry fsl_hhs_sleephungry_freq
#> 1                  <NA>                <NA>                     <NA>
#> 2             sometimes                 yes                sometimes
#> 3                  <NA>                  no                     <NA>
#> 4                rarely                 yes                sometimes
#> 5                  <NA>                  no                     <NA>
#> 6                rarely                 yes                sometimes
#>   fsl_hhs_alldaynight fsl_hhs_alldaynight_freq fsl_rcsi_lessquality
#> 1                <NA>                     <NA>                   NA
#> 2                 yes                   rarely                    2
#> 3                  no                     <NA>                    3
#> 4                  no                     <NA>                    3
#> 5                  no                     <NA>                    0
#> 6                  no                     <NA>                    3
#>   fsl_rcsi_borrow fsl_rcsi_mealsize fsl_rcsi_mealadult fsl_rcsi_mealnb
#> 1              NA                NA                 NA              NA
#> 2               5                 2                  1               1
#> 3               3                 3                  3               3
#> 4               2                 1                  0               0
#> 5               0                 0                  0               0
#> 6               2                 1                  0               0
#>   fsl_lcsi_stress1_host fsl_lcsi_stress1_camp fsl_lcsi_stress2_host
#> 1                  <NA>                  <NA>                  <NA>
#> 2                  <NA>          no_exhausted                  <NA>
#> 3                   yes                  <NA>                   yes
#> 4          no_exhausted                  <NA>          no_exhausted
#> 5          no_exhausted                  <NA>          no_exhausted
#> 6          no_exhausted                  <NA>          no_exhausted
#>   fsl_lcsi_stress2_camp fsl_lcsi_stress3 fsl_lcsi_stress4 fsl_lcsi_crisis1
#> 1                  <NA>             <NA>             <NA>             <NA>
#> 2                   yes   no_had_no_need   no_had_no_need   no_had_no_need
#> 3                  <NA>   no_had_no_need     no_exhausted     no_exhausted
#> 4                  <NA>              yes     no_exhausted     no_exhausted
#> 5                  <NA>     no_exhausted   no_had_no_need     no_exhausted
#> 6                  <NA>              yes     no_exhausted   no_had_no_need
#>   fsl_lcsi_crisis2 fsl_lcsi_crisis3 fsl_lcsi_emergency1
#> 1             <NA>             <NA>                <NA>
#> 2   no_had_no_need   no_had_no_need                 yes
#> 3     no_exhausted     no_exhausted        no_exhausted
#> 4     no_exhausted              yes      not_applicable
#> 5   no_had_no_need   no_had_no_need      no_had_no_need
#> 6     no_exhausted              yes                 yes
#>   fsl_lcsi_emergency2_host fsl_lcsi_emergency2_camp fsl_lcsi_emergency3_host
#> 1                     <NA>                     <NA>                     <NA>
#> 2                     <NA>           no_had_no_need                     <NA>
#> 3             no_exhausted                     <NA>             no_exhausted
#> 4             no_exhausted                     <NA>           no_had_no_need
#> 5           no_had_no_need                     <NA>           no_had_no_need
#> 6           not_applicable                     <NA>           no_had_no_need
#>   fsl_lcsi_emergency3_camp wash_hwise_drink wash_hwise_hands wash_hwise_plans
#> 1                     <NA>             <NA>             <NA>             <NA>
#> 2           no_had_no_need        sometimes        sometimes           rarely
#> 3                     <NA>        sometimes        sometimes        sometimes
#> 4                     <NA>           rarely        sometimes        sometimes
#> 5                     <NA>            never            never            never
#> 6                     <NA>            often        sometimes        sometimes
#>   wash_hwise_worry hwise4_score comp_wash_score_water_quantity
#> 1             <NA>           NA                             NA
#> 2            often            8                              3
#> 3        sometimes            8                              3
#> 4        sometimes            7                              3
#> 5            never            0                              1
#> 6        sometimes            9                              4
#>   wash_drinking_water_source wash_drinking_water_time_yn
#> 1                       <NA>                        <NA>
#> 2             piped_compound                        <NA>
#> 3                        tap              number_minutes
#> 4             piped_dwelling                        <NA>
#> 5             piped_compound                        <NA>
#> 6             piped_dwelling                        <NA>
#>   wash_drinking_water_time_int wash_drinking_water_time_sl
#> 1                           NA                        <NA>
#> 2                           NA                        <NA>
#> 3                            3                        <NA>
#> 4                           NA                        <NA>
#> 5                           NA                        <NA>
#> 6                           NA                        <NA>
#>   wash_sanitation_facility wash_sanitation_facility_sharing_yn
#> 1                     <NA>                                <NA>
#> 2        flush_pit_latrine                                 yes
#> 3        flush_pit_latrine                                 dnk
#> 4                   bucket                                  no
#> 5        flush_septic_tank                                  no
#> 6         flush_open_drain                                 yes
#>   wash_sanitation_facility_sharing_n hh_size     setting
#> 1                                 NA      NA        <NA>
#> 2                          67.798964       6 camp_formal
#> 3                                 NA       3       rural
#> 4                           4.000000       4       rural
#> 5                           7.000000       7       rural
#> 6                           9.618088       4       rural
#>   wash_handwashing_facility wash_handwashing_facility_observed_water_yn
#> 1                      <NA>                                        <NA>
#> 2          available_mobile                         water_not_available
#> 3          available_mobile                         water_not_available
#> 4                      none                                        <NA>
#> 5   available_fixed_in_plot                             water_available
#> 6             no_permission                                        <NA>
#>   wash_handwashing_facility_reported
#> 1                               <NA>
#> 2                               <NA>
#> 3                               <NA>
#> 4                               <NA>
#> 5                               <NA>
#> 6                         fixed_yard
#>   wash_handwashing_facility_water_reported_yn wash_soap_observed_yn
#> 1                                        <NA>                  <NA>
#> 2                                        <NA>        soap_available
#> 3                                        <NA>    soap_not_available
#> 4                                        <NA>                  <NA>
#> 5                                        <NA>        soap_available
#> 6                                          no                  <NA>
#>   wash_soap_observed_type wash_soap_reported_yn wash_soap_reported_type
#> 1                    <NA>                  <NA>                    <NA>
#> 2               detergent                  <NA>                    <NA>
#> 3                    <NA>                  <NA>                    <NA>
#> 4                    <NA>                  <NA>                    <NA>
#> 5               detergent                  <NA>                    <NA>
#> 6                    <NA>                    no                    <NA>
#>    snfi_shelter_type snfi_shelter_type_individual      snfi_shelter_issue
#> 1               <NA>                         <NA>                    <NA>
#> 2 individual_shelter                    apartment lack_privacy lack_space
#> 3 individual_shelter          unfinished_building            lack_privacy
#> 4 individual_shelter                        house              lack_space
#> 5 individual_shelter                    apartment                    none
#> 6 individual_shelter                    makeshift  lack_space temperature
#>   snfi_shelter_issue/none snfi_shelter_issue/lack_privacy
#> 1                      NA                              NA
#> 2                       0                               1
#> 3                       0                               1
#> 4                       0                               0
#> 5                       1                               0
#> 6                       0                               0
#>   snfi_shelter_issue/lack_space snfi_shelter_issue/temperature
#> 1                            NA                             NA
#> 2                             1                              0
#> 3                             0                              0
#> 4                             1                              0
#> 5                             0                              0
#> 6                             1                              1
#>   snfi_shelter_issue/ventilation snfi_shelter_issue/vectors
#> 1                             NA                         NA
#> 2                              0                          0
#> 3                              0                          0
#> 4                              0                          0
#> 5                              0                          0
#> 6                              0                          0
#>   snfi_shelter_issue/no_natural_light snfi_shelter_issue/leak
#> 1                                  NA                      NA
#> 2                                   0                       0
#> 3                                   0                       0
#> 4                                   0                       0
#> 5                                   0                       0
#> 6                                   0                       0
#>   snfi_shelter_issue/lock snfi_shelter_issue/lack_lighting
#> 1                      NA                               NA
#> 2                       0                                0
#> 3                       0                                0
#> 4                       0                                0
#> 5                       0                                0
#> 6                       0                                0
#>   snfi_shelter_issue/difficulty_move snfi_shelter_issue/lack_space_laundry
#> 1                                 NA                                    NA
#> 2                                  0                                     0
#> 3                                  0                                     0
#> 4                                  0                                     0
#> 5                                  0                                     0
#> 6                                  0                                     0
#>   snfi_shelter_issue/other snfi_shelter_issue/dnk snfi_shelter_issue/pnta
#> 1                       NA                     NA                      NA
#> 2                        0                      0                       0
#> 3                        0                      0                       0
#> 4                        0                      0                       0
#> 5                        0                      0                       0
#> 6                        0                      0                       0
#>   snfi_shelter_damage/none snfi_shelter_damage/minor_roof
#> 1                       NA                             NA
#> 2                        0                              1
#> 3                        0                              0
#> 4                        1                              0
#> 5                        1                              0
#> 6                        0                              1
#>   snfi_shelter_damage/major_roof snfi_shelter_damage/windows_doors
#> 1                             NA                                NA
#> 2                              1                                 0
#> 3                              1                                 0
#> 4                              0                                 0
#> 5                              0                                 0
#> 6                              1                                 0
#>   snfi_shelter_damage/floors snfi_shelter_damage/walls
#> 1                         NA                        NA
#> 2                          0                         0
#> 3                          0                         0
#> 4                          0                         0
#> 5                          0                         0
#> 6                          1                         0
#>   snfi_shelter_damage/total_collapse snfi_shelter_damage/other
#> 1                                 NA                        NA
#> 2                                  0                         0
#> 3                                  0                         0
#> 4                                  0                         0
#> 5                                  0                         0
#> 6                                  0                         0
#>   snfi_shelter_damage/dnk snfi_shelter_damage/pnta snfi_fds_cooking
#> 1                      NA                       NA             <NA>
#> 2                       0                        0              yes
#> 3                       0                        0       no_no_need
#> 4                       0                        0               no
#> 5                       0                        0               no
#> 6                       0                        0               no
#>   snfi_fds_sleeping snfi_fds_storing  energy_lighting_source hlp_occupancy
#> 1              <NA>             <NA>                    <NA>          <NA>
#> 2               yes              yes rechargeable_flashlight   hosted_free
#> 3         undefined               no rechargeable_flashlight        rented
#> 4                no               no             electricity     ownership
#> 5               yes              yes             electricity     ownership
#> 6                no               no                    none     ownership
#>   hlp_risk_eviction prot_needs_3_movement/no_changes_feel_unsafe
#> 1              <NA>                                           NA
#> 2                no                                            0
#> 3                no                                            0
#> 4                no                                            1
#> 5                no                                            0
#> 6               yes                                            0
#>   prot_needs_3_movement/no_safety_concerns
#> 1                                       NA
#> 2                                        0
#> 3                                        0
#> 4                                        0
#> 5                                        1
#> 6                                        1
#>   prot_needs_3_movement/women_girls_avoid_places
#> 1                                             NA
#> 2                                              1
#> 3                                              1
#> 4                                              0
#> 5                                              0
#> 6                                              0
#>   prot_needs_3_movement/men_avoid_places
#> 1                                     NA
#> 2                                      0
#> 3                                      0
#> 4                                      0
#> 5                                      0
#> 6                                      0
#>   prot_needs_3_movement/boys_avoid_places
#> 1                                      NA
#> 2                                       1
#> 3                                       0
#> 4                                       0
#> 5                                       0
#> 6                                       0
#>   prot_needs_3_movement/women_girls_avoid_night
#> 1                                            NA
#> 2                                             1
#> 3                                             0
#> 4                                             0
#> 5                                             0
#> 6                                             0
#>   prot_needs_3_movement/men_avoid_night prot_needs_3_movement/boys_avoid_night
#> 1                                    NA                                     NA
#> 2                                     0                                      1
#> 3                                     0                                      0
#> 4                                     0                                      0
#> 5                                     0                                      0
#> 6                                     0                                      0
#>   prot_needs_3_movement/girls_boys_avoid_school
#> 1                                            NA
#> 2                                             0
#> 3                                             0
#> 4                                             0
#> 5                                             0
#> 6                                             0
#>   prot_needs_3_movement/different_routes prot_needs_3_movement/avoid_markets
#> 1                                     NA                                  NA
#> 2                                      1                                   1
#> 3                                      0                                   0
#> 4                                      0                                   0
#> 5                                      0                                   0
#> 6                                      0                                   0
#>   prot_needs_3_movement/avoid_public_offices prot_needs_3_movement/avoid_fields
#> 1                                         NA                                 NA
#> 2                                          1                                  0
#> 3                                          0                                  0
#> 4                                          0                                  0
#> 5                                          0                                  0
#> 6                                          0                                  0
#>   prot_needs_3_movement/women_girls_boys_avoid_firewood
#> 1                                                    NA
#> 2                                                     1
#> 3                                                     0
#> 4                                                     0
#> 5                                                     0
#> 6                                                     0
#>   prot_needs_3_movement/women_girls_boys_avoid_places
#> 1                                                  NA
#> 2                                                   0
#> 3                                                   0
#> 4                                                   0
#> 5                                                   0
#> 6                                                   0
#>   prot_needs_3_movement/other_safety_measures prot_needs_3_movement/dnk
#> 1                                          NA                        NA
#> 2                                           0                         0
#> 3                                           0                         0
#> 4                                           0                         0
#> 5                                           0                         0
#> 6                                           0                         0
#>   prot_needs_3_movement/pnta comp_prot_score_prot_needs_3
#> 1                         NA                            0
#> 2                          0                           15
#> 3                          0                            2
#> 4                          0                            1
#> 5                          0                            0
#> 6                          0                            0
#>   comp_prot_score_movement prot_needs_2_activities/yes_work
#> 1                        1                               NA
#> 2                        4                                1
#> 3                        3                                0
#> 4                        2                                1
#> 5                        1                                0
#> 6                        1                                0
#>   prot_needs_2_activities/yes_livelihood prot_needs_2_activities/yes_safety
#> 1                                     NA                                 NA
#> 2                                      1                                  0
#> 3                                      1                                  0
#> 4                                      1                                  1
#> 5                                      0                                  0
#> 6                                      0                                  0
#>   prot_needs_2_activities/yes_farm prot_needs_2_activities/yes_water
#> 1                               NA                                NA
#> 2                                1                                 0
#> 3                                0                                 0
#> 4                                0                                 0
#> 5                                0                                 0
#> 6                                1                                 0
#>   prot_needs_2_activities/yes_other_activities
#> 1                                           NA
#> 2                                            0
#> 3                                            0
#> 4                                            0
#> 5                                            0
#> 6                                            0
#>   prot_needs_2_activities/yes_free_choices prot_needs_2_activities/no
#> 1                                       NA                         NA
#> 2                                        0                          0
#> 3                                        0                          0
#> 4                                        0                          0
#> 5                                        0                          1
#> 6                                        0                          0
#>   prot_needs_2_activities/dnk prot_needs_2_activities/pnta
#> 1                          NA                           NA
#> 2                           0                            0
#> 3                           0                            0
#> 4                           0                            0
#> 5                           0                            0
#> 6                           0                            0
#>   prot_needs_2_social/yes_visiting_family
#> 1                                      NA
#> 2                                       1
#> 3                                       0
#> 4                                       1
#> 5                                       0
#> 6                                       0
#>   prot_needs_2_social/yes_visiting_friends
#> 1                                       NA
#> 2                                        0
#> 3                                        0
#> 4                                        0
#> 5                                        0
#> 6                                        0
#>   prot_needs_2_social/yes_community_events
#> 1                                       NA
#> 2                                        1
#> 3                                        1
#> 4                                        1
#> 5                                        0
#> 6                                        0
#>   prot_needs_2_social/yes_joining_groups prot_needs_2_social/yes_other_social
#> 1                                     NA                                   NA
#> 2                                      0                                    0
#> 3                                      0                                    0
#> 4                                      0                                    0
#> 5                                      0                                    0
#> 6                                      0                                    0
#>   prot_needs_2_social/yes_child_recreation
#> 1                                       NA
#> 2                                        0
#> 3                                        0
#> 4                                        0
#> 5                                        0
#> 6                                        0
#>   prot_needs_2_social/yes_decision_making prot_needs_2_social/no
#> 1                                      NA                     NA
#> 2                                       0                      0
#> 3                                       0                      0
#> 4                                       0                      0
#> 5                                       0                      1
#> 6                                       0                      1
#>   prot_needs_2_social/dnk prot_needs_2_social/pnta
#> 1                      NA                       NA
#> 2                       0                        0
#> 3                       0                        0
#> 4                       0                        0
#> 5                       0                        0
#> 6                       0                        0
#>   comp_prot_score_prot_needs_2_activities comp_prot_score_prot_needs_2_social
#> 1                                       0                                   0
#> 2                                       3                                   2
#> 3                                       1                                   1
#> 4                                       3                                   2
#> 5                                       0                                   0
#> 6                                       1                                   0
#>   comp_prot_score_practices prot_needs_1_services/yes_healthcare
#> 1                         1                                   NA
#> 2                         4                                    1
#> 3                         3                                    0
#> 4                         4                                    1
#> 5                         1                                    0
#> 6                         2                                    0
#>   prot_needs_1_services/yes_schools
#> 1                                NA
#> 2                                 1
#> 3                                 1
#> 4                                 0
#> 5                                 0
#> 6                                 0
#>   prot_needs_1_services/yes_therapeutic_services
#> 1                                             NA
#> 2                                              1
#> 3                                              0
#> 4                                              0
#> 5                                              0
#> 6                                              0
#>   prot_needs_1_services/yes_edu_facilities
#> 1                                       NA
#> 2                                        1
#> 3                                        0
#> 4                                        0
#> 5                                        0
#> 6                                        0
#>   prot_needs_1_services/yes_social_services
#> 1                                        NA
#> 2                                         1
#> 3                                         0
#> 4                                         0
#> 5                                         0
#> 6                                         0
#>   prot_needs_1_services/yes_gov_services
#> 1                                     NA
#> 2                                      1
#> 3                                      0
#> 4                                      0
#> 5                                      0
#> 6                                      1
#>   prot_needs_1_services/yes_other_services prot_needs_1_services/none
#> 1                                       NA                         NA
#> 2                                        1                          0
#> 3                                        0                          0
#> 4                                        0                          0
#> 5                                        0                          1
#> 6                                        0                          0
#>   prot_needs_1_services/dnk prot_needs_1_services/pnta
#> 1                        NA                         NA
#> 2                         0                          0
#> 3                         0                          0
#> 4                         0                          0
#> 5                         0                          0
#> 6                         0                          0
#>   prot_needs_1_justice/yes_identity_documents
#> 1                                          NA
#> 2                                           1
#> 3                                           0
#> 4                                           1
#> 5                                           0
#> 6                                           0
#>   prot_needs_1_justice/yes_counselling_legal
#> 1                                         NA
#> 2                                          0
#> 3                                          1
#> 4                                          0
#> 5                                          0
#> 6                                          0
#>   prot_needs_1_justice/yes_property_docs prot_needs_1_justice/yes_gov_services
#> 1                                     NA                                    NA
#> 2                                      1                                     0
#> 3                                      0                                     0
#> 4                                      0                                     1
#> 5                                      0                                     0
#> 6                                      0                                     0
#>   prot_needs_1_justice/yes_birth_certificates
#> 1                                          NA
#> 2                                           1
#> 3                                           0
#> 4                                           0
#> 5                                           0
#> 6                                           0
#>   prot_needs_1_justice/yes_other_services prot_needs_1_justice/no
#> 1                                      NA                      NA
#> 2                                       1                       0
#> 3                                       0                       0
#> 4                                       0                       0
#> 5                                       0                       1
#> 6                                       0                       0
#>   prot_needs_1_justice/dnk prot_needs_1_justice/pnta
#> 1                       NA                        NA
#> 2                        0                         0
#> 3                        0                         0
#> 4                        0                         0
#> 5                        0                         0
#> 6                        0                         0
#>   comp_prot_score_prot_needs_1_services comp_prot_score_prot_needs_1_justice
#> 1                                     0                                    0
#> 2                                     9                                    4
#> 3                                     2                                    1
#> 4                                     2                                    3
#> 5                                     0                                    0
#> 6                                     1                                    0
#>   comp_prot_score_rights    admin1 fsl_lcsi_stress1 fsl_lcsi_stress2
#> 1                      1 county_02             <NA>             <NA>
#> 2                      4 county_05     no_exhausted              yes
#> 3                      3 county_01              yes              yes
#> 4                      4 county_02     no_exhausted     no_exhausted
#> 5                      1 county_02     no_exhausted     no_exhausted
#> 6                      2 county_02     no_exhausted     no_exhausted
#>   fsl_lcsi_emergency2 fsl_lcsi_emergency3 fcs_weight_cereal1 fcs_weight_legume2
#> 1                <NA>                <NA>                 NA                 NA
#> 2      no_had_no_need      no_had_no_need                 10                  9
#> 3        no_exhausted        no_exhausted                  6                  9
#> 4        no_exhausted      no_had_no_need                 10                  9
#> 5      no_had_no_need      no_had_no_need                 10                 21
#> 6      not_applicable      no_had_no_need                 10                  9
#>   fcs_weight_dairy3 fcs_weight_meat4 fcs_weight_veg5 fcs_weight_fruit6
#> 1                NA               NA              NA                NA
#> 2                16               20               2                 6
#> 3                12               12               3                 3
#> 4                28               20               0                 5
#> 5                28               28               5                 4
#> 6                28               20               0                 0
#>   fcs_weight_oil7 fcs_weight_sugar8 fsl_fcs_score fsl_fcs_cat
#> 1              NA                NA            NA        <NA>
#> 2             1.5               1.5            66  Acceptable
#> 3             1.5               1.5            48  Acceptable
#> 4             2.5               3.5            78  Acceptable
#> 5             3.5               3.5           103  Acceptable
#> 6             2.5               3.5            73  Acceptable
#>   fsl_hhs_nofoodhh_recoded fsl_hhs_nofoodhh_freq_recoded
#> 1                       NA                            NA
#> 2                        1                             1
#> 3                        0                             0
#> 4                        1                             1
#> 5                        0                             0
#> 6                        1                             1
#>   fsl_hhs_sleephungry_recoded fsl_hhs_sleephungry_freq_recoded
#> 1                          NA                               NA
#> 2                           1                                1
#> 3                           0                                0
#> 4                           1                                1
#> 5                           0                                0
#> 6                           1                                1
#>   fsl_hhs_alldaynight_recoded fsl_hhs_alldaynight_freq_recoded fsl_hhs_comp1
#> 1                          NA                               NA            NA
#> 2                           1                                1             1
#> 3                           0                                0             0
#> 4                           0                                0             1
#> 5                           0                                0             0
#> 6                           0                                0             1
#>   fsl_hhs_comp2 fsl_hhs_comp3 fsl_hhs_score fsl_hhs_cat_ipc  fsl_hhs_cat
#> 1            NA            NA            NA            <NA>         <NA>
#> 2             1             1             3        Moderate     Moderate
#> 3             0             0             0            None Little to No
#> 4             1             0             2        Moderate     Moderate
#> 5             0             0             0            None Little to No
#> 6             1             0             2        Moderate     Moderate
#>   rcsi_lessquality_weighted rcsi_borrow_weighted rcsi_mealsize_weighted
#> 1                        NA                   NA                     NA
#> 2                         2                   10                      2
#> 3                         3                    6                      3
#> 4                         3                    4                      1
#> 5                         0                    0                      0
#> 6                         3                    4                      1
#>   rcsi_mealadult_weighted rcsi_mealnb_weighted fsl_rcsi_score fsl_rcsi_cat
#> 1                      NA                   NA             NA         <NA>
#> 2                       3                    1             18       Medium
#> 3                       9                    3             24         High
#> 4                       0                    0              8       Medium
#> 5                       0                    0              0    No to Low
#> 6                       0                    0              8       Medium
#>   fsl_lcsi_stress_yes fsl_lcsi_stress_exhaust fsl_lcsi_stress
#> 1                <NA>                    <NA>            <NA>
#> 2                   1                       1               1
#> 3                   1                       1               1
#> 4                   1                       1               1
#> 5                   0                       1               1
#> 6                   1                       1               1
#>   fsl_lcsi_crisis_yes fsl_lcsi_crisis_exhaust fsl_lcsi_crisis
#> 1                <NA>                    <NA>            <NA>
#> 2                   0                       0               0
#> 3                   0                       1               1
#> 4                   1                       1               1
#> 5                   0                       1               1
#> 6                   1                       1               1
#>   fsl_lcsi_emergency_yes fsl_lcsi_emergency_exhaust fsl_lcsi_emergency
#> 1                   <NA>                       <NA>               <NA>
#> 2                      1                          0                  1
#> 3                      0                          1                  1
#> 4                      0                          1                  1
#> 5                      0                          0                  0
#> 6                      1                          0                  1
#>   fsl_lcsi_cat_yes fsl_lcsi_cat_exhaust fsl_lcsi_cat fsl_fc_cell fsl_fc_phase
#> 1             <NA>                 <NA>         <NA>          NA         <NA>
#> 2        Emergency               Stress    Emergency          18   Phase 2 FC
#> 3           Stress            Emergency    Emergency          31   Phase 2 FC
#> 4           Crisis            Emergency    Emergency          18   Phase 2 FC
#> 5             None               Crisis       Crisis           1   Phase 1 FC
#> 6        Emergency               Crisis    Emergency          18   Phase 2 FC
#>    fclcm_phase comp_foodsec_score comp_foodsec_in_need
#> 1         <NA>                 NA                   NA
#> 2 Phase 3 FCLC                  3                    1
#> 3 Phase 3 FCLC                  3                    1
#> 4 Phase 3 FCLC                  3                    1
#> 5 Phase 2 FCLC                  2                    0
#> 6 Phase 3 FCLC                  3                    1
#>   comp_foodsec_in_severe_need wash_drinking_water_source_cat
#> 1                          NA                           <NA>
#> 2                           0                       improved
#> 3                           0                       improved
#> 4                           0                       improved
#> 5                           0                       improved
#> 6                           0                       improved
#>   wash_drinking_water_time_cat wash_drinking_water_time_30min_cat
#> 1                         <NA>                               <NA>
#> 2                         <NA>                               <NA>
#> 3                 under_30_min                        under_30min
#> 4                     premises                           premises
#> 5                         <NA>                               <NA>
#> 6                     premises                           premises
#>   wash_drinking_water_quality_jmp_cat wash_sanitation_facility_cat
#> 1                                <NA>                         <NA>
#> 2                                <NA>                     improved
#> 3                               basic                     improved
#> 4                      safely_managed                   unimproved
#> 5                                <NA>                     improved
#> 6                      safely_managed                   unimproved
#>   wash_sharing_sanitation_facility_cat weight
#> 1                                 <NA>      1
#> 2                               shared      1
#> 3                            undefined      1
#> 4                           not_shared      1
#> 5                           not_shared      1
#> 6                               shared      1
#>   wash_sharing_sanitation_facility_n_ind wash_sanitation_facility_jmp_cat
#> 1                                   <NA>                             <NA>
#> 2                           50_and_above                          limited
#> 3                                   <NA>                        undefined
#> 4                           19_and_below                       unimproved
#> 5                           19_and_below                            basic
#> 6                           19_and_below                       unimproved
#>   survey_modality wash_handwashing_facility_jmp_cat
#> 1       in_person                              <NA>
#> 2       in_person                           limited
#> 3       in_person                           limited
#> 4       in_person                       no_facility
#> 5       in_person                             basic
#> 6       in_person                           limited
#>   comp_wash_score_water_quality comp_wash_score_sanitation
#> 1                            NA                         NA
#> 2                            NA                          4
#> 3                             1                         NA
#> 4                             1                          2
#> 5                            NA                          1
#> 6                             1                          2
#>   comp_wash_score_hygiene comp_wash_score comp_wash_in_need
#> 1                      NA              NA                NA
#> 2                       2               4                 1
#> 3                       2               3                 1
#> 4                       2               3                 1
#> 5                       1               1                 0
#> 6                       2               4                 1
#>   comp_wash_in_severe_need snfi_shelter_type_cat snfi_shelter_issue_n
#> 1                       NA                  <NA>                    0
#> 2                        1              adequate                    2
#> 3                        0            inadequate                    1
#> 4                        0              adequate                    1
#> 5                        0              adequate                    0
#> 6                        1            inadequate                    2
#>   snfi_shelter_issue_cat snfi_shelter_damage_cat snfi_fds_cooking_d
#> 1                   none                    <NA>                 NA
#> 2                 1_to_3                    part                  0
#> 3                 1_to_3                    part                  0
#> 4                 1_to_3                    none                  1
#> 5                   none                    none                  1
#> 6                 1_to_3                    part                  1
#>   snfi_fds_sleeping_d snfi_fds_storing_d energy_lighting_source_d
#> 1                  NA                 NA                       NA
#> 2                   0                  0                        0
#> 3                  NA                  1                        0
#> 4                   1                  1                        0
#> 5                   0                  0                        0
#> 6                   1                  1                        1
#>   snfi_fds_cannot_n snfi_fds_cannot_cat hlp_occupancy_cat hlp_eviction_cat
#> 1                NA                <NA>              <NA>             <NA>
#> 2                 0                none       medium_risk         low_risk
#> 3                NA                <NA>       medium_risk         low_risk
#> 4                 3        2_to_3_tasks          low_risk         low_risk
#> 5                 1              1_task          low_risk         low_risk
#> 6                 4             4_tasks          low_risk        high_risk
#>   hlp_tenure_security comp_snfi_score_shelter_type_cat
#> 1                <NA>                               NA
#> 2         medium_risk                                1
#> 3         medium_risk                                3
#> 4            low_risk                                1
#> 5            low_risk                                1
#> 6           high_risk                                3
#>   comp_snfi_score_shelter_issue_cat comp_snfi_score_tenure_security_cat
#> 1                                 1                                  NA
#> 2                                 2                                   2
#> 3                                 2                                   2
#> 4                                 2                                   1
#> 5                                 1                                   1
#> 6                                 2                                   1
#>   comp_snfi_score_fds_cannot_cat comp_snfi_score_shelter_damage_cat
#> 1                             NA                                 NA
#> 2                              1                                  4
#> 3                             NA                                  4
#> 4                              3                                  1
#> 5                              2                                  1
#> 6                              4                                  4
#>   comp_snfi_score comp_snfi_in_need comp_snfi_in_severe_need comp_prot_score
#> 1               1                 0                        0               1
#> 2               4                 1                        1               4
#> 3               4                 1                        1               3
#> 4               3                 1                        0               4
#> 5               2                 0                        0               1
#> 6               4                 1                        1               2
#>   comp_prot_in_need comp_prot_in_severe_need health_ind_healthcare_needed_no_n
#> 1                 0                        0                                NA
#> 2                 1                        1                                 1
#> 3                 1                        0                                 2
#> 4                 1                        1                                 0
#> 5                 0                        0                                 5
#> 6                 0                        0                                 2
#>   health_ind_healthcare_needed_yes_unmet_n
#> 1                                       NA
#> 2                                        0
#> 3                                        0
#> 4                                        1
#> 5                                        0
#> 6                                        2
#>   health_ind_healthcare_needed_yes_met_n comp_health_score comp_health_in_need
#> 1                                     NA                NA                  NA
#> 2                                      4                 2                   0
#> 3                                      0                 1                   0
#> 4                                      3                 3                   1
#> 5                                      1                 2                   0
#> 6                                      0                 3                   1
#>   comp_health_in_severe_need edu_schooling_age_n edu_access_n edu_no_access_n
#> 1                         NA                   0           NA               0
#> 2                          0                   2            2               0
#> 3                          0                   0           NA               0
#> 4                          0                   0           NA               0
#> 5                          0                   2            2               0
#> 6                          0                   1            1               0
#>   edu_barrier_protection_n edu_disrupted_hazards_n edu_disrupted_displaced_n
#> 1                        0                       0                         0
#> 2                        0                       2                         1
#> 3                        0                       0                         0
#> 4                        0                       0                         0
#> 5                        0                       0                         0
#> 6                        0                       1                         1
#>   edu_disrupted_teacher_n edu_disrupted_attack_n comp_edu_score_disrupted
#> 1                       0                      0                        1
#> 2                       2                      0                        3
#> 3                       0                      0                        1
#> 4                       0                      0                        1
#> 5                       0                      0                        1
#> 6                       1                      0                        3
#>   comp_edu_score_attendance comp_edu_score comp_edu_in_need
#> 1                         1              1                0
#> 2                         1              3                1
#> 3                         1              1                0
#> 4                         1              1                0
#> 5                         1              1                0
#> 6                         1              3                1
#>   comp_edu_in_severe_need msni_score msni_in_need msni_in_severe_need
#> 1                       0          1            0                   0
#> 2                       0          4            1                   1
#> 3                       0          4            1                   1
#> 4                       0          4            1                   1
#> 5                       0          2            0                   0
#> 6                       0          4            1                   1
#>   sector_in_need_n sector_in_severe_need_n
#> 1               NA                      NA
#> 2                5                       3
#> 3                4                       1
#> 4                5                       1
#> 5               NA                      NA
#> 6                5                       2
#>                                   sector_needs_profile
#> 1                                                 <NA>
#> 2 Food security - SNFI - WASH - Protection - Education
#> 3             Food security - SNFI - WASH - Protection
#> 4    Food security - SNFI - WASH - Protection - Health
#> 5                                                 <NA>
#> 6     Food security - SNFI - WASH - Health - Education
#>   sector_severe_needs_profile
#> 1                        <NA>
#> 2    SNFI - WASH - Protection
#> 3                        SNFI
#> 4                  Protection
#> 5                        <NA>
#> 6                 SNFI - WASH
```
