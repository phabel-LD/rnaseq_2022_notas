# Revisión

* ¿Debemos explorar las relaciones entre nuestras variables con información de nuestras muestras previo a hacer un análisis de expresión diferencial?
Sí es muy importante hacer un ExploratoryDataAnalysis (EDA) para determinar el mejor modelo estadístico a usar.

* ¿Por qué usamos el paquete `edgeR`?
Es útil en la parte de normalizción de datos para tener una relación correcta entre los niveles de expresión.
Su uso en la corrección de Composition Bias es fundamental cuando se tiene diferente número de transcritos.

* ¿Por qué es importante el argumento `sort.by` en `topTable()`?
Para mantener el orden original en los datos y que estos no sean reordenados por P.Value

* ¿Por qué es importante el argumento `coef` en `topTable()`?
Para seleccionar el coeficiente correspondiente a la variable de interés del modelo.

  Usemos los datos de http://research.libd.org/SPEAQeasy-example/bootcamp_intro

```{r "speaqeasy_data"}
speaqeasy_data <- file.path(tempdir(), "rse_speaqeasy.RData")
download.file("https://github.com/LieberInstitute/SPEAQeasy-example/blob/master/rse_speaqeasy.RData?raw=true", speaqeasy_data, mode = "wb")
library("SummarizedExperiment")
load(speaqeasy_data, verbose = TRUE)
rse_gene
```
* ¿Cuantos genes y muestras tenemos en estos datos?
Tenemos 60609 genes X 40 muestras.

  ## Ejercicio en equipo

* ¿Hay diferencias en `totalAssignedGene` o `mitoRate` entre los grupos de diagnosis (`PrimaryDx`)?


* Grafica la expresión de _SNAP25_ para cada grupo de diagnosis.


* Sugiere un modelo estadistico que podríamos usar en una análisis de expresión diferencial. Verifica que si sea un modelo _full rank_. ¿Cúal sería el o los coeficientes de interés?






library("ExploreModelMatrix")
library("ggplot2")

ggplot(as.data.frame(colData(rse_gene)), aes(y = totalAssignedGene, x = PrimaryDx)) +
  geom_boxplot() +
  theme_bw(base_size = 20) +
  ylab("totalAssignedGene") +
  xlab("PrimaryDx")

ggplot(as.data.frame(colData(rse_gene)), aes(y = mitoRate, x = PrimaryDx)) +
  geom_boxplot() +
  theme_bw(base_size = 20) +
  ylab("mitoRate") +
  xlab("PrimaryDx")

ggplot(df, aes(y = exp, x = diag)) +
  geom_boxplot() +
  theme_bw(base_size = 20) +
  ylab("Expression") +
  xlab("PrimaryDx")

df <- data.frame("exp"=assay(rse_gene)['ENSG00000132639.12', ],
                 "diag"=colData(rse_gene)$PrimaryDx)


modelData <- colData(rse_gene)[c("PrimaryDx", "mitoRate", "totalAssignedGene", "BrainRegion", "Sex", "AgeDeath", "rRNA_rate")]

ExploreModelMatrix::ExploreModelMatrix(
  modelData,
  ~ PrimaryDx + totalAssignedGene + mitoRate + rRNA_rate + BrainRegion + Sex + AgeDeath
)







