# clear workspace variables
rm(list = ls())
cat("\014")
# close all plots
graphics.off()
#libraries
library(ggiraph)
options(java.parameters = "-Xmx64g")
library(RBioFormats)
library(readxl)
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(scattermore)
library(magick)
library(gridExtra)
library(cowplot)
library(viridis)
library(GeomxTools)
library(SpatialOmicsOverlay)
args <- commandArgs(trailingOnly = TRUE)
#tma=args[1]
tmas=strsplit(args[1]," ")[[1]]
my_vector <- strsplit(args[2], " ")[[1]]
#my_vector <- strsplit(args[1], " ")[[1]]

for (tma in tmas){
if (tma == 593){
  ometiff='/scratch/users/barisano/TMA.593.Full.Run.2.ome.tiff'
  annots='/scratch/users/barisano/TMA-593_Run1_04.14.2022_20220503T2338_LabWorksheet.txt'
  slidename='TMA.593.FullRun.2'
  coords='/scratch/users/barisano/tma593_res2_coords.csv'
  rseq=seq(100*2,(1525*4+200)*2,1525*2)
  cseq=seq(500*2,(1525*8+200)*2,1525*2)
  infobrain=data.frame(width=16193,height=26147)
} else if (tma == '595mid' ){
  annots = "/scratch/users/barisano/TA594.595.07.20.22_20220808T1944_LabWorksheet.txt"
  ometiff = "/scratch/users/barisano/TMA.595.Mid_2.ome.tiff"
  slidename = "TMA.595.Mid_2_COMPLETED"
  coords='/scratch/users/barisano/tma595mid_res2_coords.csv'
  rseq=seq(500,(1525*3)*2,1525*2)
  cseq=seq(1000,(1525*12)*2,1525*2)
  infobrain=data.frame(width=10350,height=39779)
} else if (tma == '595top'){
  annots = "/scratch/users/barisano/TA594.595.07.20.22_20220808T1944_LabWorksheet.txt"
  ometiff = "/scratch/users/barisano/TMA.595.EXT.ome.tiff" #89 GB, took ~15 minutes
  slidename = "TMA.595.Top_2_COMPLETED"
  coords='/scratch/users/barisano/tma595top_res2_coords.csv'
  rseq=seq(500,(1525*1)*2,1525*2)
  cseq=seq(400,(1525*13)*2,1525*2)
  infobrain=data.frame(width=7381,height=40960)
} else if (tma == '594mid'){
  annots = "/scratch/users/barisano/TA594.595.07.20.22_20220808T1944_LabWorksheet.txt"
  ometiff = "/scratch/users/barisano/TMA.594.Mid_2.ome.tiff" #218 GB, took ~30 minutes, requires mem 512 GB.
  slidename = "TMA.594.Mid_2_COMPLETED"
  coords='/scratch/users/barisano/tma594mid_res2_coords.csv'
  rseq=seq(500,(1525*3+200)*2,1525*2)
  cseq=seq(400,(1525*13+200)*2,1525*2)
  infobrain=data.frame(width=18543,height=40960)
} else if (tma == '594top'){
  annots = "/scratch/users/barisano/TA594.595.07.20.22_20220808T1944_LabWorksheet.txt"
  ometiff = "/scratch/users/barisano/TMA.594_Top2.ome.tiff" #144 GB, took ~20 minutes
  slidename = "TMA.594.Top_2_COMPLETED"
  coords='/scratch/users/barisano/tma594top_res2_coords.csv'
  rseq=seq(500,(1525*5)*2,1525*2)
  cseq=seq(400,(1525*13)*2,1525*2)
  infobrain=data.frame(width=15527,height=40960)
} 

muBrain <- readSpatialOverlay(ometiff = ometiff,annots= annots,slideName=slidename,
  image=F,res=2,saveFile=F,outline=F)
muBrain@coords=read.csv(coords)
#META + GENES
genemat=read.csv("/scratch/users/barisano/Q3_Data_9575.csv")
colnames(genemat)[1]="gene"
genematlong=pivot_longer(genemat,cols=-"gene",names_to ="Sample_ID",values_to = "gene_expression")
genematlong$Sample_ID=gsub("-dcc","",gsub("\\.","-",genematlong$Sample_ID))
genematwide=pivot_wider(genematlong, names_from = gene, values_from = "gene_expression")
muBrainAnnots=read_xlsx("/scratch/users/barisano/TA593.594.595_LabWorksheet.xlsx")
muBrainAnnots=merge(muBrainAnnots[!is.na(muBrainAnnots$Cells_Broad) & muBrainAnnots$Cells_Broad!="Stroma-Enriched",],genematwide) #447 total ROIs
muBrain <- addPlottingFactor(overlay = muBrain, annots = muBrainAnnots,plottingFactor = "Cells_Broad")

#DEFINE PANELS (TMA SPECIFIC)
seqfin=apply(expand.grid(rseq,cseq), 1, paste, collapse = "+")
if (tma==593){
  dfseq=data.frame(seqfin=seqfin[-c(11,16,21,26:28,31:34,36:39)])
} else if (tma!=593){ 
  dfseq=data.frame(seqfin=apply(expand.grid(rseq,cseq), 1, paste, collapse = "+"))
}
dfseq$xycat=paste0(match(sapply(strsplit(dfseq$seqfin,split="\\+"),'[',1),rseq),match(sapply(strsplit(dfseq$seqfin,split="\\+"),'[',2),cseq))
dfseq$cn=substr(dfseq$xycat,1,1) #columns are always 1-digit number
dfseq$rn=substr(dfseq$xycat,2,3) #rows go up to 13, so 2-digits
dfseq$rseq=sapply(strsplit(dfseq$seqfin,split="\\+"),'[',1)
dfseq$cseq=sapply(strsplit(dfseq$seqfin,split="\\+"),'[',2)
#change coordinates of the 3rd-5th elements and 19th
if (tma == 593){
  dfseq$seqfin[3:5]=paste0(as.numeric(sapply(strsplit(dfseq$seqfin[3:5],split="\\+"),'[',1))-100*2,"+1000")
  dfseq$seqfin[19]=paste0(as.numeric(sapply(strsplit(dfseq$seqfin[19],split="\\+"),'[',1))+100*2,"+13600")
} else if (tma == '594mid' ){
  dfseq$seqfin[3]="6000+1000"
  dfseq$seqfin[6]="6000+4350"
  dfseq$seqfin[9]="6000+7350"
  dfseq$seqfin[11]="3550+9950"
  dfseq$seqfin[12]="6000+10350"
  dfseq$seqfin[14]="2950+12600"
  dfseq$seqfin[15]="6000+13350"
  dfseq$seqfin[18]="6400+16350"
  dfseq$seqfin[21]="6400+19350"
  dfseq$seqfin[24]="6600+22350"
  dfseq$seqfin[25]="800+24100"
  dfseq$seqfin[26]="3750+24800"
  dfseq$seqfin[27]="6600+25350"
  dfseq$seqfin[28]="1000+27850"
  dfseq$seqfin[29]="3850+27850"
  dfseq$seqfin[30]="6800+28350"
  dfseq$seqfin[31]="1000+30900"
  dfseq$seqfin[32]="3850+30350"
  dfseq$seqfin[33]="6800+31350"
  dfseq$seqfin[34]="900+33550"
  dfseq$seqfin[35]="3950+33550"
  dfseq$seqfin[36]="7000+34350"
  dfseq$seqfin[37]="1400+36500"
  dfseq$seqfin[38]="4400+36500"
  dfseq$seqfin[39]="7100+37200"
  dfseq=dfseq[-c(40:42),]
} else if (tma == '594top'){
  dfseq$rseq[seq(5,65,5)]=seq(11200,12200,77)
  dfseq$rseq[seq(15,40,5)]=as.numeric(dfseq$rseq[seq(15,40,5)])+200
  dfseq$rseq[seq(9,54,5)]=as.numeric(dfseq$rseq[seq(9,54,5)])-800 #the 4th column (9) of the second to 11th rows (54) need to be moved more left (-800)
  dfseq$rseq[2]=as.numeric(dfseq$rseq[2])-600 
  dfseq$rseq[3]=as.numeric(dfseq$rseq[3])-700 
  dfseq$rseq[4]=as.numeric(dfseq$rseq[4])-900 
  dfseq$rseq[seq(8,15,5)]=as.numeric(dfseq$rseq[seq(8,15,5)])-600
  dfseq$rseq[seq(18,30,5)]=as.numeric(dfseq$rseq[seq(18,20,5)])-500
  dfseq$cseq[c(seq(1,65,5),seq(2,65,5))]=as.numeric(dfseq$cseq[c(seq(1,65,5),seq(2,65,5))])+700
  dfseq$cseq[37]=22250
  dfseq$cseq[42]=25200
  dfseq$seqfin=paste0(dfseq$rseq,"+",dfseq$cseq)
} else if (tma == '595mid'){
  dfseq$cseq[seq(7,36,3)]=as.numeric(dfseq$cseq[seq(7,36,3)])+700
  dfseq$rseq[22:36]=as.numeric(dfseq$rseq[22:36])+700
  dfseq$cseq[c(seq(29,36,3),seq(30,36,3))]=as.numeric(dfseq$cseq[c(seq(29,36,3),seq(30,36,3))])+700
  dfseq$rseq[34]=as.numeric(dfseq$rseq[34])+500
  dfseq$rseq[35]=as.numeric(dfseq$rseq[35])+500
  dfseq$seqfin=paste0(dfseq$rseq,"+",dfseq$cseq)
} else if (tma == '595top'){
  dfseq$rseq[c(12,13)]=as.numeric(dfseq$rseq[c(12,13)])-200
  dfseq$seqfin=paste0(dfseq$rseq,"+",dfseq$cseq)
}

###
dfseq$core_name=paste0("r",dfseq$rn,"c",dfseq$cn)
#infobrain=image_info(showImage(muBrain))

#LOOP ACROSS ALL THE CORES, GENES, AND CELL TYPES (Epithelial and Malignant are different)
for (s in dfseq$seqfin){
  dir.create(paste0("/scratch/users/barisano/allgenes/",tma,"/r",dfseq$rn[dfseq$seqfin==s],"c",dfseq$cn[dfseq$seqfin==s]),recursive=T)
  test=muBrain
  r=as.numeric(strsplit(s,split = "\\+")[[1]][1])
  c=as.numeric(strsplit(s,split = "\\+")[[1]][2])#+500
  sampCoords <- coords(test)[coords(test)$xcoor > r & coords(test)$xcoor < r+3000 & 
  coords(test)$ycoor < infobrain$height-c & coords(test)$ycoor > infobrain$height-c-3000,]
  #test@image$imagePointer=image_crop(showImage(muBrain),paste0("3000x3000+",s))
  #info <- image_info(showImage(test))
  info=data.frame(width=3000,height=3000)
  


#for (gene in colnames(muBrainAnnots73)[22:length(colnames(muBrainAnnots73))]){
#for (gene in c("ACADM","APOE")){
for (gene in my_vector){
  test <- addPlottingFactor(overlay = test, annots = muBrainAnnots,plottingFactor = gene)
for (cell in c(unique(muBrainAnnots$Cells_Broad[muBrainAnnots$Sample_ID %in% unique(sampCoords$sampleID)]))){
  celllabel=substr(cell,0,4)
  pts <- as.data.frame(cbind(coords(test)[coords(test)$sampleID %in% unique(sampCoords$sampleID),], 
  colorBy = plotFactors(test)[match(coords(test)$sampleID[coords(test)$sampleID %in% unique(sampCoords$sampleID)], 
      rownames(plotFactors(test))), gene],
    celltype = plotFactors(test)[match(coords(test)$sampleID[coords(test)$sampleID %in% unique(sampCoords$sampleID)], 
      rownames(plotFactors(test))), "Cells_Broad"]))
  pts$xcoor2=pts$xcoor-r
  pts$ycoor2=info$height/2-((infobrain$height-pts$ycoor-c)-info$height/2) #the coordinates for geom_scattermore need to be flipped across the horizontal axis that divides the panel in two halves. since the panel is 1500, then half of it is 750.
  ggplot(data.frame(x = 0, y = 0), aes_string("x", "y")) + geom_blank() + theme_void() + coord_fixed(expand = FALSE, xlim = c(0, info$width), ylim = c(0, info$height))+
    annotation_raster(image_blank(info$width, info$height, color = "white"),0, info$width, info$height, 0, interpolate = T)+ 
    geom_scattermore(data = pts[pts$celltype==cell,], aes(x = xcoor2, y = ycoor2,color = colorBy), alpha = 1)+
scale_color_gradient2(low="white", high="red", limits = c(min(muBrainAnnots[,gene]),max(muBrainAnnots[,gene])))+theme(legend.position = "none")
  ggsave(paste0("/scratch/users/barisano/allgenes/",tma,"/r",dfseq$rn[dfseq$seqfin==s],"c",dfseq$cn[dfseq$seqfin==s],"/",tma,"_r",dfseq$rn[dfseq$seqfin==s],"c",dfseq$cn[dfseq$seqfin==s],
    "_",gene,"_",celllabel,".png"),height = 6,width = 6,dpi=300)
}
}
}
}
