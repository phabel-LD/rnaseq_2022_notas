# Archivo para notas generales de clase.
# Base: https://lcolladotor.github.io/rnaseq_LCG-UNAM_2022/

# 1) Bioconductor: http://bioconductor.org/

Bioconductor es un repositorio de paquetes de R enfocado en el análisis
y manejo de HT genomic data.

Los tipos de paquetes encontrado en Bioc son:
  *Software
  *Annotation
  *Experiment Data
  *Workflows

La documentación de los paquetes (vignette) es de suma importancia, dice mucho sobre
la fiabilidad del mismo. Este usualmente se encuentra en un HTML o PDF en
la página del paquete.

Existen dos ramas de Bioc: release & devel. Pero es más seguro usar release pues
ha sido más experimentada. Mientras que devel, como el nombre sugiere, es una rama
en desarrollo dirigida por las personas que desarrollan la paquetería; suele ser más
actual pero prona a errores e incompatibilidad.

# 2) Objetos en Bioconductor

* SummarizedExperiment (software): Almacena data de experimentos. Condensación
de más de una tabla por objeto interrelacionadas.
  -> rowRanges: Cada renglon es un gen.(m) Deriva del objeto DRanges.
  -> colData: Cada columna es una muestra. (n) Cada columna es un atributo de muestra.
  -> assay: (m x n) Puede haber más de una tabla con las mismas dims.
  -> exptData: metadata libre extra accesable que no está incluida en assays.

Se puede accesar a subconjuntos de tablas relacionadas.

* GenomicRanges [GRanges] (software): Analiza HT seq data, para almacenar data sobre
alineamientos e intervalos genómicos. Se pueden hacer comparaciones con seq referencia.
Indica los intervalos cromosómicos. IRanges(Interval Ranges), Rle (Re Length Ext). Partes:
  -> seqname
  -> ranges
  -> strand
Se pueden crear nuevas variables y accesarles con rowData(se)

* rtracklayer: interactua con buscadores genómicos y manipular su anotación para generar data.

