# Brecha Salarial de Género en la República Dominicana

**¿Cuánto menos gana una mujer dominicana por hora, comparada con un hombre de igual educación y experiencia?**

Investigación econométrica basada en microdatos de la Encuesta Nacional Continua de Fuerza de Trabajo (ENCFT) 2016 del Banco Central de la República Dominicana. Se estima una ecuación salarial de tipo minceriano para cuantificar la brecha salarial de género condicional en características observables de capital humano.

---

## Pregunta de investigación

> *¿Existe una brecha salarial de género estadísticamente significativa en la República Dominicana tras controlar por educación, experiencia laboral, antigüedad en el empleo y estado civil?*

---

## Hallazgo principal

Las mujeres perciben, en promedio, un salario por hora **aproximadamente 11% menor** que el de los hombres con características observables similares (educación, experiencia, antigüedad y estado civil). Esta brecha es estadísticamente significativa al 1% incluso después de controlar por capital humano, lo que sugiere la presencia de factores no explicados por diferencias en productividad observable.

---

## Metodología

### Datos
- **Fuente:** Encuesta Nacional Continua de Fuerza de Trabajo (ENCFT) 2016 — Banco Central de la República Dominicana
- **Unidad de observación:** Individuo ocupado con ingreso salarial positivo y horas trabajadas válidas
- **Observaciones finales:** 19,639 (tras limpieza y filtros de coherencia económica)

### Modelo econométrico

Ecuación salarial minceriana estimada por Mínimos Cuadrados Ordinarios (MCO):

```
ln(w_i) = β₀ + β₁Educ_i + β₂Exp_i + β₃Exp²_i + β₄Tenure_i + β₅Tenure²_i + β₆Female_i + β₇Married_i + ε_i
```

| Variable | Descripción |
|----------|-------------|
| `ln(w_i)` | Logaritmo natural del salario por hora |
| `Educ` | Años de educación (construidos desde nivel y último año aprobado) |
| `Exp` | Experiencia potencial: Edad − Educación − 6 (Mincer, 1974) |
| `Exp²` | Término cuadrático — captura rendimientos decrecientes |
| `Tenure` | Antigüedad en el empleo actual (años) |
| `Tenure²` | Término cuadrático de antigüedad |
| `Female` | Variable dicotómica: 1 = mujer, 0 = hombre |
| `Married` | Variable dicotómica: 1 = casado/unido, 0 = otro estado civil |

### Estrategia econométrica

| Diagnóstico | Prueba | Resultado | Corrección |
|-------------|--------|-----------|------------|
| Multicolinealidad | VIF | Alta en polinomios (esperada) | Centrado de variables |
| Heterocedasticidad | Breusch-Pagan + White | Detectada (p < 0.001) | Errores estándar robustos HC1 |
| Forma funcional | RESET de Ramsey | Se rechaza H₀ | Justificación teórica minceriana |

---

## Resultados principales

| Variable | Coeficiente | Interpretación |
|----------|-------------|----------------|
| Años de educación | 0.083*** | +8.3% en salario por año adicional de educación |
| Experiencia | 0.012*** | Positivo con rendimientos decrecientes |
| Tenure | 0.021*** | Antigüedad retribuida, también con rendimientos decrecientes |
| **Female** | **−0.111***` | **Las mujeres ganan ~11% menos, ceteris paribus** |
| Married | 0.239*** | Casados/unidos ganan ~27% más |
| R² | 0.347 | El modelo explica el 34.7% de la variación salarial |

*Significancia: *** p < 0.01*

---

## Estructura del repositorio

```
├── ENCFT_2016_Modelo_Brecha_Salarial.R   # Pipeline completo: carga, limpieza y construcción de variables
├── Modelo_seleccionado_limpio.R           # Construcción del dataset final del modelo
├── Test_ajuste_modelo.R                   # Estimación MCO, diagnósticos y exportación de tablas
├── Revision_NA_filtrados.R                # Diagnóstico de valores faltantes en educación
└── README.md
```

> **Nota sobre los datos:** Los microdatos de la ENCFT 2016 están disponibles públicamente en el sitio del [Banco Central de la República Dominicana](https://www.bancentral.gov.do). No se incluyen en este repositorio por su tamaño.

---

## Cómo reproducir el análisis

1. Descargar los microdatos ENCFT 2016 del Banco Central de la República Dominicana
2. Abrir `ENCFT_2016_Modelo_Brecha_Salarial.R` en RStudio — este script carga los datos y construye todas las variables
3. Ejecutar `Modelo_seleccionado_limpio.R` para generar el dataset del modelo
4. Ejecutar `Test_ajuste_modelo.R` para estimar el modelo y los diagnósticos

```r
# Paquetes requeridos
install.packages(c("tidyverse", "sandwich", "lmtest", "car", "stargazer", "broom", "readxl"))
```

---

## Contexto y relevancia

Este estudio contribuye a la evidencia empírica sobre determinación salarial en la República Dominicana, un área con relativa escasez de estudios basados en microdatos recientes. Los resultados son consistentes con la evidencia del BID (Urquidi, Serrate y Chalup, 2023), que documenta una brecha salarial residual significativa para el país tras controlar por capital humano.

Los hallazgos sugieren que políticas orientadas exclusivamente a reducir brechas educativas son necesarias pero insuficientes para cerrar la brecha salarial de género. Investigaciones futuras podrían incorporar descomposiciones Oaxaca-Blinder y controles por ocupación y sector.

---

## Referencias principales

- Mincer, J. (1974). *Schooling, Experience, and Earnings*. NBER.
- Goldin, C. (2014). A Grand Gender Convergence: Its Last Chapter. *American Economic Review*, 104(4), 1091–1119.
- Urquidi, M., Serrate, L. y Chalup, M. (2023). *Changes in Dominican Republic's Gender Earning Gap*. Inter-American Development Bank.
- Banco Central de la República Dominicana (2016). *Encuesta Nacional Continua de Fuerza de Trabajo (ENCFT)*.

---

## Autor

**Richard Federico Gil Romero**  
Estudiante de Economía — Universidad Autónoma de Santo Domingo (UASD)  
Materia: Econometría · Profesor: Francisco Ramírez  
[LinkedIn](https://www.linkedin.com/in/richard-federico-gil-romero-508286271) · [GitHub](https://github.com/GRRFede)
