# Computing the MSNI: Humind Workflow

Welcome to the humind tutorial. In the following RMarkdown file, we will
go over an example workflow using dummy MSNA data from the 2026 cycle.
The workflow is broken down by function and annotated to describe what
the function does, any key points to keep in mind during use and
required input variables (and their codes). If you have any questions,
or suggestions for improvement, please reach out to the Global MSNA
Team.

## Setup

Below, we load humind and dplyr, as well as the household-level dataset
(main) and Health and Education rosters (loops). We also make sure the
unique identifiers in each are correctly specified, in order to
summarize information from the loop to the main dataset, as is done in
the Health and Education Sectoral Composites.

``` r

library(humind)
library(dplyr)

data(humind_main)
data(humind_health_ind)
data(humind_edu_ind)

id_col_main <- "_uuid"
id_col_loop <- "_submission__uuid"
```

## Food Consumption

### Livelihood Coping Strategies Index (LCSI)

The first step for the Food Consumption Composite is to calculate the
Livelihood Coping Strategies Index (LCSI). The
[`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md)
function identifies whether households have used or exhausted stress,
crisis, or emergency coping strategies and assigns the household to the
highest applicable LCSI category: None, Stress, Crisis, or Emergency.

The example below first combines the host and camp variants of four LCSI
strategies into the variables expected by
[`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md).
This is appropriate where the questionnaire collects mutually exclusive
host/camp versions of the same coping strategy.

