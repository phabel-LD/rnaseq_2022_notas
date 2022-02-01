library("sessioninfo")
library("here")
library("ggplot2")

## Hello world
print("Soy Phabel")
print("Hola")

## Directorios
dir_plots <- here::here("figuras")
dir_rdata <- here::here("processed-data")

## Crear directorio para las figuras y archivos
dir.create(dir_plots, showWarnings = FALSE)
dir.create(dir_rdata, showWarnings = FALSE)

## Hacer una imagen de ejemplo
pdf(file.path(dir_plots, "mtcars_gear_vs_mpg.pdf"),
    useDingbats = FALSE
)
ggplot(mtcars, aes(group = gear, y = mpg)) +
  geom_boxplot()
dev.off()

## Para reproducir mi código
options(width = 120)
sessioninfo::session_info()

# - Packages -----------------------------------------------------------------------------------------------------------
#   package     * version date (UTC) lib source
# assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.1.2)
# cli           3.1.1   2022-01-20 [1] CRAN (R 4.1.2)
# colorspace    2.0-2   2021-06-24 [1] CRAN (R 4.1.2)
# crayon        1.4.2   2021-10-29 [1] CRAN (R 4.1.2)
# DBI           1.1.2   2021-12-20 [1] CRAN (R 4.1.2)
# digest        0.6.29  2021-12-01 [1] CRAN (R 4.1.2)
# dplyr         1.0.7   2021-06-18 [1] CRAN (R 4.1.2)
# ellipsis      0.3.2   2021-04-29 [1] CRAN (R 4.1.2)
# fansi         1.0.2   2022-01-14 [1] CRAN (R 4.1.2)
# farver        2.1.0   2021-02-28 [1] CRAN (R 4.1.2)
# fs            1.5.2   2021-12-08 [1] CRAN (R 4.1.2)
# generics      0.1.2   2022-01-31 [1] CRAN (R 4.1.2)
# ggplot2     * 3.3.5   2021-06-25 [1] CRAN (R 4.1.2)
# glue          1.6.1   2022-01-22 [1] CRAN (R 4.1.2)
# gtable        0.3.0   2019-03-25 [1] CRAN (R 4.1.2)
# here        * 1.0.1   2020-12-13 [1] CRAN (R 4.1.2)
# labeling      0.4.2   2020-10-20 [1] CRAN (R 4.1.1)
# lifecycle     1.0.1   2021-09-24 [1] CRAN (R 4.1.2)
# magrittr      2.0.2   2022-01-26 [1] CRAN (R 4.1.2)
# munsell       0.5.0   2018-06-12 [1] CRAN (R 4.1.2)
# pillar        1.7.0   2022-02-01 [1] CRAN (R 4.1.2)
# pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.1.2)
# purrr         0.3.4   2020-04-17 [1] CRAN (R 4.1.2)
# R6            2.5.1   2021-08-19 [1] CRAN (R 4.1.2)
# rlang         1.0.0   2022-01-26 [1] CRAN (R 4.1.2)
# rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.1.2)
# rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.1.2)
# scales        1.1.1   2020-05-11 [1] CRAN (R 4.1.2)
# sessioninfo * 1.2.2   2021-12-06 [1] CRAN (R 4.1.2)
# tibble        3.1.6   2021-11-07 [1] CRAN (R 4.1.2)
# tidyselect    1.1.1   2021-04-30 [1] CRAN (R 4.1.2)
# usethis       2.1.5   2021-12-09 [1] CRAN (R 4.1.2)
# utf8          1.2.2   2021-07-24 [1] CRAN (R 4.1.2)
# vctrs         0.3.8   2021-04-29 [1] CRAN (R 4.1.2)
# withr         2.4.3   2021-11-30 [1] CRAN (R 4.1.2)
#
# [1] C:/Users/phabe/OneDrive/Escritorio/R-4.1.2/library
#
# ----------------------------------------------------------------------------------------------------------------------
