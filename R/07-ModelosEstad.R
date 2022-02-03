# Modelos Estadísticos

################################################
# 1) ExploreModelMatrix Con R, usamos mucho la función model.matrix() y la sintáxis de fórmula Y ~ X1 + X2 tal como en el siguiente ejemplo.
################################################

## ?model.matrix
mat <- with(trees, model.matrix(log(Volume) ~ log(Height) + log(Girth)))
mat


colnames(mat)

## Aplicar regresión lineal con lm() que internamente usa model.matrix()
summary(lm(log(Volume) ~ log(Height) + log(Girth), data = trees))

# En análisis de expresion diferencial se hacen las n lm() para n genes y
# solo se extrae un coeficiente estimado de interes.

library("ExploreModelMatrix")

### Ejemplo 1
## Datos de ejemplo
(sampleData <- data.frame(
  genotype = rep(c("A", "B"), each = 4),
  treatment = rep(c("ctrl", "trt"), 4)
))

## Creemos las imágenes usando ExploreModelMatrix
vd <- ExploreModelMatrix::VisualizeDesign(
  sampleData = sampleData,
  designFormula = ~ genotype + treatment,
  textSizeFitted = 4
)

## Veamos las imágenes
cowplot::plot_grid(plotlist = vd$plotlist)

## Usaremos shiny
app <- ExploreModelMatrix(
  sampleData = sampleData,
  designFormula = ~ genotype + treatment
)
if (interactive()) shiny::runApp(app)


### Ejemplo 2: mucho más avanzado y complejo.
(sampleData <- data.frame(
  Response = rep(c("Resistant", "Sensitive"), c(12, 18)),
  Patient = factor(rep(c(1:6, 8, 11:18), each = 2)),
  Treatment = factor(rep(c("pre","post"), 15)),
  ind.n = factor(rep(c(1:6, 2, 5:12), each = 2))))
vd <- VisualizeDesign(
  sampleData = sampleData,
  designFormula = ~ Response + Response:ind.n + Response:Treatment,
  textSizeFitted = 3
)
cowplot::plot_grid(plotlist = vd$plotlist, ncol = 1)

## Usaremos shiny
app <- ExploreModelMatrix(
  sampleData = sampleData,
  designFormula = ~ Response + Response:ind.n + Response:Treatment,
)
if (interactive()) shiny::runApp(app)


## Ejercicio 3:
(sampleData = data.frame(
  condition = factor(rep(c("ctrl_minus", "ctrl_plus",
                           "ko_minus", "ko_plus"), 3)),
  batch = factor(rep(1:6, each = 2))))
vd <- VisualizeDesign(sampleData = sampleData,
                      designFormula = ~ 0 + batch + condition, # 0 + es importante para igualar intercep = 0 y eliminarlo.
                      textSizeFitted = 4, lineWidthFitted = 20,
                      dropCols = "conditionko_minus")
cowplot::plot_grid(plotlist = vd$plotlist, ncol = 1)
ExploreModelMatrix(sampleData)

# Nótese que, como la matriz no es Full Rank, no se puede estimar ConditionKO- y COnditionKO+
# por separado. Habría que eliminar uno de esos elementos para hacer la matriz Full Rank.


################################################
# 2) Datos de SRP045638
################################################

## Ejemplo con recount3
## ----download_SRP045638----------------------------------------------------------------------------------
library("recount3")

human_projects <- available_projects()

rse_gene_SRP045638 <- create_rse(
  subset(
    human_projects,
    project == "SRP045638" & project_type == "data_sources"
  )
)
assay(rse_gene_SRP045638, "counts") <- compute_read_counts(rse_gene_SRP045638)


## ----describe_issue--------------------------------------------------------------------------------------
rse_gene_SRP045638$sra.sample_attributes[1:3]


## ----solve_issue-----------------------------------------------------------------------------------------
rse_gene_SRP045638$sra.sample_attributes <- gsub("dev_stage;;Fetal\\|", "", rse_gene_SRP045638$sra.sample_attributes)
rse_gene_SRP045638$sra.sample_attributes[1:3]


