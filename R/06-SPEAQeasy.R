# Procesar datos crudos (FASTQ) con SPEQeasy & recount3

Para analizar inputs FASTQs y poder pasar a alineamientos y poder
llegar a SummarizedExperiment.

Proyecto recount3 con muestras de RNA-seq de humano & ratón,
Para poder analizar los datos sin importar quien tiene acceso
a high performance computing (HPC) (clústers para procesar datos).

Una posibilidad es determinar el nivel total de expresión de un gen
con alternative splicing con exon & gene coverage experiments.


## Load recount3 R package
library("recount3")
library("iSEE")
iSEE::iSEE(rse)

## Revisemos todos los proyectos con datos de humano en recount3
human_projects <- available_projects()

dim(human_projects)
head(human_projects)

## Encuentra tu proyecto de interés. Aquí usaremos
## SRP009615 de ejemplo
proj_info <- subset(
  human_projects,
  project == "SRP009615" & project_type == "data_sources"
)
proj_info
## Crea un objetio de tipo RangedSummarizedExperiment (RSE)
## con la información a nivel de genes
rse_gene_SRP009615 <- create_rse(proj_info)

## Explora el objeto RSE
rse_gene_SRP009615

## Explora los proyectos disponibles de forma interactiva
proj_info_interactive <- interactiveDisplayBase::display(human_projects)
## Selecciona un solo renglón en la tabla y da click en "send".

## Aquí verificamos que solo seleccionaste un solo renglón.
stopifnot(nrow(proj_info_interactive) == 1)
## Crea el objeto RSE
rse_gene_interactive <- create_rse(proj_info_interactive)

## Convirtamos las cuentas por nucleotido a cuentas por lectura
## usando compute_read_counts().
## Para otras transformaciones como RPKM y TPM, revisa transform_counts().
assay(rse_gene_SRP009615, "counts") <- compute_read_counts(rse_gene_SRP009615)

## Para este estudio en específico, hagamos más fácil de usar la
## información del experimento
rse_gene_SRP009615 <- expand_sra_attributes(rse_gene_SRP009615)
colData(rse_gene_SRP009615)[
  ,
  grepl("^sra_attribute", colnames(colData(rse_gene_SRP009615)))
]
iSEE(rse_gene_SRP009615)

## Ejercicio 1: Replicar la imagen deseada con iSEE, teniendo en cuenta los
## los siguientes criterios: usar dynamic feature selection, usar info. de
## las cols para el eje X y para los colores. El resultado se encuentra
## en Imagenes/3_FeatureAssayPlot2.pdf
