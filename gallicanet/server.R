library(shiny)
library(ggplot2)
library(plotly)
library(stringr)
library(purrr)
library(dplyr)
library(xml2)
library(markdown)
library(shinythemes)
library(htmltools)
library(httr)
library(rvest)
library(GGally)
library(network)
library(igraph)
library(ggnetwork)
library(htmlwidgets)

Plot<-function(input,tableau){
  tableau<-tableau[tableau$base2>=input$plancher,]
  tableau<-tableau[tableau$base1>=input$plancher,]
  
  table_edges<-tableau[,c(1,2,10)]
  table_edges<-table_edges[table_edges$ratio_moy>input$seuil,]
  table_edges<-table_edges[is.na(table_edges$ratio_moy)==FALSE,]
  rownames(table_edges)=NULL
  

  table_edges$color<-"autre"
  ecrivain<-input$mot
  table_edges$color[table_edges$ecrivain_1==ecrivain|table_edges$ecrivain_2==ecrivain]<-ecrivain
  table_edges$etiquette<-str_c(table_edges$ecrivain_1,"-",table_edges$ecrivain_2," - ",round(table_edges$ratio_moy,digits = 3))
  
  net <- graph.data.frame(table_edges, directed = F)
  V(net)$degree <- graph.strength(net)
  V(net)$color_v<-"autre"
  V(net)$color_n<-"autre "
  V(net)$color_v[V(net)$name==ecrivain]<-ecrivain
  V(net)$texte<-str_c(V(net)$name," - ",V(net)$degree)
  set.seed(123)
  df_net <- ggnetwork(net)
  x_end<-unique(df_net$x[df_net$name==ecrivain])
  y_end<-unique(df_net$y[df_net$name==ecrivain])
  for (i in 1:length(df_net$color_v)) {
    if(df_net$xend[i]==x_end & df_net$yend[i]==y_end){
      df_net$color_n[i]<-"reseau"
    }
  }
  
  x_end<-df_net$xend[df_net$name==ecrivain]
  y_end<-df_net$yend[df_net$name==ecrivain]
  
  for (i in 1:length(df_net$color_v)) {
    for (j in 1:length(x_end)) {
      if(df_net$x[i]==x_end[j] & df_net$y[i]==y_end[j]){
        df_net$color_n[i]<-"reseau"}
    }
  }
  for (i in 1:length(df_net$color_n)) {
    
    if(sum(str_detect(df_net$color_n[i],"reseau"))>=1){
      df_net$color_n[df_net$name==df_net$name[i]]<-"reseau"
    }
  }
  df_net$ratio_moy[is.na(df_net$ratio_moy)]<-0
  #df_net<-df_net[is.na(df_net$ratio_moy)==FALSE,]
  taille_arretes<-scale(df_net$ratio_moy[1:(length(df_net$ratio_moy)-length(unique(df_net$name)))],center=F)
  taille_arretes[which(taille_arretes>3)]<-3
  taille_noeuds<-df_net$degree[(1+length(df_net$ratio_moy)-length(unique(df_net$name))):length(df_net$ratio_moy)]

  plot=ggplot(df_net, aes(x = x, y = y, xend = xend, yend = yend, label=name)) +
    geom_edges(aes(color = color,text=etiquette), size= taille_arretes, alpha=0.2) +
    geom_nodes(aes(color = color_v,text=texte,size=degree),alpha=0.4)+scale_size(range = c(1,15))+
    geom_nodetext(aes(text=texte,color=color_n), size=3, alpha=1)+
    theme_blank(legend.title=element_blank())+guides(size=FALSE) + scale_color_manual(breaks = c("autre","autre ","reseau",ecrivain),
                                                                                      values=c("gray","black","red", "red"))
  plot2<-plot %>% ggplotly(tooltip="texte")
  xmax=max(df_net$x[df_net$color_n=="reseau"])+0.05
  xmin=min(df_net$x[df_net$color_n=="reseau"])-0.05
  ymax=max(df_net$y[df_net$color_n=="reseau"])+0.05
  ymin=min(df_net$y[df_net$color_n=="reseau"])-0.05
  
  
  plot2<-plot2%>%layout(xaxis=list(range=c(xmin,xmax)),yaxis=list(range=c(ymin,ymax)))
  return(plot2)
}
prepare_data<-function(input,liste){
  progress <- shiny::Progress$new()
  on.exit(progress$close())
  progress$set(message = "Patience...", value = 0)
  
  from<-min(input$dateRange)
  from=str_replace_all(from,"-","/")
  to<-max(input$dateRange)
  to=str_replace_all(to,"-","/")
  
  liste$requete<-str_replace_all(liste$V1,"[:punct:]","%20")
  liste$requete<-str_replace_all(liste$requete," ","%20")
  
  progress$set(message = "Patience...", value = 0)
  
  liste$base<-NA
  for (i in 1:length(liste$base)) 
  {
    url_base<-str_c("https://gallica.bnf.fr/SRU?operation=searchRetrieve&exactSearch=true&maximumRecords=1&page=1&collapsing=false&version=1.2&query=(dc.language%20all%20%22fre%22)%20and%20(text%20adj%20%22",liste$requete[i],"%22%20)%20%20and%20(dc.type%20all%20%22fascicule%22)%20and%20(ocr.quality%20all%20%22Texte%20disponible%22)%20and%20(gallicapublication_date%3E=%22",from,"%22%20and%20gallicapublication_date%3C=%22",to,"%22)&suggest=10&keywords=",liste$requete[i])  
    ngram_base<-as.character(read_xml(RETRY("GET",url_base,times = 3)))
    b<-str_extract(str_extract(ngram_base,"numberOfRecordsDecollapser&gt;+[:digit:]+"),"[:digit:]+")
    liste$base[i]<-b
    progress$inc(1/length(liste$base), message = paste("Acquisition de la base...",as.integer((i/length(liste$base))*100),"%"))
  }
  
  liste<-liste[as.integer(liste$base)>=as.integer(input$plancher_down),]
 return(liste) 
}