## ----attributes------------------------------------------------------------------------------------------
rse_gene_SRP045638 <- expand_sra_attributes(rse_gene_SRP045638)

colData(rse_gene_SRP045638)[
  ,
  grepl("^sra_attribute", colnames(colData(rse_gene_SRP045638)))
]

# Usar info para un modelo estadístico; asegurando el formato adecuado.

## ----re_cast---------------------------------------------------------------------------------------------
## Pasar de character a nuemric o factor
rse_gene_SRP045638$sra_attribute.age <- as.numeric(rse_gene_SRP045638$sra_attribute.age)
rse_gene_SRP045638$sra_attribute.disease <- factor(rse_gene_SRP045638$sra_attribute.disease)
rse_gene_SRP045638$sra_attribute.RIN <- as.numeric(rse_gene_SRP045638$sra_attribute.RIN)
rse_gene_SRP045638$sra_attribute.sex <- factor(rse_gene_SRP045638$sra_attribute.sex)

## Resumen de las variables de interés
summary(as.data.frame(colData(rse_gene_SRP045638)[
  ,
  grepl("^sra_attribute.[age|disease|RIN|sex]", colnames(colData(rse_gene_SRP045638)))
]))


## ----new_variables---------------------------------------------------------------------------------------
## Encontraremos diferencias entre muestra prenatalas vs postnatales
rse_gene_SRP045638$prenatal <- factor(ifelse(rse_gene_SRP045638$sra_attribute.age < 0, "prenatal", "postnatal"))
table(rse_gene_SRP045638$prenatal)

## http://research.libd.org/recount3-docs/docs/quality-check-fields.html para documentación de vars.
rse_gene_SRP045638$assigned_gene_prop <- rse_gene_SRP045638$recount_qc.gene_fc_count_all.assigned / rse_gene_SRP045638$recount_qc.gene_fc_count_all.total
summary(rse_gene_SRP045638$assigned_gene_prop)
with(colData(rse_gene_SRP045638), plot(assigned_gene_prop, sra_attribute.RIN))

## Hm... veamos si hay una diferencia entre los grupos
with(colData(rse_gene_SRP045638), tapply(assigned_gene_prop, prenatal, summary))
with(colData(rse_gene_SRP045638), plot(assigned_gene_prop, sra_attribute.RIN, col=prenatal))


## ----filter_rse------------------------------------------------------------------------------------------
## Guardemos nuestro objeto entero por si luego cambiamos de opinión
rse_gene_SRP045638_unfiltered <- rse_gene_SRP045638

## Eliminemos a muestras malas
hist(rse_gene_SRP045638$assigned_gene_prop)
table(rse_gene_SRP045638$assigned_gene_prop < 0.3) # Valor de corte = mediana - 3SD a izquierda. Para caso unimodal.
rse_gene_SRP045638 <- rse_gene_SRP045638[, rse_gene_SRP045638$assigned_gene_prop > 0.3]

## Calculemos los niveles medios de expresión de los genes en nuestras
## muestras.
## Ojo: en un análisis real probablemente haríamos esto con los RPKMs o CPMs
## en vez de las cuentas. Primero eliminar muestras y luego genes.
gene_means <- rowMeans(assay(rse_gene_SRP045638, "counts"))
summary(gene_means)

## Eliminamos genes. 0.1 punto de corte del primer cuartil.
rse_gene_SRP045638 <- rse_gene_SRP045638[gene_means > 0.1, ]

## Dimensiones finales
dim(rse_gene_SRP045638)

## Porcentaje de genes que retuvimos
round(nrow(rse_gene_SRP045638) / nrow(rse_gene_SRP045638_unfiltered) * 100, 2)


################################################
# 3) Normalización de data.
################################################

