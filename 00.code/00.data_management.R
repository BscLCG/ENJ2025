library(AzureGraph) # One drive read
library(dplyr) # Collapsing and data management
library(tidyr) # Data management
library(ggplot2) #Plots
library(haven) #Loads dta files

# 00. LOADS  AND MERGES CHAPTERS -------------------------------------------------------------------

## 00.01 Loads tables ------------------------------------------------------------------------------

### Files rename -----------------------------------------------------------------------------------

# Renaming done locally, renamed files were then uploaded to google drive. The main repo loads
# all tables from the online path.

pat <- "https://docs.google.com/spreadsheets/d/%s/export?format=xlsx"
files <- openxlsx::read.xlsx(sprintf(pat, "16wl4CKW5qfN-qTNEK-UigQOIYr2ixJ69igutvGiJCt4"))

### Loads and names files into a list ----------------------------------------------------------------

#| label: function-googledrive_loader 
#| Objective: loads .dta or .csv files from google drive based on extension
#| @param pat: generic download path from google drive
#| @param x: singular file ID from 'id_cap'
#| @param name: file name from 'cap' (used to check extension)
#| @return: a data frame (Stata or CSV)

options(timeout = 3600)
pat <- "https://docs.google.com/uc?id=%s&export=download"

files_f <- function(id, name) {
  if (is.na(id) || id == "") return(NULL)
  url <- sprintf(pat, id)
  
  if (grepl("\\.csv$", name, ignore.case = TRUE)) {
    message(paste("Loading CSV:", name))
    return(read.csv(url, header = TRUE, sep = ";" ))
  } else {
    message(paste("Loading DTA:", name))
    return(haven::read_dta(url))
  }
}

cap_list <- mapply(files_f, files$id_cap, files$cap, SIMPLIFY = FALSE)

# Your original summary check
lapply(cap_list, function(x) {
  if (is.null(x)) return("Failed/Empty")
  paste0("Rows = ", nrow(x) , " / ", "Cols = ", ncol(x))
})

names(cap_list) <- files$cap

### Creates a variable list for each chapter -------------------------------------------------------
  
var_list <- data.frame(var = NA, cap = NA)

for(i in 1:length(files$cap)){
  aux <- data.frame(var = names(cap_list[[files$cap[i]]]),cap = files$cap[i] )
  var_list <- rbind(var_list, aux)
  rm(aux)
  var_list <- var_list[is.na(var_list$var) == F,]
};rm(i)

#setwd(paste0(wd,"/02.aux_tables"));list.files()
#var_lab <- openxlsx::read.xlsx('2023 04 208 - diccionario III de datos ECSC 2022.xlsx')
var_lab <- openxlsx::read.xlsx(sprintf(pat, "1S5Arq1UiexCIYFdB_Ldj768D0XFpfMBi"))

var_lab$id <- paste0(var_lab$var,var_lab$var_lab)
table(duplicated(var_lab$id))
var_lab <- var_lab[!duplicated(var_lab$id),]

table(var_list$var %in% var_lab$var);table(var_lab$var %in% var_list$var) 

var_list <- merge(var_list,var_lab, all.x = TRUE, by = 'var')

rm(files_f,var_lab,files)
openxlsx::write.xlsx(var_list,"01.var_list.xlsx")
