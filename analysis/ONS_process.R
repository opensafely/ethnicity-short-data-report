################################################################################
# Description: Script to combine TPP & ONS data for deaths, imd, and age
################ RUN LOCALLY ###################################################
#
# input:  downloaded va Nomis:(https://www.nomisweb.co.uk/query/select/getdatasetbytheme.asp?opt=3&theme=&subgrp=)
#        data/populationbyimdenglandandwales2020.xlsx
#        data/nomis_2021_11_22_110504.xlsx
#        data/nomis_2021_11_22_104904.xlsx
#        data/nomis_2021_11_22_213653.xlsx
#
# output: /data/death_ons.csv.gz
#         /data/imd_ons.csv.gz
#         /data/age_ons_sex.csv.gz
#         /data/ethnicity_ons.csv.gz
#
# Author: Colm D Andrews
# Date: 26/11/2021
#
################################################################################

library("readxl")
library("tidyverse")


######### Ethnicity
# ONS data downloaded va Nomis:(https://www.nomisweb.co.uk/query/select/getdatasetbytheme.asp?opt=3&theme=&subgrp=)
eth_ons<-read_excel(here::here("data","nomis_2021_11_22_213653.xlsx"),skip = 8,n_max = 19) %>%
  mutate(Ethnic_Group=str_split(`Ethnic Group`, ": ", 2),
         Ethnic_Group=sapply(Ethnic_Group,"[",2),
         Ethnic_Group=case_when(
           Ethnic_Group=="English/Welsh/Scottish/Northern Irish/British"~"White British",
           Ethnic_Group=="Irish"~"White Irish",
           Ethnic_Group=="Arab"~"Any other ethnic group",
           Ethnic_Group=="Gypsy or Irish Traveller"~"Other White",
           TRUE ~ Ethnic_Group),
         Ethnic_Group5=case_when(
           (Ethnic_Group=="White British" | Ethnic_Group=="Irish" | Ethnic_Group=="Other White")~"White",
           (Ethnic_Group=="White and Black Caribbean"|Ethnic_Group=="White and Black African"|Ethnic_Group=="White and Asian"|Ethnic_Group=="Other Mixed")~"Mixed",
           (Ethnic_Group=="Indian"|Ethnic_Group=="Pakistani"|Ethnic_Group=="Bangladeshi"|Ethnic_Group=="Other Asian")~"Asian",
           (Ethnic_Group=="African"|Ethnic_Group=="Caribbean"|Ethnic_Group=="Other Black")~"Black",
           (Ethnic_Group=="Any other ethnic group"|Ethnic_Group=="Chinese")~"Other")) %>%
  select(-`Ethnic Group`) %>% filter(Ethnic_Group!="All usual residents")

eth_16_ons<-eth_ons %>%
  select(-Ethnic_Group5) %>%
  pivot_longer(!starts_with("Ethnic"), names_to = "region",values_to ="N" ) %>%
  group_by(region,Ethnic_Group) %>%
  summarise(N=sum(N)) %>%
  group_by(region) %>%
  mutate(Total=sum(N),
         percentage=N/Total*100,
         group="16_2001")

eth_5_ons<-eth_ons %>%
  select(-Ethnic_Group) %>%
  pivot_longer(!starts_with("Ethnic"), names_to = "region",values_to ="N" ) %>% 
  group_by(region,Ethnic_Group5) %>%
  summarise(N=sum(N)) %>%
  group_by(region) %>%
  mutate(Total=sum(N),
         percentage=N/Total*100,
         group="5_2001") %>%
  rename("Ethnic_Group" = "Ethnic_Group5")

eth_ons_2001 <-eth_5_ons %>%
  bind_rows(eth_16_ons) %>%
  mutate(cohort="ONS")
  
write_csv(eth_ons_2001,here::here("data","ethnicity_ons.csv.gz")) 
