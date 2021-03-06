library(coda)
library(Hmsc)

nice_load <- function(file, object, rename = NULL){
  
  if (!requireNamespace("stringr", quietly = TRUE)) {
    stop("stringr needed for this function to work. Please install it.",
         call. = FALSE)
  }
  
  # assertthat::assert_that(is.character(file), "file must be a string")
  # assertthat::assert_that(is.character(object), "object must be a string")
  # assertthat::assert_that((is.character(rename) | is.null(rename)), "rename must be a string or NULL")
  
  file_string <- stringr::str_replace(file, "^.*/", "")
  file_string <- stringr::str_replace(file, "\\.RData", "")
  
  # get data frame into local environment
  e = local({load(file); environment()})
  
  # make lazy-load database
  tools:::makeLazyLoadDB(e, file_string)
  lazyLoad(file_string)
  
  # load object
  get(object)
  
  if(!is.null(rename) ){
    # create object in local env that has name matching value for object, with new name same as rename
    assign(eval(rename), get(object), envir = .GlobalEnv)
    # assign(ls()[ls() == eval(object)], rename)
    rm(e)
    # return(get(eval(quote(rename))))
  }
  else{
    rm(e)
    assign(eval(object), get(object), envir = .GlobalEnv)
  }
}


# Load --------------------------------------------------------------------

abu <- nice_load("Models/Abundance_Thin300/ModelExtended.RData", "output")
pa <- nice_load("Models/PA_Thin300//ModelExtended.RData", "output")

# List --------------------------------------------------------------------

models <- list(abu = abu, pa = pa)

filename <- file.path("Panels/PSRF_") 


for (i in seq_along(models)) {
  
  mod <- models[[i]]
  
  mpost <- convertToCodaObject(mod)
  
  pdf(paste0(filename, names(models[i]), ".pdf"))
  
  par(mfrow = c(3, 2))
  
  ess.beta = effectiveSize(mpost$Beta)
  psrf.beta = gelman.diag(mpost$Beta, multivariate = FALSE)$psrf
  hist(ess.beta)
  hist(psrf.beta)
  ess.gamma = effectiveSize(mpost$Gamma)
  psrf.gamma = gelman.diag(mpost$Gamma, multivariate = FALSE)$psrf
  hist(ess.gamma)
  hist(psrf.gamma)
  sppairs = matrix(sample(x = 1:output$ns ^ 2, size = 100))
  tmp = mpost$Omega[[1]]
  for (chain in 1:length(tmp)) {
    tmp[[chain]] = tmp[[chain]][, sppairs]
  }
  ess.omega = effectiveSize(tmp)
  psrf.omega = gelman.diag(tmp, multivariate = FALSE)$psrf
  hist(ess.omega)
  hist(psrf.omega)
  
  par(mfrow = c(1, 1))
  
  dev.off()
  
}


