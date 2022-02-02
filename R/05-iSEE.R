# iSEE: Interactive SummarizedExperiment Explorer

## Explora el objeto rse de forma interactiva
library("iSEE")
iSEE::iSEE(rse) # Despliegue gráfico para hacer análisis más específicos.

# Ejercicio: iSEE
## Descarguemos unos datos de spatialLIBD
sce_layer <- spatialLIBD::fetch_data("sce_layer")
sce_layer

## Revisemos el tamaño de este objeto
lobstr::obj_size(sce_layer) / 1024^2 ## Convertir a MB

iSEE::iSEE(sce_layer)


## Ejercicio 1: Reproducir la imagen deseada con iSEE y analizar MOBP, MBP & PCP4.
## El primer resultado se encuentra en Imagenes/1_ReducedDimensionalPlot1.pdf.
## El segundo resultado se halla en ...
## ... donde se puede apreciar que
