library('tidyverse')
library('sf')

fs::dir_create(here::here("output", "tables"))

# # import data
df_input <- read_csv(here::here("codelists","opensafely-ethnicity-uk-categories.csv"))
group_split<-df_input %>%
  mutate(group=ceiling(row_number()/61)) %>%
  group_split(group)

for (i in 1:10){
  list<-group_split[i][[1]] %>% select(code,term,group)
  write_csv(list,here::here("codelists",paste0("group_",i,".csv"))) 
}
