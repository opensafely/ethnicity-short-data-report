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

df_input <- read_csv(here::here("codelists","user-candrews-full_ethnicity_coded.csv")) %>%
  filter(Grouping_6!=0)
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

### group 16
df_input <- read_csv(here::here("codelists","opensafely-ethnicity.csv"))
group_split<-df_input %>%
  group_split(Grouping_16)

ethnicities_16<-c('White_British','White_Irish','Other_White','White_and_Black_Caribbean','White_and_Black_African','White_and_Asian','Other_Mixed','Indian','Pakistani','Bangladeshi','Other_Asian','Caribbean','African','Other_Black','Chinese','Any_other_ethnic_group')

for (i in 1:16){
  list<-group_split[i][[1]] %>% select(Code,Description)
  write_csv(list,here::here("codelists",paste0("ethnicity_16_",ethnicities_16[i],".csv"))) 
}

df_input <- read_csv(here::here("codelists","user-candrews-full_ethnicity_coded.csv")) %>%
  filter(Grouping_16!=0)

group_split<-df_input %>%
  group_split(Grouping_16)

for (i in 1:16){
  list<-group_split[i][[1]] %>% select(snomedcode,Ethnicity) %>% rename(Code = snomedcode)
  write_csv(list,here::here("codelists",paste0("ethnicity_new_16_",ethnicities_16[i],".csv"))) 
}

df_input <- read_csv(here::here("codelists","primis-covid19-vacc-uptake-eth2001.csv"))
group_split<-df_input %>%
  group_split(grouping_16_id)

for (i in 1:16){
  list<-group_split[i][[1]] %>% select(code,term) %>% rename(Code=code)
  write_csv(list,here::here("codelists",paste0("ethnicity_primis_16_",ethnicities_16[i],".csv"))) 
}