## Respuestas

  ```{r "respuestas"}
## Exploremos la variable de PrimaryDx
table(rse_gene$PrimaryDx)
## Eliminemos el diagnosis "Other" porque no tiene información
rse_gene$PrimaryDx <- droplevels(rse_gene$PrimaryDx)
table(rse_gene$PrimaryDx)
## Exploremos numéricamente diferencias entre grupos de diagnosis para
## varias variables
with(colData(rse_gene), tapply(totalAssignedGene, PrimaryDx, summary))
with(colData(rse_gene), tapply(mitoRate, PrimaryDx, summary))
## Podemos hacer lo mismo para otras variables
with(colData(rse_gene), tapply(mitoRate, BrainRegion, summary))
## Podemos resolver la primeras preguntas con iSEE
if (interactive()) iSEE::iSEE(rse_gene)
## O hacer graficas nosotros mismos. Aquí les muestro una posible respuesta
## con ggplot2
library("ggplot2")
ggplot(
  as.data.frame(colData(rse_gene)),
  aes(y = totalAssignedGene, group = PrimaryDx, x = PrimaryDx)
) +
  geom_boxplot() +
  theme_bw(base_size = 20) +
  xlab("Diagnosis")
ggplot(
  as.data.frame(colData(rse_gene)),
  aes(y = mitoRate, group = PrimaryDx, x = PrimaryDx)
) +
  geom_boxplot() +
  theme_bw(base_size = 20) +
  xlab("Diagnosis")
## Otras variables
ggplot(
  as.data.frame(colData(rse_gene)),
  aes(y = mitoRate, group = BrainRegion, x = BrainRegion)
) +
  geom_boxplot() +
  theme_bw(base_size = 20) +
  xlab("Brain Region")
## Encontremos el gene SNAP25
rowRanges(rse_gene)
## En este objeto los nombres de los genes vienen en la variable "Symbol"
i <- which(rowRanges(rse_gene)$Symbol == "SNAP25")
i
## Para graficar con ggplot2, hagamos un pequeño data.frame
df <- data.frame(
  expression = assay(rse_gene)[i, ],
  Dx = rse_gene$PrimaryDx
)
## Ya teniendo el pequeño data.frame, podemos hacer la gráfica
ggplot(df, aes(y = log2(expression + 0.5), group = Dx, x = Dx)) +
  geom_boxplot() +
  theme_bw(base_size = 20) +
  xlab("Diagnosis") +
  ylab("SNAP25: log2(x + 0.5)")
## https://bioconductor.org/packages/release/bioc/vignettes/scater/inst/doc/overview.html#3_Visualizing_expression_values
scater::plotExpression(
  as(rse_gene, "SingleCellExperiment"),
  features = rownames(rse_gene)[i],
  x = "PrimaryDx",
  exprs_values = "counts",
  colour_by = "BrainRegion",
  xlab = "Diagnosis"
)
## Para el model estadístico exploremos la información de las muestras
colnames(colData(rse_gene))
## Podemos usar región del cerebro porque tenemos suficientes datos
table(rse_gene$BrainRegion)
## Pero no podemos usar "Race" porque son solo de 1 tipo
table(rse_gene$Race)
## Ojo! Acá es importante que hayamos usado droplevels(rse_gene$PrimaryDx)
## si no, vamos a tener un modelo que no sea _full rank_
mod <- with(
  colData(rse_gene),
  model.matrix(~ PrimaryDx + totalAssignedGene + mitoRate + rRNA_rate + BrainRegion + Sex + AgeDeath)
)
## Exploremos el modelo de forma interactiva
if (interactive()) {
  ## Tenemos que eliminar columnas que tienen NAs.
  info_no_NAs <- colData(rse_gene)[, c(
    "PrimaryDx", "totalAssignedGene", "rRNA_rate", "BrainRegion", "Sex",
    "AgeDeath", "mitoRate", "Race"
  )]
  ExploreModelMatrix::ExploreModelMatrix(
    info_no_NAs,
    ~ PrimaryDx + totalAssignedGene + mitoRate + rRNA_rate + BrainRegion + Sex + AgeDeath
  )
  ## Veamos un modelo más sencillo sin las variables numéricas (continuas) porque
  ## ExploreModelMatrix nos las muestra como si fueran factors (categoricas)
  ## en vez de continuas
  ExploreModelMatrix::ExploreModelMatrix(
    info_no_NAs,
    ~ PrimaryDx + BrainRegion + Sex
  )
  ## Si agregamos + Race nos da errores porque Race solo tiene 1 opción
  # ExploreModelMatrix::ExploreModelMatrix(
  #     info_no_NAs,
  #     ~ PrimaryDx + BrainRegion + Sex + Race
  # )
}
```

¿Quieres más datos? Tenemos muchos en LIBD incluyendo http://eqtl.brainseq.org/phase2/.


# spatialLIBD

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">🔥off the press! 👀 our <a href="https://twitter.com/biorxivpreprint?ref_src=twsrc%5Etfw">@biorxivpreprint</a> on human 🧠brain <a href="https://twitter.com/LieberInstitute?ref_src=twsrc%5Etfw">@LieberInstitute</a> spatial 🌌🔬transcriptomics data 🧬using Visium <a href="https://twitter.com/10xGenomics?ref_src=twsrc%5Etfw">@10xGenomics</a>🎉<a href="https://twitter.com/hashtag/spatialLIBD?src=hash&amp;ref_src=twsrc%5Etfw">#spatialLIBD</a><br><br>🔍<a href="https://t.co/RTW0VscUKR">https://t.co/RTW0VscUKR</a> <br>👩🏾‍💻<a href="https://t.co/bsg04XKONr">https://t.co/bsg04XKONr</a><br>📚<a href="https://t.co/FJDOOzrAJ6">https://t.co/FJDOOzrAJ6</a><br>📦<a href="https://t.co/Au5jwADGhY">https://t.co/Au5jwADGhY</a><a href="https://t.co/PiWEDN9q2N">https://t.co/PiWEDN9q2N</a> <a href="https://t.co/aWy0yLlR50">pic.twitter.com/aWy0yLlR50</a></p>&mdash; 🇲🇽 Leonardo Collado-Torres (@lcolladotor) <a href="https://twitter.com/lcolladotor/status/1233661576433061888?ref_src=twsrc%5Etfw">February 29, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

  <script async class="speakerdeck-embed" data-id="329db23f5f17460da31f45c7695a9f06" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

  <script async class="speakerdeck-embed" data-id="c48e671f4c93476489c3d9d679830bca" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

  <script async class="speakerdeck-embed" data-id="9e099800589b49c29a99187a6415af91" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

  * Artículo: https://www.nature.com/articles/s41593-020-00787-0