**Key considerations**: By default,
[`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md)
expects the response codes yes, no_had_no_need, no_exhausted, and
not_applicable. A household is classified according to the highest level
of coping strategy that it has either used or exhausted. The function
generates fsl_lcsi_cat, as well as separate categories based only on
strategies used (fsl_lcsi_cat_yes) and strategies exhausted
(fsl_lcsi_cat_exhaust). If your questionnaire uses different response
codes, these must be supplied through the corresponding function
arguments.

**Required variables**:

- fsl_lcsi_stress1
- fsl_lcsi_stress2
- fsl_lcsi_stress3
- fsl_lcsi_stress4
- fsl_lcsi_crisis1
- fsl_lcsi_crisis2
- fsl_lcsi_crisis3
- fsl_lcsi_emergency1
- fsl_lcsi_emergency2
- fsl_lcsi_emergency3

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
  add_lcsi()
```

### Food Consumption Score (FCS)

Next, we calculate the Food Consumption Score (FCS) using
[`add_fcs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcs.md).
The function applies the standard food-group weights to the number of
days each food group was consumed during the reference period and
assigns the resulting score to an FCS category.

**Key considerations**: The input variables should contain the number of
days consumed, from 0 to 7. With `cutoffs` = “normal”, households are
classified as Poor when the FCS is ≤21, Borderline when it is \>21 and
≤35, and Acceptable when it is \>35. The alternative cut-offs can be
selected with `cutoffs` = “alternative”, which uses thresholds of 28 and
42 instead. The function generates fsl_fcs_score and fsl_fcs_cat, in
addition to the weighted food-group variables.

**Required variables**:

- fsl_fcs_cereal
- fsl_fcs_legumes
- fsl_fcs_veg
- fsl_fcs_fruit
- fsl_fcs_meat
- fsl_fcs_dairy
- fsl_fcs_sugar
- fsl_fcs_oil

``` r

main_foodsec <- main_foodsec |>
  add_fcs(cutoffs = "normal")
```

### Household Hunger Scale (HHS)

The Household Hunger Scale (HHS) is then calculated using
[`add_hhs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hhs.md).
The function combines the three HHS questions and their corresponding
frequency questions to produce both a general HHS category and an
IPC-compatible HHS category.

**Key considerations**: By default, the function expects yes/no
responses to the three occurrence questions and rarely/sometimes/often
responses to the frequency questions. A no response is scored as 0,
rarely or sometimes as 1, and often as 2 for each item. The resulting
fsl_hhs_score ranges from 0 to 6. The function produces both fsl_hhs_cat
and fsl_hhs_cat_ipc; the latter has the categories None, Little,
Moderate, Severe, and Very Severe. The function also checks consistency
between each yes/no question and its frequency question.

**Required variables**:

- fsl_hhs_nofoodhh
- fsl_hhs_nofoodhh_freq
- fsl_hhs_sleephungry
- fsl_hhs_sleephungry_freq
- fsl_hhs_alldaynight
- fsl_hhs_alldaynight_freq

``` r

main_foodsec <- main_foodsec |>
  add_hhs()
```

### Reduced Coping Strategies Index (rCSI)

The Reduced Coping Strategies Index (rCSI) is calculated using
[`add_rcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_rcsi.md).
The function applies the standard weights to five food-related coping
strategies to produce an overall rCSI score and ordinal category.

**Key considerations**: Input values should range from 0 to 7 days. The
five strategies are weighted respectively 1, 2, 1, 3, and 1, and the
resulting fsl_rcsi_score is classified as No to Low when ≤3, Medium when
\>3 and ≤18, and High when \>18. The function generates both
fsl_rcsi_score and fsl_rcsi_cat.

**Required variables**:

- fsl_rcsi_lessquality
- fsl_rcsi_borrow
- fsl_rcsi_mealsize
- fsl_rcsi_mealadult
- fsl_rcsi_mealnb

``` r

main_foodsec <- main_foodsec |>
  add_rcsi()
```

### Food Consumption Phase

We then calculate the Food Consumption Matrix (FCM) phase using the FCS,
rCSI, and IPC-compatible HHS categories calculated in previous steps.
[`add_fcm_phase()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcm_phase.md)
maps the combination of these three indicators to one of five Food
Consumption phases, from Phase 1 FC to Phase 5 FC.

**Key considerations**: The function uses the default variable names
above and the default category labels: Acceptable, Borderline, and Poor
for FCS; No to Low, Medium, and High for rCSI; and None, Little,
Moderate, Severe, and Very Severe for IPC-compatible HHS. The resulting
variable is fsl_fc_phase, with values from Phase 1 FC to Phase 5 FC. The
function also creates fsl_fc_cell, which identifies the corresponding
cell in the 5×3×3 Food Consumption Matrix.

**Required variables**:

- fsl_fcs_cat
- fsl_rcsi_cat
- fsl_hhs_cat_ipc

``` r

main_foodsec <- main_foodsec |>
  add_fcm_phase()
```

### Food Consumption-Livelihood Coping Matrix (FCLCM)

The Food Consumption-Livelihood Coping Matrix (FCLCM) is then calculated
by combining the Food Consumption phase with the LCSI category. The
resulting phase ranges from Phase 1 FCLC to Phase 5 FCLC.

**Key considerations**: The function uses the default phase labels Phase
1 FC through Phase 5 FC and LCSI categories None, Stress, Crisis, and
Emergency. If either input is missing or contains an unexpected
category, the resulting fclcm_phase is NA.

**Required variables**:

- fsl_fc_phase
- fsl_lcsi_cat

``` r

main_foodsec <- main_foodsec |>
  add_fclcm_phase(lcs_cat_var = "fsl_lcsi_cat")
```

### Food Consumption Sectoral Composite

Finally,
[`add_comp_foodsec()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_foodsec.md)
converts the FCLCM phase directly into the Food Consumption sectoral
composite score. The five FCLCM phases correspond directly to composite
scores from 1 to 5, with the standard MSNI need and severe-need
indicators also generated.

**Key considerations**:
[`add_comp_foodsec()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_foodsec.md)
requires fclcm_phase, which must contain one of the five expected FCLCM
phase labels. The resulting variables are comp_foodsec_score,
comp_foodsec_in_need, and comp_foodsec_in_severe_need. The composite
score is directly mapped from the FCLCM phase, wherein Phase 1 results
in severity level 1 and Phase 5 results in 5.

**Required variables**:

- fclcm_phase

``` r

main_foodsec <- main_foodsec |>
  add_comp_foodsec()
```

## WASH

### Water Quantity (H-WISE)

For WASH, we start with the H-WISE 4 to compute the Water Quantity
dimension. The function below assigns a score from 0 to 3 to each of the
H-WISE variables and directly assigns the severity level based on the
row-wise sum. A new variable called “comp_wash_score_water_quantity” is
generated.

**Key considerations**: The default response codes are never, rarely,
sometimes, often, always, dnk, and pnta. If your data has different
response codes, these need to be specified through the corresponding
function parameters. The `.keep_recoded` parameter can be set to TRUE if
the individual H-WISE item scores are also required.

**Required variables**:

- wash_hwise_drink
- wash_hwise_hands
- wash_hwise_plans
- wash_hwise_worry

``` r

main_wash <- main_foodsec |>
  add_hwise()
```

### Water Quality

Next, we compute the Water Quality dimension. This is based on the type
of drinking water source and the time required to collect drinking
water. The following functions progressively recode these variables into
the categories required to derive the JMP drinking water classification.

**Key considerations**: The function recodes the choices from the global
KOBO template 2026 into the standard categories: improved, unimproved
and surface water. As these categorizations may differ between contexts,
make sure to check that the mapping fits the reality in-country. In case
of any doubts, this can be confirmed with the WASH Cluster.

**Required variables**:

- wash_drinking_water_source

``` r

main_wash <- main_wash |>
  add_drinking_water_source_cat()
```

**Key considerations**: The function uses information on whether water
is available on the premises as well as the reported collection time.
The default response codes and thresholds should be adjusted if the
survey uses different coding.

**Required variables**:

- wash_drinking_water_time_yn
- wash_drinking_water_time_int
- wash_drinking_water_time_sl
- wash_drinking_water_source

``` r

main_wash <- main_wash |>
  add_drinking_water_time_cat()
```

The resulting time-to-fetch-water categories are then classified
according to the standard 30-minute threshold used in the JMP
classification.

**Key considerations**: The default threshold is 30 minutes. This
function should be run after
[`add_drinking_water_time_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md),
as it uses the categorical variable generated in that step.

**Required variables**:

- wash_drinking_water_time_cat

``` r

main_wash <- main_wash |>
  add_drinking_water_time_threshold_cat()
```

The drinking water source and time-to-fetch-water categories are then
combined to generate the JMP drinking water quality classification.

**Key considerations**: This function uses the categories generated by
the two preceding recoding steps, so these functions should be run in
sequence.

**Required variables**:

- wash_drinking_water_source_cat
- wash_drinking_water_time_30min_cat

``` r

main_wash <- main_wash |>
  add_drinking_water_quality_jmp_cat()
```

### Sanitation

We then prepare the variables required to calculate the Sanitation
dimension. First, the type of sanitation facility is recoded into
standard categories.

**Key considerations**: Like for water sources, the function assumes the
mapping to improved and unimproved. Make sure these classifications
apply in your context.

**Required variables**:

- wash_sanitation_facility

``` r

main_wash <- main_wash |>
  add_sanitation_facility_cat()
```

The sanitation facility is then classified according to whether it is
shared with other households.

**Key considerations**: Facilities classified as none are automatically
assigned not_applicable for sharing. The default response codes for the
sharing variable should be adjusted if response codes deviate from the
global KOBO template.

**Required variables**:

- wash_sanitation_facility_sharing_yn
- wash_sanitation_facility

``` r

main_wash <- main_wash |>
 add_sharing_sanitation_facility_cat()
```

The following function estimates the number of individuals using the
sanitation facility. For shared facilities, this is calculated using the
reported number of households sharing the facility and the weighted mean
household size. For facilities that are not shared, the number of
individuals is based on household size.

**Key considerations**: `hh_size` and
`wash_sanitation_facility_sharing_n` must be numeric. The `weight`
variable is used to calculate the weighted mean household size and must
therefore be present even when the analysis is unweighted. For an
unweighted dataset, create a variable called `weight` and set it to 1
for all households, as shown in the example below.

**Required variables**:

- wash_sharing_sanitation_facility_cat
- wash_sanitation_facility_sharing_n
- hh_size
- weight

``` r

main_wash <- main_wash |>
  mutate(weight = 1) |>
  add_sharing_sanitation_facility_n_ind()
```

Using the sanitation facility category and sharing status, we can now
compute the JMP sanitation classification used in the WASH Sectoral
Composite.

**Key considerations**: This function uses the categories generated by
[`add_sanitation_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md)
and
[`add_sharing_sanitation_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md),
so these steps should be run beforehand.

**Required variables**:

- wash_sanitation_facility_cat
- wash_sharing_sanitation_facility_cat

``` r

main_wash <- main_wash |>
  add_sanitation_facility_jmp_cat()
```

### Hygiene

For the last WASH dimension, we calculate the JMP hygiene
classification. The function uses observed and self-reported information
on the availability of a handwashing facility, water, and soap. The
resulting wash_handwashing_facility_jmp_cat variable classifies
households as having a basic, limited, or no_facility handwashing
facility.

**Key considerations**: If the dataset does not contain survey_modality,
this must be added before running the function. For a fully in-person
survey, it can be set to “in_person”, as shown below. The function
distinguishes between observed and reported information depending on the
survey modality. The default soap classification distinguishes
qualifying soap (soap, detergent) from non-qualifying soap
(ash_mud_sand). These parameters can be adjusted if needed.

**Required variables**:

- survey_modality
- wash_handwashing_facility
- wash_handwashing_facility_observed_water_yn
- wash_soap_observed_yn
- wash_handwashing_facility_reported
- wash_handwashing_facility_water_reported_yn
- wash_soap_reported_yn
- wash_soap_observed_type
- wash_soap_reported_type

``` r

main_wash <- main_wash |>
  mutate(survey_modality = "in_person") |>
  add_handwashing_facility_cat()
```

### WASH Sectoral Composite

Finally, we compute the overall WASH Sectoral Composite. The
[`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md)
function combines the water quantity, water quality, sanitation, and
hygiene components to generate the WASH composite score and need
indicator.

**Key considerations**: The setting variable is required because the
WASH composite applies different scoring logic to camp, urban, and rural
settings. By default, the function expects camp_formal and camp_informal
for camp settings, urban for urban settings, and rural for rural
settings. If the dataset uses different setting codes, the corresponding
`setting_camp`, `setting_urban`, and/or `setting_rural` parameters must
be specified.

**Required variables**:

- setting
- comp_wash_score_water_quantity
- wash_drinking_water_quality_jmp_cat
- wash_sanitation_facility_jmp_cat
- wash_sanitation_facility_cat
- wash_sharing_sanitation_facility_n_ind
- wash_sharing_sanitation_facility_cat
- wash_handwashing_facility_jmp_cat

``` r

main_wash <- main_wash |>
  add_comp_wash()
```

## SNFI / HLP

### Shelter Type

We first recode the two shelter type variables into a single global
shelter type category. The function combines the general shelter type
and individual shelter type information and classifies households as
none, inadequate, adequate, or undefined. The resulting variable is
snfi_shelter_type_cat. The function gives priority to responses such as
no shelter or collective centre before applying the individual shelter
type classification.

**Key considerations**: Check that the mapping of shelter types fits
your context. The standard parameters used in the function may differ
from these. In case of doubts, reach out to the Shelter Cluster to
confirm these classifications.

**Required variables**:

- snfi_shelter_type
- snfi_shelter_type_individual

``` r

main_snfi <- main_wash |>
  add_shelter_type_cat()
```

### Shelter Issues

We then calculate the number of shelter issues reported by each
household and convert this into an ordinal category. The function counts
the reported issues across the 11 shelter issue variables and generates
both snfi_shelter_issue_n and snfi_shelter_issue_cat. The resulting
categories are none, 1_to_3, 4_to_7, and 8_to_11, with separate
categories for undefined and other.

**Key considerations**: The list of 11 shelter issues variables should
be standard across all contexts. If you deviate from this, get in touch
with the global MSNA team.

**Required variables**:

- snfi_shelter_issue

``` r

main_snfi <- main_snfi |>
  add_shelter_issue_cat()
```

### Shelter Damages

We next recode the reported shelter damage into a standardized damage
category. The function combines the different damage types and
prioritizes the most severe reported level. The resulting
snfi_shelter_damage_cat variable contains none, damaged, part, total, or
undefined.

**Key considerations**: The damage categories should be standard across
contexts. If any deviations arise, make sure to properly specify these
in the relevant function arguments.

**Required variables**:

- snfi_shelter_damage

``` r

main_snfi <- main_snfi |>
  add_shelter_damage_cat()
```

### Functional Domestic Space (FDS)

We then calculate the number of functional domestic space tasks that
cannot be performed, incorporating cooking, sleeping, storing, and
lighting. The function first standardizes the three domestic task
variables and the lighting source, then creates binary indicators and
sums them to produce snfi_fds_cannot_n. This is subsequently categorized
into snfi_fds_cannot_cat, with categories ranging from no affected tasks
to four affected tasks.

**Key considerations**: The default response codes are yes, no, and
no_need for cooking, and yes/no for sleeping and storing. pnta is
treated as undefined for the three task variables. For lighting, none
indicates no lighting source.

**Required variables**:

- snfi_fds_cooking
- snfi_fds_sleeping
- snfi_fds_storing
- energy_lighting_source

``` r

main_snfi <- main_snfi |>
  add_fds_cannot_cat()
```

### Occupancy Status / Security of Tenure

We then classify occupancy arrangements and eviction risk separately
before combining them into an overall tenure security category.
Occupancy is classified as high, medium, or low risk, while eviction
risk is classified as high or low risk. The resulting
hlp_tenure_security variable takes the highest level of risk across the
two components.

**Key considerations**: By default, no_agreement is high-risk occupancy,
rented and hosted_free are medium-risk, and ownership is low-risk. For
eviction risk, yes is high-risk and no is low-risk. dnk, pnta, and other
are treated as undefined for occupancy, while dnk and pnta are undefined
for eviction risk. The final tenure security category takes the maximum
risk level across occupancy and eviction risk.

**Required variables**:

- hlp_occupancy
- hlp_risk_eviction

``` r

main_snfi <- main_snfi |>
  add_occupancy_cat()
```

### SNFI Sectoral Composite

Finally, we compute the overall SNFI Sectoral Composite. The
[`add_comp_snfi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_snfi.md)
function combines the standardized shelter type, shelter issues, tenure
security, FDS, and shelter damage categories and assigns scores to each
component. It then derives the overall comp_snfi_score, as well as
comp_snfi_in_need and comp_snfi_in_severe_need.

**Key considerations**: The input variables are generated by the
preceding functions and should therefore be created before running
[`add_comp_snfi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_snfi.md).

**Required variables**:

- snfi_shelter_type_cat
- snfi_shelter_issue_cat
- hlp_tenure_security
- snfi_fds_cannot_cat
- snfi_shelter_damage_cat

``` r

main_snfi <- main_snfi |>
  add_comp_snfi()
```

## Protection

### Movement and Access to Public Spaces

We first calculate the Movement and Access to Public Spaces dimension.
The
[`add_prot_score_movement()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_movement.md)
function uses reported safety concerns and changes in movement or
activities to calculate a weighted score. The weighted score is then
converted to a severity score from 1 to 4 that represents the score for
this dimension.

**Key considerations**: All response options are assigned a weight
between 0 and 2. By default, men_avoid_places and men_avoid_night have a
weight of 1, but these can be adjusted in contexts where military
conscription is a characteristic of the crisis. Simply change the
`men_avoid_places_weight` and `men_avoid_night_weight` arguments,
respectively. The resulting variables are comp_prot_score_prot_needs_3
and comp_prot_score_movement.

**Required variables**:

- prot_needs_3_movement

``` r

main_prot <- main_snfi |>
  add_prot_score_movement()
```

### Safe Practices & Activities

We then calculate the Safe Practices and Activities dimension. The
[`add_prot_score_practices()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_practices.md)
function calculates separate weighted scores for restrictions affecting
household members’ ability to carry out activities and participate in
social interactions. These are then combined to produce the overall
comp_prot_score_practices severity score, ranging from 1 to 4.

**Key considerations**: The function creates three variables:
comp_prot_score_prot_needs_2_activities,
comp_prot_score_prot_needs_2_social, and comp_prot_score_practices. Only
if both underlying dimension scores are missing, the overall practices
score is also missing.

**Required variables**:

- prot_needs_2_activities
- prot_needs_2_social

``` r

main_prot <- main_prot |>
  add_prot_score_practices()
#> Warning: Missing input scores detected
#> ℹ `comp_prot_score_prot_needs_2_activities`: 12 NA.
#> ℹ `comp_prot_score_prot_needs_2_social`: 5 NA.
#> ✖ 3 rows have both inputs NA; `comp_prot_score_practices` will be NA for these
#>   rows.
```

### Access Rights & Services

Next, we compute the final Access Rights and Services dimension. As for
the other Protection dimensions, the
[`add_prot_score_rights()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_rights.md)
function calculates separate weighted scores for barriers to accessing
essential services and barriers to accessing justice and legal
resources. These are also combined to produce the comp_prot_score_rights
severity score, ranging from 1 to 4.

**Key considerations**: The different barriers are weighted according to
their severity in the Protection framework. In particular, barriers to
healthcare and schools receive a weight of 2, while other service
barriers generally receive a weight of 1. For justice and legal
resources, difficulty accessing identity and civil documents receives a
weight of 2, while the other specified barriers receive a weight of 1.
dnk and pnta are treated as missing. The function creates three columns:
comp_prot_score_prot_needs_1_services,
comp_prot_score_prot_needs_1_justice, and comp_prot_score_rights.

**Required variables**:

- prot_needs_1_services
- prot_needs_1_justice

``` r

main_prot <- main_prot |>
  add_prot_score_rights()
#> Warning: Missing input scores detected
#> ℹ `comp_prot_score_prot_needs_1_services`: 10 NA.
#> ℹ `comp_prot_score_prot_needs_1_justice`: 35 NA.
```

### Protection Sectoral Composite

Finally, we compute the overall Protection Composite. The
[`add_comp_prot()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_prot.md)
function takes the maximum severity score across the three Protection
dimensions — movement, practices, and rights and services — to generate
the overall Protection severity score (ranging from 1 to 4).

**Key considerations**: None.

**Required variables**:

- comp_prot_score_movement
- comp_prot_score_practices
- comp_prot_score_rights

``` r

main_prot <- main_prot |>
  add_comp_prot()
```

## Health

The Health Sectoral Composite is based on one dimension: Health Needs.
It involves summarizing data from the roster to the main dataset.

We first calculate healthcare need at the individual level using
[`add_loop_healthcare_needed_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_healthcare_needed_cat.md).
The function combines whether an individual needed healthcare with
whether they received it, classifying each individual as having no need,
a met need, or an unmet need. It also creates binary indicators for each
category, which are used in the subsequent household-level aggregation.

**Key considerations**: Individuals reporting that they needed
healthcare but have dnk, pnta, or missing information for whether they
received it cannot be classified as having a met or unmet need and are
therefore assigned NA. The function also creates the variables
health_ind_healthcare_needed_no, health_ind_healthcare_needed_yes_unmet,
and health_ind_healthcare_needed_yes_met, which are used to aggregate
the individual-level results to the household level.

**Required variables**:

- health_ind_healthcare_needed
- health_ind_healthcare_received

``` r

health_ind <- humind_health_ind |>
  add_loop_healthcare_needed_cat()
```

We then use
[`add_loop_healthcare_needed_cat_to_main()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_healthcare_needed_cat.md)
to aggregate the individual-level healthcare need indicators to the
household level. The function counts the number of individuals in each
category within each household and joins these counts back to the main
household dataset.

**Key considerations**: `id_col_main` and `id_col_loop` must identify
the household consistently in the main and individual-level datasets.
The function produces health_ind_healthcare_needed_no_n,
health_ind_healthcare_needed_yes_unmet_n, and
health_ind_healthcare_needed_yes_met_n, representing the number of
individuals in each category per household.

**Required variables**:

- health_ind_healthcare_needed_no
- health_ind_healthcare_needed_yes_unmet
- health_ind_healthcare_needed_yes_met
- id_col_main
- id_col_loop

``` r

main_health <- main_prot |>
  add_loop_healthcare_needed_cat_to_main(
    loop = health_ind,
    id_col_main = id_col_main, id_col_loop = id_col_loop
  )
```

Finally,
[`add_comp_health()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_health.md)
calculates the Health composite score at household level based on the
presence of unmet and met healthcare needs. A household receives a score
of 3 if at least one individual has an unmet healthcare need, 2 if there
is at least one individual with a met healthcare need but no unmet need,
and 1 if individuals in the household report no healthcare need. The
function then generates the standard in_need and in_severe_need
indicators.

**Key considerations**: None.

**Required variables**:

- health_ind_healthcare_needed_no_n
- health_ind_healthcare_needed_yes_unmet_n
- health_ind_healthcare_needed_yes_met_n

``` r

main_health <- main_health |>
  add_comp_health()
```

## Education

### Loop: Preparation

As for Health, Education involves summarizing information in the
individual roster (loop) to the household-level dataset (main). The
first step is to prepare the individual-level education dataset by
identifying children of schooling age. The
[`add_loop_edu_ind_age_corrected()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_ind_age_corrected.md)
function corrects individual age based on the timing of data collection
relative to the start of the school year and creates a binary indicator,
edu_ind_age_schooling, identifying individuals who fall within the
schooling-age population. By default, the schooling-age range is 5–17
years.

**Key considerations**: The `start` variable in the main dataset must be
a date in ISO 8601 format (YYYY-MM-DD). By default, the school year is
assumed to start in September (`school_year_start_month` = 9), and the
schooling-age population is defined as ages 5–17 (`schooling_start_age`
= 5, `schooling_end_age` = 17). These parameters should be adjusted if
the assessment uses a different school-year start month or age range.
Alternatively, a common data-collection month can be specified using the
`month` parameter. The function generates edu_ind_age_corrected and
edu_ind_age_schooling. The default age column is `ind_age`. The example
passes `ind_age = "edu_ind_age"` because the Education loop is
standalone. For other cases, adjust this parameter.

**Required variables**:

- id_col_loop (default: uuid)
- id_col_main (default: uuid)
- edu_ind_age
- start

``` r

edu_ind <- humind_edu_ind |>
  add_loop_edu_ind_age_corrected(
    main = main_health,
    id_col_loop = id_col_loop, id_col_main = id_col_main,
    ind_age = "edu_ind_age"
  )
```

### Loop: Access & Barriers to Education

We then classify whether each school-aged child has access to education.
The function creates two binary variables: edu_ind_access_d, indicating
access to education, and edu_ind_no_access_d, indicating no access to
education. Individuals outside the schooling-age population are assigned
NA.

**Key considerations**: By default, yes indicates access and no
indicates no access. dnk and pnta are treated as missing (NA) rather
than as no access. This step must be run after
[`add_loop_edu_ind_age_corrected()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_ind_age_corrected.md),
as it uses edu_ind_age_schooling.

**Required variables**:

- edu_access
- edu_ind_age_schooling

``` r

edu_ind <- edu_ind |>
  add_loop_edu_access_d()
```

**Key considerations**: By default, the function identifies the
following response codes as protection barriers:

- protection_at_school
- protection_travel_school
- child_work_home
- child_work_outside
- child_armed_group
- child_marriage
- child_pregnancy
- ban
- enroll_lack_documentation
- discrimination

If the survey uses different response codes, or the list of Protection
issues has been contextualized, the `barriers` and `protection_issues`
parameters should be adjusted.

**Required variables**:

- edu_barrier
- edu_ind_age_schooling

``` r

edu_ind <- edu_ind |>
  add_loop_edu_barrier_protection_d()
```

### Loop: Education Disruption

Finally, we identify education disruptions among school-aged children.
The function creates binary indicators for disruption due to attacks,
hazards, displacement, and teacher absence.

**Key considerations**: By default, all four disruption variables use
yes, no, dnk, and pnta as their expected response codes. yes is coded as
1, no as 0, while dnk and pnta are treated as missing. The attack
variable can be set to NULL if this dimension is not collected in the
survey. The function generates binary variables ending with “\_d”, which
are subsequently aggregated to the household level in order to compute
the Education Sectoral Composite.

**Required variables**:

- edu_disrupted_attack
- edu_disrupted_hazards
- edu_disrupted_displaced
- edu_disrupted_teacher
- edu_ind_age_schooling

``` r

edu_ind <- edu_ind |>
  add_loop_edu_disrupted_d()
```

### Main

With the new columns added to the loop, we can now summarize the
information to main.

In the first step, we aggregate the number of school-aged children in
each household. The function sums edu_ind_age_schooling across
individuals linked to the same household and creates
edu_schooling_age_n. Households with no school-aged children are
assigned a value of 0.

**Key considerations**: `id_col_main` and `id_col_loop` must contain
matching household identifiers in the main and loop datasets. The
function uses the individual-level edu_ind_age_schooling variable
generated in the previous section.

**Required variables**:

- edu_ind_age_schooling
- id_col_main (default: uuid)
- id_col_loop (default: uuid)

``` r

main_edu <- main_health |>
  add_loop_edu_ind_schooling_age_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  )
```

### Main: Access & Barriers to Education

We then aggregate the education access indicators to the household
level. The function counts the number of children with access to
education and the number with no access, generating edu_access_n and
edu_no_access_n.

**Key considerations**: The two individual-level indicators are
generated by
[`add_loop_edu_access_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_access_d.md).
The aggregation is performed by household using the specified unique
identifier columns so make sure these are specified correctly.

