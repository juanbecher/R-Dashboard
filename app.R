library(shiny)
library(tidyverse)
library(data.table)
library(lubridate)
library(openxlsx)
library(stringr)
#library(quantmod)
library(ggplot2)
library(scales)
library(highcharter)
library(shinydashboard)
library(shinyjs)
#library(PruebaLibreria)
library(formattable)
library(RColorBrewer)
library(wordcloud)
library(tools)
library(shinymanager)
library(writexl)
library(shinyvalidate)

#####CARGA #####
# setwd("C:/Users/joaqu/Desktop/Beneficios (1)/Beneficios")
AltasJub <- read.xlsx("./RDA/Altas_Octubre.xlsx",sheet = 1,detectDates = T)

AltasPen <- read.xlsx("./RDA/Altas_Octubre.xlsx",sheet = 3,detectDates = T)
AltasInv <- read.xlsx("./RDA/Altas_Octubre.xlsx",sheet = 2,detectDates = T)

Movilidad <- read.xlsx("./RDA/RetroBasico202009.xlsx",detectDates = T)

cant <- as.numeric(length(Movilidad$SOLICITUD))
Mot4 <- as.numeric(length(Movilidad[is.na(Movilidad$BAMOTACTUA) == F,]$SOLICITUD))
as.numeric(gsub(",",".",Movilidad$PAGCAL1026,fixed = T))
Movilidad$PAGCAL1026 <- as.numeric(gsub(",",".",Movilidad$PAGCAL1026,fixed = T))
Retros <- Movilidad[Movilidad$PAGCAL1026 > 0 | Movilidad$PAGCAL1026 < 0,]
Retros <- as.numeric(length(Retros$SOLICITUD))

tablaMov <- data.frame(
  CantidadSolicitudes = cant,
  Motivos4 = Mot4,
  CantidadRetros = Retros)
rm(cant,Mot4,Retros)

InvalidecesModif <- load("./RDA/InvalidecesModif.rda")

codigoMutuales <- read.xlsx("./RDA/Mutuales.xlsx",sheet = 1)

codigoMutuales <- codigoMutuales[codigoMutuales$Diferencia > 1.15 | codigoMutuales$Diferencia < 0.85, ]
comparacionAsociacion <- read.xlsx("./RDA/Mutuales.xlsx",sheet = 2)
comparacionAsociacion <- comparacionAsociacion[,c(2,3,4,5,6,7,9,14)]
comparacionCobros <- read.xlsx("./RDA/Mutuales.xlsx",sheet = 3)
comparacionCobros <- comparacionCobros[,c(2,3,4,5,6,7,9,14)]

# CARGA CANTIDAD DE BENEFICIOS
#Beneficios <- getCantidadBeneficios()
load("./RDA2/Beneficios.rda")
cantBeneficios <- as.numeric(nrow(Beneficios))
cantBeneficios <- prettyNum(cantBeneficios, scientific = FALSE, big.mark= ".", decimal.mark = ",")
#cantBeneficios <- comma(cantBeneficios, format = "f", big.mark = ",")
# CARGA DEMORA DE BENEFICIOS POR MES
#DemoraJO <- getDemoraBeneficioJO()
load("./RDA2/DemoraJO.rda")



#DemoraJI <- getDemoraBeneficioJI()
load("./RDA2/DemoraJI.rda")


# CARGA LA PROYECCION DE ALTAS ANUAL
#Proyeccion <- getProyeccionAltas()
load("./RDA/ProyeccionAltas.rda")
Proyeccion <- PersonaProx
# CARGA
#Altas <- getAltas()
load("./RDA2/Altas.rda")
load("./RDA2/Altas2.rda")
colnames(Altas_modif)[5] <- "Anio"
# Vencidos
#Vencidos <- getVencidos()
load("./RDA2/Vencidos.rda")

#RRRHH LICENCIAS

load("./RDA2/RRHH_Licencias.rda")
rh_lic <- rh_lic %>% arrange(SECTOR, DESCRIPCIONAUSENCIA.1)
colnames(rh_lic)[6] <- "Anio"
rh_lic <- rh_lic %>% 
  mutate(SECTOR = toTitleCase(str_to_lower(SECTOR, locale = "es")))
rh_lic <- rh_lic %>% 
  mutate(DESCRIPCIONAUSENCIA.1 = toTitleCase(str_to_lower(DESCRIPCIONAUSENCIA.1, locale = "es")))

load("./RDA2/RRHH_ACA.rda")
rh_ACA <- rh_ACA %>% 
  mutate(SECTOR = toTitleCase(str_to_lower(SECTOR, locale = "es")))

load("./RDA2/RRHH_Ausencias.rda")
rh_ausencias$periodo <- paste(year(rh_ausencias$FECHA),"-" ,str_pad(month(rh_ausencias$FECHA), 2,"left", pad = "0"), sep = "")
rh_ausencias <- rh_ausencias %>% 
  mutate(SECTOR = toTitleCase(str_to_lower(SECTOR, locale = "es")))

load("./RDA2/RRHH_ComisionesPorAgente.rda")
rh_com <- rh_com %>% arrange(SECTOR)
rh_com$periodo <- paste(substr(rh_com$periodo,1,5),str_pad(substr(rh_com$periodo,6,7),2,"left",pad = "0"), sep = "")
rh_com <- rh_com %>% 
  mutate(SECTOR = toTitleCase(str_to_lower(SECTOR, locale = "es")))
rh_com <- rh_com %>% 
  mutate(DESCRIPCIONAUSENCIA = toTitleCase(str_to_lower(DESCRIPCIONAUSENCIA, locale = "es")))

load("./RDA2/RRHH_detalleComisiones.rda")
rh_comision <- rh_comision %>% 
  mutate(SECTOR = toTitleCase(str_to_lower(SECTOR, locale = "es")))
rh_comision <- rh_comision %>% 
  mutate(DESCRIPCIONAUSENCIA.1 = toTitleCase(str_to_lower(DESCRIPCIONAUSENCIA.1, locale = "es")))

load("./RDA2/RRHH_Productividad.rda")
rh_productividad <- rh_productividad %>% 
  mutate(SECTOR = toTitleCase(str_to_lower(SECTOR, locale = "es")))
colnames(rh_productividad)[6] <- "Anio"

  rh_productividad$MES <- str_pad(rh_productividad$MES, 2,"left", pad = "0")
rh_productividad$periodo <- paste(rh_productividad$Anio, "-", rh_productividad$MES, sep= "")
rh_productividad$PorcentajeCumpl <- round(rh_productividad$PorcentajeCumpl, digits = 2)
rh_productividad <- rh_productividad %>%
  arrange(periodo)
# rh_productividad$PorcentajeCumpl <- rh_productividad$PorcentajeCumpl *100

load("./RDA2/variacionGasto.rda")

load("./RDA2/variacionIngreso.rda")

load("./RDA2/gastoMensual.rda")

load("./RDA2/ingresoMensual.rda")
ingresoMensual <- IngresoMensual
nuevaLey <- read.xlsx("./RDA/Ahorro Nueva Ley 04-09.xlsx",detectDates = T)
nuevaLey$mesAnio <- paste(months(nuevaLey$Mes_numero), year(nuevaLey$Mes_numero), sep=" ")
nuevaLey$Total.Ahorro <- nuevaLey$Total.Ahorro * (-1)
nuevaLey$Total.Ahorro <- round(nuevaLey$Total.Ahorro, 0)
colnames(nuevaLey) <- c("Mes_numero","Mes","Ley10333","Ahorro_haberInicial","Ahorro_dif","AporteSolidario","TotalAhorro","Ley10664","mesAnio")
nuevaLey$Ley10333 <- prettyNum(round(nuevaLey$Ley10333, 0), scientific = FALSE, big.mark= ".", decimal.mark = ",")
nuevaLey$Ley10664 <- prettyNum(round(nuevaLey$Ley10664, 0), scientific = FALSE, big.mark= ".", decimal.mark = ",")
nuevaLey$Ahorro_dif <- prettyNum(round(nuevaLey$Ahorro_dif, 0), scientific = FALSE, big.mark= ".", decimal.mark = ",")
nuevaLey$Ahorro_haberInicial <- prettyNum(round(nuevaLey$Ahorro_haberInicial, 0), scientific = FALSE, big.mark= ".", decimal.mark = ",")
nuevaLey$AporteSolidario <- prettyNum(round(nuevaLey$AporteSolidario, 0), scientific = FALSE, big.mark= ".", decimal.mark = ",")
tablaLey <- nuevaLey[,c(1,3:8)]
tablaLey$TotalAhorro <- prettyNum(round(nuevaLey$TotalAhorro, 0), scientific = FALSE, big.mark= ".", decimal.mark = ",")

#nuevaLey$Total.Ahorro2 <- prettyNum(nuevaLey$Total.Ahorro, scientific = FALSE, big.mark= ".")

load("./RDA/legales.rda")
legales$TPINDID <- as.numeric(legales$TPINDID)
legales$TPINDDVAL <- as.numeric(legales$TPINDDVAL)
legales <- legales[!is.na(legales$TPINDDVAL), ]
legales$mesAnio <- paste(legales$TPINDDEMI, "01")
legales$mesAnio <- as.Date(legales$mesAnio, "%Y%m%d")
legales$mesAnio <- paste(months(legales$mesAnio), year(legales$mesAnio), sep=" ")
legales$TPINDDEMI <- as.Date(paste(legales$TPINDDEMI,"01",sep=""), "%Y%m%d")
load("./RDA/Calidad.rda")

#####Carga Modulo 2 ####
load("./RDA/Beneficios.rda")
cantBeneficios <- as.numeric(nrow(Beneficios))
cantBeneficios <- prettyNum(cantBeneficios, scientific = FALSE, big.mark= ".")

load("./RDA/DF_Retro.rda")
load("./RDA/Dato_basico2.rda")
load("./RDA/DatoBaseImp.rda")
load("./RDA/Sectores.rda")

Dato_Retro$Retro <- round(Dato_Retro$Retro ,0)
Dato_Retro$Suma <- round(Dato_Retro$Suma ,0)

Sectores <- Sectores %>% 
  mutate(SECTNOMBRE = toTitleCase(str_to_lower(SECTNOMBRE, locale = "es")))



Proyeccion$EDAD <- round(Proyeccion$EDAD,2)
Proyeccion$Años <- round(Proyeccion$Años,2)

final_summary_words$n <- as.numeric(final_summary_words$n)

#####Lectura Usuarios####
load("./RDA/credentials.rda", envir = .GlobalEnv)
# # CARGA CANTIDAD DE BENEFICIOS
# #Beneficios <- getCantidadBeneficios()
# load("C:/Users/Juan/Desktop/Proyecto/RDA/Beneficios.rda")
# cantBeneficios <- as.numeric(nrow(Beneficios))
# cantBeneficios <- prettyNum(cantBeneficios, scientific = FALSE, big.mark= ".")
# #cantBeneficios <- comma(cantBeneficios, format = "f", big.mark = ",")
# # CARGA DEMORA DE BENEFICIOS POR MES
# #DemoraJO <- getDemoraBeneficioJO()
# load("C:/Users/Juan/Desktop/Proyecto/RDA/DemoraJO.rda")
# 
# 
# 
# #DemoraJI <- getDemoraBeneficioJI()
# load("C:/Users/Juan/Desktop/Proyecto/RDA/DemoraJI.rda")
# 
# 
# # CARGA LA PROYECCION DE ALTAS ANUAL
# #Proyeccion <- getProyeccionAltas()
# load("C:/Users/Juan/Desktop/Proyecto/RDA/ProyeccionAltas.rda")
# Proyeccion <- PersonaProx
# Proyeccion$EDAD <- round(Proyeccion$EDAD, digits = 2)
# Proyeccion$Anios <- round(Proyeccion$Anios, digits = 2)
# # CARGA
# #Altas <- getAltas()
# load("C:/Users/Juan/Desktop/Proyecto/RDA/Altas.rda")
# load("C:/Users/Juan/Desktop/Proyecto/RDA/Altas2.rda")
# 
# # Vencidos
# #Vencidos <- getVencidos()
# load("C:/Users/Juan/Desktop/Proyecto/RDA/Vencidos.rda")
# 
# #RRRHH LICENCIAS
# 
# load("C:/Users/Juan/Desktop/Proyecto/RDA/RRHH_Licencias.rda")
# rh_lic <- rh_lic %>% arrange(SECTOR, DESCRIPCIONAUSENCIA.1)
# 
# load("C:/Users/Juan/Desktop/Proyecto/RDA/RRHH_ACA.rda")
# load("C:/Users/Juan/Desktop/Proyecto/RDA/RRHH_Ausencias.rda")
# rh_ausencias$periodo <- paste(year(rh_ausencias$FECHA),"-" ,str_pad(month(rh_ausencias$FECHA), 2,"left", pad = "0"), sep = "")
# load("C:/Users/Juan/Desktop/Proyecto/RDA/RRHH_ComisionesPorAgente.rda")
# rh_com <- rh_com %>% arrange(SECTOR)
# load("C:/Users/Juan/Desktop/Proyecto/RDA/RRHH_detalleComisiones.rda")
# load("C:/Users/Juan/Desktop/Proyecto/RDA/RRHH_Productividad.rda")
# rh_productividad$MES <- str_pad(rh_productividad$MES, 2,"left", pad = "0")
# rh_productividad$periodo <- paste(rh_productividad$Anio, "-", rh_productividad$MES, sep= "")
# rh_productividad$PorcentajeCumpl <- round(rh_productividad$PorcentajeCumpl * 100, digits = 2)
# # load("C:/Users/Juan/Desktop/Proyecto/RDA/variacionGasto.rda")
# # 
# # load("C:/Users/Juan/Desktop/Proyecto/RDA/variacionIngreso.rda")
# 
# load("C:/Users/Juan/Desktop/Proyecto/RDA/gastoMensual.rda")
# 
# load("C:/Users/Juan/Desktop/Proyecto/RDA/ingresoMensual.rda")

#
# #GASTO MENSUAL_ IND 26 Y 28
# gastoMensual <- getGastoMensual()
#
# #VARIACION MENSUAL Y ANUAL DEL GASTO (52 = MENSUAL ;  53 = ANUAL)
# VariacionGasto <- getVariacionGasto()
#
# #INGRESO MENSUAL IND 44
# ingresoMensual <- getIngresoMensual()
#
# #VARIACION MENSUAL Y ANUAL DEL INGRESO (54 = MENSUAL ;  55 = ANUAL)
# variacionIngreso <- getVariacionIngreso()


###############  HEADER ###############
header <- dashboardHeader(

  title = tags$img(src="Isotipo.png", width = '50', height = '45')
  
  #tags$img(src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSspEFiANdEmogpOL9rFgrpNWQ1PrVlhoZtSKTbNyTR7xn3ZJD3", width = '100%', maxWidth = '450px',  height = '125px', align = 'center'),
  
  # column(12,
  #        tags$img(src="http://pactoglobal.org.ar/wp-content/uploads/2015/05/Isologo-CAJA-DE-JUBILACIONES.jpg", width = '100%', height = '125', align = 'center'))
  
)


###############  SIDEBAR ##############
sidebar <- dashboardSidebar(
  
  sidebarMenu(
    menuItem("Home", tabName = "Home", icon = icon("home")),
    menuItem("Beneficios", tabName = "Beneficios", icon = icon("calculator"),
             menuSubItem("Nuevos beneficios", tabName = "NuevosBeneficios"),
             menuSubItem("Tiempo de beneficios", tabName = "DemoraBeneficios"),
             menuSubItem("Vencimiento de vig", tabName = "VencimientoVig")),
    menuItem("RRHH", tabName = "RRHH", icon = icon("users"),
             menuSubItem("Control de licencias", tabName = "ControlLicencias"),
             menuSubItem("Ausentismo", tabName = "Ausencias"),
             menuSubItem("ACA", tabName = "ACA"),
             menuSubItem("Comisiones Act Laboral", tabName = "ComisionesActLaboral"),
             menuSubItem("Productividad", tabName = "Productividad")),
    menuItem("Finanzas", tabName = "Finanzas", icon = icon("balance-scale"),
             menuSubItem("Gastos", tabName = "GastoMensual"),
             menuSubItem("Ingresos", tabName = "Ingresos"),
             menuSubItem("Nueva ley", tabName = "nuevaLey")
    ),
    menuItem("Legales", tabName = "Legales", icon = icon("book"),
             menuSubItem("Causas", tabName = "Causas"),
             menuSubItem("Juicios resueltos", tabName = "Resueltos")
             ),
    menuItem("Liquidaciones", tabName = "Liquidaciones", icon = icon("coins"),
             menuSubItem("Mutuales", tabName = "ControlMutu"),
             menuSubItem("Movilidad", tabName = "ControlMovi"),
             menuSubItem("Beneficios", tabName = "ControlBene"),
             menuSubItem("Invalideces", tabName = "ControlInva")
    ),
    menuItem("Calidad", tabName = "Calidad", icon = icon("handshake"),
             menuSubItem("Consultas web", tabName = "Calidad1")
             ),
    menuItem("Proyecciones", tabName = "Proyecciones", icon = icon("chart-line"),
             menuSubItem("Variación base imp", tabName = "baseImp"),
             menuSubItem("Básico", tabName = "basico"),
             menuSubItem("Futuras altas", tabName = "altas")
    ),
    menuItem("Users", tabName = "Admin", icon = icon("address-card"),
             menuSubItem("Administración", tabName = "Admin"),
             menuSubItem("Mi Usuario", tabName = "Informacion"))
    # menuItem("SOCIAL MEDIA", tabName = "SocialMedia", icon = icon("thumbs-up"))
  )
)

#tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
###############  BODY ################
body <- dashboardBody(
  shinyjs::useShinyjs(),
  tags$link(rel = "stylesheet", type = "text/css", href = "https://fonts.googleapis.com/css2?family=Nunito:wght@300;400;600;700&display=swap"),
  #tags$link(rel = "stylesheet", type = "text/css", href = "estilos.css"),
  tags$link(rel = "stylesheet", type = "text/css", href = "logo.css"),
  tabItems(
    tabItem(tabName = "Home",
            fluidRow(
              h1(strong("Portal de transparencia"))
            ),
            
            br(),
            wellPanel(
              #style = "background-color: white;",
              
              
              
              
              #h3("\n Cantidad de beneficios"),
              h2("Prestaciones \n ", cantBeneficios),
              
              br(),
              fluidRow(
                column(6, highchartOutput("tortaCantidadBeneficiosPOJ", height = "300px")),
                column(6, highchartOutput("tortaCantidadBeneficiosSEXO", height = "300px"))
              )
              
              
              
              
              
              
              
            )
            
            
    ),
    ##### BENEF_BODY #####
    tabItem(tabName = "NuevosBeneficios",
            fluidRow(class="row-kpi",
                     br(),
                     # valueBoxOutput("contNuevosBenef"),
                     # valueBoxOutput("ProyeccionAltas"),
                     # valueBoxOutput("ultimoMesBeneficio")
                     column(4,valueBoxOutput("contNuevosBenef")),
                     # column(4,valueBoxOutput("ProyeccionAltas")),
                     column(4,valueBoxOutput("ultimoMesBeneficio"))
            ),
            fluidRow(class = "row-input",
                     column(4,
                            selectInput(
                              inputId = "IAnioDesde",
                              label = h5("Año inicio"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                              selected = 2018
                            )
                     ),
                     column(4,
                            selectInput(
                              inputId = "IAnioHasta",
                              label = h5("Año fin"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                              selected = 2020
                            )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "type",
                         label = h5("Tipo de gráfico"),
                         choices = c("Linea", "Columna", "Barra", "Curva")
                       )
                     )
            ),
            br(),
                       fluidRow(

                         # column(3,
                         #        # downloadButton("descarga", h5("Descargar"))
                         # )
                       ),
                       
                wellPanel(
                         div(class="titulo-grafico con-nav",
                             p("Nuevos beneficios", class="tit_p")
                             # downloadButton("descarga",label="", class = "boton-descargar")
                         ),
                         tabsetPanel(
                           tabPanel("Gráfico",
                                    highchartOutput("hcontainer", height = "500px")),
                           tabPanel("Tabla",
                                    DT::dataTableOutput("table",width = "100%", height = "auto"))
                           # tabPanel("Futuras Altas",
                           #          # downloadButton("descarga4",label="",class = "boton-descargar"),
                           #          br(),
                           #          DT::dataTableOutput("tablaProyeccionAltas",width = "100%", height = "auto"))
                           )
                )
    ),
    tabItem(tabName = "DemoraBeneficios",
            
            # fluidRow(
            #   br(),
            #   valueBoxOutput("contNuevosBenef"),
            #   valueBoxOutput("contNuevosBenef2"),
            #   valueBoxOutput("contNuevosBenef3")
            # ),
            fluidRow(
              column(5,offset = 1,
                     actionButton(inputId = "JO", icon = icon("user-circle"), class="boton-grande", width = '90%', p("Jub-Ordinaria"))
              ),
              column(5,
                     actionButton(inputId = "JI", icon = icon("user-circle"), width = '90%', p("Jub-Invalidez"), class="boton-grande")
              )
              
            ),
            shinyjs::hidden(
              div( id = "menuDemora",
                   fluidRow(class="row-kpi",
                     br(),
                     # valueBoxOutput("DemoraKPI"),
                     # valueBoxOutput("DemoraKPI2"),
                     # valueBoxOutput("DemoraKPI3")
                     column(4,valueBoxOutput("DemoraKPI")),
                     column(4,valueBoxOutput("DemoraKPI2")),
                     column(4,valueBoxOutput("DemoraKPI3"))
                   ),
                   
                                fluidRow( class="row-input",
                                  column(4,
                                         selectInput(
                                           inputId = "IAnioDesdeDemora",
                                           label = h5("Año inicio"),
                                           choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                                           selected = 2020
                                         )
                                  ),
                                  column(4,
                                         selectInput(
                                           inputId = "IAnioHastaDemora",
                                           label = h5("Año fin"),
                                           choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                                           selected = 2020
                                         )
                                  ),
                                  column(
                                      width = 4,
                                      selectInput(
                                        "type2",
                                        label = h5("Tipo de gráfico"),
                                        choices = c("Linea", "Columna", "Barra", "Curva")
                                      )
                                    )
                                  ),
                   br(),
                                 
                                
                                #plotOutput("nuevosBenef")
                                wellPanel(
                                  div(class="titulo-grafico con-nav",
                                      p("Demora Jubilacion Ordinaria", class="tit_p")
                                      # downloadButton("descarga2",label="", class = "boton-descargar")
                                  ),
                                  tabsetPanel(
                                    tabPanel("Gráfico",
                                    highchartOutput("graficoDemoraJO", height = "600px")),
                                    tabPanel("Tabla",
                                           DT::dataTableOutput("tablaDemoraJO",width = "100%", height = "auto"))
                                  )
                                )
                   )),
            shinyjs::hidden(
              div( id = "menuDemoraJI",
                   fluidRow(class="row-kpi",
                     br(),
                     # valueBoxOutput("DemoraJI_KPI"),
                     # valueBoxOutput("DemoraJI_KPI2"),
                     # valueBoxOutput("DemoraJI_KPI3")
                     column(4,valueBoxOutput("DemoraJI_KPI")),
                     column(4,valueBoxOutput("DemoraJI_KPI2")),
                     column(4,valueBoxOutput("DemoraJI_KPI3"))
                   ),
                   #h3("\n Demora de beneficios por area"),
                   
                   fluidRow(class="row-input",
                            column(4,
                                   selectInput(
                                     inputId = "IAnioDesdeDemoraJI",
                                     label = h5("Año inicio"),
                                     choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                                     selected = 2020
                                   )
                            ),
                            column(4,
                                   selectInput(
                                     inputId = "IAnioHastaDemoraJI",
                                     label = h5("Año fin"),
                                     choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                                     selected = 2020
                                   )
                            ),
                            column(
                              width = 4,
                              selectInput(
                                "type3",
                                label = h5("Tipo de gráfico"),
                                choices = c("Linea", "Columna", "Barra", "Curva")
                              ))
                            ),
                   br(),
                   wellPanel(
                     div(class="titulo-grafico con-nav",
                         p("Demora Jubilación Invalidez", class="tit_p")
                         # downloadButton("descarga3",label="", class = "boton-descargar")
                     ),
                     tabsetPanel(
                       tabPanel("Gráfico",
                                
                                
                               
                                #plotOutput("nuevosBenef")
                                wellPanel(
                                  
                                  highchartOutput("graficoDemoraJI", height = "500px"))
                                
                       ),
                       tabPanel("Tabla",
                                DT::dataTableOutput("tablaDemoraJI",width = "100%", height = "auto"))
                     )
                     
                   )))
            
    ),
    tabItem(tabName = "CantidadBeneficios",
            
            # fluidRow(
            #   br(),
            #   valueBoxOutput("contNuevosBenef"),
            #   valueBoxOutput("contNuevosBenef2"),
            #   valueBoxOutput("contNuevosBenef3")
            # ),
            wellPanel(
              # tabsetPanel(
              #   tabPanel("Gráfico",
              #
              #
              #            #h3("\n Cantidad de beneficios"),
              #            h4("TOTAL PRESTACIONES \n ", cantBeneficios, style = "font-family: Arial; text-align: center"),
              #
              #            br(),
              #            fluidRow(
              #              column(6, highchartOutput("tortaCantidadBeneficiosPOJ", height = "350px")),
              #              column(6, highchartOutput("tortaCantidadBeneficiosSEXO", height = "350px"))
              #            )
              #
              #
              #
              #
              #   )
              # )
              
            )
            
    ),
    tabItem(tabName = "VencimientoVig",
            fluidRow(class="row-kpi",
              br(),
              # valueBoxOutput("VenciKPI")
              # valueBoxOutput("VenciKPI2"),
              # valueBoxOutput("VenciKPI3")
              column(4,offset = 4,valueBoxOutput("VenciKPI"))
            ),
            fluidRow(class="row-input",
                     column(4,
                            dateRangeInput("rangoValidacion", label = h5("Seleccione fecha de vigencia"), start = (Sys.Date() - 28),end = Sys.Date(), width = '400px',language = "es",separator = "hasta")
                     ),
                     column(4,
                            selectInput(
                              "tipoPrestacion",
                              label = h5("Prestación"),
                              choices = sort(unique(Vencidos$PRESTDSC))
                            )
                     )),
            br(),
            wellPanel(
              div(class="titulo-grafico",
                  p("Beneficios proximos a vencer")
              ),
              
                         
                         
                         
                         DT::dataTableOutput("tablaVencidos",width = "100%", height = "auto")
                
              
              
            )
            
    ),
    
    
    ##### RRHH_BODY #####
    tabItem(tabName = "ControlLicencias",
            #h2("Widgets tab content"),
            fluidRow(class="row-kpi",
              br(),

              # valueBoxOutput("totalLicencia")
              # valueBoxOutput("totalLicencia2"),
              # valueBoxOutput("totalLicencia3")
              # valueBoxOutput("VariacionMensual"),
              # valueBoxOutput("VariacionAnual")
              column(4,offset = 4,valueBoxOutput("totalLicencia"))

            ),
            
            
                         #h3("\n GASTOS MENSUALES"),
                       
                         fluidRow(class="row-input",
                           column(4,
                                  selectInput(
                                    inputId = "IAnioDesdeLicencia",
                                    label = h5("Año inicio"),
                                    choices = c(2016, 2017, 2018, 2019, 2020,2021),
                                    selected = 2019
                                  )
                           ),
                           column(4,
                                  selectInput(
                                    inputId = "IAnioHastaLicencia",
                                    label = h5("Año fin"),
                                    choices = c(2016, 2017, 2018, 2019, 2020,2021),
                                    selected = 2020
                                  )
                           ),
                           column(4,
                                  selectInput(
                                    inputId = "tipoLicencia",
                                    label = h5("Tipo de licencia"),
                                    choices = unique(rh_lic$DESCRIPCIONAUSENCIA.1),
                                    selected = "TODAS"
                                  )
                           )),
                         
                         fluidRow(class="row-input",
                           column(
                             width = 4,
                             selectInput(
                               "typeLicencia",
                               label = h5("Tipo de gráfico"),
                               choices = c("Linea", "Columna", "Barra", "Curva")
                             )
                           ),
                           column(
                             width = 4,
                             selectInput(
                               "sectorLicencia",
                               label = h5("Sector"),
                               choices = c(unique(rh_lic$SECTOR), "Todos"),
                               selected = "Todos"
                             )
                           )
                           # ,
                           # column(3,offset = 6,
                           #        downloadButton("descargaLicencia", h5("Descargar"))
                           # )
                         ),
            br(),
                         wellPanel(
                           div(class="titulo-grafico con-nav",
                               p("Control de licencias", class ="tit_p")
                           ),
                           
                             tabsetPanel(
                               tabPanel("Gráfico",
                           highchartOutput("graficoLicencia", height = "500px")),
                           tabPanel("Tabla",
                                    br(),
                                    DT::dataTableOutput("tablaLicencia",width = "100%", height = "auto"))
                         
                         
                )
                
              
              
              
            )
    )
    ,
    tabItem(tabName = "ACA",
            fluidRow(
              br()
              # valueBoxOutput("ultimoMesGasto"),
              # valueBoxOutput("VariacionMensual"),
              # valueBoxOutput("VariacionAnual")
              
            ),
            
                         #h3("\n GASTOS MENSUALES"),
                         br(),
                         fluidRow(class="row-input",
                           column(4,
                                  selectInput(
                                    inputId = "IAnioDesdeACA",
                                    label = h5("Año inicio"),
                                    choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                                    selected = 2019
                                  )
                           ),
                           column(4,
                                  selectInput(
                                    inputId = "IAnioHastaACA",
                                    label = h5("Año fin"),
                                    choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                                    selected = 2020
                                  )
                           ),
                           column(
                             width = 4,
                             selectInput(
                               "sectorACA",
                               label = h5("Sector"),
                               choices = c(unique(rh_lic$SECTOR), "Todos"),
                               selected = "Todos"
                             )
                           )
                           # ,
                           # column(3,offset = 6,
                           #        downloadButton("descargaACA", h5("Descargar"))
                           # )
                           # column(3,
                           #        selectInput(
                           #          inputId = "tipoLicenciaACA",
                           #          label = "Tipo de licencia",
                           #          choices = unique(rh_lic$DESCRIPCIONAUSENCIA.1),
                           #          selected = "TODAS"
                           #        )
                           # )
                         ),
            br(),
                         
                        wellPanel(
                          div(class="titulo-grafico",
                              p("Ausentes con aviso", class ="tit_p")
                          ),
                          DT::dataTableOutput("tablaACA",width = "100%", height = "auto")
                        )
                         
                         
                         
              
    )
    ,
    tabItem(tabName = "Productividad",
            #h2("Widgets tab content"),
            fluidRow(class="row-kpi",
              br(),
              # valueBoxOutput("produ")
              # valueBoxOutput("produ2"),
              # valueBoxOutput("produ3")
              column(4,offset = 4,valueBoxOutput("produ"))
            ),
            fluidRow(clasS="row-input",
              column(3,
                     selectInput(
                       inputId = "IAnioDesdeProdu",
                       label = h5("Año inicio"),
                       choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                       selected = 2019
                     )
              ),
              column(3,
                     selectInput(
                       inputId = "IAnioHastaProdu",
                       label = h5("Año fin"),
                       choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                       selected = 2020
                     )
              ),
              column(
                width = 3,
                selectInput(
                  "typeProdu",
                  label = h5("Tipo de gráfico"),
                  choices = c("Linea", "Columna", "Barra", "Curva")
                )
              ),
              column(
                width = 3,
                selectInput(
                  "sectorProdu",
                  label = h5("Sector"),
                  choices = c(unique(rh_productividad$SECTOR), "Todos"),
                  selected = "SISTEMAS"
                )
              )
              ),
            br(),
            # fluidRow(
            #   
            #   column(3,offset = 6,
            #          downloadButton("descargaProdu", h5("Descargar"))
            #   )
            # ),
            wellPanel(
              div(class="titulo-grafico con-nav",
                  p("Productividad mensual", class ="tit_p")
              ),
              tabsetPanel(
                tabPanel("Gráfico",
                         #h3("\n GASTOS MENSUALES"),
                         # br(),
                         
                         
                           highchartOutput("graficoProdu", height = "500px")
                         
                         
                ),
                tabPanel("Tabla",
                         # br(),
                         DT::dataTableOutput("tablaProdu",width = "100%", height = "auto"),
                         h4("* El Porcentaje de cumplimiento esta expresado en %
                            "))
              )),
            br(),
            br(),
            
            fluidRow(class="row-input",
                     column(4,
                            selectInput(
                              inputId = "periodoProduExt",
                              label = h5("Periodo"),
                              choices = unique(rh_productividad$periodo),
                              selected = "2019-05"
                            )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "typeProduExt",
                         label = h5("Tipo de gráfico"),
                         choices =  c("Linea", "Columna", "Barra", "Curva"),
                         selected = "Barra"
                       )
                     )),
            br(),
            wellPanel(
              div(class="titulo-grafico con-nav",
                  p("Productividad por sector", class ="tit_p")
              ),
              tabsetPanel(
                tabPanel("Gráfico",
                         #h3("\n GASTOS MENSUALES"),
                         br(),
                         
                         
                         # fluidRow(
                         #   ,
                         #   # column(
                         #   #   width = 3,
                         #   #   selectInput(
                         #   #     "sectorProduExt",
                         #   #     label = "Sector",
                         #   #     choices = c(unique(rh_productividad$SECTOR), "Todos"),
                         #   #     selected = "SISTEMAS"
                         #   #   )
                         #   # ),
                         #   column(3,offset = 6,
                         #          downloadButton("descargaProduExt", h5("Descargar"))
                         #   )
                         # ),
                         
                           highchartOutput("graficoProduExt", height = "500px")
                         
                         
                ),
                tabPanel("Tabla",
                         DT::dataTableOutput("tablaProduExt",width = "100%", height = "auto"))
              )
              
            )
    )
    ,
    tabItem(tabName = "ComisionesActLaboral",
            #h2("Widgets tab content"),
            # fluidRow(class="row-kpi",
            #   br()
            #   #valueBoxOutput("produ")
            #   # valueBoxOutput("VariacionMensual"),
            #   # valueBoxOutput("VariacionAnual")
            #   
            # )
            # ,
            fluidRow(class="row-input",
                     column(4,
                            selectInput(
                              inputId = "periodoComision",
                              label = h5("Periodo   (Año-Mes)"),
                              choices = sort(unique(rh_com$periodo)),
                              selected = "2019-5"
                            )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "typeComision",
                         label = h5("Tipo de gráfico"),
                         choices = c("Linea", "Columna", "Barra", "Curva")
                       )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "sectorComision",
                         label = h5("Sector"),
                         choices = c(unique(rh_com$SECTOR), "Todos"),
                         selected = "Todos"
                       )
                     )
            ),
            br(),
            wellPanel(
              div(class="titulo-grafico con-nav",
                  p("Comisiónes de actividad laboral", class ="tit_p")
              ),
              tabsetPanel(
                tabPanel("Gráfico",
                         #h3("\n GASTOS MENSUALES"),
                         br(),
                         
                         
                         # fluidRow(
                         #   ,
                         #   column(3,offset = 6,
                         #          downloadButton("descargaComision", h5("Descargar"))
                         #   )
                         # ),
                         
                           
                           highchartOutput("graficoComision", height = "500px")
                         
                         
                ),
                tabPanel("Tabla",
                         DT::dataTableOutput("tablaActLaboral",width = "100%", height = "auto"))
              )
              
            )
    )
    ,
    tabItem(tabName = "Ausencias",
            #h2("Widgets tab content"),
            # fluidRow(class="row-kpi",
            #   br()
            #   #valueBoxOutput("produ")
            #   # valueBoxOutput("VariacionMensual"),
            #   # valueBoxOutput("VariacionAnual")
            #   
            # )
            # ,
            fluidRow(class="row-input",
                     column(4,
                            selectInput(
                              inputId = "periodoAusencia",
                              label = h5("Periodo   (Año-Mes)"),
                              choices = sort(unique(rh_ausencias$periodo)),
                              selected = "2019-05"
                            )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "typeAusencia",
                         label = h5("Tipo de gráfico"),
                         choices = c("Linea", "Columna", "Barra", "Curva"),
                         selected = "Columna"
                       )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "sectorAusencia",
                         label = h5("Sector"),
                         choices = c(unique(rh_ausencias$SECTOR), "Todos"),
                         selected = "Todos"
                       )
                     )
            ),
            br(),
            wellPanel(
              div(class="titulo-grafico con-nav",
                  p("Ausencias por sector", class ="tit_p")
              ),
              tabsetPanel(
                tabPanel("Gráfico",
                         #h3("\n GASTOS MENSUALES"),
                         # br(),
                         
                         
                         # fluidRow(
                         #   ,
                         #   column(3,offset = 6,
                         #          downloadButton("descargaAusencia", h5("Descargar"))
                         #   )
                         # ),
                         
                           highchartOutput("graficoAusencia", height = "500px")
                         
                         
                ),
                tabPanel("Tabla",
                         DT::dataTableOutput("tablaAusencia",width = "100%", height = "auto"))
              )
              
            )
    )
    ,
    ######## FINANZAS_BODY #####
    tabItem(tabName = "GastoMensual",
            fluidRow(class="row-kpi",
              br(),
              # valueBoxOutput("ultimoMesGasto"),
              # valueBoxOutput("VariacionMensual"),
              # valueBoxOutput("VariacionAnual")
              column(4,valueBoxOutput("ultimoMesGasto")),
              column(4,valueBoxOutput("VariacionMensual")),
              column(4,valueBoxOutput("VariacionAnual"))
              
            ),
            fluidRow(class="row-input",
                     column(4,
                            selectInput(
                              inputId = "IAnioDesdeGasto",
                              label = h5("Año inicio"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                              selected = 2019
                            )
                     ),
                     column(4,
                            selectInput(
                              inputId = "IAnioHastaGasto",
                              label = h5("Año fin"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                              selected = 2020
                            )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "typeGasto",
                         label = h5("Tipo de gráfico"),
                         choices = c("Linea", "Columna", "Barra", "Curva")
                       )
                     )),
            br(),
            wellPanel(
              div(class="titulo-grafico con-nav",
                  p("Gasto mensual", class ="tit_p")
              ),
              
              tabsetPanel(
                tabPanel("Gráfico",
                         #h3("\n GASTOS MENSUALES"),
                         br(),
                         
                         
                         # fluidRow(
                         #   ,
                         #   column(3,offset = 6,
                         #          downloadButton("descargaGasto", h5("Descargar"))
                         #   )
                         # ),
                         
                           highchartOutput("graficoGastoMensual", height = "500px")
                         
                         
                ),
                tabPanel("Tabla",
                         DT::dataTableOutput("tablaGastoMensual",width = "100%", height = "auto"))
              )
              
            )
    ),
    tabItem(tabName = "Ingresos",
            fluidRow(class="row-kpi",
              br(),
              # valueBoxOutput("ultimoMesIngreso"),
              # 
              # valueBoxOutput("VariacionMensualIngresos"),
              # valueBoxOutput("VariacionAnualIngresos")
              #infoBoxOutput("progreso"),
              #infoBoxOutput("progreso2")
              column(4,valueBoxOutput("ultimoMesIngreso")),
              column(4,valueBoxOutput("VariacionMensualIngresos")),
              column(4,valueBoxOutput("VariacionAnualIngresos"))
            ),
            fluidRow(class="row-input",
                     column(4,
                            selectInput(
                              inputId = "IAnioDesdeIngreso",
                              label = h5("Año inicio"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                              selected = 2019
                            )
                     ),
                     column(4,
                            selectInput(
                              inputId = "IAnioHastaIngreso",
                              label = h5("Año fin"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                              selected = 2020
                            )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "typeIngreso",
                         label = h5("Tipo de gráfico"),
                         choices = c("Linea", "Columna", "Barra", "Curva")
                       )
                     )
            ),
            br(),
            
            wellPanel(
              div(class="titulo-grafico con-nav",
                  p("Ingreso mensual", class ="tit_p")
              ),
              tabsetPanel(
                tabPanel("Gráfico",
                         #h3("\n INGRESOS MENSUALES"),
                         # br(),
                         
                         
                         # fluidRow(
                         #   
                         #   column(3,offset = 6,
                         #          downloadButton("descargaIngreso", h5("Descargar"))
                         #   )
                         # ),
                         
                           highchartOutput("graficoIngresoMensual", height = "500px")
                         
                         
                ),
                tabPanel("Tabla",
                         DT::dataTableOutput("tablaIngresoMensual",width = "100%", height = "auto"))
              )
              
            )
    ),
    
    tabItem(tabName = "nuevaLey",
            fluidRow(class="row-kpi",
                     br(),
                     # valueBoxOutput("ultimoMesIngreso"),
                     # 
                     # valueBoxOutput("VariacionMensualIngresos"),
                     # valueBoxOutput("VariacionAnualIngresos")
                     
                     
            ),
            fluidRow(class="row-input",
                     column(4,
                            selectInput(
                              inputId = "IAnioDesdeNuevaLey",
                              label = h5("Año inicio"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                              selected = 2019
                            )
                     ),
                     column(4,
                            selectInput(
                              inputId = "IAnioHastaNuevaLey",
                              label = h5("Año fin"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                              selected = 2020
                            )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "typeNuevaLey",
                         label = h5("Tipo de gráfico"),
                         choices = c("Linea", "Columna", "Barra", "Curva")
                       )
                     )
            ),
            
            br(),
            
            wellPanel(
              div(class="titulo-grafico con-nav",
                  p("Ahorro nueva ley", class ="tit_p")
                  # downloadButton("descargaNuevaLey",label="", class = "boton-descargar")
              ),
              tabsetPanel(
                tabPanel("Gráfico",
                         #h3("\n INGRESOS MENSUALES"),
                         br(),
                         
                         
                         # fluidRow(
                         #   
                         #   column(3,offset = 6,
                         #          downloadButton("descargaIngreso", h5("Descargar"))
                         #   )
                         # ),
                         
                         highchartOutput("graficoNuevaLey", height = "500px")
                         
                         
                ),
                tabPanel("Tabla",
                         DT::dataTableOutput("tablaNuevaLey",width = "100%", height = "auto"))
              )
              
            )
    ),
    ### LEGALES_BODY ####
    tabItem(tabName = "Resueltos",
            br(),
            fluidRow(class="row-kpi",
                     # valueBoxOutput("totalFavorables"),
                     # 
                     # valueBoxOutput("totalDesfavorables")
                     column(4,offset = 2,valueBoxOutput("totalFavorables")),
                     column(4,offset = 0,valueBoxOutput("totalDesfavorables"))
            ),
            fluidRow(class="row-input",
                     column(4,
                            selectInput(
                              inputId = "IAnioDesdeResueltos",
                              label = h5("Año inicio"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                              selected = 2019
                            )
                     ),
                     column(4,
                            selectInput(
                              inputId = "IAnioHastaResueltos",
                              label = h5("Año fin"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021,2022),
                              selected = 2020
                            )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "typeResueltos",
                         label = h5("Tipo de gráfico"),
                         choices = c("Linea", "Columna", "Barra", "Curva")
                       )
                     )
            ),
            br(),
            
            wellPanel(
              div(class="titulo-grafico",
                  p("Juicios resueltos", class ="tit_p")
              ),
              
                         
                         
                         # fluidRow(
                         #   
                         #   column(3,offset = 6,
                         #          downloadButton("descargaIngreso", h5("Descargar"))
                         #   )
                         # ),
                         
                           highchartOutput("graficoResueltos", height = "500px")
                         
                         
                
              
              
            )
    ),
    tabItem(tabName = "Causas",
            br(),
            fluidRow(class="row-kpi con-dos"
                     # valueBoxOutput("totalFavorables"),
                     # 
                     # valueBoxOutput("totalDesfavorables")
                     
            ),
            fluidRow(class="row-input",
                     column(4,
                            selectInput(
                              inputId = "IAnioDesdeCausas",
                              label = h5("Año inicio"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021),
                              selected = 2019
                            )
                     ),
                     column(4,
                            selectInput(
                              inputId = "IAnioHastaCausas",
                              label = h5("Año fin"),
                              choices = c(2016, 2017, 2018, 2019, 2020,2021),
                              selected = 2020
                            )
                     ),
                     column(
                       width = 4,
                       selectInput(
                         "typeCausas",
                         label = h5("Tipo de gráfico"),
                         choices = c("Linea", "Columna", "Barra", "Curva")
                       )
                     )
            ),
            br(),
            
            wellPanel(
              div(class="titulo-grafico",
                  p("Estado de causas", class ="tit_p")
              ),
              
              
              
              # fluidRow(
              #   
              #   column(3,offset = 6,
              #          downloadButton("descargaIngreso", h5("Descargar"))
              #   )
              # ),
              
              highchartOutput("graficoCausas", height = "500px")
              
              
              
              
              
            )
    ),
    ### LIQUIDACIONES_BODY  ####
     tabItem(tabName = "ControlMutu",
             br(),
             br(),
             tabsetPanel(
               tabPanel("Código de Mutuales",
             wellPanel(
               div(class="titulo-grafico",
                   p("Código de Mutuales", class ="tit_p")
                   # downloadButton("descargaCodigoMutuales", label="",class="boton-descargar")
               ),
               DT::dataTableOutput("tablaMutuales",width = "100%", height = "auto")
             )
             
             ),
             tabPanel("Asociación a Mutuales",
                      wellPanel(
                        div(class="titulo-grafico",
                            p("Asociaciones", class ="tit_p")
                            # downloadButton("descargaAsociacionMutuales", label="",class="boton-descargar")
                        ),
                        DT::dataTableOutput("tablaMutualesAsociacion",width = "100%", height = "auto")
                      )
                      ),
             tabPanel("Cobros de Mutuales",
                      wellPanel(
                        div(class="titulo-grafico",
                            p("Cobros", class ="tit_p")
                            # downloadButton("descargaCobroMutuales", label="",class="boton-descargar")
                            
                        ),
                        DT::dataTableOutput("tablaMutualesCobro",width = "100%", height = "auto")
                      )
                      )
             )),
             
        tabItem(tabName = "ControlBene",
                br(),
                br(),
                     tabsetPanel(
                       tabPanel("Jubilaciones",
                                wellPanel(
                                  div(class="titulo-grafico",
                                      p("Altas de Jubilaciones", class ="tit_p")
                                      # downloadButton("descargaAltasJub", label="",class="boton-descargar")
                                      
                                  ),
                                  DT::dataTableOutput("tablaAltasJub",width = "100%", height = "auto")
                                )
                       ),
                       tabPanel("Pensiones",
                                wellPanel(
                                  div(class="titulo-grafico",
                                      p("Altas de Pensiones", class ="tit_p")
                                      # downloadButton("descargaAltasPen", label="",class="boton-descargar")
                                      
                                  ),
                                  DT::dataTableOutput("tablaAltasPen",width = "100%", height = "auto")
                                )
                       ),
                       tabPanel("Invalideces",
                                wellPanel(
                                  div(class="titulo-grafico",
                                      p("Altas de Invalideces", class ="tit_p")
                                      # downloadButton("descargaAltasInv", label="",class="boton-descargar")
                                      
                                  ),
                                  DT::dataTableOutput("tablaAltasInv",width = "100%", height = "auto")
                                )
                       )
                       )),
    tabItem(tabName = "ControlInva",
            fluidRow(class="row-input",
                     column(4,
                            dateRangeInput("rangoValidacion2", label = h5("Seleccione fecha de Cambio"), start = (Sys.Date() - 28),end = Sys.Date(), width = '400px',language = "es",separator = "hasta")
                     ),
                     column(4,
                            selectInput(
                              "usuarioInv",
                              label = h5("Usuario"),
                              choices = sort(unique(InvalidecesModificacion$Usuario)
                            )
                     ))
                     ),
            br(),
            wellPanel(
              div(class="titulo-grafico",
                  p("Fecha de vigencia Modificada", class ="tit_p")
                  # downloadButton("descargaInvModif", label="",class="boton-descargar")
                  
              ),
              br(),
              DT::dataTableOutput("tablaInvalidecesModif",width = "100%", height = "auto")
              
            )
            
    ),
    tabItem(tabName = "ControlMovi",
            br(),
            
            br(),
            fluidRow(class="row-input",
                     br(),
                     wellPanel(
                       div(class="titulo-grafico",
                           p("Informe Movilidad", class ="tit_p")
                           # downloadButton("descargaMovilidad", label="",class="boton-descargar")
                           
                       ),
                       br(),
                       DT::dataTableOutput("tablaMovilidad",width = "100%", height = "auto")
                       
                     )
                     
            )),
    
    ### CALIDAD_BODY  ####
    tabItem(tabName = "Calidad1",
            br(),
            wellPanel(
              div(class="titulo-grafico con-nav",
                  p("Consultas web", class ="tit_p")
              ),
              tabsetPanel(
                tabPanel("Tópico 1",
                         highchartOutput("graficoCalidad1", height = "400px")
                         ),
                tabPanel("Tópico 2",
                         highchartOutput("grafico_cal2", height = "400px")
                         ),
                tabPanel("Tópico 3",
                         highchartOutput("grafico3_cal", height = "400px")
                )
              ),
              
            )
    ),
    ### PROYECCIONES ####
    tabItem(tabName = "baseImp",
            fluidRow(class = "row-input",
                     column(4,
                            selectInput(
                              inputId = "Sector",
                              label = h5("Sector"),
                              choices = c("Municipalidad", "Bancarios","EPEC"),
                              selected = "Municipalidad"
                            )
                     ),
                     column(4,
                            numericInput(
                              inputId = "Porcentaje",
                              label = h5("Porcentaje base Imp"),
                              value = 70
                            )
                     )
            ),
            br(),
            wellPanel(
              div(class="titulo-grafico",
                  p("Base imponible", class ="tit_p")
              ),
              highchartOutput("baseImp", height = "500px"))),
    tabItem(tabName = "altas",
            
            fluidRow(class="row-kpi",
                     br(),
                     # valueBoxOutput("KPI_Retro"),
                     # valueBoxOutput("KPI_Retro2"),
                     # #tags$hr()
                     # valueBoxOutput("KPI_Retro3")
                     column(4,valueBoxOutput("ProyeccionAltas"))
                     # column(4,valueBoxOutput("KPI_Retro2")),
                     # column(4,valueBoxOutput("KPI_Retro3")),
            ),
            # br(),
            
            # fluidRow(class = "row-input",
            #          column(4,
            #                 dateInput(format = "dd-mm-yyyy",
            #                           inputId = "Fecha_retro",
            #                           label = h5("Ingrese fecha de alta")
            #                 )
            #          ),
            #          column(4,
            #                 selectInput(
            #                   inputId = "Sector_retro",
            #                   label = h5("Sector"),
            #                   width = '100%',
            #                   choices = c("Todos",Sectores$SECTNOMBRE),
            #                   selected = "Todos"
            #                 ))
            # ),
            br(),
            wellPanel(
              div(class="titulo-grafico",
                  p("Futuras altas", class ="tit_p")
              ),
              # br(),
              DT::dataTableOutput("tablaProyeccionAltas",width = "100%", height = "auto")
            )
    ),
    tabItem(tabName = "basico",
            fluidRow(class = "row-input",
                     column(4,
                            selectInput(
                              inputId = "Sector_basico",
                              label = h5("Sector"),
                              width = '100%',
                              choices = Sectores$SECTNOMBRE
                            )
                     ),
                     column(4,
                            numericInput(
                              inputId = "Porcentaje_sector",
                              label = h5("Porcentaje aumento"),
                              value = 10
                            )
                     )
            ),
            br(),
            wellPanel(
              div(class="titulo-grafico",
                  p("Proyeccion de básico", class ="tit_p")
              ),
              highchartOutput("grafico_basico", height = "500px"))),
    
    ### ADMIN_BODY  ####
    tabItem(tabName = "Admin",
            
            # fluidRow(
            #   br(),
            #   valueBoxOutput("contNuevosBenef"),
            #   valueBoxOutput("contNuevosBenef2"),
            #   valueBoxOutput("contNuevosBenef3")
            # ),
            tabsetPanel(
              tabPanel("Consultar Usuarios",
                       DT::dataTableOutput("tablaUsuarios")
                       
                       
                       # fluidRow(,
                       # column(3,offset = 6,0
                       #        downloadButton("descarga3", h5("Descargar"))
                       # )),
                       #plotOutput("nuevosBenef")
              ),
              tabPanel("Crear Usuario",
                       fluidRow(class="row-input",
                       column(4,textInput("NombreId", label = h5("Nombre"))),
                       column(4,textInput("ApellidoId", label = h5("Apellido"))),
                       
                       column(4,numericInput("DniID", label = h5("Dni"), value = 0))),
                       br(),
                       br(),
                       fluidRow(class="row-input",
                       column(4,textInput("user", label = h5("Usuario"))),
                       column(4,passwordInput("password", label = h5("Contraseña"))),
                       column(4,passwordInput("password2", label = h5("Valide su contraseña")))),
                       verbatimTextOutput("errtext"),
                       
                       br(),
                       br(),
                       br(),
                       br(),
                       br(),
                       column(10, actionButton("btnCreateUser", "Crear Usuario", class = "btn btn-success"))
              ),
              tabPanel("Modificar Usuario",
                       fluidRow(class="row-input",
                       column(4,numericInput("DniModif", label = h5("Dni"),value = 0)),
                       column(4,passwordInput("passwordModif", label = h5("Contraseña"))),
                       column(4,passwordInput("passwordModif2", label = h5("Valide su contraseña")))),
                       verbatimTextOutput("errtext2"),
                       
                       br(),
                       br(),
                       column(10, actionButton("btnAlterUser", "Modificar Usuario", class = "btn btn-warning"))
              ),
              tabPanel("Eliminar Usuario",
                       column(4,textInput("DniDelete", label = h5("Dni"))),
                       verbatimTextOutput("errtext3"),
                       
                       br(),
                       br(),
                       br(),
                       br(),
                       br(),
                       column(10, actionButton("btnDeleteUser", "Eliminar Usuario", class = "btn btn-danger")))
              
            )
    ),
    tabItem(tabName = "Informacion",
            
            # fluidRow(
            #   br(),
            #   valueBoxOutput("contNuevosBenef"),
            #   valueBoxOutput("contNuevosBenef2"),
            #   valueBoxOutput("contNuevosBenef3")
            # ),
            tabsetPanel(
              tabPanel("Consultar Informacion",
                       DT::dataTableOutput("tablaUsuarioPropio")
                       
                       
                       # fluidRow(,
                       # column(3,offset = 6,0
                       #        downloadButton("descarga3", h5("Descargar"))
                       # )),
                       #plotOutput("nuevosBenef")
              ),
              tabPanel("Modificar Contraseña",
                       fluidRow(class="row-input",
                                column(4,passwordInput("passwordAnterior", label = h5("Contraseña Anterior"),value = 0)),
                                column(4,passwordInput("passwordModifUsu", label = h5("Contraseña Nueva"))),
                                column(4,passwordInput("passwordModif2Usu", label = h5("Valide su contraseña")))),
                       br(),
                       br(),
                       column(10, actionButton("btnAlterUserUsu", "Modificar Usuario", class = "btn btn-warning"))
              )
              
            )
    )
  )
)

####################################d
set_labels(language = "en",
           "Please authenticate" = "",
           "Username:" = "Usuario:",
           "Password:" = "Contraseña:",
           "Username or password are incorrect" = "El usuario o la contraseña son incorrectos.")
ui <- dashboardPage(skin = "black",header, sidebar, body)
ui <- secure_app(ui, tags_top = tagList(
  tags$img(src = "Jubidash-01.png"
, width = '60%'),
tags$link(rel = "stylesheet", type = "text/css", href = "login.css")
))


server <- function(input, output, session) {
  # stockdata <- getSymbols(input$accion, src="google", from = input$fechadesde,
  #                         to = input$fechahasta, auto.assign = FALSE)
  
  # check_credentials returns a function to authenticate users
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )
  # Create reactive values including all credentials
  creds_reactive <- reactive({
    reactiveValuesToList(res_auth)
  })
  
  # Hide extraOutput only when condition is TRUE
  observe({
    if (!is.null(creds_reactive()$level) && creds_reactive()$level > 0) shinyjs::hide(selector = 'a[data-value = "GastoMensual"')
  })
  
  output$auth_output <- renderPrint({
    reactiveValuesToList(res_auth)
  })
  
  
  
  ####### DESCARGAS ######
  output$descarga<- downloadHandler(
    filename = function() { paste("NuevosBeneficios_",Sys.Date(),".xlsx", sep = "")},
    content = function(file) {write_xlsx(Altas, path = file)}
   )
    
  output$descarga2<- downloadHandler(
    filename = function() { paste('DemoraJO_', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(DemoraJO, path = file)}
  )
  
  output$descarga3<- downloadHandler(
    filename = function() {paste('DemoraJI_', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(DemoraJI, path = file)}
  )
  
  output$descargaNuevaLey <- downloadHandler(
    filename = function() {paste('AhorroNuevaley_', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(nuevaLey, path = file)}
  )
  output$descargaCodigoMutuales <- downloadHandler(
    filename = function() {paste('CodigosMutuales', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(codigoMutuales, path = file)}
  )
  output$descargaAsociacionMutuales <- downloadHandler(
    filename = function() {paste('AsociacionesMutuales', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(comparacionAsociacion, path = file)}
  )
  output$descargaCobroMutuales <- downloadHandler(
    filename = function() {paste('CobrosMutuales', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(comparacionCobros, path = file)}
  )
  
  output$descargaAltasJub <- downloadHandler(
    filename = function() {paste('AltasJub', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(AltasJub, path = file)}
  )
  output$descargaAltasPen <- downloadHandler(
    filename = function() {paste('AltasPen', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(AltasPen, path = file)}
  )
  output$descargaAltasInv <- downloadHandler(
    filename = function() {paste('AltasInv', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(AltasInv, path = file)}
  )
  output$descargaInvModif <- downloadHandler(
    filename = function() {paste('InvalidecesModificacion', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(InvalidecesModificacion, path = file)}
  )
  output$descargaMovilidad <- downloadHandler(
    filename = function() {paste('Movilidad', Sys.Date(), '.xlsx', sep='')},
    content = function(file) {write_xlsx(Movilidad, path = file)}
  )
  
  output$descarga4<- downloadHandler(
    filename = function() {
      paste('ProyeccionAltas_', Sys.Date(), '.xlsx', sep='')
    },
    content = function(file) {
      write.xlsx(Proyeccion, file, row.names = TRUE)
    }
  )
  
  output$descargaIngreso<- downloadHandler(
    filename = function() {
      paste('Ingresos_', Sys.Date(), '.xlsx', sep='')
    },
    content = function(file) {
      write.xlsx(x = ingresoMensual, file, row.names = TRUE)
    },
    contentType = "text/csv")
  
  output$descargaGasto<- downloadHandler(
    filename = function() {
      paste('Gasto_', Sys.Date(), '.xlsx', sep='')
    },
    content = function(file) {
      write.xlsx(x = gastoMensual, file, row.names = TRUE)
    },
    contentType = "text/csv")
  
  ########################################A
  
  gen_plot <- function(){
    Altas$TPINDID <- as.numeric(Altas$TPINDID)
    Dato <- Altas %>%
      filter(year(Altas$Periodo) >= input$IAnioDesde,
             year(Altas$Periodo) <= input$IAnioHasta)
    Dato <- Dato %>% group_by(anio) %>% mutate(Prom = mean(TPINDDVAL))
    
   tipo <- switch(input$type, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
   hc  <- highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato, name = "Cant", type = tipo, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#84C77E") ) %>%
      hc_add_series(data = Dato, name = "Promedio", type = tipo, hcaes(x = mesAnio, y = Prom), color = c("red") ) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Cantidad"))
    
    return(hc)
  }
  
  # output$descarga <- downloadHandler(filename ="1.png",
  #                                         content = function(file) {
  #                                           png(file, width=800, height=800)
  #                                           gen_plot()
  #                                           dev.off()
  #                                         },
  #                                         contentType = "image/png")
  
  
  ######## BENEF_SV #######
  
  output$hcontainer <- renderHighchart({
    
    validate(
      need(input$IAnioDesde <= input$IAnioHasta & input$IAnioDesde <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    #Altas$TPINDID <- as.numeric(Altas$TPINDID)
    
    Dato <- Altas_modif %>%
      filter(Altas_modif$Anio >= input$IAnioDesde,
             Altas_modif$Anio <= input$IAnioHasta)
    Dato <- Dato %>% group_by(Anio) %>% mutate(Prom = mean(cont))
    Dato$Prom <- round(Dato$Prom, 0)
    #
    # hchart(input$type, hcaes(x = mesAnio, y = TPINDDVAL),   color = c("#84C77E")) %>%
    # hc_title(text = "<span style=\"color:#68AD62\"> NUEVOS BENEFICIOS </span> ", useHTML = TRUE) %>%
    # hc_tooltip(pointFormat = paste('Cantidad: {point.y} <br/>')) %>%
    #
    # hc_xAxis(title = list(text = "Periodo")) %>%
    # hc_yAxis(title = list(text = "Cantidad"))#EEA13F
    tipo <- switch(input$type, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato, name = "Total", type = tipo, hcaes(x = mesAnio, y = cont), color = c("#68BAF3") ) %>%
      hc_add_series(data = Dato, name = "Promedio", type = tipo, hcaes(x = mesAnio, y = Prom), color = c("#84C77E") ) %>%
      hc_add_series(data = Dato, name = "Jubilación", type = tipo, hcaes(x = mesAnio, y = J), color = c("#DFCA63") ) %>%
      hc_add_series(data = Dato, name = "Pensión", type = tipo, hcaes(x = mesAnio, y = P), color = c("#EEA13F") ) %>%
      # hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\">  </span> ", useHTML = TRUE) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Cantidad"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
    
  })
  
  output$VenciKPI <- renderValueBox({
    DF  <- Vencidos %>%
      filter(Vencidos$JBSOLFECVI >= input$rangoValidacion[1],
             Vencidos$JBSOLFECVI <= input$rangoValidacion[2]) 
    
    n <- DF[DF$PRESTDSC == input$tipoPrestacion, ]
    cant <- as.numeric(nrow(n))
    valueBox(
      value =  cant,
      subtitle = paste("Cantidad a vencer", sep = ""),
      icon = icon("address-book"),
      color = "olive"
    )
  })
  output$VenciKPI2 <- renderValueBox({
    
    n <- last(DemoraJI)
    
    valueBox(
      value =  n$DIAS,
      subtitle = paste("Días en ", n$mesAnio, sep = ""),
      icon = icon("address-book"),
      color = "teal"
    )
  })
  output$VenciKPI3 <- renderValueBox({
    
    n <- last(DemoraJI)
    
    valueBox(
      value =  n$DIAS,
      subtitle = paste("Días en ", n$mesAnio, sep = ""),
      icon = icon("address-book"),
      color = "blue"
    )
  })
  
  
  
  
  output$torta <- renderHighchart({
    validate(
      need(input$IAnioDesde <= input$IAnioHasta & input$IAnioDesde <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    Altas %>%
      hchart("pie", hcaes(x = anio, y = TPINDDVAL))
  })
  
  ######################f
  output$graficoDemoraJO <- renderHighchart({
    validate(
      need(input$IAnioDesdeDemora <= input$IAnioHastaDemora & input$IAnioDesdeDemora <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    Dato <- DemoraJO %>%
      filter(year(DemoraJO$fecha_fin) >= input$IAnioDesdeDemora,
             year(DemoraJO$fecha_fin) <= input$IAnioHastaDemora)
    tipo <- switch(input$type2, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    Dato$Prom <- round(Dato$Prom, 0)
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato, name = "Días", type = tipo, hcaes(x = mesAnio, y = DIAS), color = c("#68BAF3") ) %>%
      hc_add_series(data = Dato, name = "Promedio", type = tipo, hcaes(x = mesAnio, y = Prom), color = c("#84C77E") ) %>%
      
      
      # hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Tiempo JubilaciÃ³n Ordinaria </span> ", useHTML = TRUE) %>%
      #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Días"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  ######################f
  output$graficoDemoraJI <- renderHighchart({
    validate(
      need(input$IAnioDesdeDemoraJI <= input$IAnioHastaDemoraJI & input$IAnioDesdeDemoraJI <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    Dato <- DemoraJI %>%
      filter(year(DemoraJI$fecha_fin) >= input$IAnioDesdeDemoraJI,
             year(DemoraJI$fecha_fin) <= input$IAnioHastaDemoraJI)
    Dato$Prom <- round(Dato$Prom, 0)
    tipo <- switch(input$type3, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato, name = "Días", type = tipo, hcaes(x = mesAnio, y = DIAS), color = c("#68BAF3") ) %>%
      hc_add_series(data = Dato, name = "Promedio", type = tipo, hcaes(x = mesAnio, y = Prom), color = c("#84C77E") ) %>%
      
      
      # hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Tiempo JubilaciÃ³n Invalidez </span> ", useHTML = TRUE) %>%
      #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Días"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  ############## RRHH_SV #####
  output$graficoProdu <- renderHighchart({
    validate(
      need(input$IAnioDesdeProdu <= input$IAnioHastaProdu & input$IAnioDesdeProdu <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    
    #rh_productividad <- rh_productividad[rh_productividad$DESCRIPCIONAUSENCIA.1 == input$tipoProdu , ]
    
    
    rh_productividad <- rh_productividad[rh_productividad$SECTOR == input$sectorProdu , ]
    
    
    rh_productividad$Anio <- as.numeric(rh_productividad$Anio)
    
    rh_productividad <- rh_productividad[rh_productividad$Anio >=input$IAnioDesdeProdu & rh_productividad$Anio <=input$IAnioHastaProdu, ]
    
    #   filter(rh_productividad$Anio  >= 2018)]
    #
    
    data <- rh_productividad %>%
      group_by(MES, Anio, mesAnio,periodo) %>%
      summarise(Prom = mean(PorcentajeCumpl))
    
    data <- data %>% arrange(periodo)
    tipo <- switch(input$typeProdu, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    data$Prom <- round(data$Prom, 2)
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = data, name = "Productividad(%)", type = tipo, hcaes(x = mesAnio , y = Prom), color = c("#68BAF3") ) %>%
      # hc_add_series(data = , name = "Gasto Contable", type = input$typeGasto, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#84C77E") ) %>%
      
      
      #hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\">Productividad Por Mes</span> ", useHTML = TRUE) %>%
      # # #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Cumplimiento"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  output$graficoProduExt <- renderHighchart({
    validate(
      need(input$IAnioDesdeProdu <= input$IAnioHastaProdu & input$IAnioDesdeProdu <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    
    
    
    rh_productividad <- rh_productividad[rh_productividad$periodo == input$periodoProduExt , ]
    
    
    
    
    #   filter(rh_productividad$Anio  >= 2018)]
    #
    rh_productividad <- rh_productividad %>%
      group_by(SECTOR) %>%
      summarise(Prom = round(mean(PorcentajeCumpl),2))
   
     tipo <- switch(input$typeProduExt, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = rh_productividad, name = "Productividad", type = tipo, hcaes(x = SECTOR , y = Prom), color = c("#68BAF3") ) %>%
      # hc_add_series(data = , name = "Gasto Contable", type = input$typeGasto, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#84C77E") ) %>%
      
      
      #hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Productividad Por Sector </span> ", useHTML = TRUE) %>%
      # # #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Cumplimiento"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  
  output$tablaLicencia <- DT::renderDataTable({
    rh_lic  <- rh_lic[!(rh_lic$Cuil2 == " "), ]
    validate(
      need(input$IAnioDesdeLicencia <= input$IAnioHastaLicencia & input$IAnioDesdeLicencia <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    
    rh_lic <- rh_lic[rh_lic$DESCRIPCIONAUSENCIA.1 == input$tipoLicencia , ]
    
    if( input$sectorLicencia != "Todos"){
      rh_lic <- rh_lic[rh_lic$SECTOR == input$sectorLicencia , ]
    }
    
    rh_lic$Anio <- as.numeric(rh_lic$Anio)
    
    rh_lic <- rh_lic %>%
      filter(rh_lic$Anio  >= input$IAnioDesdeLicencia,
             rh_lic$Anio <= input$IAnioHastaLicencia)
    
    
    data <- rh_lic %>%
      group_by(DESCRIPCIONAUSENCIA.1,mesAnio) %>%
      summarise(total = sum(cant))
    # DT::datatable(rh_lic,extensions = "Responsive")
    DT::datatable(rh_lic, extensions = c('Buttons',"Responsive"),
                  options = list(dom = 'Bfrtip',
                                 buttons = 
                                   list(
                                     list(extend = 'colvis', text='Columnas'), 
                                     list(
                                       extend = 'collection',
                                       buttons = list(list(extend='csv',
                                                           filename = "csv_asd"),
                                                      list(extend='excel',
                                                           filename = "xls_asd"),
                                                      list(extend='pdf',
                                                           filename= "pdf_asd")),
                                       text = 'Descargar'
                                     )
                                   ),
                                 scrollX = TRUE
                  ))
    })
  #
  output$tablaProdu <- DT::renderDataTable({
    
    colnames(rh_productividad)[10] <- "PorcentajeCUmpl(%)"
    
    # DT::datatable(rh_productividad,extensions = "Responsive")
    DT::datatable(rh_productividad, extensions = c('Buttons',"Responsive"),
                  options = list(dom = 'Bfrtip',
                                 buttons = 
                                   list(
                                     list(extend = 'colvis', text='Columnas'), 
                                     list(
                                       extend = 'collection',
                                       buttons = list(list(extend='csv',
                                                           filename = "csv_asd"),
                                                      list(extend='excel',
                                                           filename = "xls_asd"),
                                                      list(extend='pdf',
                                                           filename= "pdf_asd")),
                                       text = 'Descargar'
                                     )
                                   ),
                                 scrollX = TRUE
                  ))
    })
  #
  output$tablaProduExt <- DT::renderDataTable({
    
    colnames(rh_productividad)[10] <- "PorcentajeCUmpl(%)"
    
    DT::datatable(rh_productividad,extensions = "Responsive")
    DT::datatable(rh_productividad, extensions = c('Buttons',"Responsive"),
                  options = list(dom = 'Bfrtip',
                                 buttons = 
                                   list(
                                     list(extend = 'colvis', text='Columnas'), 
                                     list(
                                       extend = 'collection',
                                       buttons = list(list(extend='csv',
                                                           filename = "csv_asd"),
                                                      list(extend='excel',
                                                           filename = "xls_asd"),
                                                      list(extend='pdf',
                                                           filename= "pdf_asd")),
                                       text = 'Descargar'
                                     )
                                   ),
                                 scrollX = TRUE
                  ))
    })
  #
  output$tablaACA <- DT::renderDataTable({
    validate(
      need(input$IAnioDesdeACA <= input$IAnioHastaACA & input$IAnioDesdeACA <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    if(input$sectorACA != "Todos"){
      rh_ACA <- rh_ACA[rh_ACA$SECTOR == input$sectorACA, ]
    }
    tabla <- rh_ACA[year(rh_ACA$FECHA) >= input$IAnioDesdeACA & year(rh_ACA$FECHA) <= input$IAnioHastaACA, c(1:3,5:8)]
    # DT::datatable(tabla,extensions = "Responsive")
    DT::datatable(tabla, extensions = c('Buttons',"Responsive"),
                  options = list(dom = 'Bfrtip',
                                 buttons = 
                                   list(
                                     list(extend = 'colvis', text='Columnas'), 
                                     list(
                                       extend = 'collection',
                                       buttons = list(list(extend='csv',
                                                           filename = "csv_asd"),
                                                      list(extend='excel',
                                                           filename = "xls_asd"),
                                                      list(extend='pdf',
                                                           filename= "pdf_asd")),
                                       text = 'Descargar'
                                     )
                                   ),
                                 scrollX = TRUE
                  ))
    })
  #
  output$tablaActLaboral <- DT::renderDataTable({
    if( input$sectorComision != "Todos"){
      rh_com <- rh_com[rh_com$SECTOR == input$sectorComision , ]
    }
    rh_com <- rh_com[rh_com$periodo == input$periodoComision, ]
    validate(
      need(nrow(rh_com) != 0, ("No se encontraron comisiones de act laboral."))
    )
    dato <- rh_com %>%
      group_by(SECTOR) %>%
      summarise(Total = sum(cant))
    
    
    # DT::datatable(dato,extensions = "Responsive")
    DT::datatable(dato, extensions = c('Buttons',"Responsive"),
                  options = list(dom = 'Bfrtip',
                                 buttons = 
                                   list(
                                     list(extend = 'colvis', text='Columnas'), 
                                     list(
                                       extend = 'collection',
                                       buttons = list(list(extend='csv',
                                                           filename = "csv_asd"),
                                                      list(extend='excel',
                                                           filename = "xls_asd"),
                                                      list(extend='pdf',
                                                           filename= "pdf_asd")),
                                       text = 'Descargar'
                                     )
                                   ),
                                 scrollX = TRUE
                  ))
    })
  #
  output$tablaAusencia <- DT::renderDataTable({
    if(input$sectorAusencia != "Todos"){
      rh_ausencias <- rh_ausencias[rh_ausencias$SECTOR == input$sectorACA, ]
    }
    
    # DT::datatable(rh_ausencias,extensions = "Responsive")
    DT::datatable(rh_ausencias, extensions = c('Buttons',"Responsive"),
                  options = list(dom = 'Bfrtip',
                                 buttons = 
                                   list(
                                     list(extend = 'colvis', text='Columnas'), 
                                     list(
                                       extend = 'collection',
                                       buttons = list(list(extend='csv',
                                                           filename = "csv_asd"),
                                                      list(extend='excel',
                                                           filename = "xls_asd"),
                                                      list(extend='pdf',
                                                           filename= "pdf_asd")),
                                       text = 'Descargar'
                                     )
                                   ),
                                 scrollX = TRUE
                  ))
    })
  
  ##tablaProdu
  
  # output$tablaACA <- DT::renderDataTable({
  #   
  #   
  #   DT::datatable(rh_ACA)})
  ##
  output$tablaProdu <- DT::renderDataTable({
    rh_productividad <- rh_productividad[rh_productividad$SECTOR == input$sectorProdu , ]
    # DT::datatable(rh_productividad,extensions = "Responsive")
    DT::datatable(rh_productividad, extensions = c('Buttons',"Responsive"),
                  options = list(dom = 'Bfrtip',
                                 buttons = 
                                   list(
                                     list(extend = 'colvis', text='Columnas'), 
                                     list(
                                       extend = 'collection',
                                       buttons = list(list(extend='csv',
                                                           filename = "csv_asd"),
                                                      list(extend='excel',
                                                           filename = "xls_asd"),
                                                      list(extend='pdf',
                                                           filename= "pdf_asd")),
                                       text = 'Descargar'
                                     )
                                   ),
                                 scrollX = TRUE
                  ))
  })
  output$tablaProduExt <- DT::renderDataTable({
    rh_productividad <- rh_productividad[rh_productividad$SECTOR == input$sectorProdu , ]
    # DT::datatable(rh_productividad,extensions = "Responsive")
    DT::datatable(rh_productividad, extensions = c('Buttons',"Responsive"),
                  options = list(dom = 'Bfrtip',
                                 buttons = 
                                   list(
                                     list(extend = 'colvis', text='Columnas'), 
                                     list(
                                       extend = 'collection',
                                       buttons = list(list(extend='csv',
                                                           filename = "csv_asd"),
                                                      list(extend='excel',
                                                           filename = "xls_asd"),
                                                      list(extend='pdf',
                                                           filename= "pdf_asd")),
                                       text = 'Descargar'
                                     )
                                   ),
                                 scrollX = TRUE
                  ))
    
  })
  
  output$graficoLicencia <- renderHighchart({
    validate(
      need(input$IAnioDesdeLicencia <= input$IAnioHastaLicencia & input$IAnioDesdeLicencia <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    
    rh_lic <- rh_lic[rh_lic$DESCRIPCIONAUSENCIA.1 == input$tipoLicencia , ]
    
    if( input$sectorLicencia != "Todos"){
      rh_lic <- rh_lic[rh_lic$SECTOR == input$sectorLicencia , ]
    }
    
    rh_lic$Anio <- as.numeric(rh_lic$Anio)
    
    rh_lic <- rh_lic %>%
      filter(rh_lic$Anio  >= input$IAnioDesdeLicencia,
             rh_lic$Anio <= input$IAnioHastaLicencia)
    
    
    data <- rh_lic %>%
      group_by(DESCRIPCIONAUSENCIA.1,mesAnio) %>%
      summarise(total = sum(cant))
    tipo <- switch(input$typeLicencia, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = data, name = "Licencias", type = tipo, hcaes(x = mesAnio, y = total), color = c("#68BAF3") )  %>%
      # hc_add_series(data = , name = "Gasto Contable", type = input$typeGasto, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#84C77E") ) %>%
      
      
      # hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Licencias Mensuales </span> ", useHTML = TRUE) %>%
      # #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Cantidad"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  
  output$graficoAusencia <- renderHighchart({
    # validate(
    #   need(input$IAnioDesdeLicencia <= input$IAnioHastaLicencia & input$IAnioDesdeLicencia <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    # )
    
    if( input$sectorAusencia != "Todos"){
      rh_ausencias <- rh_ausencias[rh_ausencias$SECTOR == input$sectorAusencia , ]
    }
    
    rh_ausencias <- rh_ausencias[rh_ausencias$periodo == input$periodoAusencia, ]
    
    dato <- rh_ausencias %>%
      group_by(SECTOR) %>%
      summarise(cont = n())
    tipo <- switch(input$typeAusencia, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = dato, name = "Ausencias", type = tipo, hcaes(x = SECTOR, y = cont), color = c("#68BAF3") )  %>%
      # hc_add_series(data = , name = "Gasto Contable", type = input$typeGasto, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#84C77E") ) %>%
      
      
      #hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Ausencias Por Sector </span> ", useHTML = TRUE) %>%
      # #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Sector")) %>%
      hc_yAxis(title = list(text = "Cantidad"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  
  
  output$graficoComision <- renderHighchart({
    
    
    #rh_lic <- rh_lic[rh_lic$DESCRIPCIONAUSENCIA.1 == input$tipoLicencia , ]
    
    if( input$sectorComision != "Todos"){
      rh_com <- rh_com[rh_com$SECTOR == input$sectorComision , ]
    }
    rh_com <- rh_com[rh_com$periodo == input$periodoComision, ]
    validate(
      need(nrow(rh_com) != 0, ("No se encontraron comisiones de act laboral."))
    )
    dato <- rh_com %>%
      group_by(SECTOR) %>%
      summarise(Total = sum(cant))
    
    tipo <- switch(input$typeComision, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = dato, name = "Comisiones", type = tipo, hcaes(x = SECTOR, y = Total), color = c("#68BAF3") )  %>%
      # hc_add_series(data = , name = "Gasto Contable", type = input$typeGasto, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#84C77E") ) %>%
      
      
      #hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Comisiones </span> ", useHTML = TRUE) %>%
      # #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Sector")) %>%
      hc_yAxis(title = list(text = "Cantidad"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  ##### FINANZAS_SV #####
  output$graficoGastoMensual <- renderHighchart({
    validate(
      need(input$IAnioDesdeGasto <= input$IAnioHastaGasto & input$IAnioDesdeGasto <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    
    Dato26 <- gastoMensual[gastoMensual$TPINDID == 26, ]
    
    Dato26 <- Dato26 %>%
      filter(year(Dato26$TPINDDEMI) >= input$IAnioDesdeGasto,
             year(Dato26$TPINDDEMI) <= input$IAnioHastaGasto)
    
    Dato28 <- gastoMensual[gastoMensual$TPINDID == 28, ]
    
    Dato28 <- Dato28 %>%
      filter(year(Dato28$TPINDDEMI) >= input$IAnioDesdeGasto,
             year(Dato28$TPINDDEMI) <= input$IAnioHastaGasto)
    tipo <- switch(input$typeGasto, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato26, name = "Gasto Recibos($)", type = tipo, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#68BAF3") ) %>%
      hc_add_series(data = Dato28, name = "Gasto Contable($)", type = tipo, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#84C77E") ) %>%
      
      
      # hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Gasto Mensual </span> ", useHTML = TRUE) %>%
      #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Monto            (en millones de $)"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  
  
  output$graficoIngresoMensual <- renderHighchart({
    validate(
      need(input$IAnioDesdeIngreso <= input$IAnioHastaIngreso & input$IAnioDesdeIngreso <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    
    Dato <- ingresoMensual
    
    Dato <- Dato %>%
      filter(year(Dato$TPINDDEMI) >= input$IAnioDesdeIngreso,
             year(Dato$TPINDDEMI) <= input$IAnioHastaIngreso)
    tipo <- switch(input$typeIngreso, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato, name = "Ingresos($)", type = tipo, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#68BAF3") ) %>%
      
      
      # hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Ingreso Mensual </span> ", useHTML = TRUE) %>%
      #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Monto       (en millones de $)"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  
  output$graficoNuevaLey <- renderHighchart({
    validate(
      need(input$IAnioDesdeNuevaLey <= input$IAnioHastaNuevaLey & input$IAnioDesdeNuevaLey <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    
    Dato <- nuevaLey
    
    Dato <- Dato %>%
      filter(year(Dato$Mes_numero) >= input$IAnioDesdeNuevaLey,
             year(Dato$Mes_numero) <= input$IAnioHastaNuevaLey)
    tipo <- switch(input$typeNuevaLey, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato, name = "Ahorro($)", type = tipo, hcaes(x = mesAnio, y = TotalAhorro), color = c("#68BAF3") ) %>%
      
      
      # hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Ingreso Mensual </span> ", useHTML = TRUE) %>%
      #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Ahorro($)"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "AhorroNuevaLey",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  #### LEGALES_SV ####
  output$graficoResueltos <- renderHighchart({
    validate(
      need(input$IAnioDesdeResueltos <= input$IAnioHastaResueltos & input$IAnioDesdeResueltos <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    # 
    # Dato26 <- gastoMensual[gastoMensual$TPINDID == 26, ]
    # 
    # Dato26 <- Dato26 %>%
    #   filter(year(Dato26$TPINDDEMI) >= input$IAnioDesdeGasto,
    #          year(Dato26$TPINDDEMI) <= input$IAnioHastaGasto)
    # 
    # Dato28 <- gastoMensual[gastoMensual$TPINDID == 28, ]
    # 
    legales <- legales %>%
      filter(year(legales$TPINDDEMI) >= input$IAnioDesdeResueltos,
             year(legales$TPINDDEMI) <= input$IAnioHastaResueltos)
    legales <- legales %>%
      arrange(TPINDDEMI)
    favorables <- legales[legales$TPINDID == 100, ]
    desfavorables <- legales[legales$TPINDID == 101, ]
    total <- rbind(favorables,desfavorables)
    total <- total %>% 
      group_by(TPINDDEMI) %>%
      summarise(
        suma =sum(TPINDDVAL),
        mesAnio = first(mesAnio)
      ) %>%
      arrange(TPINDDEMI)
    tipo <- switch(input$typeCausas, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = total, name = "Total", type = tipo, hcaes(x = mesAnio, y = suma), color = c("#68BAF3") ) %>%
      hc_add_series(data = favorables, name = "Favorables", type = tipo, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#84C77E") ) %>%
      hc_add_series(data = desfavorables, name = "Desfavorables", type = tipo, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#EEA13F") ) %>%
      
      
      # hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Gasto Mensual </span> ", useHTML = TRUE) %>%
      #hc_tooltip(pointFormat = paste('Días: {point.y} <br/>')) %>%
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Cantidad"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
  })
  output$totalFavorables <- renderValueBox({
    legales <- legales %>%
      filter(year(legales$TPINDDEMI) >= input$IAnioDesdeResueltos,
             year(legales$TPINDDEMI) <= input$IAnioHastaResueltos)
    legales <- legales %>%
      arrange(TPINDDEMI)
    favorables <- legales[legales$TPINDID == 100, ]
    dato <- sum(favorables$TPINDDVAL)
    texto <- paste("Total casos favorables")
    valueBox(
      value =  dato,
      subtitle = texto,
      icon = icon("address-book"),
      color = "blue"
    )
  })
  output$totalDesfavorables <- renderValueBox({
    legales <- legales %>%
      filter(year(legales$TPINDDEMI) >= input$IAnioDesdeResueltos,
             year(legales$TPINDDEMI) <= input$IAnioHastaResueltos)
    legales <- legales %>%
      arrange(TPINDDEMI)
    desfavorables <- legales[legales$TPINDID == 101, ]
    dato <- sum(desfavorables$TPINDDVAL)
    texto <- paste("Total casos desfavorables")
    valueBox(
      value =  dato,
      subtitle = texto,
      icon = icon("address-book"),
      color = "green"
    )
  })
  
  output$graficoCausas <- renderHighchart({
    
    validate(
      need(input$IAnioDesdeCausas <= input$IAnioHastaCausas & input$IAnioDesdeCausas <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    #Altas$TPINDID <- as.numeric(Altas$TPINDID)
    legales$anio <- substr(legales$TPINDDEMI,1,4)
    Dato <- legales %>%
      filter(legales$anio >= input$IAnioDesdeCausas,
             legales$anio <= input$IAnioHastaCausas)
    Dato <- Dato %>%
      arrange(TPINDDEMI)
    nuevas <- Dato[Dato$TPINDID == 86, ]
    suspendidas <- Dato[Dato$TPINDID == 76, ] 
    terminadas <- Dato[Dato$TPINDID == 77, ]
    
    tipo <- switch(input$typeCausas, "Linea" = "line", "Columna" = "column", "Barra"= "bar","Curva" ="spline")
    
    highchart() %>%
      hc_chart(type= tipo) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = nuevas, name = "Iniciadas", type = tipo, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#68BAF3") ) %>%
      hc_add_series(data = suspendidas, name = "Suspendidas", type = tipo, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#84C77E") ) %>%
      hc_add_series(data = terminadas, name = "Terminadas", type = tipo, hcaes(x = mesAnio, y = TPINDDVAL), color = c("#DFCA63") ) %>%
      # hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Nuevos Beneficios </span> ", useHTML = TRUE) %>%
      
      hc_xAxis(title = list(text = "Periodo")) %>%
      hc_yAxis(title = list(text = "Cantidad"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
    
  })

  
  ##### CALIDAD_SV #####
  
  
  output$graficoCalidad1 <- renderHighchart({
    # validate(
    #   need(input$IAnioDesdeIngreso <= input$IAnioHastaIngreso & input$IAnioDesdeIngreso <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    # )
    # Dato <- Dato %>%
    #   filter(year(Dato$TPINDDEMI) >= input$IAnioDesdeGasto,
    #          year(Dato$TPINDDEMI) <= input$IAnioHastaGasto)
    #
    Dato1 <- final_summary_words[final_summary_words$topic == 1, ]


    # pal <- brewer.pal(6,"Dark2")
    # pal <- pal[-(1)]
    Dato1$n <- ifelse(is.na(Dato1$n),0,Dato1$n)
    # hchart(Dato1[ ,c(2,3)], "wordcloud", hcaes(name = word, weight = log(n)))
    
    highchart() %>%
      hc_chart(type= "wordcloud") %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato1[ ,c(2,3)], name = "Ocurrencia", type = "wordcloud", hcaes(name = word, weight = n))
    # wordcloud(Dato$word,Dato$n,max.words = 20,colors =  pal)
    
  })
  
  output$grafico_cal2 <- renderHighchart({
    # validate(
    #   need(input$IAnioDesdeIngreso <= input$IAnioHastaIngreso & input$IAnioDesdeIngreso <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    # )
    # Dato <- Dato %>%
    #   filter(year(Dato$TPINDDEMI) >= input$IAnioDesdeGasto,
    #          year(Dato$TPINDDEMI) <= input$IAnioHastaGasto)
    #
    Dato <- final_summary_words[final_summary_words$topic == 2, ]
    
  
    Dato$n <- ifelse(is.na(Dato$n),0,Dato$n)
    #hchart(Dato[ ,c(2,3)], "wordcloud", hcaes(name = word, weight = log(n)))
    
    highchart() %>%
      hc_chart(type= "wordcloud") %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato[ ,c(2,3)], name = "Ocurrencia", type = "wordcloud", hcaes(name = word, weight = n))
    
  })
  
  output$grafico3_cal <- renderHighchart({
    # validate(
    #   need(input$IAnioDesdeIngreso <= input$IAnioHastaIngreso & input$IAnioDesdeIngreso <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    # )
    # Dato <- Dato %>%
    #   filter(year(Dato$TPINDDEMI) >= input$IAnioDesdeGasto,
    #          year(Dato$TPINDDEMI) <= input$IAnioHastaGasto)
    #
    Dato <- final_summary_words[final_summary_words$topic == 3, ]
    
    Dato$n <- ifelse(is.na(Dato$n),0,Dato$n)
    #hchart(Dato[ ,c(2,3)], "wordcloud", hcaes(name = word, weight = log(n)))
    
    highchart() %>%
      hc_chart(type= "wordcloud") %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato[ ,c(2,3)], name = "Ocurrencia", type = "wordcloud", hcaes(name = word, weight = n))
    
    
  })
  
  #### PROYECCIONES_SV ####
  Porcentaje_reactive <- eventReactive( input$Porcentaje, {
    
    Dato_baseImp$Gasto <- Dato_baseImp$RADRENUM1 + Dato_baseImp$RADCONSS
    porcentaje <- input$Porcentaje/100
    Dato_baseImp$AumenE2.1 <- Dato_baseImp$RADRENUM1 * porcentaje
    Dato_baseImp$ApoE2.1 <- Dato_baseImp$AumenE2.1 * Dato_baseImp$PorApos
    Dato_baseImp$ConsE2.1 <- Dato_baseImp$AumenE2.1 * Dato_baseImp$PorCons
    Dato_baseImp$SueldoE2.1 <- Dato_baseImp$RADRENUM1 - Dato_baseImp$ApoE2.1
    Dato_baseImp$GastoE2.1 <- Dato_baseImp$RADRENUM1 + Dato_baseImp$ConsE2.1
    
    
    Dato <- Dato_baseImp
    
    
  })
  
  
  output$baseImp <- renderHighchart({
    
    # validate(
    #   need(input$IAnioDesde <= input$IAnioHasta & input$IAnioDesde <= (year(Sys.Date())), ("FECHAS INGRESADAS NO VALIDAS"))
    # )
    
    #Dato <- getProyeccionBaseImp(input$Sector, (input$Porcentaje/100) )
    #Dato_baseImp <- getProyeccionBaseImp("Municipalidad", 0.7)
    Dato <- Porcentaje_reactive()
    
    Dato1 <- as.data.frame( c("Sueldo Promedio","Gasto Promedio"))
    colnames(Dato1)[1] <- "Tipo"
    Dato1$Valor <- c(mean(Dato$Sueldo),mean(Dato$Gasto))
    #Dato1<- round(Dato1$Valor,0)
    Dato2 <- as.data.frame( c("Sueldo Promedio","Gasto Promedio"))
    colnames(Dato2)[1] <- "Tipo"
    Dato2$Valor <- c(mean(Dato$SueldoE2.1),mean(Dato$GastoE2.1))
    
    
    highchart() %>%
      #hc_chart(type= input$type) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato1, name = "Vigente($)", type = "column", hcaes(x = Tipo, y = round(Valor,0)), color = c("#68BAF3") ) %>%
      hc_add_series(data = Dato2, name = "Proyeccion($)", type = "column", hcaes(x = Tipo, y = round(Valor,0)), color = c("#84C77E") ) %>%
      # hc_add_series(data = Dato, name = "JubilacÃ³n", type = input$type, hcaes(x = mesAnio, y = J), color = c("#DFCA63") ) %>%
      # hc_add_series(data = Dato, name = "PensiÃ³n", type = input$type, hcaes(x = mesAnio, y = P), color = c("#EEA13F") ) %>%
      # hc_title(text = "<span> Base imponible </span> ", useHTML = TRUE) %>%
      
      hc_xAxis(title = list(text = "Tipo")) %>%
      hc_yAxis(title = list(text = "Cantidad($)"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
    
  })
  
  
  
  output$tablaRetro <- DT::renderDataTable({
    fecha1 <- input$Fecha_retro
    fecha <- paste(substr(fecha1,9,10),"/",substr(fecha1,6,7),"/",substr(fecha1,1,4), sep = "")
    
    tabla <- Dato_Retro
    #Dato_Retro <- getRetro("01/09/2019")
    if (input$Sector_retro != "Todos") {
      sector <- substr(input$Sector_retro,1,6)
      tabla <- tabla[tabla$PAGCALSECT == sector, ]
    }
    validate(
      need(nrow(tabla) != 0, ("EL SECTOR SELECCIONADO NO TUVO RETROACTIVIDAD"))
    )
    
    tabla <- tabla[ , -c(2,4:12)]
    colnames(tabla)[8] <- "Descripcion"
    tabla$Descripcion <- ifelse(tabla$Descripcion == 1, "Incorrecto","Correcto")
    DT::datatable(tabla)})
  
  output$KPI_Retro <- renderValueBox({
    tabla <- Dato_Retro
    if (input$Sector_retro != "Todos") {
      sector <- substr(input$Sector_retro,1,6)
      tabla <- tabla[tabla$PAGCALSECT ==sector, ]
    }
    
    prom <- mean(tabla$Retro)
    if (nrow(tabla) == 0) {
      prom <- 0
    }
    prom <- paste("$",prettyNum(round(prom,0), scientific = FALSE, big.mark= "."), sep = "")
    
    valueBox(
      value =  prom,
      subtitle = paste("Promedio retroactividad"),
      icon = icon("address-book"),
      color = "olive"
    )
  })
  
  output$KPI_Retro2 <- renderValueBox({
    tabla <- Dato_Retro
    if (input$Sector_retro != "Todos") {
      sector <- substr(input$Sector_retro,1,6)
      tabla <- tabla[tabla$PAGCALSECT == sector, ]
    }
    
    suma <- sum(tabla$Retro)
    if (nrow(tabla) == 0) {
      suma <- 0
    }
    
    suma <- paste("$",prettyNum(round(suma,0), scientific = FALSE, big.mark= "."),sep = "")
    valueBox(
      value =  suma,
      subtitle = paste("Total retroactividad"),
      icon = icon("address-book"),
      color = "light-blue"
    )
  })
  
  output$KPI_Retro3 <- renderValueBox({
    tabla <- Dato_Retro
    if (input$Sector_retro != "Todos") {
      sector <- substr(input$Sector_retro,1,6)
      tabla <- tabla[tabla$PAGCALSECT == sector, ]
    }
    
    cantidad <- as.numeric(length(unique(tabla$PAGCALSOLN)))
    if (nrow(tabla) == 0) {
      cantidad <- 0
    }
    cantidad <- prettyNum(cantidad, scientific = FALSE, big.mark= ".")
    
    valueBox(
      value =  cantidad,
      subtitle = paste("Cantidad solicitudes pagadas"),
      icon = icon("address-book"),
      color = "aqua"
    )
  })
  
  # sector_reactive <- eventReactive( input$Sector_basico, {
  #   
  #   sector <- Sectores[Sectores$SECTNOMBRE == input$Sector_basico, "SECTID"]
  #   
  # })
  
  porcentajeBasico_reactive <- eventReactive( {input$Porcentaje_sector || input$Sector_basico } , {
    sector <- Sectores[Sectores$SECTNOMBRE == input$Sector_basico, "SECTID"]
    porcentaje <- 1 + (input$Porcentaje_sector/100)
    DatoBasico <- Dato_basico[Dato_basico$PAGCALSECT == sector, ]
    DatoBasico$BasicoNuevo <- DatoBasico$PAGCAL9997 * porcentaje
    
    DatoBasico <- DatoBasico %>% summarise(PromedioBasico = mean(PAGCAL9997),
                                           GastoActual = sum(PAGCAL9997),
                                           PromedioAumento = mean(BasicoNuevo),
                                           GastoAumento = sum(BasicoNuevo))
    
  })
  
  
  
  
  output$grafico_basico <- renderHighchart({
    
    # validate(
    #   need(input$IAnioDesde <= input$IAnioHasta & input$IAnioDesde <= (year(Sys.Date())), ("FECHAS INGRESADAS NO VALIDAS"))
    # )
    #print(input$Sector_basico)
    ### sector <- sector_reactive()
    #sector <- as.numeric(sector)
    #Dato <- getBasico(sector, input$Porcentaje_sector/100)
    Dato <- porcentajeBasico_reactive()
    #Dato_basico <- getBasico("020100",10)
    #Dato <- getProyeccionBaseImp("Municipalidad", 0.7)
    #prue <- dcast(Prueba,Cuil2 + PERAPE + PERNOM + SECTOR ~ DESCRIPCIONAUSENCIA.1, var = "cant")
    Dato1 <- as.data.frame( c("Promedio","Gasto(EnMiles)"))
    colnames(Dato1)[1] <- "Tipo"
    Dato1$Valor <- c(Dato[1, ]$PromedioBasico,Dato[1, ]$GastoActual /1000)
    Dato1$Tipo <- as.character(Dato1$Tipo)
    
    Dato2 <- as.data.frame( c("Promedio","Gasto(EnMiles)"))
    colnames(Dato2)[1] <- "Tipo"
    Dato2$Valor <- c(Dato[1, ]$PromedioAumento,Dato[1, ]$GastoAumento/1000 )
    Dato2$Tipo <- as.character(Dato2$Tipo)
    
    highchart() %>%
      #hc_chart(type= input$type) %>%
      hc_xAxis(type="category") %>%
      hc_add_series(data = Dato1, name = "Vigente($)", type = "column", hcaes(x = Tipo, y = round(Valor,0)), color = c("#68BAF3") ) %>%
      hc_add_series(data = Dato2, name = "Proyeccion($)", type = "column", hcaes(x = Tipo, y = round(Valor,0)), color = c("#84C77E") ) %>%
      # hc_add_series(data = Dato, name = "JubilacÃ³n", type = input$type, hcaes(x = mesAnio, y = J), color = c("#DFCA63") ) %>%
      # hc_add_series(data = Dato, name = "PensiÃ³n", type = input$type, hcaes(x = mesAnio, y = P), color = c("#EEA13F") ) %>%
      # hc_title(text = "<span style=\"color:#005c64;font-family: Arial ; font-size: 25px\"> Proyeccion de basico </span> ", useHTML = TRUE) %>%
      
      hc_xAxis(title = list(text = "Tipo")) %>%
      hc_yAxis(title = list(text = "Cantidad($)"))%>%
      hc_title(text= "<span style=\"background-color:#ecf0f5\"> </span>", useHTML = TRUE) %>%
      hc_exporting(plotOptions= list(line = list(
        dataLabels = list(enabled = TRUE))),
        text = "Descargar",
        enabled = TRUE, # always enabled
        filename = "NuevosBeneficios",
        buttons = list(contextButton = list(menuItems = c("downloadJPEG", "downloadPDF","downloadXLS")))
      )
    
    
    
  })
  
  ####### ADMIN_SV ######
  ####Create User
  
  # saveDataSql <- function(query) {
  #   con = dbConnect(RMySQL::MySQL(), dbname  =  "database", host = "host", user = "root", password = "password", port = 3306)
  #   dbGetQuery(con, query)
  #   dbDisconnect(con)
  # }
  # 
  # 
  
  iv1 <- InputValidator$new()
  
  # 2. Add validation rules
  # iv1$add_rule("DniID", sv_numeric(message = "El dni es requerido."))
  iv1$add_rule("DniID", function(value) {
    if (nchar(value) < 7) {
      'Debe tener 8 caracteres'
    }
  })
  
  
  # iv1$add_rule("NombreId", sv_required(message = "El nombre es requerido."))
  iv1$add_rule("NombreId", function(value) {
    if (nchar(value) < 3) {
      'Debe tener mas de 3 caracteres.'
    }
  })
  # iv1$add_rule("ApellidoId", sv_required(message = "El apellido es requerido."))
  iv1$add_rule("ApellidoId", function(value) {
    if (nchar(value) < 3) {
      'Debe tener más de 3 caracteres.'
    }
  })
  # iv1$add_rule("user", sv_required(message = "El usuario es requerido."))
  iv1$add_rule("user", function(value) {
    if (nchar(value) < 3) {
      'Debe tener más de 3 caracteres.'
    }
  })
  # iv1$add_rule("password", sv_required(message = "La contraseña es requerido."))
  iv1$add_rule("password", function(value) {
    if (nchar(value) < 3) {
      'Debe tener más de 3 caracteres.'
    }
  })
  # iv1$add_rule("password2", sv_required(message = "Valide su contraseña."))
  iv1$add_rule("password2", function(value) {
    if (value != input$password) {
      'Las contraseñas deben coincidir.'
    }
  })
  
  
  
  # 3. Start displaying errors in the UI
  
  observeEvent(input$btnCreateUser,{
    load(file = "./RDA/credentials.rda",envir = .GlobalEnv)
    iv1$enable()
    
    if (iv1$is_valid()) {
        if ((input$DniID %in% credentials$dni) == F & (input$user %in% credentials$user) == F) {
          
          
          
          
          u1 <- data.frame(
            user = input$user, # mandatory
            password = input$password, 
            level = 0,
            nombre = input$NombreId,
            apellido = input$ApellidoId,
            dni = input$DniID
          )
          
          credentials <- rbind(credentials,u1)
          save(credentials,file = "./RDA/credentials.rda")
          load(file = "./RDA/credentials.rda",envir = .GlobalEnv)
          
          showNotification("Usuario Creado correctamente",duration = 5,closeButton = T,type = "message")
          output$tablaUsuarios <-
            DT::renderDataTable(DT::datatable(credentials))
          
          updateTextInput(session, "NombreId", value = " ")     
          updateTextInput(session, "ApellidoId", value = " ")
          updateTextInput(session, "user", value = " ")
          updateNumericInput(session, "DniID", value = 0)
          output$errtext <- NULL
          
          
        }
        else{
          showNotification("No se puede crear el usuario: DNI o USUARIO ya existente",duration = 5,closeButton = T,type = "error")
        }
      iv1$disable()
      
    }
    
    
  },ignoreInit = T
  )
  
  iv2 <- InputValidator$new()
  
  # 2. Add validation rules
  # iv1$add_rule("DniID", sv_numeric(message = "El dni es requerido."))
  iv2$add_rule("DniModif", function(value) {
    if (nchar(value) < 7) {
      'Debe tener 8 caracteres'
    }
  })
  
  # iv1$add_rule("password", sv_required(message = "La contraseña es requerido."))
  iv2$add_rule("passwordModif", function(value) {
    if (nchar(value) < 3) {
      'Debe tener más de 3 caracteres.'
    }
  })
  # iv1$add_rule("password2", sv_required(message = "Valide su contraseña."))
  iv2$add_rule("passwordModif2", function(value) {
    if (value != input$passwordModif) {
      'Las contraseñas deben coincidir.'
    }
  })
  ####Alter User
  observeEvent(input$btnAlterUser,{
    load(file = "./RDA/credentials.rda",envir = .GlobalEnv)
    iv2$enable()
    
    if (iv2$is_valid()) {
    
    if ((input$DniModif %in% credentials$dni) == T ) {
      credentials[credentials$dni == input$DniModif,]$password <- input$passwordModif
      
      save(credentials,file = "./RDA/credentials.rda")
      showNotification("Usuario Modificado correctamente",duration = 5,closeButton = T,type = "message")
      load(file = "./RDA/credentials.rda",envir = .GlobalEnv)
      
      output$tablaUsuarios <-
        DT::renderDataTable(DT::datatable(credentials))
      updateNumericInput(session, "DniModif", value = 0)
      
      
    }
    else{
      showNotification("No se puede actualizar el usuario: DNI No existente",duration = 5,closeButton = T,type = "error")
    }
      iv2$disable()
      
    }
    
  }
  )
  
  # 
  # 
  
  iv3<- InputValidator$new()
  
  # 2. Add validation rules
  # iv1$add_rule("DniID", sv_numeric(message = "El dni es requerido."))
  iv3$add_rule("DniDelete", function(value) {
    if (nchar(value) < 7) {
      'Debe tener 8 caracteres'
    }
  })
  
  observeEvent(input$btnDeleteUser,{
    load(file = "./RDA/credentials.rda",envir = .GlobalEnv)
   
    iv3$enable()
    
    if (iv3$is_valid()) {
    if ((input$DniDelete %in% credentials$dni) == T ) {
      
      credentials <- credentials[credentials$dni != input$DniDelete, ]
      
      save(credentials,file = "./RDA/credentials.rda")
      load(file = "./RDA/credentials.rda",envir = .GlobalEnv)
      
      showNotification("Usuario eliminado correctamente",duration = 5,closeButton = T,type = "message")
      output$tablaUsuarios <-
        DT::renderDataTable(DT::datatable(credentials))
      updateNumericInput(session, "DniDelete", value = 0)
      
      
    }
    else{
      showNotification("No se puede eliminar el usuario: DNI No existente",duration = 5,closeButton = T,type = "error")
    }
      iv3$disable()
    }
  }
  )
  
  
  
  
  
  iv4 <- InputValidator$new()
  
  # 2. Add validation rules
  # iv1$add_rule("DniID", sv_numeric(message = "El dni es requerido."))
  iv4$add_rule("passwordAnterior", function(value) {
    if (nchar(value) < 3) {
      'Debe tener más de 3 caracteres.'
    }
  })
  
  # iv1$add_rule("password", sv_required(message = "La contraseña es requerido."))
  iv4$add_rule("passwordModifUsu", function(value) {
    if (nchar(value) < 3) {
      'Debe tener más de 3 caracteres.'
    }
  })
  # iv1$add_rule("password2", sv_required(message = "Valide su contraseña."))
  iv4$add_rule("passwordModif2Usu", function(value) {
    if (value != input$passwordModifUsu) {
      'Las contraseñas deben coincidir.'
    }
  })
  
 
  observeEvent(input$btnAlterUserUsu,{
    load(file = "./RDA/credentials.rda",envir = .GlobalEnv)
    
    # validate(
    #   need(input$DniModif, 'Debe ser solo número'),
    #   need(nchar(input$passwordModif) > 5, 'Debe ingresar una contraseña'),
    #   need(input$passwordModif == input$passwordModif2, 'Las contraseñas deben coincidir')
    # 
    # )
    iv4$enable()
    
    if (iv4$is_valid()) {
      
    if ((input$passwordAnterior == credentials[credentials$dni == creds_reactive()$dni,"password"]) == T ) {
      credentials[credentials$dni == creds_reactive()$dni,]$password <- input$passwordModifUsu
      
      save(credentials,file = "./RDA/credentials.rda")
      showNotification("Contraseña Modificado correctamente",duration = 5,closeButton = T,type = "message")
      load(file = "./RDA/credentials.rda",envir = .GlobalEnv)
      
      output$tablaUsuarios <-
        DT::renderDataTable(DT::datatable(credentials))

      output$tablaUsuarioPropio <-
        DT::renderDataTable({
          dataUser <- credentials[credentials$dni == creds_reactive()$dni,]
          
          DT::datatable(dataUser,extensions = "Responsive")})      
    }
    else{
      showNotification("No se puede actualizar la contraseña: Contraseña Incorrecta",duration = 5,closeButton = T,type = "error")
    }
      iv4$disable()
    }
  }
  )
  
  
  ########### TABLAS ####
  output$tablaUsuarios <-
    DT::renderDataTable(DT::datatable(credentials,extensions = "Responsive"))
  
  output$tablaMutuales <-
    DT::renderDataTable(
      # DT::datatable(codigoMutuales,extensions = "Responsive")
      DT::datatable(codigoMutuales, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    ))
      )
  
  output$tablaMutualesAsociacion <-
    DT::renderDataTable(
      # DT::datatable(comparacionAsociacion,extensions = "Responsive")
      DT::datatable(comparacionAsociacion, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    ))
      )
  
  output$tablaMutualesCobro <-
    DT::renderDataTable(
      # DT::datatable(comparacionCobros,extensions = "Responsive")
      DT::datatable(comparacionCobros, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    )))
  
  output$tablaAltasJub <-
    DT::renderDataTable(
      # DT::datatable(AltasJub,extensions = "Responsive")
      DT::datatable(AltasJub, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    )))
  
  output$tablaAltasPen <-
    DT::renderDataTable(
      # DT::datatable(AltasPen,extensions = "Responsive")
      DT::datatable(AltasPen, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    )))
  
  output$tablaAltasInv <-
    DT::renderDataTable(
      # DT::datatable(AltasInv,extensions = "Responsive")
      DT::datatable(AltasInv, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    )))
 
   output$tablaMovilidad <-
    DT::renderDataTable(
      # DT::datatable(tablaMov,extensions = "Responsive")
      DT::datatable(tablaMov, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    )))
  
  output$tablaInvalidecesModif <- DT::renderDataTable({
    validate(
      need(input$rangoValidacion2[1] <= input$rangoValidacion2[2] & input$rangoValidacion2[1] <= Sys.Date(), ("Fechas ingresadas no validas."))
    )
    # Vencidos <- Vencidos[Vencidos$PRESTDSC == input$tipoPrestacion, ]
    
    InvalidecesModificacion %>%
      filter(InvalidecesModificacion$Fecha_Modificacion >= input$rangoValidacion2[1],
             InvalidecesModificacion$Fecha_Modificacion <= input$rangoValidacion2[2],
             InvalidecesModificacion$Usuario == input$usuarioInv) %>%
      select(Solicitud,Tipo_Beneficio,Fecha_Inicio,Fecha_Nueva,Fecha_Anterior,Fecha_Modificacion,Usuario) %>%
      
      # DT::datatable(extensions = "Responsive")
      DT::datatable(extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    ))
  })
  
  
  output$tablaUsuarioPropio <-
    DT::renderDataTable({
      dataUser <- credentials[credentials$dni == creds_reactive()$dni,]
      
      # DT::datatable(dataUser,extensions = "Responsive")
      DT::datatable(dataUser, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    ))})
  
  
  
  
  
  
  output$table <- DT::renderDataTable({
    validate(
      need(input$IAnioDesde <= input$IAnioHasta & input$IAnioDesde <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
    )
    #Altas$TPINDID <- as.numeric(Altas$TPINDID)
    
    Dato <- Altas_modif %>%
      filter(Altas_modif$Anio >= input$IAnioDesde,
             Altas_modif$Anio <= input$IAnioHasta)
    Dato <- Dato %>% group_by(Anio) %>% mutate(Prom = mean(cont))
    Dato$Prom <- round(Dato$Prom, 0)
    # DT::datatable(Dato,extensions = c("Responsive","Buttons"),
    #               
    #               options = list(
    #                 dom = 'tB',
    #                 buttons = c('copy', 'csv', 'excel')
    #               ))
    DT::datatable(Dato, extensions = c('Buttons',"Responsive"),
                  options = list(dom = 'Bfrtip',
                                 buttons = 
                                   list(
                                     list(extend = 'colvis', text='Columnas'), 
                                     list(
                                        extend = 'collection',
                                        buttons = list(list(extend='csv',
                                                         filename = "csv_asd"),
                                                    list(extend='excel',
                                                         filename = "xls_asd"),
                                                    list(extend='pdf',
                                                         filename= "pdf_asd")),
                                     text = 'Descargar'
                                    )
                                  ),
                                 scrollX = TRUE
                  )
    )
  })
  
  #####################d
  output$tablaProyeccionAltas <- DT::renderDataTable(
    DT::datatable(Proyeccion, extensions = c('Buttons',"Responsive"),
                  options = list(dom = 'Bfrtip',
                                 buttons = 
                                   list(
                                     list(extend = 'colvis', text='Columnas'), 
                                     list(
                                       extend = 'collection',
                                       buttons = list(list(extend='csv',
                                                           filename = "csv_asd"),
                                                      list(extend='excel',
                                                           filename = "xls_asd"),
                                                      list(extend='pdf',
                                                           filename= "pdf_asd")),
                                       text = 'Descargar'
                                     )
                                   ),
                                 scrollX = TRUE
                  ))
  )
    # Proyeccion,extensions = "Responsive")
  
  ######################d
  
  output$tablaDemoraJO <-
    DT::renderDataTable({
      validate(
        need(input$IAnioDesdeDemora <= input$IAnioHastaDemora & input$IAnioDesdeDemora <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
      )
      Dato <- DemoraJO %>%
        filter(year(DemoraJO$fecha_fin) >= input$IAnioDesdeDemora,
               year(DemoraJO$fecha_fin) <= input$IAnioHastaDemora)  %>%
        select(fecha_fin,tramites,WEB,DIAS,mesAnio,Prom)
      Dato$Prom <- round(Dato$Prom, 0)
      # DT::datatable(Dato,extensions = "Responsive")
      DT::datatable(Dato, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    ))
    })
  ######################d
  
  output$tablaDemoraJI <-
    DT::renderDataTable({
      validate(
        need(input$IAnioDesdeDemoraJI <= input$IAnioHastaDemoraJI & input$IAnioDesdeDemoraJI <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
      )
      Dato <- DemoraJI %>%
        filter(year(DemoraJI$fecha_fin) >= input$IAnioDesdeDemoraJI,
               year(DemoraJI$fecha_fin) <= input$IAnioHastaDemoraJI)%>%
        select(fecha_fin,tramites,DIAS,mesAnio,Prom)
      Dato$Prom <- round(Dato$Prom, 0)
      # DT::datatable(Dato,extensions = "Responsive")
      DT::datatable(Dato, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    ))
    })
  
  ######################################a
  
  output$tablaGastoMensual <-
    DT::renderDataTable({
      validate(
        need(input$IAnioDesdeGasto <= input$IAnioHastaGasto & input$IAnioDesdeGasto <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
      )
      
      Dato26 <- gastoMensual[gastoMensual$TPINDID == 26, ]
      
      Dato26 <- Dato26 %>%
        filter(year(Dato26$TPINDDEMI) >= input$IAnioDesdeGasto,
               year(Dato26$TPINDDEMI) <= input$IAnioHastaGasto)
      
      Dato28 <- gastoMensual[gastoMensual$TPINDID == 28, ]
      
      Dato28 <- Dato28 %>%
        filter(year(Dato28$TPINDDEMI) >= input$IAnioDesdeGasto,
               year(Dato28$TPINDDEMI) <= input$IAnioHastaGasto)
      DT::datatable(rbind(Dato28,Dato26),extensions = "Responsive")
      DT::datatable(rbind(Dato28,Dato26), extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    ))
    })
  ######################################a
  
  output$tablaIngresoMensual <-
    DT::renderDataTable({
      validate(
        need(input$IAnioDesdeIngreso <= input$IAnioHastaIngreso & input$IAnioDesdeIngreso <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
      )
      
      Dato <- ingresoMensual
      
      Dato <- Dato %>%
        filter(year(Dato$TPINDDEMI) >= input$IAnioDesdeIngreso,
               year(Dato$TPINDDEMI) <= input$IAnioHastaIngreso)
      # DT::datatable(Dato,extensions = "Responsive")
      DT::datatable(Dato, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    ))
    })
  
  output$tablaNuevaLey <-
    DT::renderDataTable({
      validate(
        need(input$IAnioDesdeNuevaLey <= input$IAnioHastaNuevaLey & input$IAnioDesdeNuevaLey <= (year(Sys.Date())), ("Fechas ingresadas no validas."))
      )
      
      Dato <- nuevaLey
      colnames(Dato)[4] <- "Ahorro_haberInicial($)"
      colnames(Dato)[5] <- "Ahorro_dif($)"
      colnames(Dato)[6] <- "AporteSolidario($)"
      colnames(Dato)[7] <- "TotalAhorro($)"
      colnames(Dato)[8] <- "Ley10664($)"
      
      colnames(Dato)[3] <- "Ley10333($)"
      Dato <- Dato %>%
        filter(year(Dato$Mes_numero) >= input$IAnioDesdeNuevaLey,
               year(Dato$Mes_numero) <= input$IAnioHastaNuevaLey)
      # DT::datatable(Dato,extensions = "Responsive")
      DT::datatable(Dato, extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    ))
    })
  
  ######################d
  
  output$tablaVencidos <- DT::renderDataTable({
    validate(
      need(input$rangoValidacion[1] <= input$rangoValidacion[2] & input$rangoValidacion[1] <= Sys.Date(), ("Fechas ingresadas no validas."))
    )
   # Vencidos <- Vencidos[Vencidos$PRESTDSC == input$tipoPrestacion, ]
    
    Vencidos %>%
      filter(Vencidos$JBSOLFECVI >= input$rangoValidacion[1],
             Vencidos$JBSOLFECVI <= input$rangoValidacion[2],
             Vencidos$PRESTDSC == input$tipoPrestacion) %>%
      select(JBSOLNUMER,JBSOLPERNI,EMINRO,JBSOLFECVI) %>%
      DT::datatable(extensions = c('Buttons',"Responsive"),
                    options = list(dom = 'Bfrtip',
                                   buttons = 
                                     list(
                                       list(extend = 'colvis', text='Columnas'), 
                                       list(
                                         extend = 'collection',
                                         buttons = list(list(extend='csv',
                                                             filename = "csv_asd"),
                                                        list(extend='excel',
                                                             filename = "xls_asd"),
                                                        list(extend='pdf',
                                                             filename= "pdf_asd")),
                                         text = 'Descargar'
                                       )
                                     ),
                                   scrollX = TRUE
                    ))
      # DT::datatable(extensions = "Responsive")
  })
  #####################d
  
  #####################D
  output$tortaCantidadBeneficiosPOJ <- renderHighchart({
    dato <- Beneficios %>%
      group_by(JBSOLPOJ) %>% summarise(cant = n())
    dato$JBSOLPOJ <- ifelse(dato$JBSOLPOJ == "J", "Jubilación", "Pensión")
    dato$cant <- comma(dato$cant, format = "f", big.mark = ",")
    
    highchart() %>%
      #   hc_add_series(data = dato, hcaes(JBSOLPOJ, cant), type = "pie", color = c("green","pink"),
      #                 tooltip = list(pointFormat = "<br><b>{point.percentage:.1f}%</b><br>{point.cant}")) %>%
      #   hc_tooltip(crosshairs = TRUE,  borderWidth = 5, sort = TRUE, shared = TRUE, table = FALSE) %>%
      #
      #   hc_title(text = "Porcentaje por P y J",
      #          margin = 20,
      #          style = list(color = "#144746", useHTML = TRUE))
      hc_chart(type = "pie") %>%
      hc_add_series_labels_values(labels = dato$JBSOLPOJ, values = dato$cant, text = dato$cant, color = c("#84C77E", "#144746")) %>%
      hc_tooltip(crosshairs = TRUE, borderWidth = 5, sort = TRUE, shared = TRUE, table = FALSE,
                 pointFormat = paste('{point.y} <br/><b>{point.percentage:.1f}%</b>'))%>%
      hc_title(text = "Beneficio",
               margin = 20)
    
  })
  ##################A
  output$tortaCantidadBeneficiosSEXO <- renderHighchart({
    dato <- Beneficios %>%
      group_by(PERSEXO) %>% summarise(cant = n())
    dato$PERSEXO <- ifelse(dato$PERSEXO == "M", "Masculino", "Femenino")
    dato$cant <- as.numeric(dato$cant)
    #dato$cant <- as.numeric(prettyNum(dato$cant, big.mark = ",", scientific = FALSE))
    highchart() %>%
      hc_chart(type = "pie") %>%
      hc_add_series_labels_values(labels = dato$PERSEXO, values = dato$cant, color = c("#73A7D9", "#F36868")) %>%
      hc_tooltip(crosshairs = TRUE, borderWidth = 5, sort = TRUE, shared = TRUE, table = FALSE, pointFormat = paste('{point.y} <br/><b>{point.percentage:.1f}%</b>'))%>%
      hc_title(text = "Sexo",
               margin = 20)
    
  })
  
  
  
  ####################D
  
  # output$textProyeccion <- renderPrint({
  #
  #   n <- nrow(Proyeccion)
  #
  #   print(n)
  #
  #
  # })
  
  
  
  
  #### KPI ####
  output$contNuevosBenef <- renderValueBox({
    dato <- Altas_modif %>%
      filter(Altas_modif$Anio >= input$IAnioDesde,
             Altas_modif$Anio <= input$IAnioHasta)
    valueBox(
      value =  prettyNum(sum(dato$cont), scientific = FALSE, big.mark= ".", decimal.mark = ","),
      subtitle = paste("Total beneficios ",input$IAnioDesde, "-",input$IAnioHasta, sep = ""),
      icon = icon("address-book"),
      color = "olive"
    )
  })
  
  output$ProyeccionAltas <- renderValueBox({
    
    n <- nrow(Proyeccion)
    
    valueBox(
      value =  n,
      subtitle = "Futuras altas anuales",
      icon = icon("chart-area"),
      color = "light-blue"
    )
  })
  
  output$DemoraKPI <- renderValueBox({
    
    n <- last(DemoraJO)
    
    valueBox(
      value =  n$DIAS,
      subtitle = paste("Días en ", n$mesAnio, sep = ""),
      icon = icon("address-book"),
      color = "green"
    )
  })
  output$DemoraKPI2 <- renderValueBox({
    
    n <- DemoraJO %>%
      filter(year(fecha_fin) == 2019) %>%
      summarise(DE = sd(DIAS))
    
    valueBox(
      value =  prettyNum(round(n, 2), scientific = FALSE, decimal.mark= ","),
      subtitle = "Desviación estandar 2019",
      icon = icon("chart-area"),
      color = "aqua"
    )
  })
  output$DemoraKPI3 <- renderValueBox({
    
    
    n <- last(DemoraJO)
    
    valueBox(
      value =  n$tramites,
      subtitle = paste("Cantidad de tramites ", n$mesAnio, sep = ""),
      icon = icon("chart-area"),
      color = "light-blue"
    )
  })
  
  
  output$DemoraJI_KPI <- renderValueBox({
    
    n <- last(DemoraJI)
    
    valueBox(
      value =  n$DIAS,
      subtitle = paste("Días en ", n$mesAnio, sep = ""),
      icon = icon("address-book"),
      color = "green"
    )
  })
  output$DemoraJI_KPI2 <- renderValueBox({
    
    n <- DemoraJI %>%
      filter(year(fecha_fin) == 2019) %>%
      summarise(DE = sd(DIAS))
    
    valueBox(
      value =  prettyNum(round(n, 2), scientific = FALSE, decimal.mark= ","),
      subtitle = "Desviación estandar 2019",
      icon = icon("chart-area"),
      color = "aqua"
    )
  })
  output$DemoraJI_KPI3 <- renderValueBox({
    
    n <- last(DemoraJI)
    
    valueBox(
      value =  n$tramites,
      subtitle = paste("Cantidad de tramites ", n$mesAnio, sep = ""),
      icon = icon("chart-area"),
      color = "light-blue"
    )
  })
  
  output$ultimoMesBeneficio <- renderValueBox({
    dato <- Altas[Altas$TPINDDEMI == max(Altas$TPINDDEMI), ]
    texto <- paste("Altas en ", dato$mesAnio)
    valueBox(
      value =  dato$TPINDDVAL,
      subtitle = texto,
      icon = icon("address-book"),
      color = "aqua"
    )
  })
  
  output$VariacionMensual <- renderValueBox({
    dato <- VariacionGasto[VariacionGasto$TPINDID == 52 & VariacionGasto$TPINDDEMI == max(VariacionGasto$TPINDDEMI), ]
    
    valueBox(
      paste0(prettyNum(dato$TPINDDVAL, scientific = FALSE, big.mark= ".", decimal.mark = ","), "%"), "Variación mensual", icon = icon("address-book"),
      color = "green"
    )
  })
  
  output$VariacionAnual <- renderValueBox({
    dato <- VariacionGasto[VariacionGasto$TPINDID == 53 & VariacionGasto$TPINDDEMI == max(VariacionGasto$TPINDDEMI), ]
    # valueBox(
    #   value =  dato$TPINDDVAL,
    #   subtitle = "Variacion anual",
    #   icon = icon("chart-area"),
    #   color = "light-blue"
    # )
    valueBox(
      paste0(prettyNum(dato$TPINDDVAL, scientific = FALSE, decimal.mark= ","), "%"), "Variación anual", icon = icon("chart-area"),
      color = "light-blue"
    )
  })
  
  output$VariacionMensualIngresos <- renderValueBox({
    dato <- variacionIngreso[variacionIngreso$TPINDID == 54 & variacionIngreso$TPINDDEMI == max(variacionIngreso$TPINDDEMI), ]
    valueBox(
      paste0(prettyNum(dato$TPINDDVAL, scientific = FALSE, decimal.mark= ","), "%"), "Variación mensual", icon = icon("address-book"),
      color = "green"
    )
  })
  
  output$VariacionAnualIngresos <- renderValueBox({
    dato <- variacionIngreso[variacionIngreso$TPINDID == 55 & variacionIngreso$TPINDDEMI == max(variacionIngreso$TPINDDEMI), ]
    
    valueBox(
      paste0(prettyNum(dato$TPINDDVAL, scientific = FALSE, decimal.mark= ","), "%"), "Variación anual", icon = icon("chart-area"),
      color = "light-blue"
    )
  })
  
  output$ultimoMesGasto <- renderValueBox({
    dato <- gastoMensual[gastoMensual$TPINDID == 28 & gastoMensual$TPINDDEMI == max(gastoMensual$TPINDDEMI), ]
    valueBox(
      value =  paste("$",prettyNum(dato$TPINDDVAL, scientific = FALSE, big.mark= ".", decimal.mark = ",")),
      subtitle = "Gasto en el ultimo mes",
      icon = icon("address-book"),
      color = "blue"
    )
  })
  
  output$ultimoMesIngreso <- renderValueBox({
    dato <- ingresoMensual[ingresoMensual$TPINDDEMI == max(ingresoMensual$TPINDDEMI), ]
    texto <- paste("Ingreso en el ultimo mes")
    valueBox(
      value =  paste("$",prettyNum(dato$TPINDDVAL, scientific = FALSE, big.mark= ".", decimal.mark = ",")),
      subtitle = texto,
      icon = icon("address-book"),
      color = "blue"
    )
  })
  
  output$totalLicencia <- renderValueBox({
    rh_lic <- rh_lic[rh_lic$DESCRIPCIONAUSENCIA.1 == input$tipoLicencia , ]
    if( input$sectorLicencia != "Todos"){
      rh_lic <- rh_lic[rh_lic$SECTOR == input$sectorLicencia , ]
    }
    dato <- rh_lic
    texto <- paste("Total de licencias")
    valueBox(
      value =  sum(dato$cant),
      subtitle = texto,
      icon = icon("address-book"),
      color = "olive"
    )
  })
  
  output$totalLicencia2 <- renderValueBox({
    rh_lic <- rh_lic[rh_lic$DESCRIPCIONAUSENCIA.1 == input$tipoLicencia , ]
    if( input$sectorLicencia != "Todos"){
      rh_lic <- rh_lic[rh_lic$SECTOR == input$sectorLicencia , ]
    }
    dato <- rh_lic
    texto <- paste("Total de licencias")
    valueBox(
      value =  sum(dato$cant),
      subtitle = texto,
      icon = icon("address-book"),
      color = "aqua"
    )
  })
  
  output$totalLicencia3 <- renderValueBox({
    rh_lic <- rh_lic[rh_lic$DESCRIPCIONAUSENCIA.1 == input$tipoLicencia , ]
    if( input$sectorLicencia != "Todos"){
      rh_lic <- rh_lic[rh_lic$SECTOR == input$sectorLicencia , ]
    }
    dato <- rh_lic
    texto <- paste("Total de licencias")
    valueBox(
      value =  sum(dato$cant),
      subtitle = texto,
      icon = icon("address-book"),
      color = "blue"
    )
  })
  
  output$produ <- renderValueBox({
    rh_productividad <- rh_productividad[rh_productividad$periodo == input$periodoProduExt, ]
    dato <- rh_productividad %>%
      group_by(periodo) %>%
      summarise(Prom = mean(PorcentajeCumpl))
    
    valueBox(
      value =  paste(round(dato$Prom,2),"%", sep = " "),
      subtitle = paste("Productividad ",input$periodoProduExt, sep = ""),
      icon = icon("chart-area"),
      color = "aqua"
    )
  })
  
  output$produ2 <- renderValueBox({
    rh_productividad <- rh_productividad[rh_productividad$periodo == input$periodoProduExt, ]
    dato <- rh_productividad %>%
      group_by(periodo) %>%
      summarise(Prom = mean(PorcentajeCumpl))
    
    valueBox(
      value =  round(dato$Prom,2),
      subtitle = paste("Productividad ",input$periodoProduExt, sep = ""),
      icon = icon("chart-area"),
      color = "aqua"
    )
  })
  
  output$produ3 <- renderValueBox({
    rh_productividad <- rh_productividad[rh_productividad$periodo == input$periodoProduExt, ]
    dato <- rh_productividad %>%
      group_by(periodo) %>%
      summarise(Prom = mean(PorcentajeCumpl))
    
    valueBox(
      value =  round(dato$Prom,2),
      subtitle = paste("Productividad ",input$periodoProduExt, sep = ""),
      icon = icon("chart-area"),
      color = "blue"
    )
  })
  
  
  
  
  observe({
    shinyjs::onclick("JO",{
      shinyjs::hide(id = "menuDemoraJI")
      shinyjs::show(id = "menuDemora")}
      
    )
    shinyjs::onclick("JI",{
      shinyjs::hide(id = "menuDemora")
      shinyjs::show(id = "menuDemoraJI")}
      
    )
    
  })
  
  
  # output$progreso <- renderInfoBox({
  #   infoBox(
  #     "Progress", paste0(25, "%"), icon = icon("chart-area"),
  #     color = "green"
  #   )
  # })
  #
  # output$progreso2 <- renderInfoBox({
  #   infoBox(
  #     "Progress", paste0(25, "%"), icon = icon("list"),
  
  #     color = "green", fill = TRUE
  #   )
  # })
  
}



shinyApp(ui, server)


