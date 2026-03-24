library(readxl)
Base_ENCFT_20161_20164 <- read_excel("Base ENCFT 20161 - 20164.xlsx")
View(Base_ENCFT_20161_20164)
names(Base_ENCFT_20161_20164)
str(Base_ENCFT_20161_20164)

ENCFT_2016 <- Base_ENCFT_20161_20164

summary(ENCFT_2016$EDAD)
table(ENCFT_2016$SEXO)
table(ENCFT_2016$ZONA)
table(ENCFT_2016$EDAD)
table(ENCFT_2016$NIVEL_ULTIMO_ANO_APROBADO)
table(ENCFT_2016$ULTIMO_ANO_APROBADO)


ENCFT_2016$EDAD

#Instalacion de paquetes y librerias para trabajar con los datos
install.packages(c("tidyverse", "broom", "modelr","sandwich", "lmtest", "ggplot2",
                   "stargazer", "car"))
install.packages(c(
  "janitor","haven","labelled","sjlabelled",
  "skimr","summarytools","survey","DataExplorer"
))

library(tidyverse)
library(janitor)
library(haven)
library(labelled)
library(sjlabelled)
library(skimr)
library(stringr)
library(forcats)
library(car)
library(wooldridge)
library(lmtest)
library(sandwich)
library(stargazer)
library(broom)
library(openxlsx)

#Estimacion de variable anos de educacion
funcion_anos_educacion <- function(data,
                                   nivel = "NIVEL_ULTIMO_ANO_APROBADO",
                                   grado = "ULTIMO_ANO_APROBADO") {
  
  data %>%
    mutate(
      anos_educacion = case_when(
        #Sin estudios
        .data[[nivel]] %in% c(0,1,9,10) ~ 0,
        
        #primaria
        .data[[nivel]] == 2 ~ .data[[grado]],
        
        #secundaria
        .data[[nivel]] %in% c(3,4) ~ 8 + .data[[grado]],
        
        #bachillerato
        .data[[nivel]] == 5 ~ 12 + .data[[grado]],
        
        #universidad o +
        .data[[nivel]] %in% c(6,7,8) ~ 16 + .data[[grado]],
        
        TRUE ~ NA_real_
        
      )
    )
}

ENCFT_2016 <- funcion_anos_educacion(ENCFT_2016)

summary(ENCFT_2016$anos_educacion)
hist(ENCFT_2016$anos_educacion)

table(ENCFT_2016$anos_educacion)
colnames(ENCFT_2016)

#Estimacion Horas trabajadas 
ENCFT_2016 <- ENCFT_2016 %>%
  mutate(horas_semana  = HORAS_TRABAJA_SEMANA_PRINCIPAL)


summary(ENCFT_2016$horas_semana)
hist(ENCFT_2016$horas_semana)
table(ENCFT_2016$horas_semana)

#Busqueda de variables con para Horas Trabajadas y Salario
grep("INGR", names(ENCFT_2016), value=TRUE)
grep("HORAS", names(ENCFT_2016), value=TRUE)
grep("SALAR", names(ENCFT_2016), value=TRUE)
grep("Brut", names(ENCFT_2016), value=TRUE)


#Estimacion Salario     
#Se usara "Ingreso salario principal" para el Salario
ENCFT_2016 <- ENCFT_2016 %>%
  mutate(horas_mes = horas_semana * 4.33) %>%
  mutate(Salario_hora = INGRESO_ASALARIADO / horas_mes)

summary(ENCFT_2016$Salario_hora)
hist(ENCFT_2016$Salario_hora)
table(ENCFT_2016$Salario_hora)

#Observacion de NA y 0 para limpieza de datos
sum(is.na(ENCFT_2016$horas_semana))
sum(is.na(ENCFT_2016$INGRESO_ASALARIADO))
sum(ENCFT_2016$INGRESO_ASALARIADO == 0, na.rm = TRUE)
sum(ENCFT_2016$horas_semana == 0, na.rm = TRUE)

# SE filtra y limpia NA 
ENCFT_2016_filtrada <- ENCFT_2016 %>%
  # eliminar NAs educación
  filter(!is.na(anos_educacion)) %>%
  # eliminar horas absurdas
  filter(horas_semana > 0 & horas_semana < 100) %>%
  # Filtrar desocupados
  filter(INGRESO_ASALARIADO > 0)

#Observacion de NA y 0 para limpieza de datos
sum(is.na(ENCFT_2016_filtrada$horas_semana))
sum(is.na(ENCFT_2016_filtrada$INGRESO_ASALARIADO))
sum(ENCFT_2016_filtrada$INGRESO_ASALARIADO == 0, na.rm = TRUE)
sum(ENCFT_2016_filtrada$horas_semana == 0, na.rm = TRUE)
sum(is.na(ENCFT_2016_filtrada$anos_educacion))

