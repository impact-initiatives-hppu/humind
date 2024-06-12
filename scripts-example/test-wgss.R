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


# Use WGSS functions--------------------------------------------------------

source("R/internals.R")
source("R/add_loop_wgq_ss.R")

loop %>% select(starts_with("difficulty")) %>% lapply(unique) %>% unlist %>% unique

loop.out <-  add_loop_wgq_ss(loop = loop,
                             ind_age = "ind_age",
                             vision = "difficulty_seeing",
                             hearing = "difficulty_hearing",
                             mobility = "difficulty_walking",
                             cognition = "difficulty_remembering",
                             self_care = "difficulty_self_care",
                             communication = "difficulty_communicating",
                             no_difficulty = "no_difficulty",
                             some_difficulty = "some_difficulty",
                             lot_of_difficulty = "a_lot_of_difficulty",
                             cannot_do = "cannot_do_at_all",
                             undefined = c("refused_to_answer", "dont_know"))


main.out <- add_loop_wgq_ss_to_main(main = main,
                                    loop = loop.out,
                                    wgq_dis_4 = "wgq_dis_4",
                                    wgq_dis_3 = "wgq_dis_3",
                                    wgq_dis_2 = "wgq_dis_2",
                                    wgq_dis_1 = "wgq_dis_1",
                                    ind_age_above_5 = "ind_age_above_5",
                                    id_col_main = "uuid",
                                    id_col_loop = "uuid"
)


# test age pyramid function ------------------------------------------------

source("R/graph_add_pyramid.R")

main <- main %>% add_age_cat(age_col = "resp_age",
                             breaks = c(0,18, 30, 65, 100, 120),
                             int_undefined = c(-999, 999),
                             char_undefined = "undefined",
                             new_colname = "resp_age_cat")
# main$admin1 %>% unique

age_table <- aggregate_age(df = main, 
                           var_age_cat = "resp_age_cat",
                           var_gender = "resp_gender",
                           gender_filtered_values = c(NA, "other", "pnta"),
                           group_var = "admin1",
                           col_weight = "weight")

age_table %>% plot.age.pyramid(var_gender = "resp_gender",
                               var_age_cat = "resp_age_cat",
                               col_stat = "prop",
                               col_n = "n",
                               unit = "Respondent",
                               group_var = "admin1",
                               save = F,
                               value_men = "male",
                               value_women = "female")

df <- age_table
var_gender = "resp_gender"
var_age_cat = "resp_age_cat"
col_stat = "prop"
col_n = "n"
unit = "Respondent"
group_var = NULL
save = F
value_men = "male"
value_women = "female"