**Required variables**:

- edu_ind_access_d
- edu_ind_no_access_d
- id_col_main (default: uuid)
- id_col_loop (default: uuid)

``` r

main_edu <- main_edu |>
  add_loop_edu_access_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  )
```

Next, we aggregate the number of school-aged children facing child
protection barriers to the household level. The function generates
edu_barrier_protection_n, representing the number of school-aged
children in the household who face a protection barrier to education.

**Key considerations**: The individual-level protection indicator must
first be generated using
[`add_loop_edu_barrier_protection_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_barrier_protection_d.md).

**Required variables**:

- edu_ind_barrier_protection_d
- id_col_main (default: uuid)
- id_col_loop (default: uuid)

``` r

main_edu <- main_edu |>
  add_loop_edu_barrier_protection_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  )
```

### Main: Education Disruption

Finally, we aggregate the different education disruption indicators to
the household level. The function counts the number of school-aged
children experiencing each type of disruption and generates new columns:
edu_disrupted_attack_n, edu_disrupted_hazards_n,
edu_disrupted_displaced_n, and edu_disrupted_teacher_n.

**Key considerations**: The four disruption indicators used here are
generated by
[`add_loop_edu_disrupted_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_disrupted_d.md).
The attack dimension can be omitted by setting `attack_d` = NULL when
this indicator has been omitted.