#Estimacion de variable female
#Observacion de columna SEXO para convertir en dummy
ENCFT_2016_filtrada$SEXO

#Se crea variable dummy de female para el dataset filtrado
ENCFT_2016_filtrada <- ENCFT_2016_filtrada %>%
  mutate(female = ifelse(SEXO == 2,1,0))

# Revision de variables proxy posibles para tenure
grep("TIEMP", names(ENCFT_2016_filtrada), value = TRUE)
grep("ANTIG", names(ENCFT_2016_filtrada), value = TRUE)
grep("PERM", names(ENCFT_2016_filtrada), value = TRUE)
sum(is.na(ENCFT_2016_filtrada$TIEMPO_EMPLEO_ANOS))
sum(ENCFT_2016_filtrada$TIEMPO_EMPLEO_ANOS == 0, na.rm = TRUE)
sum(is.na(ENCFT_2016_filtrada$TIEMPO_EMPLEO_MESES))
sum(ENCFT_2016_filtrada$TIEMPO_EMPLEO_MESES == 0, na.rm = TRUE)
sum(is.na(ENCFT_2016_filtrada$TIEMPO_EMPLEO_DIAS))
sum(ENCFT_2016_filtrada$TIEMPO_EMPLEO_DIAS == 0, na.rm = TRUE)

#Estimacion de experiencia potencial por ecuacion de Mincer
ENCFT_2016_filtrada<- ENCFT_2016_filtrada %>% 
  mutate(
    experiencia = EDAD - anos_educacion - 6,
    
    #Correcion en caso de valores NA o negativos
    experiencia = case_when(
      is.na(EDAD) | is.na(anos_educacion) ~ NA_real_,
      experiencia < 0 ~ 0,
      TRUE ~ experiencia
    )
  )
# Verifiacion de valores extremos y valores en 0
head(ENCFT_2016_filtrada$experiencia)
hist(ENCFT_2016_filtrada$experiencia)
summary(ENCFT_2016_filtrada$experiencia)
sum(ENCFT_2016_filtrada$experiencia == 0)

ENCFT_2016_filtrada %>%
  filter(experiencia > 50) %>%
  select(EDAD, anos_educacion, experiencia) %>%
  arrange(desc(experiencia)) %>%
  head(50)


#Estimacion de variable married
#verificacion de columna ESTADO CIVIL
grep("CIVIL", names(ENCFT_2016_filtrada), value = TRUE)
#Verificacion de codigos de ESTADO CIVIl
table(ENCFT_2016_filtrada$ESTADO_CIVIL, useNA = "ifany")

  #Se usa ESTADO CIVIL en 2 y 3
ENCFT_2016_filtrada <- ENCFT_2016_filtrada %>%
  mutate(
    married = case_when(
    ESTADO_CIVIL %in% c(2,3) ~ 1,
    ESTADO_CIVIL %in% c(1,4,5,6) ~ 0,
    TRUE ~ NA_real_
  )
) %>%
  filter(!is.na(married))

# Verificacionde NA
table(ENCFT_2016_filtrada$married, useNA = "ifany")

#Estimacion de variable tenure, se usa proxy de tiempo
  #Creacionde funcion para TIEMPO
funcion_tiempo_total_empleo_dias <- function(tbl) {
  tbl %>%
    dplyr::mutate(
      # Calculo de tiempo total en dias
      # Donde años * 365 + meses * 30 + dias
      tiempo_total_empleo_dias = 
        TIEMPO_EMPLEO_ANOS * 365 +
        TIEMPO_EMPLEO_MESES * 30 +
        TIEMPO_EMPLEO_DIAS
    )
}

ENCFT_2016_filtrada <- ENCFT_2016_filtrada %>%
  funcion_tiempo_total_empleo_dias() %>%
  mutate(
    tenure = tiempo_total_empleo_dias / 365, # Conversion a anos
    tenure2 = tenure^2 #por si es necesario en el modelo
  )

# Verificacion de valores estimados
cat("=== TENURE CALCULADO ===\n")
summary(ENCFT_2016_filtrada$tenure)

#Ejemplos
ENCFT_2016_filtrada %>%
  select(TIEMPO_EMPLEO_ANOS, TIEMPO_EMPLEO_MESES, TIEMPO_EMPLEO_DIAS,
         tiempo_total_empleo_dias, tenure) %>%
  slice_sample(n = 15)
hist(ENCFT_2016_filtrada$tenure, breaks = 50)

