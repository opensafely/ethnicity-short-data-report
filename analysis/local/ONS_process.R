################################################################################
# Description: Script to combine TPP & ONS data for deaths, imd, and age
################ RUN LOCALLY ###################################################
#
# input:  downloaded va Nomis:(https://www.nomisweb.co.uk/query/select/getdatasetbytheme.asp?opt=3&theme=&subgrp=)
#        data/nomis_2021_11_22_213653.xlsx
#
# output: /data/ethnicity_ons.csv.gz
#
# Author: Colm D Andrews
# Date: 14/07/2022
#
################################################################################

library("readxl")
library("tidyverse")
library("ggsci")


######### Ethnicity 2021
# ONS data downloaded va Nomis:(https://www.nomisweb.co.uk/query/select/getdatasetbytheme.asp?opt=3&theme=&subgrp=)
eth_ons_2021 <- read_excel(here::here("data", "nomis_2022_12_01_124621.xlsx"), skip = 7, n_max = 21) %>%
  mutate(
    Ethnic_Group = str_split(`Ethnic group`, ": ", 2),
    Ethnic_Group = sapply(Ethnic_Group, "[", 2),
    Ethnic_Group = case_when(
      Ethnic_Group == "English/Welsh/Scottish/Northern Irish/British" ~ "White British",
      Ethnic_Group == "Irish" ~ "White Irish",
      Ethnic_Group == "Arab" ~ "Any other ethnic group",
      Ethnic_Group == "Gypsy or Irish Traveller" ~ "Other White",
      TRUE ~ Ethnic_Group
    ),
    Ethnic_Group5 = case_when(
      (Ethnic_Group == "White British" | Ethnic_Group == "White Irish" | Ethnic_Group == "Other White" |Ethnic_Group =="English, Welsh, Scottish, Northern Irish or British"  | Ethnic_Group == "Roma" ) ~ "White",
      (Ethnic_Group == "White and Black Caribbean" | Ethnic_Group == "White and Black African" | Ethnic_Group == "White and Asian" | Ethnic_Group == "Other Mixed or Multiple ethnic groups") ~ "Mixed",
      (Ethnic_Group == "Indian" | Ethnic_Group == "Pakistani" | Ethnic_Group == "Bangladeshi" | Ethnic_Group == "Other Asian") ~ "Asian",
      (Ethnic_Group == "African" | Ethnic_Group == "Caribbean" | Ethnic_Group == "Other Black") ~ "Black",
      (Ethnic_Group == "Any other ethnic group" | Ethnic_Group == "Chinese" | Ethnic_Group == "Other Mixed or Multiple ethnic groups") ~ "Other"
    )
  ) %>%
  select(-`Ethnic group`,
         -Wales) %>%
  filter(Ethnic_Group != "All usual residents")

eth_16_ons_2021_2001 <- eth_ons_2021 %>%
  select(-Ethnic_Group5) %>%
  pivot_longer(!starts_with("Ethnic"), names_to = "region", values_to = "N") %>%
  group_by(region, Ethnic_Group) %>%
  summarise(N = sum(N)) %>%
  group_by(region) %>%
  mutate(
    Total = sum(N),
    percentage = N / Total * 100,
    group = "16"
  )

eth_ons_2021_16_2011 <- eth_16_ons_2021_2001 %>%
  # bind_rows(eth_5_ons_2021) %>%
  mutate(cohort = "ONS") %>%
  write_csv( here::here("data", "ethnicity_2021_census_2001_16_categories.csv.gz"))


eth_5_ons_2021_2001 <- eth_ons_2021 %>%
  select(-Ethnic_Group) %>%
  pivot_longer(!starts_with("Ethnic"), names_to = "region", values_to = "N") %>%
  group_by(region, Ethnic_Group5) %>%
  summarise(N = sum(N)) %>%
  group_by(region) %>%
  mutate(
    Total = sum(N),
    percentage = N / Total * 100,
    group = "5"
  ) %>%
  rename("Ethnic_Group" = "Ethnic_Group5")

