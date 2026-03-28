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

# Loads and names files into a list ----------------------------------------------------------------

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



