library('tidyverse')
library('sf')

fs::dir_create(here::here("codelists"))

# # import data
df_input <- read_csv(here::here("codelists","opensafely-ethnicity-snomed-0removed.csv"))
group_split<-df_input %>%
  mutate(group=ceiling(row_number()/60)) %>%
  group_split(group)

for (i in 1:10){
  list<-group_split[i][[1]] %>% select(snomedcode,Ethnicity,group)
  write_csv(list,here::here("codelists",paste0("group_",i,".csv"))) 
}
