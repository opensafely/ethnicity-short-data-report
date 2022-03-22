library('tidyverse')
library('sf')

files=dir(here::here("output"),pattern = "input")
print(files)
dataInp <- files %>%
  map(function(x)
    # # import data
    read_csv(here::here("output",x)) %>%
      pivot_longer(
        cols = starts_with("eth_"),
        names_to = "snomedcode",
        names_prefix = "eth_",
        values_to = "count",
        values_drop_na = TRUE
      ) %>%
      group_by(snomedcode) %>%
      summarise(snomedcode_count=sum(count))) %>%
  reduce(rbind)


files2=dir(here::here("codelists"),pattern = "group_")

data <- files2 %>%
  map(function(x)
    read_csv(here::here("codelists",x),
             col_names =c("snomedcode","term","group"),
             col_types = cols(col_character(),col_character())))  %>% 
  # combines in one tibble
  reduce(rbind) %>%
  inner_join(dataInp,by="snomedcode") %>% 
  ### remove unused codes
  filter(snomedcode_count!=0) %>%
  arrange(as.numeric(group)) 

write_csv(data,here::here("output","R_snomed_ethnicity_counts.csv"))   
