library(targets)
source("R/functions.R")
source("R/plot.R")
source("R/utils.R")

# Set options
tar_option_set(
  packages = c(
    "dplyr",
    "fs",
    "ggplot2",
    "ggpubr",
    "ggsidekick",
    "here",
    "magrittr",
    "readr",
    "rlang",
    "tictoc",
    "tidyr",
    "usethis"
  )
)
options(tidyverse.quiet = TRUE)

# List target objects
list(
  # Watch data -----------------------------------------------------------------
  list(),
  list()
)
