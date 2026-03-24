#Se define y corre el modelo propuesto de MCO 
mod <- lm(
  log_salario ~ anos_educacion + experiencia + experiencia2 + tenure + tenure2
  + female + married, data = ENCFT_2016_modelo
)
summary(mod)

#####
#Evaluacion y test del modelo

### --- MULTICOLINEALIDAD ---
library(car)
vif(mod)

## Ausencia de evidencia de multicolinealidad severa en las variables, sin embargo,
## presencia de multicolinealidad estructural por los polinomios en experiencia y en tenure

#La literatura indica que es multicolinealidad no es problema y puede ser obviada, sin embargo se presenta un ajuste,
#Restando las medias en las variables con alto VIF

ENCFT_2016_modelo_c <- ENCFT_2016_modelo %>%
  mutate(
    experiencia_c = experiencia - mean(experiencia),
    experiencia2_c = experiencia_c^2,
    tenure_c = tenure - mean(tenure),
    tenure2_c = tenure_c^2
  )
## modelo con polinomios centrados
mod_c <- lm(
  log_salario ~ anos_educacion + experiencia_c + experiencia2_c +
    tenure_c + tenure2_c + female + married,
  data = ENCFT_2016_modelo_c
)
summary(mod_c)
vif(mod_c)

### --- HETEROCEDASTICIDAD ---

# Evaluacion visual de la variacion de los errores
# residuos y valores ajustados
residuos <- residuals(mod_c)
yhat <- fitted(mod_c)

plot(
  yhat, residuos,
  xlab = "Valores ajustados (log salario)",
  ylab = "Residuos",
  main = "Residuos vs Valores Ajustados"
)
abline(h = 0, col = "red", lwd = 2)

# Breusch–Pagan
#Ho: Los errores son homocedasticos
#H1: Los errores son heterocedasticos

bptest(mod_c)
# Se rechaza la nula, pues el p-value es menor que 1%, que 5% y 10%

#Test de White
bptest(
  mod_c,
  ~ anos_educacion + experiencia_c + tenure_c +
    I(anos_educacion^2) + I(experiencia_c^2) + I(tenure_c^2),
  data = ENCFT_2016_modelo_c
)


## Correccion por heterocedasticidad
# Errores estandar robustos
coeftest(mod_c, vcov=vcovHC(mod_c,type="HC0"))
coeftest(mod_c, vcov=vcovHC(mod_c,type="HC1"))
coeftest(mod_c, vcov=vcovHC(mod_c,type="HC2"))
coeftest(mod_c, vcov=vcovHC(mod_c,type="HC3"))

### --- RESET DE RAMSEY PARA LA FORMA FUNCIONAL---
#Ho: La forma funcional es la correcta
#H1: La forma funcional está mal especificada
resettest(mod_c, power = 2:3)


###----EXPORTACION DE TABLAS DEL MODELO-----

#---Tabla resumen de Ecuación del salario (MCO)---
stargazer(
  mod,
  type = "html",
  out = "tabla_modelo_base.html",
  title = "Ecuación Salario (MCO)",
  dep.var.labels = "Log del Salario por hora",
  covariate.labels = c(
    "Años de educación",
    "Experiencia",
    "Experiencia²",
    "Tenure",
    "Tenure²",
    "Mujer",
    "Casado/a"
  ),
  digits = 3
)

#---Tabla prueba de multicolinealidad (VIF) al modelo base---
vif_tabla <- data.frame(
  Variable = names(vif(mod)),
  VIF = as.numeric(vif(mod))
)

write.csv(vif_tabla, "tabla_vif.csv", row.names = FALSE)

#----Tabla resumen del modelo MCO con polinomios centrados ----
# Errores estándar robustos HC1
robust_se <- sqrt(diag(vcovHC(mod_c, type = "HC1")))
stargazer(
  mod_c,
  type = "html",
  out = "Ecuación Mincer con errores estándar robustos (HC1).html",
  se = list(robust_se),
  title = "Ecuación Mincer con errores estándar robustos (HC1)",
  dep.var.labels = "Log del salario por hora",
  covariate.labels = c(
    "Años de educación",
    "Experiencia (centrada)",
    "Experiencia²",
    "Tenure (centrado)",
    "Tenure²",
    "Mujer",
    "Casado/a"
  ),
  notes = "Errores estándar robustos a heterocedasticidad (HC1).",
  digits = 3
)


#---Tabla prueba de multicolinealidad (VIF) al modelo con polinomios centrados---
vif_tabla_robusta <- data.frame(
  Variable = names(vif(mod_c)),
  VIF = as.numeric(vif(mod_c))
)

write.csv(vif_tabla_robusta, "tabla_vif_robusto.csv", row.names = FALSE)

#---Tabla prueba de Heterocedasticidad (Breusch-Pagan y White) al modelo con polinomios centrados 
bp <- bptest(mod_c)
white <- bptest(
  mod_c,
  ~ anos_educacion + experiencia_c + tenure_c +
    I(anos_educacion^2) + I(experiencia_c^2) + I(tenure_c^2),
  data = ENCFT_2016_modelo_c
)

sink("tests_heterocedasticidad.txt")
print(bp)
print(white)
sink()

#---Tabla prueba RESET de Ramsey al modelo con polinomios centrados 
reset <- resettest(mod_c, power = 2:3)

sink("test_reset.txt")
print(reset)
sink()

#---Grafico se residuos para la prueba de heterocedasticidad al modelo con polinomios centrados 
png("residuos_vs_ajustados.png", width = 800, height = 600)
plot(fitted(mod_c), residuals(mod_c),
     xlab = "Valores ajustados (log salario)",
     ylab = "Residuos",
     main = "Residuos vs valores ajustados")
abline(h = 0, col = "red", lwd = 2)
dev.off()
