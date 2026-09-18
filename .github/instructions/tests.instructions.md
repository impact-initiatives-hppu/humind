---
applyTo: "tests/**/*.R"
---

# Reviewing humind tests

- Each new branch or edge case needs an explicit expectation; prefer
  `expect_snapshot(error = TRUE)` over message regex for `cli_abort()`.
- Tests must cover out-of-set categorical values, `dnk`/`pnta`, empty
  strings, unmatched loop rows, and zero-member households.
- Integration tests must exercise `add_*` -> `add_comp_*` -> `add_msni()`
  chains, so an upstream output change breaks a test instead of passing
  silently.
- Tests must be self-contained; use `withr` for state and never rely on
  the network or real/sensitive respondent data.
- Assert column names and accepted value domains, not just row counts.
