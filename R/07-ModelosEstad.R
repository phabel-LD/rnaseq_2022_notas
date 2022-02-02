# Modelos Estadísticos

# Con R, usamos mucho la función model.matrix() y la sintáxis de fórmula Y ~ X1 + X2 tal como en el siguiente ejemplo.
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


