library(tidyverse)

muni_data <- read.csv("data/municipal-data_raw.csv", check.names = FALSE)
issues_data <- read.csv("data/issues-data.csv")

pred_data <- muni_data |>
  filter(
    issue == "pa_iss_2",
    Name == "Calgary",
    # filter out the empty row used for the muni_menu placeholder
    Name != ""
  )

# rename variables and create group IDs
issues_data <- issues_data |>
  select("issue" = issue_id, "Agreement" = Agreement, Opinion) |>
  filter(issue == "pa_iss_2") |>
  mutate(group = "National")

pred_data <- pred_data |>
  select("Agreement" = prediction, issue, "Opinion" = opinion) |>
  mutate(group = "Municipality")

plot_data <- bind_rows(pred_data, issues_data)

plot_data <- plot_data |>
  pivot_longer(
    cols = c(Agreement, Opinion),
    names_to = "pred_type",
    values_to = "pred"
  )

plot_data$pred <- round(plot_data$pred, 2) * 100

ggplot(plot_data, aes(x = pred_type, y = pred, fill = group)) +
  geom_col(
    position = "dodge"
  ) +
  geom_text(
    aes(label = paste0(round(pred, 2), "%")),
    position = position_dodge(width = 0.9),
    vjust = -0.5,
    size = 5
  ) +
  labs(title = "Pct. Agreement and Pct. Have an opinion") +
  ylab("Pct.") +
  scale_fill_manual(
    values = c("Municipality" = "#0091AC", "National" = "#6C6E74")
  ) +
  theme_minimal(base_size = 16) +
  theme(
    legend.position = "right",
    legend.title = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.x = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )
