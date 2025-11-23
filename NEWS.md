# humind (development version)

# humind 2025.1.4

This release fixes a shelter classification bug affecting tents.

---

## 🛠 Codebase Changes

### 🛠 Bug Fixes

* Reclassify `tent` as an **inadequate** shelter type in `add_shelter_type_cat()` (was incorrectly grouped with adequate shelters).

### 🧪 Testing

* Updated and expanded regression tests to cover tent -> `inadequate` scenarios, including the priority-rule edge cases.

# humind 2025.1.3

This release fixes a Protection bug related to choice-column separator handling.

---

## 🛠 Codebase Changes

### 🛠 Bug Fixes

* Respect the `sep` argument when constructing choice-column names in `add_prot_score_practices()` and `add_prot_score_rights()`. Both `/` (default) and `.` separators are supported.

### 🧪 Testing

* Added unit test "the non-default separator does not affect the behavior"

# humind 2025.1.2

This release introduces major terminology and logic changes across the MSNI framework, WASH, Protection, and Healthcare indicators. Several functions have new required parameters, altered defaults, or renamed outputs — **breaking changes are significant**.

---

## 📖 2025 Programmatic Changes

* **Terminology Migration**  
  All references to *acute need* are migrated to **severe need**, in line with 2025 guidance.  
  - Function `is_in_acute_need()` is now **`is_in_severe_need()`**.  
  - All composite outputs renamed from `*_in_acute_need` → **`*_in_severe_need`** across MSNI, WASH, Health, Food Security, SNFI, Education, and Protection.

* **WASH (Handwashing Facilities)**  
  - Expanded logic in `add_handwashing_facility_cat()` to incorporate **soap type** (qualifying vs non-qualifying).  
  - Harmonized observed vs reported classification rules.  
  - Stricter handling of NA values (reported “yes” with NA → now “limited”).  

* **Healthcare**  
  - `add_loop_healthcare_needed_cat()` improved to propagate NA correctly and issue explicit warnings.  

* **Protection**  
  - `add_prot_score_rights()` and `add_prot_score_practices()` reworked NA handling: DNK/PNTA now nullifies **sub-scores** rather than collapsing the entire composite.  
  - Added diagnostics and warnings for transparency.  

---

## 🛠 Codebase Changes

### 🚀 New Features
* **WASH**:  
  - Soap-type support in `add_handwashing_facility_cat()`.  
  - Vectorized handling of “no” codes for water/soap inputs.  
* **Protection**:  
  - Warnings when sub-dimension scores are NA.  
  - More robust NA handling in rights and practices composites.  
* **Healthcare**:  
  - Warning when `needed == yes` and `received == NA`.  

---

### 🔄 Enhancements
* Harmonized observed/reported classification trees for handwashing facilities.  
* Row-wise composite score computation for protection.  
* More explicit documentation of function arguments and classification logic.  

---

### 🛠 Bug Fixes
* Corrected misclassification in reported handwashing facilities where NA water/soap previously returned NA instead of “limited.”  
* Fixed inconsistent handling of vector “no” codes in handwashing classification.  
* Corrected logic in protection composites to avoid premature collapse to NA.  

---

### 🧪 Testing
* Exhaustive test grids added for handwashing classification (soap-type handling, scalar vs vector inputs).  
* Regression tests ensure new NA/warning behaviors in protection and healthcare are validated.  
* Expanded unit tests for new “severe need” naming.  

---

### 📚 Documentation
* Updated all function documentation to reflect “severe” terminology.  
* Added detailed decision tree explanation for handwashing facility classification.  
* Clarified parameter defaults for composite functions.  

---

### ⚠️ Breaking Changes

* **Renames**
  - `is_in_acute_need()` → **`is_in_severe_need()`**.  
  - Output columns: all `*_in_acute_need` → **`*_in_severe_need`**.  

* **WASH**
  - `add_comp_wash()` default parameter for `drinking_water_quantity` now **`wash_hwise_drink`** (was `wash_drinking_water_quantity`).  
  - `add_handwashing_facility_cat()` requires new **soap type** columns/args and accepts vectorized “no” codes.  
  - Classification rules: soap type can **demote `basic` → `limited`**, and NA handling has changed.  

* **Protection**
  - DNK/PNTA handling refined: only sub-dimensions become NA; composites NA only if **both** subs are NA.  

* **Healthcare**
  - `add_loop_healthcare_needed_cat()` now returns NA with warnings when `needed == yes` and `received == NA`.  

---

# humind 2025.1.1

