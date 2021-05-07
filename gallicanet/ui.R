library(shiny)
library(ggplot2)
library(plotly)
library(stringr)
library(markdown)
library(shinythemes)
library(htmltools)

shinyUI(navbarPage("Gallicanet",
                   tabPanel("Réseau",fluidPage(
                            tags$head(),
                            plotlyOutput("plot"),
                            #downloadButton('downloadPlot', 'Télécharger le graphique interactif'),
                            
                            column(4,
                                   wellPanel(
                                     textInput("mot","Coeur du réseau","paul morand"),
                            div(style="display: inline-block;vertical-align:bottom;width: 45%;",numericInput("plancher","Nombre minimum de mentions pour chaque terme",100,step = 10)),
                            div(style="display: inline-block;vertical-align:bottom;width: 45%;",numericInput("seuil","Seuil définissant un lien entre deux termes",0.02,min = 0,max=1,step = 0.01))#,
                            #actionButton("update","Mettre à jour le graphe")
                            )),
                            column(4,
                                   wellPanel(
                                     fileInput('target_upload','', 
                                      accept = c(
                                        'text/csv',
                                        'text/comma-separated-values',
                                        '.csv'
                                      ),buttonLabel='Importer', placeholder='une liste de termes'),
                            numericInput("distance","Distance maximale entre les termes (en caractères)",50))),
                            column(4,
                                   wellPanel(
                                     dateRangeInput('dateRange',
                                           label = '\n',
                                           start = as.Date.character("1918-11-11"), end = as.Date.character("1939-09-01"),
                                           separator="à", startview = "century"),
                            actionButton("do","Générer les graphiques"),
                            downloadButton('downloadData', 'Télécharger les données')))
                            )),
                   tabPanel("Notice",shiny::includeMarkdown("Notice.md")),
                   tabPanel(title=HTML("<li><a href='https://shiny.ens-paris-saclay.fr/app/gallicagram' target='_blank'>Gallicagram")),
                   tabPanel(title=HTML("<li><a href='https://shiny.ens-paris-saclay.fr/app/gallicapresse' target='_blank'>Gallicapresse"))
))