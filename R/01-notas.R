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

* SummarizedExperiment [se] (software) <http://bioconductor.org/packages/release/bioc/html/SummarizedExperiment.html>:
Almacena data de experimentos. Condensación
de más de una tabla por objeto interrelacionadas.
  -> rowRanges: Cada renglon es un gen.(m) Deriva del objeto DRanges.
  -> colData: Cada columna es una muestra. (n) Cada columna es un atributo de muestra.
  -> assay: (m x n) Puede haber más de una tabla con las mismas dims.
  -> exptData: metadata libre extra accesable que no está incluida en assays.

Se puede accesar a subconjuntos de tablas relacionadas.

* GenomicRanges [GRanges] (software) http://bioconductor.org/packages/release/bioc/html/GenomicRanges.html:
Analiza HT seq data, para almacenar data sobre
alineamientos e intervalos genómicos. Se pueden hacer comparaciones con seq referencia.
Indica los intervalos cromosómicos. IRanges(Interval Ranges), Rle (Re Length Ext). Partes:
  -> seqname
  -> ranges
  -> strand
Se pueden crear nuevas variables y accesarles con rowData(se)

* rtracklayer http://bioconductor.org/packages/release/bioc/html/rtracklayer.html:
Interactua con buscadores genómicos y manipular su anotación para generar data.
Es capaz de manipula la informacion en varios formatos (GFF, BED, WIG)

*iSEE (Interactive SummarizedExperiment Explorer) <http://bioconductor.org/packages/release/bioc/html/iSEE.html>:
Crea una interfaz gráfica con un objeto "se", a través de la cual un usuario puede interactuar
más libremente con la información contenida en row, cols & metadata. Es una herramienta muy
útil para generar, analizar y descargar gráficos y tablas; siendo posible aplicar varios
análisis estadísticos como PCA y ver relaciones de expresión diferencial entre genes.

# 3) RNA-seq data

* SingleCellExperiment <http://bioconductor.org/packages/release/bioc/html/SingleCellExperiment.html>:
  Es un objeto especializado en almacenar data de experimentos single cell; se puede recuperar informacion,
reducir dimensionalidad y acceder a metadata.

* recount3 <http://bioconductor.org/packages/release/bioc/html/recount3.html>:
Se implementa también el paquete recount3 para acceder a datos uniformemente procesados de RNA-seq de humano y ratón.

# 3) Modelos estadísticos

* ExploreModelMatrix <http://bioconductor.org/packages/release/bioc/html/ExploreModelMatrix.html>:
Explora los resultados para la creación de modelos de regresiones lineales y predicciones. Sú lógica se basa
en determinar diferencias entre los datos para hallar expresión diferencial.
Lanza la app shiny para visualizar la información más fácilmente.

* Datos de SRP045638
  1) Importar con recount3
  2) Limpiar data manualmente
  3) Transform -> Visulizacion -> Modelo
  4) Comunicar con GitHub.

RNA integrity Number (RIN): número que indica la calidad experimental de la muestra.

En la normalización se asume que la mayoría de los genes no están diferencialmente expresados.
El factor de normalización se estima con métodos estadísticos con dicha asunción como heurística.
