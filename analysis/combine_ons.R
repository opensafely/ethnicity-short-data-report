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
         cohort="SNOMED",
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
         cohort="CTV3",
         group=5)


eth_primis_5 <- df_input %>%
  mutate(Ethnic_Group=case_when(
    ethnicity_primis_5 == "1" ~ "White",
    ethnicity_primis_5 == "2" ~ "Mixed",
    ethnicity_primis_5 == "3" ~ "Asian",
    ethnicity_primis_5 == "4" ~ "Black",
    ethnicity_primis_5 == "5" ~ "Other"))  %>%
  group_by(region,Ethnic_Group) %>%
  summarise(N=n()) %>%
  ungroup %>%
  group_by(region) %>% 
  mutate(Total = sum(N),
         cohort="PRIMIS",
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

eth_primis_16 <- df_input %>%
  mutate(Ethnic_Group=case_when(
    ethnicity_primis_16 == "1" ~ "White British",
    ethnicity_primis_16 == "2" ~ "White Irish",
    ethnicity_primis_16 == "3" ~ "Other White",
    ethnicity_primis_16 == "4" ~ "White and Black Caribbean",
    ethnicity_primis_16 == "5" ~ "White and Black African",
    ethnicity_primis_16 == "6" ~ "White and Asian",
    ethnicity_primis_16 == "7" ~ "Other Mixed",
    ethnicity_primis_16 == "8" ~ "Indian",
    ethnicity_primis_16 == "9" ~ "Pakistani",
    ethnicity_primis_16 == "10" ~ "Bangladeshi",
    ethnicity_primis_16 == "11" ~ "Other Asian",
    ethnicity_primis_16 == "12" ~ "Caribbean",
    ethnicity_primis_16 == "13" ~ "African",
    ethnicity_primis_16 == "14" ~ "Other Black",
    ethnicity_primis_16 == "15" ~ "Chinese",
    ethnicity_primis_16 == "16" ~ "Any other ethnic group"))  %>%
  group_by(region,Ethnic_Group) %>%
  summarise(N=n()) %>%
  ungroup %>%
  group_by(region) %>% 
  mutate(Total = sum(N),
         cohort="PRIMIS",
         group=16)


ethnicity<-eth_16 %>%
  bind_rows(eth_5) %>%
  bind_rows(eth_new_16) %>%
  bind_rows(eth_new_5) %>%
  bind_rows(eth_primis_5) %>%
  bind_rows(eth_primis_16) %>%
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

# Refactors 5 group ethnicity to match the 2011 census groups
ethnicity_2011 <- ethnicity2 %>%
  filter( group == "16") %>%
  mutate(Ethnic_Group=
          case_when(
            Ethnic_Group=="African"|
            Ethnic_Group=="Caribbean"|
            Ethnic_Group=="Other Black" ~ "Black",
            Ethnic_Group=="Indian"|
            Ethnic_Group=="Bangladeshi"|
            Ethnic_Group=="Other Asian"|
            Ethnic_Group=="Pakistani"|
            Ethnic_Group=="Chinese" ~ "Asian",
            Ethnic_Group=="White and Black African"|
              Ethnic_Group=="White and Asian"|
              Ethnic_Group=="White and Black Caribbean"|
              Ethnic_Group=="Other Mixed" ~ "Mixed",
            Ethnic_Group=="White British"|
              Ethnic_Group=="White Irish"|
              Ethnic_Group=="Other White" ~ "White",
            Ethnic_Group=="Any other ethnic group" ~ "Other")) %>%
    group_by(cohort,region,Ethnic_Group) %>%
    summarise(N=sum(N),
           Total=mean(Total),
           group =5,
           percentage=round(N/Total*100,1))


write_csv(ethnicity_2011,here::here("output", "ons","ethnic_group_2011_registered.csv")) 

# check new groups matches the old 5 group (Asian and Other should be the only groups wuth differences other than rounding errors)
data_check<-ethnicity_2011 %>%
   full_join(ethnicity2 %>% filter(group == "5")%>%mutate(percentage=round(percentage,1)),by=c("cohort","region","Ethnic_Group","group")) %>%
  mutate(N_diff=N.x-N.y,
         Total_diff=Total.x-Total.y,
         perc_diff=percentage.x-percentage.y)

write.csv(data_check,here::here("output", "ons", "data_check.csv"))

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

# Refactors 5 group ethnicity to match the 2011 census groups 
ethnicity_na_2011 <- ethnicity_na %>% 
  filter( group == "16") %>%
  mutate(Ethnic_Group=
           case_when(
             Ethnic_Group=="African"|
               Ethnic_Group=="Caribbean"|
               Ethnic_Group=="Other Black" ~ "Black",
             Ethnic_Group=="Indian"|
               Ethnic_Group=="Bangladeshi"|
               Ethnic_Group=="Other Asian"|
               Ethnic_Group=="Pakistani"|
               Ethnic_Group=="Chinese" ~ "Asian",
             Ethnic_Group=="White and Black African"|
               Ethnic_Group=="White and Asian"|
               Ethnic_Group=="White and Black Caribbean"|
               Ethnic_Group=="Other Mixed" ~ "Mixed",
             Ethnic_Group=="White British"|
               Ethnic_Group=="White Irish"|
               Ethnic_Group=="Other White" ~ "White",
             Ethnic_Group=="Any other ethnic group" ~ "Other")) %>%
  group_by(cohort,region,Ethnic_Group) %>%
  summarise(N=sum(N),
            Total=mean(Total),
            group =5,
            percentage=round(N/Total*100,1)) 

write_csv(ethnicity_na,here::here("output", "ons","ethnic_group_2011_NA_registered.csv"))

# check new groups matches the old 5 group (Asian and Other should be the only groups wuth differences other than rounding errors)
data_check_na<-ethnicity_na_2011 %>%
  full_join(ethnicity_na %>% filter(group == "5")%>%mutate(percentage=round(percentage,1)),by=c("cohort","region","Ethnic_Group","group")) %>%
  mutate(N_diff=N.x-N.y,
         Total_diff=Total.x-Total.y,
         perc_diff=percentage.x-percentage.y) %>%
  write.csv(here::here("output", "ons", "data_check_na.csv"))


