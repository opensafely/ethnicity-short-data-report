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

fs::dir_create(here::here("output","ons"))

## import data
eth_ons<-read_csv(here::here("data","ethnicity_ons.csv.gz"))

df_input <- arrow::read_feather(file.path(here::here("output","data","input.feather"))) %>%
  filter(registered==1) %>%
  mutate(age_band = factor(age_band,levels=c("0-19","20-29","30-39","40-49","50-59","60-69","70-79","80+")),
       sex = case_when(sex=="F"~"Female",sex=="M"~"Male"))

eth_new_5 <- df_input %>%
  mutate(Ethnic_Group=case_when(
    ethnicity_new_5 == "1" ~ "White",
    ethnicity_new_5 == "2" ~ "Mixed",
    ethnicity_new_5 == "3" ~ "Asian",
    ethnicity_new_5 == "4" ~ "Black",
    ethnicity_new_5 == "5" ~ "Other"))  %>%
  group_by(region,Ethnic_Group) %>%
  summarise(N=n()) %>%
  ungroup %>%
  group_by(region) %>% 
  mutate(Total = sum(N),
         cohort="CTV3",
         group=5)

eth_5 <- df_input %>%
  mutate(Ethnic_Group=case_when(
    ethnicity_5 == "1" ~ "White",
    ethnicity_5 == "2" ~ "Mixed",
    ethnicity_5 == "3" ~ "Asian",
    ethnicity_5 == "4" ~ "Black",
    ethnicity_5 == "5" ~ "Other"))  %>%
  group_by(region,Ethnic_Group) %>%
  summarise(N=n()) %>%
  ungroup %>%
  group_by(region) %>% 
  mutate(Total = sum(N),
         cohort="SNOMED",
         group=5)

eth_16 <- df_input %>%
  mutate(Ethnic_Group=case_when(
    ethnicity_16 == "1" ~ "White British",
    ethnicity_16 == "2" ~ "White Irish",
    ethnicity_16 == "3" ~ "Other White",
    ethnicity_16 == "4" ~ "White and Black Caribbean",
    ethnicity_16 == "5" ~ "White and Black African",
    ethnicity_16 == "6" ~ "White and Asian",
    ethnicity_16 == "7" ~ "Other Mixed",
    ethnicity_16 == "8" ~ "Indian",
    ethnicity_16 == "9" ~ "Pakistani",
    ethnicity_16 == "10" ~ "Bangladeshi",
    ethnicity_16 == "11" ~ "Other Asian",
    ethnicity_16 == "12" ~ "Caribbean",
    ethnicity_16 == "13" ~ "African",
    ethnicity_16 == "14" ~ "Other Black",
    ethnicity_16 == "15" ~ "Chinese",
    ethnicity_16 == "16" ~ "Any other ethnic group"))  %>%
  group_by(region,Ethnic_Group) %>%
  summarise(N=n()) %>%
  ungroup %>%
  group_by(region) %>% 
  mutate(Total = sum(N),
         cohort="CTV3",
         group=16)

eth_new_16 <- df_input %>%
 mutate(Ethnic_Group=case_when(
    ethnicity_new_16 == "1" ~ "White British",
    ethnicity_new_16 == "2" ~ "White Irish",
    ethnicity_new_16 == "3" ~ "Other White",
    ethnicity_new_16 == "4" ~ "White and Black Caribbean",
    ethnicity_new_16 == "5" ~ "White and Black African",
    ethnicity_new_16 == "6" ~ "White and Asian",
    ethnicity_new_16 == "7" ~ "Other Mixed",
    ethnicity_new_16 == "8" ~ "Indian",
    ethnicity_new_16 == "9" ~ "Pakistani",
    ethnicity_new_16 == "10" ~ "Bangladeshi",
    ethnicity_new_16 == "11" ~ "Other Asian",
    ethnicity_new_16 == "12" ~ "Caribbean",
    ethnicity_new_16 == "13" ~ "African",
    ethnicity_new_16 == "14" ~ "Other Black",
    ethnicity_new_16 == "15" ~ "Chinese",
    ethnicity_new_16 == "16" ~ "Any other ethnic group"))  %>%
  group_by(region,Ethnic_Group) %>%
  summarise(N=n()) %>%
  ungroup %>%
  group_by(region) %>% 
  mutate(Total = sum(N),
         cohort="SNOMED",
         group=16)



ethnicity<-eth_16 %>%
  bind_rows(eth_5) %>%
  bind_rows(eth_new_16) %>%
  bind_rows(eth_new_5) %>%
  bind_rows(eth_ons) 

### Add England
ethnicity_unrounded <-ethnicity %>%
  group_by(group,Ethnic_Group,cohort) %>%
  summarise(N=sum(N)) %>% 
  group_by(group,cohort) %>%
  mutate(N=N,
         Total=sum(N),
         region="England") %>%
  bind_rows(ethnicity) 

ethnicity2 <- ethnicity_unrounded %>%
  ## add rounding
  mutate(N=round(N/5)*5,
         Total=round(Total/5)*5,
         percentage=N/Total * 100) 

write_csv(ethnicity2,here::here("output", "ons","ethnic_group_registered.csv")) 


#### NA removed

ethnicity_na<-ethnicity_unrounded %>%
  drop_na(Ethnic_Group) %>%
  group_by(group,cohort, region) %>%
  mutate(
    Total=sum(N),
    N=round(N/5)*5,
    Total=round(Total/5)*5,
    percentage=N/Total * 100) 

write_csv(ethnicity_na,here::here("output", "ons","ethnic_group_NA_registered.csv"))
