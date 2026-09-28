---
applyTo: "vignettes/**,NEWS.md"
---

# Reviewing humind documentation

- Flag when vignette or NEWS text contradicts the implemented logic:
  parameter names, default values, aggregation direction, and acronyms.
- Verify documented column names and answer options match the pinned MSNA
  form in `.github/copilot-instructions.md`.
- Any user-visible change in `R/` must be reflected in `NEWS.md` under the
  current dev version.
- Examples must run; flag any example that touches real or sensitive
  respondent data.
