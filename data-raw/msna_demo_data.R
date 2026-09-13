library(readxl)
library(usethis)

path <- "data-raw/msna_demo.xlsx"

humind_main <- read_excel(path, sheet = "main", guess_max = Inf)
humind_health_ind <- read_excel(path, sheet = "health_ind", guess_max = Inf)
humind_edu_ind <- read_excel(path, sheet = "edu_ind", guess_max = Inf)

use_data(humind_main, overwrite = TRUE)
use_data(humind_health_ind, overwrite = TRUE)
use_data(humind_edu_ind, overwrite = TRUE)
