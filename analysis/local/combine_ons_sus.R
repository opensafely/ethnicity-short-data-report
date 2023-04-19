################################################################################
# Description: Script to combine TPP & ONS data ethnicity
#
# input: /data/ethnicity_ons.csv.gz
#
# output: /output/tables/ethnic_group.csv
#
# Author: Colm D Andrews
# Date: 14/07/2022
#
################################################################################


## import libraries
library('tidyverse')
library('gtsummary')
# library('ggalluvial')

fs::dir_create(here::here("output","tests"))

## import ONS Census data
eth_ons_input_2001<-read_csv(here::here("data","ethnicity_2021_census_2001_5_categories.csv.gz"))
eth_ons_input_2021 <- read_csv(here::here("data","ethnicity_2021_census_5_categories.csv.gz"))

### Add England to ONS Census data
eth_ons <-eth_ons_input_2001 %>%
  group_by(group,Ethnic_Group,cohort) %>%
  summarise(N=sum(N)) %>% 
  group_by(group,cohort) %>%
  mutate(N=N,
         Total=sum(N),
         region="England") %>%
  bind_rows(eth_ons_input_2001) 

eth_ons_2021 <-eth_ons_input_2021 %>%
  group_by(group,Ethnic_Group,cohort) %>%
  summarise(N=sum(N)) %>% 
  group_by(group,cohort) %>%
  mutate(N=N,
         Total=sum(N),
         region="England") %>%
  bind_rows(eth_ons_input_2021) 

# get total population per region for OS data
population  <-   read_csv(here::here("output","released","simple_patient_counts_5_sus_registered.csv"),col_types =(cols())) %>%
  filter(group=="region" | group=="all" ) %>%
  summarise(subgroup=subgroup,
            population_new = ethnicity_new_5_filled,
            population_supplemented = any_filled) %>% 
  pivot_longer(contains("population"),
               names_to = c( "cohort"),
               names_pattern = "_(.*)",
               values_to = "Total"
  ) 
               
# filter OS data to regions
ethnicity <-
  read_csv(here::here("output","released","simple_patient_counts_categories_5_group_registered.csv"),col_types =(cols())) %>%
  filter(group=="region" | group=="all") %>%
  select(-population)

ethnicity_2001 <- ethnicity %>%
  # prune column headings
  rename_with(~sub("ethnicity_","",.),contains("ethnicity_")) %>%
  rename_with(~sub("_5_filled","",.),contains("_5_filled")) %>%
  # remove unused columns
  select(-contains("filled"),-contains("missing"),-contains("sus")) %>%
  pivot_longer(
    cols = c(contains("_")),
    names_to = c( "ethnicity","cohort"),
    names_pattern = "(.*)_(.*)",
    values_to = "N"
  ) %>%
  filter(cohort!="any") %>%
  inner_join(population,by=c("subgroup","cohort")) %>%
  summarise(
    region=case_when(subgroup=="with records"~"England",
                    TRUE~subgroup),
    Ethnic_Group = fct_relevel(ethnicity,
                            "Asian","Black","Mixed", "White","Other"),
    N = N,
    Total =Total,
    group = 5,
    cohort
  ) %>%
  bind_rows(eth_ons) %>%
  mutate(N=round(N/5)*5,
         Total=round(Total/5)*5,
         percentage=N/Total * 100,
         group=as.character(group),
         region = case_when(region=="East"~"East of England",
                            region=="Yorkshire and The Humber"~"Yorkshire and the Humber",
                            TRUE~region)) %>%
  filter(region!="Wales") 

write_csv(ethnicity_2001,here::here("output", "released","made_locally","ethnic_group_2021_registered_with_2001_categories.csv")) 

#### Check Sum of N against Total population (should be close with some errors from rounding)
ethnicity_2001 %>% 
  group_by(region,cohort) %>% 
  summarise(N= sum(N),percentage = sum(percentage),Total = median(Total),diff=N-Total) %>%
  print(n = 30) %>%
  write_csv(here::here("output", "tests","test_combine_sus_total.csv")) 

### 2021 amended SNOMED group
ethnicity_16 <-
  read_csv(here::here("output","released","simple_patient_counts_categories_16_group_registered.csv"),col_types =(cols())) %>%
  filter(group=="region" | group=="all") %>%
  select(-population)

ethnicity_2021 <- ethnicity_16 %>%
  # prune column headings
  rename_with(~sub("ethnicity_","",.),contains("ethnicity_")) %>%
  rename_with(~sub("_16_filled","",.),contains("_16_filled")) %>%
  # remove unused columns
  select(-contains("filled"),-contains("missing"),-contains("sus")) %>%
  pivot_longer(
    cols = c(contains("_")),
    names_to = c( "ethnicity","cohort"),
    names_pattern = "(.*)_(.*)",
    values_to = "N"
  ) %>%
  filter(cohort!="any") %>%
  inner_join(population,by=c("subgroup","cohort")) %>%
  mutate(ethnicity = gsub("_"," ",ethnicity)) %>%
  summarise(
    region=case_when(subgroup=="with records"~"England",
                     TRUE~subgroup),
    Ethnic_Group = case_when(
      (ethnicity == "White British" | ethnicity == "White Irish" | ethnicity == "Other White" |ethnicity =="English, Welsh, Scottish, Northern Irish or British"  | ethnicity == "Roma" ) ~ "White",
      (ethnicity == "White and Black Caribbean" | ethnicity == "White and Black African" | ethnicity == "White and Asian" | ethnicity == "Other Mixed or Multiple ethnic groups" | ethnicity == "Other Mixed") ~ "Mixed",
      (ethnicity == "Indian" | ethnicity == "Pakistani" | ethnicity == "Bangladeshi" | ethnicity == "Chinese" | ethnicity == "Other Asian") ~ "Asian",
      (ethnicity == "African" | ethnicity == "Caribbean" | ethnicity == "Other Black") ~ "Black",
      (ethnicity == "Any other ethnic group") ~ "Other"
    ),
    N = N,
    Total =Total,
    group = 5,
    cohort,
  ) %>%
  group_by(group,cohort,Ethnic_Group,region) %>%
  summarise(N= sum(N),
            Total = median(Total)) %>%
  bind_rows(eth_ons_2021) %>%
  mutate(N=round(N/5)*5,
         Total=round(Total/5)*5,
         percentage=N/Total * 100,
         group=as.character(group),
         region = case_when(region=="East"~"East of England",
                            region=="Yorkshire and The Humber"~"Yorkshire and the Humber",
                            TRUE~region)) %>%
  filter(region!="Wales") 

write_csv(ethnicity_2021,here::here("output", "released","made_locally","ethnic_group_2021_registered_with_2021_categories.csv")) 

#### Check Sum of N against Total population (should be close with some errors from rounding)
ethnicity_2021 %>% 
  group_by(region,cohort) %>% 
  summarise(N= sum(N),percentage = sum(percentage),Total = median(Total),diff=N-Total) %>%
  print(n = 30) %>%
  write_csv(here::here("output", "tests","test_combine_sus_2021_total.csv")) 


### Check Ethnicity 2021 vs ethnicity 2001 (should have large increase for Asian and equivalent drop for other)
ethnicity_2021 %>%
  left_join(ethnicity_2001,by = c("group","cohort","Ethnic_Group","region")) %>%
  mutate(diff = N.x - N.y) %>%
  arrange(diff) %>% 
  print(n = 150) %>%
  write_csv(here::here("output", "tests","test_combine_sus_2021_vs_2011.csv")) 

