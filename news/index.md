# Changelog

## humind (development version)

## humind 2026.3.0

This release is a patch/bug-fix round within the 2026 cycle. It tightens
input validation and answer-option handling across WASH and Food
Security functions, fixes inconsistent `NA` handling in
[`add_hhs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hhs.md),
corrects the time-to-fetch-water bucketing in
[`add_drinking_water_source_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md),
and removes the runtime dependency on `impactR.utils`.

------------------------------------------------------------------------

### Codebase Changes

#### Enhancements

- [`add_quantile_interval()`](https://impact-initiatives-hppu.github.io/humind/reference/add_quantile_interval.md)
  no longer depends on `impactR.utils` — the `df_diff` logic is now
  inlined locally
  ([\#709](https://github.com/impact-initiatives-hppu/humind/issues/709)).
- Loop-to-main helpers (`add_loop_*_to_main()`) stop relying on
  `df_diff`; a new internal
  [`drop_shared_loop_cols()`](https://impact-initiatives-hppu.github.io/humind/reference/drop_shared_loop_cols.md)
  handles differing `id_col_main`/`id_col_loop`
  ([\#757](https://github.com/impact-initiatives-hppu/humind/issues/757)).
- [`add_loop_edu_ind_age_corrected()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_ind_age_corrected.md):
  new `schooling_end_age` parameter (default 17) to cap the
  schooling-age population
  ([\#783](https://github.com/impact-initiatives-hppu/humind/issues/783)).

#### Bug Fixes

- [`add_hhs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hhs.md):
  genuinely missing `_freq` responses are recoded to `NA` instead of
  silently to `0`, which previously deflated `fsl_hhs_score`
  ([\#753](https://github.com/impact-initiatives-hppu/humind/issues/753)).
- [`add_hhs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hhs.md):
  added validation for inconsistent yes/no and frequency answer pairs,
  and `NA` scoring for invalid combinations (with warnings/errors)
  ([\#753](https://github.com/impact-initiatives-hppu/humind/issues/753)).
- [`add_drinking_water_time_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md):
  `dnk`/`pnta` recoding aligned with the xlsxform.
- [`add_drinking_water_time_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md):
  30/60-minute bucket boundaries are now inclusive; accepts multiple
  `sl_under_30_min` response codes
  ([\#755](https://github.com/impact-initiatives-hppu/humind/issues/755)).
- [`add_handwashing_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_handwashing_facility_cat.md):
  fixed the `facility_observed_water` default naming; documented
  `survey_modality`
  ([\#759](https://github.com/impact-initiatives-hppu/humind/issues/759)).
- [`add_sharing_sanitation_facility_n_ind()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md):
  checks for the presence of the survey weight column
  ([\#760](https://github.com/impact-initiatives-hppu/humind/issues/760)).
- [`add_loop_edu_access_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_access_d.md):
  `pnta`/`dnk` coded as `NA`, not non-attendance
  ([\#771](https://github.com/impact-initiatives-hppu/humind/issues/771)).
- [`add_comp_edu()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_edu.md):
  households with no school-age children no longer end up as `NA` — the
  education count is coerced to `0`
  ([\#767](https://github.com/impact-initiatives-hppu/humind/issues/767)).

#### Testing

- Added integration tests for
  [`add_drinking_water_time_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md)
  with `threshold_cat`.

#### Breaking Changes

- [`add_drinking_water_time_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md):
  `max` parameter renamed to `max_minutes`.
- [`add_drinking_water_quality_jmp_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md):
  the `safely_managed` classification was removed; improved sources with
  water on premises now classify as `basic`
  ([\#782](https://github.com/impact-initiatives-hppu/humind/issues/782)).
- [`add_sharing_sanitation_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md):
  `skipped_sanitation_facility` now defaults to `c("none")` (previously
  `NULL`); skipped facilities recode to `"not_applicable"` instead of
  `NA`
  ([\#773](https://github.com/impact-initiatives-hppu/humind/issues/773)).

## humind 2026.2.0

This release rolls out the 2026 MSNI framework update across WASH,
Protection, SNFI, Food Security, and Education indicators, including a
new HWISE-4 prerequisite step, a mandatory shelter-damage component, and
several parameter/default changes to match this year’s Kobo form.
**Breaking changes are significant** — read the section below before
upgrading.

------------------------------------------------------------------------

### 2026 Programmatic Changes

- **WASH**
  - Water-quantity scoring is no longer computed inside
    [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md).
    It now requires a pre-computed HWISE-4 score, produced by the new
    [`add_hwise()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hwise.md)
    prerequisite function.
  - Drinking-water-quality severity thresholds shifted to match MSNI
    2026 guidance.
  - The list of “unimproved” sanitation facilities was revised.
  - Default answer-option codes realigned to the updated Kobo form
    across several WASH functions (camp/urban/rural settings, water
    source, time to fetch water, handwashing facility).
- **Protection**
  - The movement composite’s linear scoring formula was replaced with an
    explicit, capped severity scale, and gained a rule to force `NA`
    when only `other_safety_measures` is selected.
  - Movement options split into separate men/boys categories, with new
    optional weight parameters.
  - Two new movement answer options added to
    [`add_prot_score_movement()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_movement.md):
    `women_girls_boys_avoid_firewood` and
    `women_girls_boys_avoid_places` (both weighted 2)
  - [`add_prot_score_rights()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_rights.md)
    gains four new answer options: `yes_therapeutic_services` (w=1),
    `yes_edu_facilities` (w=2), and `yes_social_services` (w=1) in the
    services sub-dimension, and `yes_birth_certificates` (w=1) in the
    justice sub-dimension. Weights for `yes_healthcare` and
    `yes_schools` corrected from 1 to 2. The `yes_other_services`
    (previously weight 1) and `yes_other_services_justice` (previously
    weight 1) are now unweighted and no longer contribute to the
    composite score.
  - [`add_prot_score_practices()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_practices.md):
    `yes_other_activities` (previously weight 2) and `yes_other_social`
    (previously weight 1) are now unweighted and no longer contribute to
    the composite score.
- **SNFI**
  - Shelter damage is now a **mandatory** input to
    [`add_comp_snfi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_snfi.md)
    (previously toggled on/off via a `shelter_damage` argument).
  - Shelter-damage category labels and severity scores were overhauled.
  - Default answer options for domestic-task assessment
    (add_fds_cannot_cat()) adapted to the 2026 framework. The previous
    logic had a mix of affirmative and negative responses resulting in
    FDS severity.
- **Food Security**
  - Severity classification now derived from the Food Consumption &
    Livelihood Coping Matrix (FCLCM) in add_comp_foodsec().
  - [`add_fcs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcs.md),
    [`add_hhs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hhs.md),
    [`add_rcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_rcsi.md),
    [`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md),
    and
    [`add_fcm_phase()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcm_phase.md)
    — previously re-exported from `impactR4PHU` — are now vendored
    locally in `humind`. A new
    [`add_fclcm_phase()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fclcm_phase.md)
    function is added.
- **Education**
  - `edu_ind_schooling_age_d` renamed to `edu_ind_age_schooling` (shared
    default across the education loop functions).
  - `child_pregnancy` added as a recognized protection barrier in
    [`add_loop_edu_barrier_protection_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_barrier_protection_d.md).
- **MSNI**
  - [`add_msni()`](https://impact-initiatives-hppu.github.io/humind/reference/add_msni.md)
    gains `sector_in_severe_need_n` and `sector_severe_needs_profile`
    outputs.

------------------------------------------------------------------------

### Codebase Changes

#### New Features

- [`add_hwise()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hwise.md):
  new function for HWISE-4 water/handwashing scoring, intended as a
  prerequisite step for
  [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md).
- [`add_fclcm_phase()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fclcm_phase.md):
  new function computing the FCLCM phase from FCS, rCSI, HHS, and LCSI
  outputs.
- [`add_msni()`](https://impact-initiatives-hppu.github.io/humind/reference/add_msni.md)
  now returns `sector_in_severe_need_n` and
  `sector_severe_needs_profile`.
- [`add_loop_edu_barrier_protection_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_barrier_protection_d.md)
  recognizes `child_pregnancy` as an additional protection barrier
  (existing codes still match as before).

#### Enhancements

- Strengthened input validation: `sharing_sanitation_facility_cat` added
  to the `if_not_in_stop` check in
  [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md);
  corrected the `are_values_in_set` validation set in
  [`add_drinking_water_quality_jmp_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md).

#### Bug Fixes

- Corrected the all-missing-columns validation check in
  [`add_msni()`](https://impact-initiatives-hppu.github.io/humind/reference/add_msni.md)
  — it previously aborted whenever *any* sectoral composite was missing
  instead of only when *all* of them were; calls with a partial set of
  composites now succeed (with a warning) instead of erroring.
- Fixed a trailing-comma bug in
  [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md)
  (no output change).
- Fixed NSE evaluation and modernized pipe usage in food security
  functions to satisfy `R CMD check` (internal only, no output change).

#### Testing

- Added tests covering the 2026 WASH logic changes, including custom
  value recoding for columns and answer options.
- Added a test verifying `other_safety_measures` does not affect the
  Protection score when combined with other options.
- Added a regression test for
  [`add_shelter_damage_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_shelter_damage_cat.md).
- Added an end-to-end integration test for the food security pipeline
  ([`add_fcs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcs.md)
  →
  [`add_hhs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hhs.md)
  →
  [`add_rcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_rcsi.md)
  →
  [`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md)
  →
  [`add_fcm_phase()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcm_phase.md)
  →
  [`add_fclcm_phase()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fclcm_phase.md)
  →
  [`add_comp_foodsec()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_foodsec.md)).
- Repaired and expanded WASH test fixtures.

#### Documentation

- Clarified that recoded HWISE items are only exposed via
  `.keep_recoded`.
- Regenerated documentation after removing the dead
  `sanitation_facility_jmp_cat_safely_managed` parameter.

#### Dependency Management

- Added `checkmate` to `Imports`.
- Removed the runtime dependency on `impactR4PHU` —
  [`add_fcs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcs.md),
  [`add_hhs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hhs.md),
  [`add_rcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_rcsi.md),
  [`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md),
  and
  [`add_fcm_phase()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcm_phase.md)
  are now vendored locally instead of imported.

#### Breaking Changes

- **Renames**
  - `edu_ind_schooling_age_d` → **`edu_ind_age_schooling`** (shared
    default across
    [`add_loop_edu_access_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_access_d.md),
    [`add_loop_edu_barrier_protection_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_barrier_protection_d.md),
    [`add_loop_edu_disrupted_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_disrupted_d.md)).
  - [`add_comp_foodsec()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_foodsec.md):
    `fc_phase` → **`fclcm_phase`** (default column `"fsl_fc_phase"` →
    `"fclcm_phase"`), and phase labels `"Phase X FC"` →
    **`"Phase X FCLC"`**.
- **WASH**
  - [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md)
    no longer computes water-quantity scoring from raw HWISE-drink
    responses. The `drinking_water_quantity*` parameters are gone; the
    function now requires a pre-computed `comp_wash_hwise_score` column
    (produced by the new
    [`add_hwise()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hwise.md)).
  - [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md):
    `setting_camp` default changed from `"camp"` to
    `c("camp_formal", "camp_informal")`, and matching switched from `==`
    to `%in%` — default callers whose data still uses `"camp"` will no
    longer match.
  - [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md):
    removed the dead `sanitation_facility_jmp_cat_safely_managed`
    parameter (the JMP category function never actually produced that
    value).
  - [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md):
    drinking-water-quality severity thresholds shifted by one level
    across camp/urban/rural branches.
  - [`add_sanitation_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md):
    “unimproved” facility codes changed (dropped
    `flush_elsewhere`/`plastic_bag`; added
    `twin_pit_latrine_wo_slab`/`other_container`).
  - [`add_drinking_water_source_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md):
    default code `protected_spring` → `well_spring`; `sl_under_30_min`
    changed from a free scalar default to a
    [`match.arg()`](https://rdrr.io/r/base/match.arg.html)-constrained
    vector (out-of-set values now error); `water_on_premises` default
    changed from `"water_on_premises"` to
    `c("water_in_dwelling", "water_in_plot")`.
  - [`add_handwashing_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_handwashing_facility_cat.md):
    `facility_undefined` narrowed from `c("other", "pnta")` to
    `"other"`; observed/reported soap and water column-name defaults
    changed to `_yn`-suffixed names, with new value codes
    (e.g. `yes_soap_shown` → `soap_available`).
  - [`add_loop_wgq_ss()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_wgq_ss.md):
    default codes `lot_of_difficulty` → `a_lot_of_difficulty` and
    `cannot_do` → `cannot_do_at_all`.
- **SNFI**
  - [`add_comp_snfi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_snfi.md):
    the `shelter_damage` toggle parameter was removed — shelter damage
    is now always required and always scored (previously optional, off
    by default).
  - [`add_shelter_damage_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_shelter_damage_cat.md):
    default damage-type codes changed (`minor` → `minor_roof`, `major` →
    `major_roof`, `damage_windows_doors` → `windows_doors`,
    `damage_floors` → `floors`, `damage_walls` → `walls`), **and** the
    returned category labels changed entirely:
    `"No damage"/"Damaged"/"Partial collapse or destruction"/ "Total collapse or destruction"/"Undefined"`
    → `"none"/"damaged"/"part"/"total"/"undefined"`.
  - [`add_comp_snfi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_snfi.md):
    shelter-damage severity score scale shifted — `total` 4→5, `part`
    3→4, `damaged` 2→3 (`none` stays 1).
  - [`add_fds_cannot_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fds_cannot_cat.md):
    `fds_cooking_can`/`fds_cooking_cannot` defaults swapped (previously
    backwards: “can cook” defaulted to `"no"`); output category strings
    simplified (`"no_cannot"` → `"no"`).
- **Protection**
  - [`add_prot_score_movement()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_movement.md):
    the linear `comp_prot_score_prot_needs_3 + 1` scoring formula was
    replaced by an explicit, capped scale (`>= 3 ~ 4`, `== 2 ~ 3`,
    `== 1 ~ 2`, `== 0 ~ 1`); the NA rule now also triggers when only
    `other_safety_measures` is selected with a zero score.
  - [`add_prot_score_movement()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_movement.md):
    `men_boys_avoid_places` split into `men_avoid_places` +
    `boys_avoid_places` (same split for `..._avoid_night`), with new
    optional weight parameters (`men_avoid_places_weight`,
    `men_avoid_night_weight`).
  - [`add_prot_score_movement()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_movement.md):
    two new required columns —
    `prot_needs_3_movement/women_girls_boys_avoid_firewood`,
    `prot_needs_3_movement/women_girls_boys_avoid_places`
  - [`add_prot_score_rights()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_rights.md):
    four new required columns —
    `prot_needs_1_services/yes_therapeutic_services`,
    `prot_needs_1_services/yes_edu_facilities`,
    `prot_needs_1_services/yes_social_services`,
    `prot_needs_1_justice/yes_birth_certificates`

## humind 2025.1.4

This release fixes a shelter classification bug affecting tents.

------------------------------------------------------------------------

### 🛠 Codebase Changes

#### 🛠 Bug Fixes

- Reclassify `tent` as an **inadequate** shelter type in
  [`add_shelter_type_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_shelter_type_cat.md)
  (was incorrectly grouped with adequate shelters).

#### 🧪 Testing

- Updated and expanded regression tests to cover tent -\> `inadequate`
  scenarios, including the priority-rule edge cases.

## humind 2025.1.3

This release fixes a Protection bug related to choice-column separator
handling.

------------------------------------------------------------------------

### 🛠 Codebase Changes

#### 🛠 Bug Fixes

- Respect the `sep` argument when constructing choice-column names in
  [`add_prot_score_practices()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_practices.md)
  and
  [`add_prot_score_rights()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_rights.md).
  Both `/` (default) and `.` separators are supported.

#### 🧪 Testing

- Added unit test “the non-default separator does not affect the
  behavior”

## humind 2025.1.2

This release introduces major terminology and logic changes across the
MSNI framework, WASH, Protection, and Healthcare indicators. Several
functions have new required parameters, altered defaults, or renamed
outputs — **breaking changes are significant**.

------------------------------------------------------------------------

### 📖 2025 Programmatic Changes

- **Terminology Migration**  
  All references to *acute need* are migrated to **severe need**, in
  line with 2025 guidance.
  - Function `is_in_acute_need()` is now
    **[`is_in_severe_need()`](https://impact-initiatives-hppu.github.io/humind/reference/is_in_need.md)**.  
  - All composite outputs renamed from `*_in_acute_need` →
    **`*_in_severe_need`** across MSNI, WASH, Health, Food Security,
    SNFI, Education, and Protection.
- **WASH (Handwashing Facilities)**
  - Expanded logic in
    [`add_handwashing_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_handwashing_facility_cat.md)
    to incorporate **soap type** (qualifying vs non-qualifying).  
  - Harmonized observed vs reported classification rules.  
  - Stricter handling of NA values (reported “yes” with NA → now
    “limited”).
- **Healthcare**
  - [`add_loop_healthcare_needed_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_healthcare_needed_cat.md)
    improved to propagate NA correctly and issue explicit warnings.
- **Protection**
  - [`add_prot_score_rights()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_rights.md)
    and
    [`add_prot_score_practices()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_practices.md)
    reworked NA handling: DNK/PNTA now nullifies **sub-scores** rather
    than collapsing the entire composite.  
  - Added diagnostics and warnings for transparency.

------------------------------------------------------------------------

### 🛠 Codebase Changes

#### 🚀 New Features

- **WASH**:
  - Soap-type support in
    [`add_handwashing_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_handwashing_facility_cat.md).  
  - Vectorized handling of “no” codes for water/soap inputs.  
- **Protection**:
  - Warnings when sub-dimension scores are NA.  
  - More robust NA handling in rights and practices composites.  
- **Healthcare**:
  - Warning when `needed == yes` and `received == NA`.

------------------------------------------------------------------------

#### 🔄 Enhancements

- Harmonized observed/reported classification trees for handwashing
  facilities.  
- Row-wise composite score computation for protection.  
- More explicit documentation of function arguments and classification
  logic.

------------------------------------------------------------------------

#### 🛠 Bug Fixes

- Corrected misclassification in reported handwashing facilities where
  NA water/soap previously returned NA instead of “limited.”  
- Fixed inconsistent handling of vector “no” codes in handwashing
  classification.  
- Corrected logic in protection composites to avoid premature collapse
  to NA.

------------------------------------------------------------------------

#### 🧪 Testing

- Exhaustive test grids added for handwashing classification (soap-type
  handling, scalar vs vector inputs).  
- Regression tests ensure new NA/warning behaviors in protection and
  healthcare are validated.  
- Expanded unit tests for new “severe need” naming.

------------------------------------------------------------------------

#### 📚 Documentation

- Updated all function documentation to reflect “severe” terminology.  
- Added detailed decision tree explanation for handwashing facility
  classification.  
- Clarified parameter defaults for composite functions.

------------------------------------------------------------------------

#### ⚠️ Breaking Changes

- **Renames**
  - `is_in_acute_need()` →
    **[`is_in_severe_need()`](https://impact-initiatives-hppu.github.io/humind/reference/is_in_need.md)**.  
  - Output columns: all `*_in_acute_need` → **`*_in_severe_need`**.
- **WASH**
  - [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md)
    default parameter for `drinking_water_quantity` now
    **`wash_hwise_drink`** (was `wash_drinking_water_quantity`).  
  - [`add_handwashing_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_handwashing_facility_cat.md)
    requires new **soap type** columns/args and accepts vectorized “no”
    codes.  
  - Classification rules: soap type can **demote `basic` → `limited`**,
    and NA handling has changed.
- **Protection**
  - DNK/PNTA handling refined: only sub-dimensions become NA; composites
    NA only if **both** subs are NA.
- **Healthcare**
  - [`add_loop_healthcare_needed_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_healthcare_needed_cat.md)
    now returns NA with warnings when `needed == yes` and
    `received == NA`.

------------------------------------------------------------------------

## humind 2025.1.1

This release introduces major updates across protection indicators, SNFI
and shelter categorization, expenditure scoring, testing framework
improvements, dependency management, and documentation. Deprecated WGQ
components are fully removed.

------------------------------------------------------------------------

### 📖 2025 Programmatic Changes

- **Protection**: complete revamp, based on a series of new Tier 1
  indicators related to Protection Needs.

- **SNFI**:

  - Changes to the number of shelter issues and their mapping to the FW
    (from 8 to 11 total issues).
  - Inclusion of one additional indicator to the security of tenure
    dimension: `hlp_eviction_risk.`
  - Hygiene indicator removed from the FDS series - making the total
    number of domestic tasks (and lighting) equal to 4 instead of 5.
  - Optional shelter damages component added.

- **Health**: removal of the WGQs from the framework.

- **WASH**: small changes to incorporate the self-reported hygiene
  variants (availability of soap & water) and map them to the JMP
  classifications.

- **Food Security**: new additional step to analyze the impact of
  livelihood coping strategies on Food Consumption (changes done in
  [impactR4PHU](https://github.com/impact-initiatives/impactR4PHU) and
  reflected in humind).

- **Education**: small changes to indicator naming to reflect “direct
  attack on education”. Indicator name was `edu_disrupted_occupation`
  and is now called `edu_disrupted_attack.` `edu_disrupted_occupation`
  and is now called `edu_disrupted_attack.`

### 🛠 Codebase Changes

#### 🚀 New Features

- **Protection Composite Indicators**
  - Added `add_comp_prot_score()` as main function for computing overall
    Protection Composite.
  - Introduced supporting functions for rights, practices, and
    participation dimensions.

------------------------------------------------------------------------

#### 🔄 Enhancements

- **SNFI & Shelter Categorization**
  - Revised
    [`add_shelter_issue_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_shelter_issue_cat.md)
    logic for better category handling and alignment with 2025
    specifications.
  - Updated
    [`add_comp_snfi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_snfi.md)
    for consistent categorization and explicit handling of special
    cases.
- **Expenditure Indicators**
  - Enhanced infrequent expenditure categorization functions and ranking
    logic.
- **Data Integrity**
  - Composition functions now preserve original data instead of
    overwriting with intermediate steps.

------------------------------------------------------------------------

#### 🛠 Bug Fixes

- Fixed improper handling of invalid inputs in multiple test cases.
- Addressed warnings triggered by implicit handling of
  [`max()`](https://rdrr.io/r/base/Extremes.html) with all-NA vectors.

------------------------------------------------------------------------

#### 🧪 Testing

- Adopted `testthat` best practices across test suites.
- Expanded unit tests for:
  - Protection composite framework
  - Shelter and occupancy categorization
  - Expenditure ranking
- Standardized warning suppression and ensured expected warnings are
  captured.
- Removed obsolete tests linked to deprecated WGQ components.

------------------------------------------------------------------------

#### 📚 Documentation

- Completed function documentation for all updated indicators.
- Updated argument descriptions and clarified logic for SNFI and
  protection functions.
- Removed all references to WGQ components.
- Added Humind 2025 change documentation.

------------------------------------------------------------------------

#### 📦 Dependency Management

- Removed unused packages and implicit dependency on `tibble`.
- Now depends on forked **impactR.utils** package.

------------------------------------------------------------------------

#### ⚠️ Breaking Changes

- Fully removed WGQ-related components and associated tests.
- Deleted obsolete function `add_child_sep_cat.R`.

## humind 2024.1.4

This release covers bug fixes, documentation updates, changes to
parameters, and additional enhancements:

- Documentation updates to better describe function purpose, outputs,
  and prerequisite functions.
- Functions no lover use \_levels but instead use separate parameters.
  ([\#547](https://github.com/impact-initiatives-hppu/humind/issues/547))
- [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md)
  per the MSNI framework, the function was updated for the urban
  categorization “basic which should be score 1 instead of score 2
  ([\#558](https://github.com/impact-initiatives-hppu/humind/issues/558))
- [`add_comp_edu()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_edu.md)
  updates to show comp_edu_score_disrupted as 3 if displaced_n is
  greater than 0, instead of greater than
  1.([\#556](https://github.com/impact-initiatives-hppu/humind/issues/556))
- [`add_comp_health()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_health.md)
  updated so that households with at least one person with a disability
  have the value 3 for comp_health_score
  ([\#550](https://github.com/impact-initiatives-hppu/humind/issues/550))
- [`add_loop_edu_ind_age_corrected()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_ind_age_corrected.md)
  updated to allow custom starting age for education analysis based on
  country-specific requirements
  ([\#549](https://github.com/impact-initiatives-hppu/humind/issues/549))
- [`add_comp_snfi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_snfi.md)
  now correctly categorizes “other”” for snfi_shelter_issue_cat
  ([\#545](https://github.com/impact-initiatives-hppu/humind/issues/545))
- [`add_loop_edu_ind_age_corrected()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_ind_age_corrected.md)
  function error message added for date formats not in the ISO 8601
  format
  ([\#513](https://github.com/impact-initiatives-hppu/humind/issues/513))

## humind 2024.1.3

This release covers bug fixes.

- `comp_edu_score_attendance()` now categorizes households correctly
  when children are not attending school and no protection issue was
  faced.
  ([\#532](https://github.com/impact-initiatives-hppu/humind/issues/532))
- [`add_shelter_issue_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_shelter_issue_cat.md)
  do not add -999 or -998 when the shelter issue is Don’t know or Prefer
  not to answer (it keeps NAs) and “Other” is categorized as others and
  not undefined.
  ([\#534](https://github.com/impact-initiatives-hppu/humind/issues/534))
- [`add_comp_snfi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_snfi.md)
  default values were fixed in documentation.
  ([\#535](https://github.com/impact-initiatives-hppu/humind/issues/535))
- [`add_drinking_water_time_threshold_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md):
  corrected input parameters “under_30min” and “above_30min”.
  ([\#539](https://github.com/impact-initiatives-hppu/humind/issues/539))
- [`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md):
  corrected assigned severities for `comp_wash_score_sanitation` among
  HHs in camps.
  ([\#536](https://github.com/impact-initiatives-hppu/humind/issues/536))

## humind 2024.1.2

This release covers a hot patch, a new function, and enhancements.

- [`add_sanitation_facility_jmp_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md)
  now correctly handles the cases when the sanitation facility is
  improved and not shared
  ([\#522](https://github.com/impact-initiatives-hppu/humind/issues/522))
- A marvelous new function
  [`add_quantile_interval()`](https://impact-initiatives-hppu.github.io/humind/reference/add_quantile_interval.md)
  now allows to add (weighted) quantile intervals columns for any
  numeric variables
  ([\#516](https://github.com/impact-initiatives-hppu/humind/issues/516)),
  for instance for adding income quantiles.
- Some bug fixes for
  [`add_loop_healthcare_needed_cat_to_main()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_healthcare_needed_cat.md)
  and `add_loop_edu_disrupted_d_to_main` when datasets do not name UUI
  columns “uuid”
  ([\#517](https://github.com/impact-initiatives-hppu/humind/issues/517)).
- [`add_age_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_age_cat.md)
  has more intuitive breaks due to a fix and improvement of
  [`num_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/num_cat.md).
  To be able to get the following thresholds: 0-17, 18-59, 60-119, 120+,
  you can write `add_age_cat("resp_age", breaks = c(0, 18, 60, 120))`
  ([\#504](https://github.com/impact-initiatives-hppu/humind/issues/504)).
  Default breaks also changed to the aforementioned ones.
- If occupation by armed groups was not added in country due to
  relevancy,
  [`add_loop_edu_disrupted_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_disrupted_d.md)
  and
  [`add_loop_edu_disrupted_d_to_main()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_disrupted_d.md),
  `occupation` can be set to NULL.

## humind 2024.1.1

This release covers mostly hot patches on a few bugs.

- For perceived protection risks,
  [`add_comp_prot()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_prot.md)
  assigns the score of 1 to a severity level.
  ([\#514](https://github.com/impact-initiatives-hppu/humind/issues/514))
- [`add_msni()`](https://impact-initiatives-hppu.github.io/humind/reference/add_msni.md)
  now correctly handles metrics 3 and 4, adding a missing value when the
  household is not in need
  ([\#509](https://github.com/impact-initiatives-hppu/humind/issues/509),
  [\#510](https://github.com/impact-initiatives-hppu/humind/issues/510))
- `add_comp_wash` has some minor refinements.
  ([\#507](https://github.com/impact-initiatives-hppu/humind/issues/507))
- For total income, loans to friends and from assistance should not be
  considered. Function
  [`add_income_source_prop()`](https://impact-initiatives-hppu.github.io/humind/reference/add_income_source_prop.md)
  now has these two parameters as `NULL` by default. It is still
  possible to include them.
  ([\#506](https://github.com/impact-initiatives-hppu/humind/issues/506))

## humind 2024.1.0

Provides functions to compose usual humanitarian composite indicators
related to IMPACT Multi-Sector Needs Assessments (MSNAs). Such as:

- Food security indicators (rCSI, LCSI, HHS, FCS).
- Washington Group Short Set of questions (WG-SS).
- JMP ladders.
- Specific indicators related to the MSNI framework.

The package follows the ‘Step-Composition’ approach of IMPACT R
framework.

## humind 0.1.900

- Expect many breaking changes as we are moving towards a more
  consistent and coherent package for 2024 MSNAs
- Food security indicators will be imported from impactR4PHU,
  potentially all Public Health functions.

## humind 0.0.5.3

- Bug fix: `rsci()` now correctly adds the `rcsi_score` variable.

## humind 0.0.5.2

- Breaking change: `drinking_water_quantity()` now recodes the
  frequencies of days without drinking water, while
  `drinking_water_quantity_score()` assigns a score on a 5-point scale.
- Added: `time_to_fetch_water_int_char()` and
  `time_to_fetch_water_combine()` to recode and combine both variables
  for the time to fetch water.

## humind 0.0.5.1

- Bug fix and breaking change: `handwashing_facility()` now recodes the
  types of handwashing facility.
- Added: `handwashing_facility_score()` which calculates a score on a
  2-point scale based on `handwashing_facility()`

## humind 0.0.5

- Breaking changes: revamp of all water sources and sanitation
  facilities fonctions with the same approach as the food security
  functions.
- Added: `drinking_water_source()` recodes the types of water sources,
  `time_to_fetch_water()` the time to fetch water according to a chosen
  threshold, and `drinking_water_source_score()` classify each
  household/individual on a 5-point scale.
- Added: `sanitation_facility()` recodes the types of sanitation
  facilities, `sharing_sanitation_facility()` recodes the number of
  people sharing the sanitation facility, and
  `sanitation_facility_score()` classify each household on a 5-point
  scale.

## humind 0.0.4

- Added `water_source()`: Water source 5-point-scale.
- Added `sanitation_facility()`: Sanitation facility 5-point scale.
- Added `handwashing_facility()`: Handwashing facility 2-point scale.
- Added `drinking_water_quantity()`: Drinking water quantity 5-point
  scale.

## humind 0.0.3

- Added `hdds()`: Household Dietary Diversity Scores (HDDS)
  ([\#5](https://github.com/gnoblet/humind/issues/5))
- Added `fies()`: Food Insecurity Experience Scale (FIES)
  [\#6](https://github.com/gnoblet/humind/issues/6)
- Bug fix: error in `lcsi()` on aggregated categories’ names corrected
  ([\#20](https://github.com/impact-initiatives-hppu/humind/issues/20))

## humind 0.0.2

- Added: HWISE functions.
  ([\#16](https://github.com/impact-initiatives-hppu/humind/issues/16))
- Updated: to dplyr v1.1.0 with the
  [`dplyr::case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)
  revamp. (#)
- Modified: dependency know goes to `impactR.utils` and not `impactR`.
  (#)

## humind 0.0.1

- A few patches to github-action and pages

## humind 0.0.0.9000

- Initial commit
