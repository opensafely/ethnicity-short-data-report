library('tidyverse')
library('sf')

# # import data
df_input <- read_csv(here::here("codelists","opensafely-ethnicity.csv"))
group_split<-df_input %>%
  group_split(Grouping_6)

ethnicities<-c('white','mixed','asian','black','other')

for (i in 1:5){
  list<-group_split[i][[1]] %>% select(Code,Description)
  write_csv(list,here::here("codelists",paste0("grouped_",ethnicities[i],".csv"))) 
}

