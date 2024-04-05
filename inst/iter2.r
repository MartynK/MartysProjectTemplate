# Second forray, can I "dumb down" the model to simple dt steps?
# Takes waaaaaaaaaaaay too long, abandon this route

try(source(here::here("inst","datasets.r")))

library(saemix)
library(dplyr)

saemix.data.teoph2 <- saemixData(name.data = Theoph2, header = TRUE, sep = " ", na = NA,
                          name.group = c("Id"), name.predictors = c("Time"),
                          name.response = c("Concentration"),
                          units = list(x = "hr", y = "mg/L"),
                          name.X = c("Time"))

step_t <- function(k_a, k_e, q_gi, q_plas, dt=.1 ) {

  absorbed  <- k_a * q_gi
  q_gi_end  <- q_gi - absorbed
  q_plas    <- q_plas + absorbed
  elimmed   <- k_e * q_plas
  q_plas_end <- q_plas - elimmed
  return( list( absorbed = absorbed,
                q_gi_end = q_gi_end,
                elimmed = elimmed,
                q_plas_end = q_plas_end))
}

# Mucking with ode

model_for_ode <- function(time, state, parameters) {

  # Unpack state variables and parameters
  q_gi      <- state[1]
  q_plas    <- state[2]

  k_a  <- parameters$par_ka
  k_e  <- parameters$par_ke
  #par_3  <- parameters$par_3  # not used at present

  # Define the system of ODEs
  absorbed  <- k_a * q_gi
  #q_gi_end  <- q_gi - absorbed    # added for clarity
  q_plas    <- q_plas + absorbed
  elimmed   <- k_e * q_plas
  #q_plas_end <- q_plas - elimmed  # added for clarity

  # Define the dt differences
  dt_gi   <- - absorbed
  dt_plas <- absorbed - elimmed

  # Return the derivatives as a list
  return(list(c(dt_gi,dt_plas)))
}



sim_a_profile <- function( K_A.,K_E.,q_gi0 = 100, timez) {

  profil <- expand.grid(t = timez,
                        absorbed = NA,
                        q_plas = NA,
                        q_gi = NA
  )

  profil$absorbed[1] <- 0
  profil$q_plas[1]   <- 0
  profil$q_gi[1]     <- q_gi0

  for (i in 2:nrow(profil)) {
    act_list <- step_t(K_A.,K_E.,profil$q_gi[i-1],profil$q_plas[i-1],dt=.1)
    profil$q_plas[i] <- act_list[["q_plas_end"]]
    profil$q_gi[i]   <- act_list[["q_gi_end"]]
  }

  return( profil)

}

model1cpt_classic <- function(psi, id, xidep) {
  dose <- 100
  tim <- xidep[,1]
  ka <- psi[id,1]
  V <- psi[id,2]
  CL <- psi[id,3]
  k <- CL/V
  ypred <- dose * ka/(V*(ka-k)) * (exp(-k*tim) - exp(-ka*tim))
  return(ypred)
}

model1cpt_step <- function(psi, id, xidep) {
  dose <- 100
  tim <- xidep[,1]
  ka <- psi[id,1]
  V <- psi[id,2]
  CL <- psi[id,3]
  k <- CL/V
  ypred <- rep(NA, length(tim))

  for( i in 1:length(tim)) {
    ypred[i] <- sim_a_profile(ka[i],k[i],dose,seq(0,tim[i],length.out=100))$q_plas[100]
  }


  return(ypred)
}

model1cpt_ode <- function(psi, id, xidep) {
  dose <- 100
  tim <- xidep[,1]
  ka <- psi[id,1]
  V <- psi[id,2]
  CL <- psi[id,3]
  k <- CL/V
  ypred <- rep(NA, length(tim))

  for( i in 1:length(tim)) {

    initial_conditions <- c(q_gi  = dose,
                            q_plas = 0)

    parameters <- list(par_ka = ka[i],
                       par_ke = k[i])

    result <- deSolve::ode(y = initial_conditions,
                           times = c(0,tim[i]),
                           func = model_for_ode,
                           parms = parameters,
                           method = "adams",
                           rtol = 1e-02, # default 1e-6, but perf.increase and good enough
                           atol = 1e-02, # default 1e-6, but perf.increase and good enough
                           #hmin = 1e-02,
                           hmax = 1e-02)


    ypred[i] <- result[2,3]
  }


  return(ypred)
}


saemix.model <- saemixModel(model = model1cpt_ode, error.model = "combined",
                            description = "One-compartment model with first-order absorption",
                            psi0 = matrix(c(.015, 18, .18), ncol = 3,
                                          dimnames = list(NULL, c("ka", "V", "CL"))),
                            transform.par = c(1, 1, 1))

saemix.options <- list(seed = 632545, save = TRUE,
                       save.graphs = TRUE, nb.chains = 10,
                       maxim.maxiter = 200,
                       nbiter.saemix = c(600, 600))


## Model fitting, ~90secs per model, commented out the two alternates
saemix.fit.teoph2 <- saemix(saemix.model, saemix.data.teoph2, saemix.options)



# Choosing a mod to plot out for further investigation
ACT_MOD <- "dapto"

get(paste0("saemix.fit.",ACT_MOD)) %>% plot
get(paste0("saemix.fit.",ACT_MOD)) %>% saemix.plot.fits
get(paste0("saemix.fit.",ACT_MOD)) %>% saemix.plot.randeff
get(paste0("saemix.fit.",ACT_MOD)) %>% saemix.plot.correlations



