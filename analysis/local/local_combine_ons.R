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
eth_ons_input<-read_csv(here::here("data","ethnicity_ons.csv.gz"))

### Add England
eth_ons <-eth_ons_input %>%
  group_by(group,Ethnic_Group,cohort) %>%
  summarise(N=sum(N)) %>% 
  group_by(group,cohort) %>%
  mutate(N=N,
         Total=sum(N),
         region="England") %>%
  bind_rows(eth_ons_input) 

population  <-   read_csv(here::here("output","from_jobserver","release_2022_11_18","simple_patient_counts_registered.csv"),col_types =(cols())) %>%
  filter(group=="region" | group=="all" ) %>%
  summarise(subgroup=subgroup,
            population_new = ethnicity_new_5_filled,
            population_any = any_filled) %>% 
  pivot_longer(contains("population"),
               names_to = c( "codelist"),
               names_pattern = "_(.*)",
               values_to = "Total"
  ) 
               


ethnicity <-
  read_csv(here::here("output","from_jobserver","release_2022_11_18","simple_patient_counts_categories_registered.csv"),col_types =(cols())) %>%
  filter(group=="region" | group=="all") %>%
  select(-population)


ethnicity1 <- ethnicity %>%
  rename_with(~sub("ethnicity_","",.),contains("ethnicity_")) %>%
  rename_with(~sub("_5_filled","",.),contains("_5_filled")) %>%
  select(-contains("filled"),-contains("missing"),-contains("sus")) %>%
  pivot_longer(
    cols = c(contains("_")),
    names_to = c( "ethnicity","codelist"),
    names_pattern = "(.*)_(.*)",
    values_to = "N"
  ) %>%
  left_join(population,by=c("subgroup","codelist")) %>%
  mutate(percentage = round(N / Total *100,1),
         across('ethnicity', str_replace, '_ethnicity_new_5_filled', '')
  ) %>%
  summarise(
    region=case_when(subgroup=="with records"~"England",
                    TRUE~subgroup),
    Ethnic_Group = fct_relevel(ethnicity,
                            "Asian","Black","Mixed", "White","Other"),
    N = N,
    Total =Total,
    percentage =percentage,
    group = 5,
    cohort=codelist
  ) %>%
  bind_rows(eth_ons) %>%
  mutate(N=round(N/5)*5,
         Total=round(Total/5)*5,
         percentage=N/Total * 100,
         group=as.character(group)) 



write_csv(ethnicity1,here::here("output", "from_jobserver","release_2022_11_18","made_locally","ethnic_group_registered.csv")) 

# # Refactors 5 group ethnicity to match the 2011 census groups
# ethnicity_2011 <- ethnicity1 %>%
#   filter( group == "5") %>%
#   mutate(Ethnic_Group=
#           case_when(
#             Ethnic_Group=="African"|
#             Ethnic_Group=="Caribbean"|
#             Ethnic_Group=="Other Black" ~ "Black",
#             Ethnic_Group=="Indian"|
#             Ethnic_Group=="Bangladeshi"|
#             Ethnic_Group=="Other Asian"|
#             Ethnic_Group=="Pakistani"|
#             Ethnic_Group=="Chinese" ~ "Asian",
#             Ethnic_Group=="White and Black African"|
#               Ethnic_Group=="White and Asian"|
#               Ethnic_Group=="White and Black Caribbean"|
#               Ethnic_Group=="Other Mixed" ~ "Mixed",
#             Ethnic_Group=="White British"|
#               Ethnic_Group=="White Irish"|
#               Ethnic_Group=="Other White" ~ "White",
#             Ethnic_Group=="Any other ethnic group" ~ "Other")) %>%
#     group_by(cohort,region,Ethnic_Group) %>%
#     summarise(N=sum(N),
#            Total=mean(Total),
#            group ="5",
#            percentage=round(N/Total*100,1))
# 
# 
# write_csv(ethnicity1,here::here("output", "from_jobserver","release_2022_11_18","made_locally","ethnic_group_2011_registered.csv")) 
# 
# # check new groups matches the old 5 group (Asian and Other should be the only groups wuth differences other than rounding errors)
# data_check<-ethnicity_2011 %>%
#    full_join(ethnicity1 %>% filter(group == "5")%>%mutate(percentage=round(percentage,1)),by=c("cohort","region","Ethnic_Group","group")) %>%
#   mutate(N_diff=N.x-N.y,
#          Total_diff=Total.x-Total.y,
#          perc_diff=percentage.x-percentage.y)
# 
# write_csv(data_check,here::here("output", "from_jobserver","release_2022_11_18","made_locally", "data_check.csv"))

# #### NA removed
# 
# ethnicity_na<-ethnicity_unrounded %>%
#   drop_na(Ethnic_Group) %>%
#   group_by(group,cohort, region) %>%
#   mutate(
#     Total=sum(N),
#     N=round(N/5)*5,
#     Total=round(Total/5)*5,
#     percentage=N/Total * 100) 
# 
# write_csv(ethnicity_na,here::here("output", "ons","ethnic_group_NA_registered.csv"))
# 
# # Refactors 5 group ethnicity to match the 2011 census groups 
# ethnicity_na_2011 <- ethnicity_na %>% 
#   filter( group == "16") %>%
#   mutate(Ethnic_Group=
#            case_when(
#              Ethnic_Group=="African"|
#                Ethnic_Group=="Caribbean"|
#                Ethnic_Group=="Other Black" ~ "Black",
#              Ethnic_Group=="Indian"|
#                Ethnic_Group=="Bangladeshi"|
#                Ethnic_Group=="Other Asian"|
#                Ethnic_Group=="Pakistani"|
#                Ethnic_Group=="Chinese" ~ "Asian",
#              Ethnic_Group=="White and Black African"|
#                Ethnic_Group=="White and Asian"|
#                Ethnic_Group=="White and Black Caribbean"|
#                Ethnic_Group=="Other Mixed" ~ "Mixed",
#              Ethnic_Group=="White British"|
#                Ethnic_Group=="White Irish"|
#                Ethnic_Group=="Other White" ~ "White",
#              Ethnic_Group=="Any other ethnic group" ~ "Other")) %>%
#   group_by(cohort,region,Ethnic_Group) %>%
#   summarise(N=sum(N),
#             Total=mean(Total),
#             group =5,
#             percentage=round(N/Total*100,1)) 
# 
# write_csv(ethnicity_na_2011,here::here("output", "ons","ethnic_group_2011_NA_registered.csv"))
# 
# # check new groups matches the old 5 group (Asian and Other should be the only groups wuth differences other than rounding errors)
# data_check_na<-ethnicity_na_2011 %>%
#   full_join(ethnicity_na %>% filter(group == "5")%>%mutate(percentage=round(percentage,1)),by=c("cohort","region","Ethnic_Group","group")) %>%
#   mutate(N_diff=N.x-N.y,
#          Total_diff=Total.x-Total.y,
#          perc_diff=percentage.x-percentage.y)
#   
# write.csv(data_check_na,here::here("output", "ons", "data_check_na.csv"))
# 

