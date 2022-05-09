library('tidyverse')
library('sf')

fs::dir_create(here::here("codelists"))

# # import data
df_input <- read_csv(here::here("codelists","user-candrews-snomed_ethnicity_cda.csv"))
group_split<-df_input %>%
  mutate(group=ceiling(row_number()/61)) %>%
  group_split(group)

for (i in 1:11){
  list<-group_split[i][[1]] %>% select(code,term,group)
  write_csv(list,here::here("codelists",paste0("group_",i,".csv"))) 
}
