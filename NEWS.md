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
