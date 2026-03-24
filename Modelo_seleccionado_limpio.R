#Creacion de dataset limpio con las variables necesarias del modelo
ENCFT_2016_modelo <- ENCFT_2016_filtrada %>%
  mutate(
    experiencia2 = experiencia^2,
    log_salario = log(Salario_hora) #Para usar el log del salario
  ) %>%
  select(
    #variable dependiente
    Salario_hora,
    log_salario,
    
    #Variables independientes
    anos_educacion,
    experiencia,
    experiencia2,
    tenure,
    tenure2,
    female,
    married,
    EDAD,
    horas_semana,
    
    #variables adiconales utiles,
    SEXO,
    ESTADO_CIVIL
  )

# Ver dimensiones
cat("Dataset original:", ncol(ENCFT_2016_filtrada), "columnas\n")
cat("Dataset modelo:", ncol(ENCFT_2016_modelo), "columnas\n")
cat("Observaciones:", nrow(ENCFT_2016_modelo), "\n")

# Ver estructura
glimpse(ENCFT_2016_modelo)

