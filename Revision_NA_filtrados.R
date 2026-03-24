ENCFT_2016_2 <- Base_ENCFT_20161_20164

# 1. Verificar observaciones antes de procesar
cat("Observaciones originales:", nrow(ENCFT_2016_2), "\n")

# 2. Ver distribución de los códigos originales
table(ENCFT_2016_2$NIVEL_ULTIMO_ANO_APROBADO, useNA = "ifany")
table(ENCFT_2016_2$ULTIMO_ANO_APROBADO, useNA = "ifany")

# 3. Aplicar la función SIN filtrar
ENCFT_2016_test <- ENCFT_2016_2 %>%
  funcion_anos_educacion()

# 4. Ver cuántos NAs genera la función
sum(is.na(ENCFT_2016_test$anos_educacion))
cat("NAs generados por la función:", sum(is.na(ENCFT_2016_test$anos_educacion)), "\n")

# 5. Identificar qué casos se vuelven NA
ENCFT_2016_2 %>%
  funcion_anos_educacion() %>%
  filter(is.na(anos_educacion)) %>%
  count(NIVEL_ULTIMO_ANO_APROBADO, ULTIMO_ANO_APROBADO) %>%
  arrange(desc(n))

# 6. Verificar si hay códigos no contemplados
ENCFT_2016_2 %>%
  count(NIVEL_ULTIMO_ANO_APROBADO) %>%
  arrange(NIVEL_ULTIMO_ANO_APROBADO)

#Verificacion de los 4402 datos NA
# Ver características de los casos sin educación reportada
ENCFT_2016_2 %>%
  filter(is.na(NIVEL_ULTIMO_ANO_APROBADO) & is.na(ULTIMO_ANO_APROBADO)) %>%
  summarise(
    edad_promedio = mean(EDAD, na.rm = TRUE),
    edad_min = min(EDAD, na.rm = TRUE),
    edad_max = max(EDAD, na.rm = TRUE),
    prop_con_ingreso = mean(INGRESO_ASALARIADO > 0, na.rm = TRUE),
    n_total = n()
  )

# Ver distribución por edad
ENCFT_2016_2 %>%
  filter(is.na(NIVEL_ULTIMO_ANO_APROBADO)) %>%
  count(EDAD) %>%
  arrange(desc(n)) %>%
  head(20)