**Required variables**:

- edu_ind_age_schooling
- edu_disrupted_attack_d
- edu_disrupted_hazards_d
- edu_disrupted_displaced_d
- edu_disrupted_teacher_d
- id_col_main (default: uuid)
- id_col_loop (default: uuid)

``` r

main_edu <- main_edu |>
  add_loop_edu_disrupted_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  )
```

### Education Sectoral Composite

Finally, we can calculate the Education Sectoral Composite using the
household-level counts generated above.
[`add_comp_edu()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_edu.md)
calculates two component scores based on the two dimensions of the
framework: a disrupted education score and an attendance and barriers
score. The overall Education composite is the maximum of these two
component scores.

The disrupted education score ranges from 1 to 4. A household with no
school-aged children receives a score of 1; disruption due to an attack
results in a score of 4; disruption due to hazards or displacement
results in 3; and teacher absence results in 2.

The attendance and barriers score is 1 where all school-aged children
have access, 3 where at least one school-aged child has no access, and 4
where at least one child has both no access and faces a protection
barrier.

**Key considerations**: All seven required variables must be numeric.
The overall comp_edu_score is calculated as the maximum of the disrupted
education and attendance/barriers scores. The function then generates
comp_edu_in_need and comp_edu_in_severe_need using the standard MSNI
need thresholds. These individual, and subsequently, household-level
variables must therefore all be generated before running
[`add_comp_edu()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_edu.md).

