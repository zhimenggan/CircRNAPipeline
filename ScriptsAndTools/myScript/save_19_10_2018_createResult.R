

library("jsonlite")
library("optparse");
library("dplyr");


# COMANNDE : Rscript mergeScript.R --circExplorer2="./HMKMGBGXY_Sen_back_spliced_junction_withHeaders.bed" --circRNAFinder="HMKMGBGXY_Sen_filteredJunctions_withHeaders.bed" --findCirc="HMKMGBGXY_Sen_filtered_splice_circ_withHeaders.bed" --condition="Senescence" --outputPath="./Octobre2016/"


getArguments = function(){
  option_list = list(
    make_option(c("--config"), type="character", default=NULL, 
                help="config file", metavar="character"),
    make_option(c("--geneIdsList"), type="character", default=NULL,
                help="geneIdsList file", metavar="character")  
); 
  opt_parser = OptionParser(option_list=option_list);
  opt = parse_args(opt_parser);
  return(opt);
}


opt = getArguments()
if(!is.null(opt$config)){

  geneIdsList = read.table(opt$geneIdsList)

  jsonConfig = fromJSON(opt$config)
  
  dataAnalyseCirc = data.frame()
  dataAnalyseProcess = data.frame()
  dataHTSeqCount = data.frame(GeneID = as.character(geneIdsList[,1]))  

  for(SampleIndex in 1:length(jsonConfig$SAMPLE)){
      SampleName = jsonConfig$SAMPLE[SampleIndex]
      
      Sample = jsonConfig[[SampleName]]
      pathCirc = paste0(Sample$REPLICAT, "/", Sample$CONDITION_NAME, "/Global_results/", SampleName, Sample$CONDITION_NAME, "_Annotate.csv")
      pathProcess = paste0(Sample$REPLICAT, "/", Sample$CONDITION_NAME, "/Global_results/", SampleName, Sample$CONDITION_NAME, "_ProcessingInfos.csv")
      pathHTSeqCount = paste0(Sample$REPLICAT, "/", Sample$CONDITION_NAME, "/Global_results/", SampleName, Sample$CONDITION_NAME, "_htSeqCount.txt")

      # On met tout sur la forme d'un tableau
      CircPrediction = read.table(file = pathCirc, header = TRUE, sep="\t", comment.char = "")
      CircPrediction$Sample = SampleName
      CircPrediction$Condition = Sample$CONDITION_NAME
      CircPrediction$Replicat = Sample$REPLICAT
      
      ProcessInfo = read.table(file = pathProcess, header = TRUE, sep="\t")
      ProcessInfo$Sample = SampleName
      ProcessInfo$Condition = Sample$CONDITION_NAME
      ProcessInfo$Replicat = Sample$REPLICAT
      
      HTSeqCount = read.table(file = pathHTSeqCount, sep = "\t", colClasses=c("character", "numeric"))
      colnames(HTSeqCount) = c("GeneID", SampleName)

      dataAnalyseCirc = rbind(dataAnalyseCirc, CircPrediction)
      dataAnalyseProcess = rbind(dataAnalyseProcess, ProcessInfo)
      dataHTSeqCount = left_join(dataHTSeqCount, HTSeqCount, by="GeneID")


  }
  saveRDS(object = dataAnalyseCirc, file = "./dataAnalyseCirc.rds")
  saveRDS(object = dataAnalyseProcess, file = "./dataAnalyseProcess.rds")
  saveRDS(object = dataHTSeqCount, file = "./dataHTSEQcount.rds")
}

