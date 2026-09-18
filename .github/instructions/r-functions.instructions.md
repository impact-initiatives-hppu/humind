---
applyTo: "R/**/*.R"
---

# Reviewing humind R functions

- For raw-form inputs: verify column names, answer options, and default
  parameters align with the pinned MSNA form in
  `.github/copilot-instructions.md`. Reference the form's `type`,
  `list_name`, and `choices` when checking a select_* input.
- For functions on intermediate results: verify accepted sets, column
  names, and value domains match the upstream function's outputs.
- Check every categorical input against its accepted domain with
  `are_values_in_set()` before coercion.
- Verify `dnk`/`pnta`/`other`/`""` are handled as `NA`.
- For `add_loop_*_to_main()`: verify join coverage, missing-to-0 coercion,
  idempotency, and that `NULL` optional args do not reference unbound
  objects.
- If an upstream output changes, ensure downstream functions and their
  integration tests are updated in the same PR.
- Flag `match.arg()` calls that do not pass an explicit `choices =`.
