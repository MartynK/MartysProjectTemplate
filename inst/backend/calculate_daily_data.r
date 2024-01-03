library(dplyr)
library(lubridate)
library(ggplot2)

dat_short <- readxl::read_excel(here::here("infla_app",
                                   "Fogyasztói_árindex_,_1990._évi_bázison.xlsx"), 
                        skip = 6) %>%
  `colnames<-`(c("time_orig","cpi"))
#View(CPI)

month.local <- data.frame( month = c("január","február",
                                     "március","április",
                                     "május","június",
                                     "július","augusztus",
                                     "szeptember","október",
                                     "november","december"))
month.local$month_num <- 1:nrow(month.local)

dat_short <- dat_short %>% 
  mutate( year = 0,
          month_hun = "")

dat_short$year <- sapply( 1:nrow(dat_short), 
                          function(x){ strsplit(dat_short$time_orig[x], ". ")[[1]][1]})
dat_short$month_hun <- sapply( 1:nrow(dat_short), 
                               function(x){ strsplit(dat_short$time_orig[x], ". ")[[1]][2]})
dat_short$month <- sapply(1:nrow(dat_short),
                          function(x){month.local$month_num[
                            month.local$month == 
                              dat_short$month_hun[x]]})

dat_short <- dat_short %>%
  mutate( time = lubridate::ymd(paste0(year,"-",month,"-",1)))

dat <- dat_short[0,]
for(i in 1:(nrow(dat_short)-1)) {
  act <- dat_short[ rep(i, lubridate::days_in_month(dat_short$month[i])), ]
  act$cpi <- seq( act$cpi[1], dat_short$cpi[i+1], length.out = nrow(act)+1)[1:nrow(act)]
  y_act <- act$year[1]
  m_act <- act$month[1]
  
  act$time <- sapply( 1:nrow(act), function(x){
    paste0(y_act,"-",m_act,"-",x)
  })
  act$time <- ymd(act$time)
  dat <- rbind( dat, act)
}

calc_yearly_infl <- function(x){
  loc_b4 <- dat$time == dat$time[x] - years(1)
  
  if( sum(loc_b4) == 1) {
    return( 
      dat$cpi[x] /
        dat$cpi[ loc_b4]
    )
  } else {
    return(NA)
  }
}

dat$infl_curr <- sapply( 1:nrow(dat), function(x){
  calc_yearly_infl(x)
})


dat_yearly <- 
  dat %>%
    group_by(year) %>%
    dplyr::filter( month == 1,
                   day(time ) == 1) %>%
    ungroup() %>%
    mutate(infl_curr = lead(infl_curr,n=1))
dat_yearly$infl_curr[nrow(dat_yearly)] <- 1.1 # HARD CODED

dat <- dat %>%
  mutate( infl_daily = lead(cpi,1)/cpi)

plot(dat$infl_daily[1:365],type = 'l')
plot(dat$infl_daily,type = 'l')


save(dat,dat_yearly,file = here::here("infla_app","backend",
                                      "calculate_daily_data.rdata"))

writexl::write_xlsx(dat, path = here::here("infla_app","backend",
                                           "calculate_daily_data.xlsx"))

