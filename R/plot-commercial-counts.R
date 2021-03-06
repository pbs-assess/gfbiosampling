
# Adapted from gfplot::plot_sample_avail
plot_commercial_counts <- function (data,
                                    years = NULL,
                                    title = "Commercial specimen counts",
                                    text_colour = "white",
                                    na_colour = "white") {

  # Define years ---------------------------------------------------------------

  if (is.null(years)) {
    years <- seq(min(data$year, na.rm = TRUE), max(data$year, na.rm = TRUE), 1L)
  }

  # Augment data ---------------------------------------------------------------

  data <- data %>%
    dplyr::filter(.data$year %in% .env$years) %>%
    dplyr::mutate(
      n_plot = sqrt(.data$n),
      n_text = gfplot:::round_nice(.data$n),
      type = gfplot:::firstup(as.character(gsub("_", " ", .data$type))),
      type = gsub("Ageing structure", "Age structures", .data$type),
      type = paste("#", .data$type, sep = " ")
    )

  # Expand all combinations ----------------------------------------------------

  all <- tidyr::expand_grid(
      type = unique(data$type),
      area = factor(levels(data$area), levels = levels(data$area)),
      year = .env$years
    )

  # Join data and combinations -------------------------------------------------

  data <- data %>%
    dplyr::right_join(
      all,
      by = c("type", "area", "year")
    ) %>%
    dplyr::mutate(
      n_plot = ifelse(
        is.na(.data$n_plot), NA,
        ifelse(
          .data$n_plot == 0, NA,
          .data$n_plot
        )
      )
    ) %>%
    dplyr::mutate(
      type = factor(
        .data$type,
        levels = rev(
          c(
            "# Length",
            "# Weight",
            "# Maturity",
            "# Age",
            "# Age structures"
          )
        )
      )
    )

  # Plot specimen counts -------------------------------------------------------

  p1 <- ggplot2::ggplot(
    data,
    mapping = ggplot2::aes_string("year", "type", fill = "n_plot")
  ) +
    ggplot2::geom_tile(colour = "grey90") +
    ggplot2::facet_grid(rows = ggplot2::vars(.data$area)) +
    ggplot2::scale_x_continuous(
      breaks = seq(gfplot:::round_down_even(min(years)), max(years), 2)
    ) +
    ggplot2::scale_y_discrete(position = "left") +
    viridis::scale_fill_viridis(
      option = "D",
      end = 0.82,
      na.value = na_colour
    ) +
    ggplot2::coord_cartesian(
      xlim = c(min(years), max(years)) + c(-0.5, 0.5),
      expand = FALSE
    ) +
    ggplot2::xlab("") +
    ggplot2::ylab("") +
    ggplot2::geom_text(
      ggplot2::aes_string(x = "year", label = "n_text"),
      colour = text_colour,
      size = 2.1,
      alpha = 1,
      na.rm = TRUE
    ) +
    ggplot2::ggtitle(title) +
    gfplot::theme_pbs() +
    ggplot2::theme(
      axis.ticks.x = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      strip.text.y = ggplot2::element_text(angle = 0),
      legend.position = "none"
    )

  # Return plot ----------------------------------------------------------------

  return(p1)
}
