library('tidyverse')
library('sf')

# # import data
df_input <- read_csv(here::here("codelists","opensafely-ethnicity.csv"))
group_split<-df_input %>%
  group_split(Grouping_6)

ethnicities<-c('white','mixed','asian','black','other')

for (i in 1:5){
  list<-group_split[i][[1]] %>% select(Code,Description)
  write_csv(list,here::here("codelists",paste0("ethnicity_5_",ethnicities[i],".csv"))) 
}

df_input <- read_csv(here::here("codelists","user-candrews-full_ethnicity_coded.csv"))
group_split<-df_input %>%
  group_split(Grouping_6)

for (i in 1:5){
  list<-group_split[i][[1]] %>% select(snomedcode,Ethnicity) %>% rename(Code = snomedcode)
  write_csv(list,here::here("codelists",paste0("ethnicity_new_5_",ethnicities[i],".csv"))) 
}

df_input <- read_csv(here::here("codelists","primis-covid19-vacc-uptake-eth2001.csv"))
group_split<-df_input %>%
  group_split(grouping_6_id)

for (i in 1:5){
  list<-group_split[i][[1]] %>% select(code,term) %>% rename(Code=code)
  write_csv(list,here::here("codelists",paste0("ethnicity_primis_5_",ethnicities[i],".csv"))) 
}