**Required variables**:

- edu_schooling_age_n
- edu_no_access_n
- edu_barrier_protection_n
- edu_disrupted_attack_n
- edu_disrupted_hazards_n
- edu_disrupted_displaced_n
- edu_disrupted_teacher_n

``` r

main_edu <- main_edu |>
  add_comp_edu()
```

## MSNI

Once all sectoral composites have been calculated, we can generate the
overall Multi-sector Needs Index (MSNI) using
[`add_msni()`](https://impact-initiatives-hppu.github.io/humind/reference/add_msni.md).
The function combines the sectoral composite scores and calculates the
overall MSNI severity score and associated indicators of need. The
resulting msni_output dataset can then be used for subsequent analysis
and reporting.

**Key considerations**: All six sectoral composite scores are used to
calculate the overall msni_score, which is the maximum sectoral
composite score. The sectoral composite scores are expected to range
from 1 to 5. The corresponding “\_in_need” and “\_in_severe_need”
variables are used to calculate the number and profile of sectoral
needs.

The Health sector is included in the overall MSNI score and in the
calculation of the number and profile of sectoral needs, but
comp_health_in_severe_need is not an input to the current
[`add_msni()`](https://impact-initiatives-hppu.github.io/humind/reference/add_msni.md)
function, since the maximum severity for Health is 3. Consequently,
Health is not included in sector_in_severe_need_n or
sector_severe_needs_profile in the current implementation.

The function can accommodate missing sectoral composite variables: if
some sectoral scores or indicators are absent, it will issue a warning
and calculate the relevant outputs using the sectors that are available.
Be careful to report this in any output, as missing dimensions and
sectors will result in an under-estimation of need, due to the maximum
approach used in the overall MSNI computation.

The function generates the following seven main output columns that
characterize the needs profile of each household:

- msni_score.
- msni_in_need.
- msni_in_severe_need.
- sector_in_need_n.
- sector_in_severe_need_n.
- sector_needs_profile.
- sector_severe_needs_profile.

**Required variables**:

- comp_edu_score
- comp_foodsec_score
- comp_health_score
- comp_prot_score
- comp_snfi_score
- comp_wash_score
- comp_foodsec_in_need
- comp_snfi_in_need
- comp_wash_in_need
- comp_prot_in_need
- comp_health_in_need
- comp_edu_in_need
- comp_foodsec_in_severe_need
- comp_snfi_in_severe_need
- comp_wash_in_severe_need
- comp_prot_in_severe_need
- comp_edu_in_severe_need

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
#> 2                                 12       6 camp_formal
#> 3                                 NA       3       rural
#> 4                                 NA       4       rural
#> 5                                 NA       7       rural
#> 6                                  2       4       rural
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
#>   comp_prot_score_rights  admin1 fsl_lcsi_stress1 fsl_lcsi_stress2
#> 1                      1 zone_02             <NA>             <NA>
#> 2                      4 zone_05     no_exhausted              yes
#> 3                      3 zone_01              yes              yes
#> 4                      4 zone_02     no_exhausted     no_exhausted
#> 5                      1 zone_02     no_exhausted     no_exhausted
#> 6                      2 zone_02     no_exhausted     no_exhausted
#>   fsl_lcsi_emergency2 fsl_lcsi_emergency3 fsl_lcsi_stress_yes
#> 1                <NA>                <NA>                <NA>
#> 2      no_had_no_need      no_had_no_need                   1
#> 3        no_exhausted        no_exhausted                   1
#> 4        no_exhausted      no_had_no_need                   1
#> 5      no_had_no_need      no_had_no_need                   0
#> 6      not_applicable      no_had_no_need                   1
#>   fsl_lcsi_stress_exhaust fsl_lcsi_stress fsl_lcsi_crisis_yes
#> 1                    <NA>            <NA>                <NA>
#> 2                       1               1                   0
#> 3                       1               1                   0
#> 4                       1               1                   1
#> 5                       1               1                   0
#> 6                       1               1                   1
#>   fsl_lcsi_crisis_exhaust fsl_lcsi_crisis fsl_lcsi_emergency_yes
#> 1                    <NA>            <NA>                   <NA>
#> 2                       0               0                      1
#> 3                       1               1                      0
#> 4                       1               1                      0
#> 5                       1               1                      0
#> 6                       1               1                      1
#>   fsl_lcsi_emergency_exhaust fsl_lcsi_emergency fsl_lcsi_cat_yes
#> 1                       <NA>               <NA>             <NA>
#> 2                          0                  1        Emergency
#> 3                          1                  1           Stress
#> 4                          1                  1           Crisis
#> 5                          0                  0             None
#> 6                          0                  1        Emergency
#>   fsl_lcsi_cat_exhaust fsl_lcsi_cat fcs_weight_cereal1 fcs_weight_legume2
#> 1                 <NA>         <NA>                 NA                 NA
#> 2               Stress    Emergency                 10                  9
#> 3            Emergency    Emergency                  6                  9
#> 4            Emergency    Emergency                 10                  9
#> 5               Crisis       Crisis                 10                 21
#> 6               Crisis    Emergency                 10                  9
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
#>   fsl_fc_cell fsl_fc_phase  fclcm_phase comp_foodsec_score comp_foodsec_in_need
#> 1          NA         <NA>         <NA>                 NA                   NA
#> 2          18   Phase 2 FC Phase 3 FCLC                  3                    1
#> 3          31   Phase 2 FC Phase 3 FCLC                  3                    1
#> 4          18   Phase 2 FC Phase 3 FCLC                  3                    1
#> 5           1   Phase 1 FC Phase 2 FCLC                  2                    0
#> 6          18   Phase 2 FC Phase 3 FCLC                  3                    1
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
#> 4                               basic                   unimproved
#> 5                                <NA>                     improved
#> 6                               basic                   unimproved
#>   wash_sharing_sanitation_facility_cat weight
#> 1                                 <NA>      1
#> 2                               shared      1
#> 3                            undefined      1
#> 4                           not_shared      1
#> 5                           not_shared      1
#> 6                               shared      1
#>   wash_sanitation_facility_sharing_n_calc
#> 1                                      NA
#> 2                               67.798964
#> 3                                      NA
#> 4                                      NA
#> 5                                      NA
#> 6                                9.618088
#>   wash_sharing_sanitation_facility_n_ind wash_sanitation_facility_jmp_cat
#> 1                                   <NA>                             <NA>
#> 2                           50_and_above                          limited
#> 3                                   <NA>                        undefined
#> 4                                   <NA>                       unimproved
#> 5                                   <NA>                            basic
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
#> 6                                 2                                   3
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
#> 1                         NA                   0           NA              NA
#> 2                          0                   2            2               0
#> 3                          0                   0           NA              NA
#> 4                          0                   0           NA              NA
#> 5                          0                   2            2               0
#> 6                          0                   1            1               0
#>   edu_barrier_protection_n edu_disrupted_hazards_n edu_disrupted_displaced_n
#> 1                       NA                      NA                        NA
#> 2                        0                       2                         1
#> 3                       NA                      NA                        NA
#> 4                       NA                      NA                        NA
#> 5                        0                       0                         0
#> 6                        0                       1                         1
#>   edu_disrupted_teacher_n edu_disrupted_attack_n comp_edu_score_disrupted
#> 1                      NA                     NA                        1
#> 2                       2                      0                        3
#> 3                      NA                     NA                        1
#> 4                      NA                     NA                        1
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
