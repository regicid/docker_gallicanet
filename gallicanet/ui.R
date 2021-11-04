library(shiny)
library(ggplot2)
library(plotly)
library(stringr)
library(markdown)
library(shinythemes)
library(htmltools)
library(shinybusy)

shinyUI(navbarPage("Gallicanet",
                   tabPanel("Réseau",fluidPage(
                            tags$head(),
                            plotlyOutput("plot"),
                            
                            column(4,
                                   wellPanel(
                                     uiOutput("mot"),
                            div(style="display: inline-block;vertical-align:bottom;width: 45%;",numericInput("plancher","Nombre minimum de mentions pour chaque terme",100,step = 10)),
                            div(style="display: inline-block;vertical-align:bottom;width: 45%;",numericInput("seuil","Seuil définissant un lien entre deux termes",0.03,min = 0,max=1,step = 0.01)),
                            div(style="display: inline-block;vertical-align:bottom;",downloadButton('downloadData', 'Données')),
                            div(style="display: inline-block;vertical-align:bottom;",downloadButton('downloadPlot', 'Graphique interactif'))
                            )),
                            column(4,
                                   wellPanel(
                                     selectInput("pretraites","Explorer des réseaux pré-traités",choices = list("Ecrivains de l'entre-deux guerres"=1,"Personnages publics de l'Occupation"=2),selected=1),
                                     div(style = "margin-top: -30px"),
                                     fileInput('net_file','', 
                                               accept = c(
                                                 'text/csv',
                                                 'text/comma-separated-values',
                                                 '.csv'
                                               ),buttonLabel='Importer', placeholder='une table de réseau'),
                                     div(style = "margin-top: -20px"),
                                     p("Fichier .csv produit par Gallicanet"),
                                     fileInput('target_upload', 
                                      accept = c(
                                        'text/csv',
                                        'text/comma-separated-values',
                                        '.csv'
                                      ),label = '',buttonLabel='Importer', placeholder='une liste de termes'),
                                     div(style = "margin-top: -20px"),
                                     p("Fichier .csv, UTF-8, une colonne sans titre, mots séparés par une virgule")
                                     )),
                            column(4,
                                   wellPanel(
                                     radioButtons("source", "",choices = list("Gallica-presse"=1,"CAIRN"=3),inline = T),
                                     conditionalPanel(condition="input.source == 1",div(style="display: inline-block;vertical-align:bottom;width: 45%;",numericInput("distance","Distance maximale entre les termes (en mots)",50)),
                                     div(style="display: inline-block;vertical-align:bottom;width: 45%;",numericInput("plancher_down","Nombre minimum de mentions pour chaque terme",100,step = 10)),
                                     dateRangeInput('dateRange',
                                           label = 'Période',
                                           start = as.Date.character("1918-11-11"), end = as.Date.character("1939-09-01"),
                                           separator="à", startview = "century")),
                            actionButton("do","Générer le réseau")
                            
                            ))
                            )),
                   tabPanel("Notice",shiny::includeMarkdown("Notice.md")),
                   tabPanel(title=HTML("<li><a href='https://shiny.ens-paris-saclay.fr/app/gallicagram' target='_blank'>Gallicagram")),
                   tabPanel(title=HTML("<li><a href='https://shiny.ens-paris-saclay.fr/app/gallicapresse' target='_blank'>Gallicapresse"))
))