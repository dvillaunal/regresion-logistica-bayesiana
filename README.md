# Regresión logística bayesiana para el diagnóstico de cáncer de mama

**EN** — Bayesian binary logistic regression (brms/Stan) that estimates the probability of a positive breast cancer diagnosis from age, BI-RADS assessment, breast density, family history and BMI, using mammography records from the Breast Cancer Surveillance Consortium (BCSC). The project focuses on MCMC diagnostics (HDI, R-hat, effective sample size, trace, autocorrelation and energy plots) and on prediction plots for each covariate.

**ES** — Regresión logística binaria bayesiana (brms/Stan) que estima la probabilidad de un diagnóstico positivo de cáncer de mama a partir de la edad, la evaluación BI-RADS, la densidad mamaria, los antecedentes familiares y el IMC, con registros de mamografías del Breast Cancer Surveillance Consortium (BCSC). El trabajo se centra en el diagnóstico de las cadenas MCMC (HDI, R̂, tamaño efectivo de muestra, gráficos de traza, autocorrelación y energía) y en gráficos de predicción por covariable.

## Objetivo

Proponer un modelo que permita predecir, con los datos del examen ambulatorio, si la mujer examinada presenta cáncer de mama, y responder tres preguntas:

- ¿Es la densidad mamaria (escala BI-RADS) una variable de peso en el modelo?
- ¿Son los antecedentes familiares suficientes para determinar signos de cáncer de mama?
- ¿Un mayor IMC implica más casos de cáncer de mama?

## Datos

- **Fuente:** [BCSC Digital Mammography Dataset](https://www.bcsc-research.org/data/mammography_dataset/dataset_documentation), con información de 20.000 mamografías digitales y 20.000 de película realizadas entre enero de 2005 y diciembre de 2008. *Data collection and sharing was supported by the National Cancer Institute-funded Breast Cancer Surveillance Consortium (HHSN261201100031C).*
- **Variables:** `age_c` (edad), `assess_c` (evaluación BI-RADS, 0–5), `density_c` (densidad mamaria BI-RADS, 1–4), `famhx_c` (antecedentes familiares en primer grado: 0 = no, 1 = sí, 9 = falta), `bmi_c` (IMC) y `cancer_c` (diagnóstico: 0 = negativo, 1 = positivo).
- **Archivos incluidos:**
  - `breastexam.csv` y `dataset.zip`: datos originales (40.000 registros, 259 positivos; IMC faltante codificado como −99).
  - `dataset.csv`: base usada en el modelo, construida con `simu_data.R`. Combina 20.000 registros reales (con el IMC faltante imputado con valores aleatorios entre 18,5 y 30) y 20.000 registros **simulados** con reglas sobre BI-RADS, densidad y antecedentes. Alrededor del 3 % de sus registros son positivos.
  - `dataset_BreastExam.csv`: variante intermedia que usa el notebook de Python.

Los resultados deben leerse como un ejercicio metodológico y no como evidencia clínica, porque la mitad de la base de modelado es simulada.

## Métodos

- Análisis descriptivo de cada variable.
- Modelo: `cancer_c ~ age_c + assess_c + famhx_c + density_c + bmi_c` con verosimilitud Bernoulli y enlace logit, ajustado con `brms` sobre Stan, con los priors por defecto: planos para los coeficientes y Student-t(3, 0, 2,5) para el intercepto. Se usaron 3 cadenas de 15.000 iteraciones con 3.000 de calentamiento y semilla 123.
- Diagnóstico MCMC con `bayesplot`: intervalos HDI, R̂, razón Neff/N, gráficos de traza y de rangos, divergencias NUTS, ACF y gráfico de energía.
- Importancia de variables por AUC y curvas de probabilidad predicha por covariable.
- Variante con edad e IMC categorizados (`projectEnd.Rmd`). Versión exploratoria en Python con Bambi y ArviZ (WAIC, LOO, Pareto k, separation plot).

## Resultados principales

- **Convergencia:** R̂ = 1 en todos los parámetros y tamaños efectivos de muestra entre unos 21.000 y 58.000 (resumen posterior en `notas`). Los gráficos de traza no muestran divergencias.
- **Intervalos de credibilidad del 95 %:** excluyen el cero los coeficientes de edad, de todas las categorías de BI-RADS, de la densidad 2 y 3 y de los antecedentes familiares = 1. Incluyen el cero los de la densidad 4, los antecedentes = 9 (falta) y el IMC (−0,01 a 0,02).
- **Conclusiones del autor:** las cadenas convergen, pero el modelo tiene poca capacidad discriminativa por la baja proporción de casos positivos (3 %). La edad es la variable más influyente, y los antecedentes familiares pesan más que la evaluación BI-RADS. Recomienda probar otras variables u otros enfoques de predicción.

## Estructura del repositorio

```
.
├── Trabajo_Final_Bayesiana.pdf    # Informe final (22 páginas)
├── projectEnd.Rmd                 # Análisis en R: modelo brms y diagnósticos MCMC
├── modelBayes.R                   # Script del modelo y gráficos de áreas posteriores
├── simu_data.R                    # Imputación del IMC y construcción de dataset.csv
├── Bayesian Logit Regre.ipynb     # Versión exploratoria en Python (Bambi, ArviZ)
├── TrabajoFinal.Rmd, TrabajoFinal.pdf   # Borrador inicial del informe
├── notas                          # Resumen posterior y odds ratios copiados de la salida del modelo
├── breastexam.csv, dataset.zip, dataset.csv, dataset_BreastExam.csv   # Datos (ver sección Datos)
├── df_logit_coef.csv              # Coeficientes y odds ratios de una regresión logística clásica
├── *.png, modelo1.jpg             # Figuras del informe (descriptivas, HDI, R̂, traza, ACF, energía, predicciones)
├── SSRN-id1450589.pdf, SSRN-id1450589 es.pdf   # Artículo de referencia sobre el separation plot (original y traducción)
├── Estructura_CEED.rda, trabajo final.state.rda   # Objetos de R que el código no referencia
└── Trabajo 2 (Fallido)/           # Propuesta descartada: regresión logística bayesiana con datos de erupciones solares (UCI)
```

## Cómo reproducir

- R 4.2.0 con RStan instalado.
- Paquetes de `projectEnd.Rmd`: `tidyverse`, `magrittr`, `janitor`, `readr`, `BayesFactor`, `bayesplot` y `brms`. Para `simu_data.R` y `modelBayes.R` se necesitan además `caret`, `GGally`, `UPG`, `corrplot`, `rstanarm`, `loo`, `projpred`, `haven`, `sjstats` y `modelr`.
- Archivo de entrada: `projectEnd.Rmd`, que lee `dataset.csv`. El chunk `dataset` usa `df0`, que no está definido; reemplácelo por `df` antes de ejecutar. El ajuste es costoso: 3 cadenas de 15.000 iteraciones sobre 40.000 registros.
- Notebook de Python (Python 3.8): `pandas`, `numpy`, `seaborn`, `matplotlib`, `arviz` y `bambi`.

## Contexto y autoría

Trabajo final del curso Estadística Bayesiana, Escuela de Estadística, Facultad de Ciencias, Universidad Nacional de Colombia, sede Medellín (2022).

Autor: Daniel Felipe Villa Rengifo.
