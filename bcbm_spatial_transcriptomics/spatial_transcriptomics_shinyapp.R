library(shiny)
library(ggplot2)
library(viridis)

gene_data <- read.csv("tablebarplot_sites_epi+mali.csv")
gene_data$Cells_Broad_GB[gene_data$Cells_Broad_GB=="Neuro-Enriched"]="Brain-Enriched"
gene_data$Cells_Broad_GB=factor(gene_data$Cells_Broad_GB,levels=c("Epithelial","Malignant","Immune-Enriched","Brain-Enriched"))
#gene_data$Cells_Broad_GB=factor(gene_data$Cells_Broad_GB,levels=c("Epithelial/Malignant","Immune-Enriched","Brain-Enriched"))
website="https://stanfordmedicine.box.com/shared/static/"
#link_data=read.csv("final_gene_table.csv")


wi=12
# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background-color: black;
        color: white;
      }
      .zoom {
        border: 1px solid white;
      }
      h4 {
        color: white;
      }
      .fixed-top {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        z-index: 1000;
        background-color: black;
        color: white;
        padding: 10px;
        border-bottom: 1px solid white;
      }
      .content {
        margin-top: 250px; /* Adjust this value depending on the height of your fixed element */
      }
      .opacitySlider1 .irs-from, opacitySlider1 .irs-to, opacitySlider1 .irs-single {
        display: none; /* Hide the min, max, and current value labels */
      }
      .opacitySlider1 .irs-min, .opacitySlider1 .irs-max {
        display: none; /* Hide min and max value labels */
      }
      .bullet-point {
        display: flex;
        align-items: center;
        margin-bottom: 10px;
      }
      .bullet {
        width: 15px; /* Width of the square */
        height: 15px; /* Height of the square */
        border-radius: 2px; /* Slight rounding for a softer square */
        margin-right: 10px; /* Space between bullet and text */
      }
      .cell1 { background-color: blue; }
      .cell2 { background-color: purple; }
      .cell3 { background-color: yellow; }
      .cell4 { background-color: green; }
    ")),
  ),
  div(class = "fixed-top",
      fluidRow(
        column(2,
                 textInput(width = "150px","geneNameInput", "Enter Gene Name:", "ACADM"),
                 actionButton("submitGene", "Submit"),
               actionButton("info", "App Info")  # Button to open the popup
        ),
        column(4,plotOutput("genePlot",height="200px")),
        column(2,div(class = "bullet-point", 
                     div(class = "bullet cell1"), 
                     "DAPI+"),
               div(class = "bullet-point", 
                   div(class = "bullet cell2"), 
                   HTML("CD45+<br>(Immune-enriched)")),
               div(class = "bullet-point", 
                   div(class = "bullet cell4"), 
                   "PanCK+ (Epithelial/Malignant)"),
               div(class = "bullet-point", 
                   div(class = "bullet cell3"), 
                   "GFAP+ (Brain-enriched)")),
        column(2,sliderInput("opacitySlider1", min = 0, max = 1, value=1, step = 0.1,label = NULL,ticks=F),
               checkboxInput("showOverlay1", "Epithelial opacity", value = TRUE),
               sliderInput("opacitySlider4", min = 0, max = 1, value=1, step = 0.1,label = NULL,ticks=F),
               checkboxInput("showOverlay4", "Malignant opacity", value = TRUE)),
        column(2,sliderInput("opacitySlider2", min = 0, max = 1, value = 1, step = 0.1,label = NULL,ticks=F),
               checkboxInput("showOverlay2", "Brain-enriched opacity", value = TRUE),
               sliderInput("opacitySlider3", min = 0, max = 1, value = 1, step = 0.1,label = NULL,ticks=F),
               checkboxInput("showOverlay3", "Immune-enriched opacity", value = TRUE))
      ),
  ),
  div(class = "content",
  fluidRow(
    # Create 6 columns with headers
    column(wi,tags$h2("Primary Breast Tumor"),
    column(wi/4,
           tags$h4("TNBC"),
           div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
               uiOutput("prim_tn")
           )
    ),
    column(wi/4,
           tags$h4("HER2+"),
           div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
               uiOutput("prim_her2")
           )
    ),
    column(wi/4,
           tags$h4("ER+PR+ (Luminal A)"),
           div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
               uiOutput("prim_luma")
           )
    ),
    column(wi/4,
           tags$h4("ER+PR- (Luminal B)"),
           div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
               uiOutput("prim_lumb")
           )
    ),
    ),
    column(wi,tags$h2("Brain Metastasis"),
           column(wi/4,
                  tags$h4("TNBC"),
                  div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
                      uiOutput("brainmet_tn")
                  )
           ),
           column(wi/4,
                  tags$h4("HER2+"),
                  div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
                      uiOutput("brainmet_her2")
                  )
           ),
           column(wi/4,
                  tags$h4("ER+PR+ (Luminal A)"),
                  div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
                      uiOutput("brainmet_luma")
                  )
           ),
           column(wi/4,
                  tags$h4("ER+PR- (Luminal B)"),
                  div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
                      uiOutput("brainmet_lumb")
                  )
           ),
    ),
    column(wi,tags$h2("Control Tissue"),
           column(wi/3,
                  tags$h4("Epithelial"),
                  div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
                      uiOutput("controlepi")
                  )
           ),
           column(wi/3,
                  tags$h4("Immune-Enriched"),
                  tags$a(div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
                      uiOutput("controlimm")
                  ))
           ),
           column(wi/3,
                  tags$h4("Brain-Enriched"),
                  tags$a(div(style = "height: 300px; overflow-y: scroll; border: 1px solid white",
                      uiOutput("controlneuro")
                  ))
           )
    ),
  ) #fluidrow content
  ) #div content
) #fluidpage