## ----normalize-------------------------------------------------------------------------------------------
library("edgeR") # BiocManager::install("edgeR", update = FALSE)
dge <- DGEList(
  counts = assay(rse_gene_SRP045638, "counts"),
  genes = rowData(rse_gene_SRP045638)
)
dge <- calcNormFactors(dge)


## ----explore_gene_prop_by_age----------------------------------------------------------------------------
library("ggplot2")
ggplot(as.data.frame(colData(rse_gene_SRP045638)), aes(y = assigned_gene_prop, x = prenatal)) +
  geom_boxplot() +
  theme_bw(base_size = 20) +
  ylab("Assigned Gene Prop") +
  xlab("Age Group")


## ----statiscal_model-------------------------------------------------------------------------------------
mod <- model.matrix(~ prenatal + sra_attribute.RIN + sra_attribute.sex + assigned_gene_prop,
                    data = colData(rse_gene_SRP045638)
)
colnames(mod)


## ----run_limma-------------------------------------------------------------------------------------------
library("limma")
vGene <- voom(dge, mod, plot = TRUE)

eb_results <- eBayes(lmFit(vGene))

de_results <- topTable(
  eb_results,
  coef = 2,
  number = nrow(rse_gene_SRP045638),
  sort.by = "none"
)
dim(de_results)
head(de_results)

## Genes diferencialmente expresados entre pre y post natal con FDR < 5%
table(de_results$adj.P.Val < 0.05)

## Visualicemos los resultados estadísticos
plotMA(eb_results, coef = 2)

volcanoplot(eb_results, coef = 2, highlight = 3, names = de_results$gene_name)
de_results[de_results$gene_name %in% c("ZSCAN2", "VASH2", "KIAA0922"), ]


## ----pheatmap--------------------------------------------------------------------------------------------
## Extraer valores de los genes de interés
exprs_heatmap <- vGene$E[rank(de_results$adj.P.Val) <= 50, ]

## Creemos una tabla con información de las muestras
## y con nombres de columnas más amigables
df <- as.data.frame(colData(rse_gene_SRP045638)[, c("prenatal", "sra_attribute.RIN", "sra_attribute.sex")])
colnames(df) <- c("AgeGroup", "RIN", "Sex")

## Hagamos un heatmap
library("pheatmap")
pheatmap(
  exprs_heatmap,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = FALSE,
  show_colnames = FALSE,
  annotation_col = df
)


## ----plot_mds--------------------------------------------------------------------------------------------
## Para colores
library("RColorBrewer")

## Conviertiendo los grupos de edad a colores
col.group <- df$AgeGroup
levels(col.group) <- brewer.pal(nlevels(col.group), "Set1")
col.group <- as.character(col.group)

## MDS por grupos de edad
plotMDS(vGene$E, labels = df$AgeGroup, col = col.group)

## Conviertiendo los valores de Sex a colores
col.sex <- df$Sex
levels(col.sex) <- brewer.pal(nlevels(col.sex), "Dark2")
col.sex <- as.character(col.sex)

## MDS por sexo
plotMDS(vGene$E, labels = df$Sex, col = col.sex)


## ----respuesta, out.height="1100px"----------------------------------------------------------------------
## Tenemos que usar gene_id y gene_name
rowRanges(rse_gene_SRP045638)

## Con match() podemos encontrar cual es cual
rownames(exprs_heatmap) <- rowRanges(rse_gene_SRP045638)$gene_name[
  match(rownames(exprs_heatmap), rowRanges(rse_gene_SRP045638)$gene_id)
]

## Y luego podemos cambiar el valor de show_rownames de FALSE a TRUE
pheatmap(
  exprs_heatmap,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = TRUE,
  show_colnames = FALSE,
  annotation_col = df
)

## Guardar la imagen en un PDF largo para poder ver los nombres de los genes
pdf("pheatmap_con_nombres.pdf", height = 14, useDingbats = FALSE)
pheatmap(
  exprs_heatmap,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  show_rownames = TRUE,
  show_colnames = FALSE,
  annotation_col = df
)
dev.off()