This release introduces major updates across protection indicators, SNFI and
shelter categorization, expenditure scoring, testing framework improvements,
dependency management, and documentation. Deprecated WGQ components are fully
removed.

---

## 📖 2025 Programmatic Changes

* **Protection**: complete ravamp, based on a series of new Tier 1 indicators
related to Protection Needs. 

* **SNFI**:
  * Changes to the number of shelter issues and their mapping to the FW (from 8
  to 11 total issues).
  * Inclusion of one additional indicator to the security of tenure dimension:
  `hlp_eviction_risk.`
  * Hygiene indicator removed from the FDS series - making the total number of
  domestic tasks (and lighting) equal to 4 instead of 5.
  * Optional shelter damages component added.


* **Health**: removal of the WGQs from the framework.

* **WASH**: small changes to incorporate the self-reported hygiene variants (availability of soap & water) and map them to the JMP classifications.

* **Food Security**: new additional step to analyze the impact of livelihood coping
strategies on Food Consumption (changes done in [impactR4PHU](https://github.com/impact-initiatives/impactR4PHU)
and reflected in humind).

* **Education**: small changes to indicator naming to reflect "direct attack on
education". Indicator name was `edu_disrupted_occupation` and is now called
`edu_disrupted_attack.` `edu_disrupted_occupation` and is now called
`edu_disrupted_attack.`

## 🛠 Codebase Changes

### 🚀 New Features

* **Protection Composite Indicators**
  * Added `add_comp_prot_score()` as main function for computing overall
  Protection Composite.
  * Introduced supporting functions for rights, practices, and participation dimensions.

---

### 🔄 Enhancements

* **SNFI & Shelter Categorization**
  * Revised `add_shelter_issue_cat()` logic for better category handling and
  alignment with 2025 specifications.
  * Updated `add_comp_snfi()` for consistent categorization and explicit
  handling of special cases.
* **Expenditure Indicators**
  * Enhanced infrequent expenditure categorization functions and ranking logic.
* **Data Integrity**
  * Composition functions now preserve original data instead of overwriting
  with intermediate steps.

---

### 🛠 Bug Fixes

* Fixed improper handling of invalid inputs in multiple test cases.
* Addressed warnings triggered by implicit handling of `max()` with all-NA vectors.

---

### 🧪 Testing

* Adopted `testthat` best practices across test suites.
* Expanded unit tests for:
  * Protection composite framework
  * Shelter and occupancy categorization
  * Expenditure ranking
* Standardized warning suppression and ensured expected warnings are captured.
* Removed obsolete tests linked to deprecated WGQ components.

---

### 📚 Documentation

* Completed function documentation for all updated indicators.
* Updated argument descriptions and clarified logic for SNFI and protection functions.
* Removed all references to WGQ components.
* Added Humind 2025 change documentation.

---

### 📦 Dependency Management

* Removed unused packages and implicit dependency on `tibble`.
* Now depends on forked **impactR.utils** package.

---

### ⚠️ Breaking Changes

* Fully removed WGQ-related components and associated tests.
* Deleted obsolete function `add_child_sep_cat.R`.

# humind 2024.1.4

This release covers bug fixes, documentation updates, changes to parameters, and additional enhancements:

 - Documentation updates to better describe function purpose, outputs, and prerequisite functions. 
 - Functions no lover use _levels but instead use separate parameters. (#547)
 - `add_comp_wash()` per the MSNI framework, the function was updated for the urban categorization "basic which should be score 1 instead of score 2 (#558)
 - `add_comp_edu()` updates to show comp_edu_score_disrupted as 3 if displaced_n is greater than 0, instead of greater than 1.(#556)
 - `add_comp_health()` updated so that households with at least one person with a disability have the value 3 for comp_health_score (#550)
 - `add_loop_edu_ind_age_corrected()` updated to allow custom starting age for education analysis based on country-specific requirements (#549)
 - `add_comp_snfi()` now correctly categorizes "other"" for snfi_shelter_issue_cat (#545)
 - `add_loop_edu_ind_age_corrected()` function error message added for date formats not in the ISO 8601 format (#513)

# humind 2024.1.3

This release covers bug fixes.

 - `comp_edu_score_attendance()` now categorizes households correctly when children are not attending school and no protection issue was faced. (#532)
 - `add_shelter_issue_cat()` do not add -999 or -998 when the shelter issue is Don't know or Prefer not to answer (it keeps NAs) and "Other" is categorized as others and not undefined. (#534)
 - `add_comp_snfi()` default values were fixed in documentation. (#535)
 - `add_drinking_water_time_threshold_cat()`: corrected input parameters "under_30min" and "above_30min". (#539)
 - `add_comp_wash()`: corrected assigned severities for `comp_wash_score_sanitation` among HHs in camps. (#536)
 

# humind 2024.1.2

This release covers a hot patch, a new function, and enhancements.

- `add_sanitation_facility_jmp_cat()` now correctly handles the cases when the sanitation facility is improved and not shared (#522)
- A marvelous new function `add_quantile_interval()` now allows to add (weighted) quantile intervals columns for any numeric variables (#516), for instance for adding income quantiles.
- Some bug fixes for `add_loop_healthcare_needed_cat_to_main()` and 
`add_loop_edu_disrupted_d_to_main` when datasets do not name UUI columns "uuid" (#517).
- `add_age_cat()` has more intuitive breaks due to a fix and improvement of `num_cat()`. To be able to get the following thresholds: 0-17, 18-59, 60-119, 120+, you can write `add_age_cat("resp_age", breaks = c(0, 18, 60, 120))` (#504). Default breaks also changed to the aforementioned ones.
- If occupation by armed groups was not added in country due to relevancy, `add_loop_edu_disrupted_d()` and `add_loop_edu_disrupted_d_to_main()`, `occupation` can be set to NULL.


# humind 2024.1.1

This release covers mostly hot patches on a few bugs.

- For perceived protection risks, `add_comp_prot()` assigns the score of 1 to a severity level. (#514) 
- `add_msni()` now correctly handles metrics 3 and 4, adding a missing value when the household is not in need (#509, #510)
- `add_comp_wash` has some minor refinements. (#507)
- For total income, loans to friends and from assistance should not be considered. Function `add_income_source_prop()` now has these two parameters as `NULL` by default. It is still possible to include them. (#506)

# humind 2024.1.0

Provides functions to compose usual humanitarian composite indicators related to IMPACT Multi-Sector Needs Assessments (MSNAs). Such as:

   * Food security indicators (rCSI, LCSI, HHS, FCS).
   * Washington Group Short Set of questions (WG-SS).
   * JMP ladders.
   * Specific indicators related to the MSNI framework.

The package follows the ‘Step-Composition’ approach of IMPACT R framework.


# humind 0.1.900

* Expect many breaking changes as we are moving towards a more consistent and coherent package for 2024 MSNAs
* Food security indicators will be imported from impactR4PHU, potentially all Public Health functions.

# humind 0.0.5.3

* Bug fix: `rsci()` now correctly adds the `rcsi_score` variable.

# humind 0.0.5.2

* Breaking change: `drinking_water_quantity()` now recodes the frequencies of days without drinking water, while `drinking_water_quantity_score()` assigns a score on a 5-point scale.
* Added: `time_to_fetch_water_int_char()` and `time_to_fetch_water_combine()` to recode and combine both variables for the time to fetch water.

# humind 0.0.5.1

* Bug fix and breaking change: `handwashing_facility()` now recodes the types of handwashing facility.
* Added: `handwashing_facility_score()` which calculates a score on a 2-point scale based on `handwashing_facility()`


# humind 0.0.5

* Breaking changes: revamp of all water sources and sanitation facilities fonctions with the same approach as the food security functions.
* Added: `drinking_water_source()` recodes the types of water sources, `time_to_fetch_water()` the time to fetch water according to a chosen threshold, and `drinking_water_source_score()` classify each household/individual on a 5-point scale.
* Added: `sanitation_facility()` recodes the types of sanitation facilities, `sharing_sanitation_facility()` recodes the number of people sharing the sanitation facility, and `sanitation_facility_score()` classify each household on a 5-point scale.

# humind 0.0.4

* Added `water_source()`: Water source 5-point-scale.
* Added `sanitation_facility()`: Sanitation facility 5-point scale.
* Added `handwashing_facility()`: Handwashing facility 2-point scale.
* Added `drinking_water_quantity()`: Drinking water quantity 5-point scale.

# humind 0.0.3

* Added `hdds()`: Household Dietary Diversity Scores (HDDS) ([#5](https://github.com/gnoblet/humind/issues/5))
* Added `fies()`: Food Insecurity Experience Scale (FIES) [#6](https://github.com/gnoblet/humind/issues/6)
* Bug fix: error in `lcsi()` on aggregated categories' names corrected (#20)

# humind 0.0.2

* Added: HWISE functions. (#16)
* Updated: to dplyr v1.1.0 with the `dplyr::case_when()` revamp. (#)
* Modified: dependency know goes to `impactR.utils` and not `impactR`. (#)

# humind 0.0.1

* A few patches to github-action and pages

# humind 0.0.0.9000

* Initial commit
