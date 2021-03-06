##################################################
## Project: SLM
## Script purpose: Validate model fits
## Date: 2020-08-17
## Author: Daniel Smith
## Contact: dansmi@ceh.ac.uk
## Licence: MIT
##################################################

## load up the packages we will need:

library(tidyverse)
library(Hmsc)

## ---------------------------
 load("Models/Abundance_Thin300/ModelExtended.RData")
 assign('abu', get("output"))

# load("Models/AbundanceHurdle/Model.RData")
# assign('abuhur', get("output"))

# load("Models/PA/Model.RData")
# assign('pa', get("output"))

model_list = list(abu = abu)
  #abuhur = abuhur)
#pa = pa)

# -------------------------------------------------------------------------

partition = lapply(model_list, function(x) createPartition(x, nfolds = 5, column = "plot_id"))

MF = list()
MFCV = list()

for (i in seq_along(model_list)) {
  # Explanatory Power - Not Cross Validated
  preds = computePredictedValues(model_list[[i]], expected = FALSE)
  MF[[i]] = evaluateModelFit(hM = model_list[[i]], predY = preds)  
  # Predictive Power - Cross Validated
  preds = computePredictedValues(model_list[[i]], partition = partition[[i]], nParallel = 8, expected = FALSE)
  MFCV[[i]] = evaluateModelFit(hM = model_list[[i]], predY = preds)
}

# Keep only the CV outputs
rm(list=setdiff(ls(), c("MF", "MFCV")))

save.image(file = "Models/CV-AbundanceExtended.RData")