prepare_data_suite<-function(input,liste){
  
  progress <- shiny::Progress$new()
  on.exit(progress$close())
  progress$set(message = str_c("Liste limitée à ",length(liste$base)," termes"), value = 0)
  Sys.sleep(2)
  from<-min(input$dateRange)
  from=str_replace_all(from,"-","/")
  to<-max(input$dateRange)
  to=str_replace_all(to,"-","/")

  
  tableau_croise<-as.data.frame(matrix(nrow=length(liste[,1])^2,ncol=2),stringsAsFactors = FALSE)
  for (i in 1:length(liste[,1])) 
  {
    for (j in 1:length(liste[,1])) 
    {
      h=(i-1)*length(liste[,1])+j
      tableau_croise[h,1]<-liste[i,1]
      tableau_croise[h,2]<-liste[j,1]
      progress$inc(1/(length(liste[,1])^2), message = paste("Calcul des combinaisons...",round((h/(length(liste[,1])^2))*100,digits = 2),"%"))
      
    }
  }
  colnames(tableau_croise)<-c("ecrivain_1","ecrivain_2")
  
  tableau_croise<-tableau_croise[tableau_croise$ecrivain_1!=tableau_croise$ecrivain_2,]
  
  tableau_croise1<-tableau_croise %>%
    group_by(grp = paste(pmax(ecrivain_1, ecrivain_2), pmin(ecrivain_1, ecrivain_2), sep = "_")) %>%
    slice(1) %>%
    ungroup() %>%
    select(-grp)
  
  tableau_croise1$requete_1<-str_replace_all(tableau_croise1$ecrivain_1,"[:punct:]","%20")
  tableau_croise1$requete_2<-str_replace_all(tableau_croise1$ecrivain_2,"[:punct:]","%20")
  tableau_croise1$requete_1<-str_replace_all(tableau_croise1$requete_1," ","%20")
  tableau_croise1$requete_2<-str_replace_all(tableau_croise1$requete_2," ","%20")
  
  
  
  progress$set(message = "Patience...", value = 0)
  
  tableau_croise1$count<-NA
  for (i in 1:length(tableau_croise1$requete_1)) 
  {tryCatch({
    url_base<-str_c("https://gallica.bnf.fr/SRU?operation=searchRetrieve&exactSearch=true&maximumRecords=1&page=1&collapsing=false&version=1.2&query=(dc.language%20all%20%22fre%22)%20and%20((%20text%20adj%20%22",tableau_croise1$requete_1[i],"%22%20%20prox/unit=word/distance=",input$distance,"%20%22",tableau_croise1$requete_2[i],"%22))%20%20and%20(dc.type%20all%20%22fascicule%22)%20and%20(ocr.quality%20all%20%22Texte%20disponible%22)%20and%20(gallicapublication_date%3E=%22",from,"%22%20and%20gallicapublication_date%3C=%22",to,"%22)&suggest=10&keywords=")  
    tryCatch({ngram_base<-RETRY("GET",url_base,times = 3)})
    ngram_base<-as.character(read_xml(ngram_base))
    b<-str_extract(str_extract(ngram_base,"numberOfRecordsDecollapser&gt;+[:digit:]+"),"[:digit:]+")
    tableau_croise1$count[i]<-b
    progress$inc(1/length(tableau_croise1$requete_1), message = paste("Téléchargement en cours...",as.integer((i/length(tableau_croise1$requete_1))*100),"%"))
  })}
  tableau_croise1$base1<-NA
  tableau_croise1$base2<-NA
  for (i in 1:length(liste$base)) 
  {
    tableau_croise1$base1[liste$V1[i]==tableau_croise1$ecrivain_1]<-liste$base[i]
    tableau_croise1$base2[liste$V1[i]==tableau_croise1$ecrivain_2]<-liste$base[i]
  }
  tableau_croise1$count<-as.integer(tableau_croise1$count)
  tableau_croise1$base1<-as.integer(tableau_croise1$base1)
  tableau_croise1$base2<-as.integer(tableau_croise1$base2)
  
  tableau_croise1$ratio_1<-tableau_croise1$count/tableau_croise1$base1
  tableau_croise1$ratio_2<-tableau_croise1$count/tableau_croise1$base2
  tableau_croise1$ratio_moy<-(tableau_croise1$ratio_1+tableau_croise1$ratio_2)/2

  return(tableau_croise1)
}

