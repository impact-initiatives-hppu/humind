# Add composite score for Ability to Participate in Safe Practices and Activities

Creates weighted scores for two multi-choice questions about threats
affecting household members’ ability to engage in activities and social
interactions. Then computes an overall severity category (1–4) from the
combined scores.

## Usage

``` r
add_prot_score_practices(
  df,
  sep = "/",
  prot_needs_2_activities = "prot_needs_2_activities",
  yes_work = "yes_work",
  yes_livelihood = "yes_livelihood",
  yes_safety = "yes_safety",
  yes_farm = "yes_farm",
  yes_water = "yes_water",
  yes_other_activities = "yes_other_activities",
  yes_free_choices = "yes_free_choices",
  prot_needs_2_social = "prot_needs_2_social",
  yes_visiting_family = "yes_visiting_family",
  yes_visiting_friends = "yes_visiting_friends",
  yes_community_events = "yes_community_events",
  yes_joining_groups = "yes_joining_groups",
  yes_other_social = "yes_other_social",
  yes_child_recreation = "yes_child_recreation",
  yes_decision_making = "yes_decision_making",
  no = "no",
  dnk = "dnk",
  pnta = "pnta",
  .keep_weighted = FALSE
)
```

## Arguments

- df:

  A data frame containing binary indicator columns. Each question has
  multiple "option" columns named using the pattern
  `question\(sep\)option_suffix`.

- sep:

  Separator between question names and suffixes in the column names.
  Defaults to "/".

- prot_needs_2_activities:

  Name of the first question (activities). Default:
  "prot_needs_2_activities".

- yes_work:

  Answer option name for "Yes, it affected the ability to work" option.
  Default: "yes_work".

- yes_livelihood:

  Answer option name for "Yes, it affected the general access to
  livelihood" column. Default: "yes_livelihood". "Yes, it affected the
  general access to livelihood" option. Default: "yes_livelihood".

- yes_safety:

  Answer option name for "Yes, it affected the ability to seek safety"
  column. Default: "yes_safety". "Yes, it affected the ability to seek
  safety" option. Default: "yes_safety".

- yes_farm:

  Answer option name for "Yes, it affected the ability to farm" column.
  Default: "yes_farm". "Yes, it affected the ability to farm" option.
  Default: "yes_farm".

- yes_water:

  Answer option name for "Yes, it affected the ability to collect water"
  column. Default: "yes_water". "Yes, it affected the ability to collect
  water" option. Default: "yes_water".

- yes_other_activities:

  Answer option name for "Yes, it affected other activities needed to
  meet needs" column. Default: "yes_other_activities". "Yes, it affected
  other activities needed to meet needs" option. Default:
  "yes_other_activities".

- yes_free_choices:

  Answer option name for "Yes, it affected the ability to make free
  choices" column. Default: "yes_free_choices". "Yes, it affected the
  ability to make free choices" option. Default: "yes_free_choices".

- prot_needs_2_social:

  Name of the second question (social interactions). Default:
  "prot_needs_2_social".

- yes_visiting_family:

  Answer option name for "Yes, visiting family members" column. Default:
  "yes_visiting_family". "Yes, visiting family members" option. Default:
  "yes_visiting_family".

- yes_visiting_friends:

  Answer option name for "Yes, visiting friends" column. Default:
  "yes_visiting_friends". "Yes, visiting friends" option. Default:
  "yes_visiting_friends".

- yes_community_events:

  Answer option name for "Yes, attending community events" column.
  Default: "yes_community_events". "Yes, attending community events"
  option. Default: "yes_community_events".

- yes_joining_groups:

  Answer option name for "Yes, joining groups or public gatherings"
  column. Default: "yes_joining_groups". "Yes, joining groups or public
  gatherings" option. Default: "yes_joining_groups".

- yes_other_social:

  Answer option name for "Yes, participating in other social activities"
  column. Default: "yes_other_social". "Yes, participating in other
  social activities" option. Default: "yes_other_social".

- yes_child_recreation:

  Answer option name for "Yes, children's recreational activities"
  column. Default: "yes_child_recreation". "Yes, children's recreational
  activities" option. Default: "yes_child_recreation".

- yes_decision_making:

  Answer option name for "Yes, participating in decision making bodies"
  column. Default: "yes_decision_making". "Yes, participating in
  decision making bodies" option. Default: "yes_decision_making".

- no:

  Answer option name for "No" column. Default: "no". "No" option.
  Default: "no".

- dnk:

  Answer option name for "Don't know" column (treated as NA). Default:
  "dnk". "Don't know" option (treated as NA). Default: "dnk".

- pnta:

  Answer option name for "Prefer not to answer" column (treated as NA).
  Default: "pnta". "Prefer not to answer" option (treated as NA).
  Default: "pnta".

- .keep_weighted:

  Logical; if TRUE, retains the intermediate weighted columns (suffix
  "\_w"). Default: FALSE.

## Value

The input data frame with three new composite-score columns:

- `comp_prot_score_prot_needs_2_activities`: weighted sum of
  activity-related options.

- `comp_prot_score_prot_needs_2_social`: weighted sum of social-related
  options.

- `comp_prot_score_practices`: overall severity (1–4) based on combined
  score.

Plus optional weighted columns (suffix "\_w") if
`.keep_weighted = TRUE`.