eth_ons_2021_2001 <- eth_5_ons_2021_2001 %>%
  # bind_rows(eth_5_ons_2021) %>%
  mutate(cohort = "ONS") %>%
  write_csv( here::here("data", "ethnicity_2021_census_2001_5_categories.csv.gz"))


# ### 2021 ONS with 2011 categories
# ONS data downloaded va Nomis:(https://www.nomisweb.co.uk/query/select/getdatasetbytheme.asp?opt=3&theme=&subgrp=)
eth_ons_2021 <- read_excel(here::here("data", "nomis_2022_12_01_124621.xlsx"), skip = 7, n_max = 21) %>%
  mutate(
    Ethnic_Group = str_split(`Ethnic group`, ": ", 2),
    Ethnic_Group = sapply(Ethnic_Group, "[", 2),
    Ethnic_Group = case_when(
      Ethnic_Group == "English/Welsh/Scottish/Northern Irish/British" ~ "White British",
      Ethnic_Group == "Irish" ~ "White Irish",
      Ethnic_Group == "Arab" ~ "Any other ethnic group",
      Ethnic_Group == "Gypsy or Irish Traveller" ~ "Other White",
      TRUE ~ Ethnic_Group
    ),
    Ethnic_Group5 = case_when(
      (Ethnic_Group == "White British" | Ethnic_Group == "White Irish" | Ethnic_Group == "Other White" |Ethnic_Group =="English, Welsh, Scottish, Northern Irish or British"  | Ethnic_Group == "Roma" ) ~ "White",
      (Ethnic_Group == "White and Black Caribbean" | Ethnic_Group == "White and Black African" | Ethnic_Group == "White and Asian" | Ethnic_Group == "Other Mixed or Multiple ethnic groups") ~ "Mixed",
      (Ethnic_Group == "Indian" | Ethnic_Group == "Pakistani" | Ethnic_Group == "Bangladeshi" | Ethnic_Group == "Chinese" | Ethnic_Group == "Other Asian") ~ "Asian",
      (Ethnic_Group == "African" | Ethnic_Group == "Caribbean" | Ethnic_Group == "Other Black") ~ "Black",
      (Ethnic_Group == "Any other ethnic group" | Ethnic_Group == "Other Mixed or Multiple ethnic groups") ~ "Other"
    )
  ) %>%
  select(-`Ethnic group`,
         -Wales) %>%
  filter(Ethnic_Group != "All usual residents")

eth_16_ons_2021 <- eth_ons_2021 %>%
  select(-Ethnic_Group5) %>%
  pivot_longer(!starts_with("Ethnic"), names_to = "region", values_to = "N") %>%
  group_by(region, Ethnic_Group) %>%
  summarise(N = sum(N)) %>%
  group_by(region) %>%
  mutate(
    Total = sum(N),
    percentage = N / Total * 100,
    group = "16"
  )

eth_ons_2021_16 <- eth_16_ons_2021 %>%
  # bind_rows(eth_5_ons_2021) %>%
  mutate(cohort = "ONS") %>%
  write_csv( here::here("data", "ethnicity_2021_census_16_categories.csv.gz"))

eth_5_ons_2021 <- eth_ons_2021 %>%
  select(-Ethnic_Group) %>%
  pivot_longer(!starts_with("Ethnic"), names_to = "region", values_to = "N") %>%
  group_by(region, Ethnic_Group5) %>%
  summarise(N = sum(N)) %>%
  group_by(region) %>%
  mutate(
    Total = sum(N),
    percentage = N / Total * 100,
    group = "5"
  ) %>%
  rename("Ethnic_Group" = "Ethnic_Group5")

eth_ons_2021_5 <- eth_5_ons_2021 %>%
  # bind_rows(eth_5_ons_2021) %>%
  mutate(cohort = "ONS") %>%
  write_csv( here::here("data", "ethnicity_2021_census_5_categories.csv.gz"))