* Software: http://research.libd.org/spatialLIBD/ o `r BiocStyle::Biocpkg("spatialLIBD")`
* Interfaz de shiny: http://spatial.libd.org/spatialLIBD/
  * Libro (en construcción) donde explicamos como usar varias herramientas: https://lmweber.org/OSTA-book/
  * Pre-print sobre `SpatialExperiment` https://www.biorxiv.org/content/10.1101/2021.01.27.428431v1

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Are you working with spatial transcriptomics data such as Visium from <a href="https://twitter.com/10xGenomics?ref_src=twsrc%5Etfw">@10xGenomics</a>? Then you&#39;ll be interested in <a href="https://twitter.com/hashtag/SpatialExperiment?src=hash&amp;ref_src=twsrc%5Etfw">#SpatialExperiment</a> 📦 led by <a href="https://twitter.com/drighelli?ref_src=twsrc%5Etfw">@drighelli</a> <a href="https://twitter.com/lmwebr?ref_src=twsrc%5Etfw">@lmwebr</a> <a href="https://twitter.com/CrowellHL?ref_src=twsrc%5Etfw">@CrowellHL</a> with contributions by <a href="https://twitter.com/PardoBree?ref_src=twsrc%5Etfw">@PardoBree</a> <a href="https://twitter.com/shazanfar?ref_src=twsrc%5Etfw">@shazanfar</a> A Lun <a href="https://twitter.com/stephaniehicks?ref_src=twsrc%5Etfw">@stephaniehicks</a> <a href="https://twitter.com/drisso1893?ref_src=twsrc%5Etfw">@drisso1893</a> 🌟<br><br>📜 <a href="https://t.co/r36qlakRJe">https://t.co/r36qlakRJe</a> <a href="https://t.co/cWIiwLFitV">pic.twitter.com/cWIiwLFitV</a></p>&mdash; 🇲🇽 Leonardo Collado-Torres (@lcolladotor) <a href="https://twitter.com/lcolladotor/status/1355208674856329218?ref_src=twsrc%5Etfw">January 29, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

  Brenda Pardo

https://twitter.com/PardoBree

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Today I gave my first talk at a congress in <a href="https://twitter.com/hashtag/EuroBioc2020?src=hash&amp;ref_src=twsrc%5Etfw">#EuroBioc2020</a> about our work on adapting the package <a href="https://twitter.com/hashtag/spatialLIBD?src=hash&amp;ref_src=twsrc%5Etfw">#spatialLIBD</a> to use VisiumExperiment objects. <a href="https://t.co/U23yE32RWM">pic.twitter.com/U23yE32RWM</a></p>&mdash; Brenda Pardo (@PardoBree) <a href="https://twitter.com/PardoBree/status/1338560370382942209?ref_src=twsrc%5Etfw">December 14, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

  <blockquote class="twitter-tweet"><p lang="en" dir="ltr">Our paper describing our package <a href="https://twitter.com/hashtag/spatialLIBD?src=hash&amp;ref_src=twsrc%5Etfw">#spatialLIBD</a> is finally out! 🎉🎉🎉<br><br>spatialLIBD is an <a href="https://twitter.com/hashtag/rstats?src=hash&amp;ref_src=twsrc%5Etfw">#rstats</a> / <a href="https://twitter.com/Bioconductor?ref_src=twsrc%5Etfw">@Bioconductor</a> package to visualize spatial transcriptomics data.<br>⁰<br>This is especially exciting for me as it is my first paper as a first author 🦑.<a href="https://t.co/COW013x4GA">https://t.co/COW013x4GA</a><br><br>1/9 <a href="https://t.co/xevIUg3IsA">pic.twitter.com/xevIUg3IsA</a></p>&mdash; Brenda Pardo (@PardoBree) <a href="https://twitter.com/PardoBree/status/1388253938391175173?ref_src=twsrc%5Etfw">April 30, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