# Define server logic
server <- function(input, output,session) {
  
  # Show the popup modal when the "Show Info" button is clicked
  observeEvent(input$info, {
    showModal(modalDialog(
      title = div(style="color:black;","App Information"),
      div(style = "color: black;", # Apply black text color
      "This app includes the tissue cores analyzed in:",br(),
      "Umeh-Garcia et al., Title of the paper",br(),br(),
      "To use the app, input a gene name in the input bar and click on the 'Submit' button.",br(),
      "Overlays depicting the 'Area of Illuminations' (AOI) analyzed will appear over each tissue core panel.",br(),
      "The color of the overlay indicates the expression level detected for that gene in that specific AOI.",br(),
      "The reference color bar is included on the right side of the barplot panel on top of the App page.",br(),br(),
      "The app has been developed by Giuseppe Barisano (barisano [at] stanford [dot] edu)",br(),
      "Please contact him if you encounter any issue with the app.",
      easyClose = TRUE,  # Allows closing the popup with the X button
      footer = NULL       # Optional: you can add buttons like "OK" here, or leave NULL for no footer
      )
    ))
  })
  
  link_data=read.csv("links_by_gene/ACADM.csv") #just load one in order to make the bckg work
  render_bckg <- function(c) {
    lapply(unique(link_data$core_filename[link_data$finalclass == c]), function(i) {
      background_img <- img(src = paste0(i), alt="Local Image", style = "width: 100%; position: relative; display: inline-block;")
      overlay_images <- list()
      # Combine background image and overlay images
      div(style = "position: relative; display: inline-block;", background_img, do.call(tagList, overlay_images))
    })
  }
  
  output$prim_tn <- renderUI({
    render_bckg("Primary_TNBC")
  })
  output$prim_luma <- renderUI({
    render_bckg("Primary_LumA")
  })
  output$prim_lumb <- renderUI({
    render_bckg("Primary_LumB")
  })
  output$prim_her2 <- renderUI({
    render_bckg("Primary_HER2")
  })
  output$brainmet_tn <- renderUI({
    render_bckg("Metastasis_TNBC")
  })
  output$brainmet_luma <- renderUI({
    render_bckg("Metastasis_LumA")
  })
  output$brainmet_lumb <- renderUI({
    render_bckg("Metastasis_LumB")
  })
  output$brainmet_her2 <- renderUI({
    render_bckg("Metastasis_HER2")
  })
  output$controlepi <- renderUI({
    render_bckg("Control_Epithelial")
  })
  output$controlneuro <- renderUI({
    render_bckg("Control_Neuro-Enriched")
  })
  output$controlimm <- renderUI({
    render_bckg("Control_Immune-Enriched")
  })
  
  
observeEvent(input$submitGene, {
  gene_name <- toupper(input$geneNameInput)
  
  if (!gene_name %in% unique(gene_data$gene)) {
    showNotification("Gene was not found! Try with another gene", type = "error", duration = 5)
  } else {
  link_data=read.csv(paste0("links_by_gene/",gene_name,".csv"))
  
    output$genePlot <- renderPlot({
    ggplot(gene_data[gene_data$gene==gene_name,], aes(x=Cells_Broad_GB, y=mean,color=min)) + 
      geom_bar(stat="identity", position=position_dodge(),fill="lightgray") +
      geom_errorbar(aes(ymin=mean-sem, ymax=mean+sem),color="black", width=.2,
                    position=position_dodge(.9))+
      scale_color_gradient2(low="white", high="red",
        limits=c(min(gene_data$min[gene_data$gene==gene_name]),max(gene_data$max[gene_data$gene==gene_name])))+
      theme_bw()+theme(legend.position = "right")+labs(color=gene_name,x=NULL,y="Expression")+
      facet_grid(rows=vars(Site),switch="y")
  })
  
  render_overlays <- function(c) {
    lapply(unique(link_data$core_filename[link_data$finalclass == c]), function(i) {
      #background_img <- img(src = paste0(website, i), style = "width: 100%; position: relative; display: inline-block;")
      background_img <- img(src = paste0(i), alt="Local Image", style = "width: 100%; position: relative; display: inline-block;")
      # background_img <- image_read(paste0("/tma_panels/all/",i))
      
      overlay_images <- list()
      
      if (input$showOverlay1 & length(link_data$link[link_data$core_filename == i & link_data$gene==gene_name & link_data$cell=="Epit"]>0)) {
        overlay_images <- append(overlay_images, list(
          img(src = paste0(website, link_data$link[link_data$core_filename == i & link_data$gene==gene_name & link_data$cell=="Epit"]),
              style = paste0("position: absolute; top: 0; left: 0; width: 100%; opacity: ", input$opacitySlider1, ";"))
        ))
      }
      if (input$showOverlay4 & length(link_data$link[link_data$core_filename == i & link_data$gene==gene_name & link_data$cell=="Mali"]>0)) {
        overlay_images <- append(overlay_images, list(
          img(src = paste0(website, link_data$link[link_data$core_filename == i & link_data$gene==gene_name & link_data$cell=="Mali"]),
              style = paste0("position: absolute; top: 0; left: 0; width: 100%; opacity: ", input$opacitySlider4, ";"))
        ))
      }
      if (input$showOverlay2 & length(link_data$link[link_data$core_filename == i & link_data$gene==gene_name & link_data$cell=="Neur"]>0)) {
        overlay_images <- append(overlay_images, list(
          img(src = paste0(website, link_data$link[link_data$core_filename == i & link_data$gene==gene_name & link_data$cell=="Neur"]),
              style = paste0("position: absolute; top: 0; left: 0; width: 100%; opacity: ", input$opacitySlider2, ";"))
        ))
      }
      if (input$showOverlay3 & length(link_data$link[link_data$core_filename == i & link_data$gene==gene_name & link_data$cell=="Immu"]>0)) {
        overlay_images <- append(overlay_images, list(
          img(src = paste0(website, link_data$link[link_data$core_filename == i & link_data$gene==gene_name & link_data$cell=="Immu"]),
              style = paste0("position: absolute; top: 0; left: 0; width: 100%; opacity: ", input$opacitySlider3, ";"))
        ))
      }
      
      # Combine background image and overlay images
      div(style = "position: relative; display: inline-block;", background_img, do.call(tagList, overlay_images))
    })
  }
  
  output$prim_tn <- renderUI({
    render_overlays("Primary_TNBC")
  })
  output$prim_luma <- renderUI({
    render_overlays("Primary_LumA")
  })
  output$prim_lumb <- renderUI({
    render_overlays("Primary_LumB")
  })
  output$prim_her2 <- renderUI({
    render_overlays("Primary_HER2")
  })
  output$brainmet_tn <- renderUI({
    render_overlays("Metastasis_TNBC")
  })
  output$brainmet_luma <- renderUI({
    render_overlays("Metastasis_LumA")
  })
  output$brainmet_lumb <- renderUI({
    render_overlays("Metastasis_LumB")
  })
  output$brainmet_her2 <- renderUI({
    render_overlays("Metastasis_HER2")
  })
  output$controlepi <- renderUI({
    render_overlays("Control_Epithelial")
  })
  output$controlneuro <- renderUI({
    render_overlays("Control_Neuro-Enriched")
  })
  output$controlimm <- renderUI({
    render_overlays("Control_Immune-Enriched")
  })
  
  } #if loop
}) # observe event
  
}
# Run the application 
shinyApp(ui = ui, server = server)

