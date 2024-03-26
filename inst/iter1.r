library(saemix)
library(dplyr)

saemix.data.teoph2 <- saemixData(name.data = Theoph2, header = TRUE, sep = " ", na = NA,
                          name.group = c("Id"), name.predictors = c("Time"),
                          name.response = c("Concentration"),
                          units = list(x = "hr", y = "mg/L"),
                          name.X = c("Time"))

saemix.data.glucose <- saemixData(name.data = Glucose, header = TRUE, sep = " ", na = NA,
                                 name.group = c("Subject"), name.predictors = c("Time"),
                                 name.response = c("glucose"),
                                 units = list(x = "hr", y = "mg/L"),
                                 name.X = c("Time"))

saemix.data.dapto <- daptomycin %>%
                       dplyr::filter(FORMULATION == "ORAL",
                                     TIME < 360) %>%
                       mutate(TIME = TIME - 168) %>%
                        saemixData(name.data = ., header = TRUE, sep = " ", na = NA,
                                  name.group = c("ID"), name.predictors = c("TIME"),
                                  name.response = c("COBS"),
                                  units = list(x = "hr", y = "mg/L"),
                                  name.X = c("TIME"))

model1cpt <- function(psi, id, xidep) {
  dose <- 100
  tim <- xidep[,1]
  ka <- psi[id,1]
  V <- psi[id,2]
  CL <- psi[id,3]
  k <- CL/V
  ypred <- dose * ka/(V*(ka-k)) * (exp(-k*tim) - exp(-ka*tim))
  return(ypred)
}

saemix.model <- saemixModel(model = model1cpt, error.model = "combined",
                            description = "One-compartment model with first-order absorption",
                            psi0 = matrix(c(.015, 18, .18), ncol = 3,
                                          dimnames = list(NULL, c("ka", "V", "CL"))),
                            transform.par = c(1, 1, 1))

saemix.options <- list(seed = 632545, save = TRUE,
                       save.graphs = TRUE, nb.chains = 10,
                       maxim.maxiter = 200,
                       nbiter.saemix = c(600, 600))

saemix.fit.teoph2 <- saemix(saemix.model, saemix.data.teoph2, saemix.options)

saemix.fit.glucose <- saemix(saemix.model, saemix.data.glucose, saemix.options)

saemix.fit.dapto <- saemix(saemix.model, saemix.data.dapto, saemix.options)


ACT_MOD <- "dapto"

get(paste0("saemix.fit.",ACT_MOD)) %>% plot
get(paste0("saemix.fit.",ACT_MOD)) %>% saemix.plot.fits
get(paste0("saemix.fit.",ACT_MOD)) %>% saemix.plot.randeff
get(paste0("saemix.fit.",ACT_MOD)) %>% saemix.plot.correlations