options(shiny.maxRequestSize = 100*1024^2)

shinyServer(function(input, output, session){
  

  tableau<<-read.csv("exemple.csv",encoding = "UTF-8")
  output$mot<-renderUI({selectizeInput("mot","Coeur du réseau",choices=sort(unique(c(tableau$ecrivain_1,tableau$ecrivain_2))),selected="louis aragon" )})
  output$plot<-renderPlotly(Plot(input,tableau))
  
  
  output$target_upload <- reactive({
    return(!is.null(input$target_upload))
  })
  outputOptions(output, 'target_upload', suspendWhenHidden=FALSE)

  observeEvent(input$do,
               {
                 if (is.null(input$target_upload)){}
                 else{
                   inFile<-input$target_upload
                   liste<- read.csv(inFile$datapath, header = FALSE, encoding = "UTF-8")
                   liste<-prepare_data(input,liste)
                   tableau<<-prepare_data_suite(input,liste)
                 }
                 if (is.null(input$net_file)){}
                 else{
                   inFile<-input$net_file
                   tableau<<- read.csv(inFile$datapath, header = TRUE, encoding = "UTF-8")
                 }
                 updateNumericInput(session,"plancher",value = 1)
                 updateNumericInput(session,"seuil",value = 0.01)
                 mot_select<-tableau$ecrivain_1[tableau$ratio_moy>=0.01][1]
                 output$mot<-renderUI({selectizeInput("mot","Coeur du réseau",choices=sort(unique(c(tableau$ecrivain_1,tableau$ecrivain_2))),selected=mot_select )})
                 output$plot<-renderPlotly(Plot(input,tableau))
              })
  # observeEvent(input$update,
  #              {        
  #                output$plot<-renderPlotly(Plot(input,tableau))
  #               })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste('data_', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      write.csv(tableau, con, fileEncoding = "UTF-8",row.names = F)
    })
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste('plot_', Sys.Date(),'.html', sep='')
    },
    content = function(con) {
      htmlwidgets::saveWidget(as_widget(Plot(input,tableau)), con)
    })
  
  shinyOptions(progress.style="old")
  
})