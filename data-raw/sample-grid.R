library(dplyr)
library(ggplot2)

dir.create("figs", showWarnings = FALSE)
dir.create("data-generated", showWarnings = FALSE)

if (!file.exists("data-generated/sampling-summary.rds")) {
  f <- list.files("../gfsynopsis-2021/report/data-cache-update2/", full.names = TRUE) # will make reproducible...
  f <- f[!grepl("cpue", f)]
  f <- f[!grepl("iphc", f)]
  d <- list()
  for (i in seq_along(f)) {
    cat(f[i], "\n")
    d[[i]] <- readRDS(f[i])$commercial_samples
  }
  d <- bind_rows(d)
  d_tidy <- gfplot::tidy_sample_avail(d)
  d_tidy <- filter(d_tidy, year >= 1996, year <= 2020,
    n > 0, !is.na(species_common_name))
  saveRDS(d_tidy, "data-generated/sampling-summary.rds")
} else {
  d_tidy <- readRDS("data-generated/sampling-summary.rds")
}

d_tidy$species_common_name <- stringr::str_to_title(d_tidy$species_common_name)
d_tidy <- filter(d_tidy, species_common_name != "Pacific Halibut")
d_tidy <- filter(d_tidy, species_common_name != "Pacific Hake")
d_tidy$species_common_name[d_tidy$species_common_name == "North Pacific Spiny Dogfish"] <- "Spiny Dogfish"
d_tidy$species_common_name[d_tidy$species_common_name == "Rougheye/Blackspotted Rockfish Complex"] <- "Rough./Blackspotted Rock."
d_tidy$species_common_name <- as.factor(d_tidy$species_common_name)

make_sample_plot <- function(dat) {
  half_line <- 11
  ggplot(dat, aes(year, 1, fill = n, colour = n)) + geom_tile() +
    facet_wrap(~species_common_name, ncol = 6L, drop = FALSE) +
    # gfplot::theme_pbs() +
    ggsidekick::theme_sleek() + # remotes::install_github("seananderson/ggsidekick")
    scale_fill_viridis_c(trans = "log10") +
    scale_colour_viridis_c(trans = "log10") +
    # scale_fill_distiller(trans = "log10", palette = "Blues", direction = 1) +
    # scale_colour_distiller(trans = "log10", palette = "Blues", direction = 1) +
    theme(axis.title.y = element_blank(), axis.text.y = element_blank(),
      axis.ticks.y = element_blank(), axis.title.x = element_blank(),
      strip.text = element_text(size = 8)) +
    labs(fill = "Number of samples", colour = "Number of samples") +
    theme(legend.position = "bottom", plot.margin = margin(half_line,
      half_line + 4, half_line, half_line)) +
    scale_x_continuous(breaks = seq(2000, 2020, 10)) +
    coord_cartesian(expand = FALSE) +
    guides(fill = guide_colourbar())
}

WIDTH <- 9
HEIGHT <- 8
DPI <- 220

g <- filter(d_tidy, type == "age") %>%
  make_sample_plot() +
  ggtitle("Ages")
ggsave("figs/sample-grid-age.png", width = WIDTH, height = HEIGHT, dpi = DPI)

g <- filter(d_tidy, type == "length") %>%
  make_sample_plot()+
  ggtitle("Lengths")
ggsave("figs/sample-grid-length.png", width = WIDTH, height = HEIGHT, dpi = DPI)

g <- filter(d_tidy, type == "ageing_structure") %>%
  make_sample_plot()+
  ggtitle("Ageing structures")
ggsave("figs/sample-grid-ageing-structure.png", width = WIDTH, height = HEIGHT, dpi = DPI)

g <- filter(d_tidy, type == "weight") %>%
  make_sample_plot()+
  ggtitle("Weights")
ggsave("figs/sample-grid-weight.png", width = WIDTH, height = HEIGHT, dpi = DPI)

g <- filter(d_tidy, type == "maturity") %>%
  make_sample_plot()+
  ggtitle("Maturity")
ggsave("figs/sample-grid-maturity.png", width = WIDTH, height = HEIGHT, dpi = DPI)
