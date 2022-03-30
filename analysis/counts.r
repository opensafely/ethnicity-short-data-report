################################################################################
# Description: Script to combine TPP & ONS data for deaths, imd, and age
#
# input: /output/cohorts/input.csv.gz
#        /data/imd_ons.csv.gz
#        /data/age_ons_sex.csv.gz
#        /data/ethnicity_ons.csv.gz
#
# output: /output/tables/age_sex_count.csv.gz
#         /output/tables/age_count.csv.gz
#         /output/tables/imd_count.csv.gz
#         /output/tables/ethnic_group.csv
#
# Author: Colm D Andrews
# Date: 31/01/2022
#
################################################################################


## import libraries
library('tidyverse')
library('gtsummary')

fs::dir_create(here::here("output","tables"))

# # import data
df_input <- arrow::read_feather(file.path(here::here("output","data","input.feather"))) %>%
mutate(age_band = factor(age_band,levels=c("0-19","20-29","30-39","40-49","50-59","60-69","70-79","80+")),
       sex = case_when(sex=="F"~"Female",sex=="M"~"Male"),
       ethnicity_snomed_5=case_when(
         ethnicity_snomed_5 == "1" ~ "White",
         ethnicity_snomed_5 == "2" ~ "Mixed",
         ethnicity_snomed_5 == "3" ~ "Asian",
         ethnicity_snomed_5 == "4" ~ "Black",
         ethnicity_snomed_5 == "5" ~ "Other"),
       ethnicity_5=case_when(
         ethnicity_5 == "1" ~ "White",
         ethnicity_5 == "2" ~ "Mixed",
         ethnicity_5 == "3" ~ "Asian",
         ethnicity_5 == "4" ~ "Black",
         ethnicity_5 == "5" ~ "Other"))
  
  definitions <- c("ctv3_yn","snomed_yn")
  demographic_covariates <- c('age_band', 'sex', 'region', 'imd')
  clinical_covariates <-  c('dementia', 'diabetes', 'hypertension', 'learning_disability')
  
  
set_table <- function (name,input,variable,heading){ DF <- input %>%
                                               select(c(all_of(variable),all_of(demographic_covariates),all_of(clinical_covariates))) %>%
                                               tbl_summary(by= variable,
                                                           label = list(age_band ~ "Patient Age", dementia ~ "Dementia",imd ~ "IMD")) %>%
                                               modify_header(all_stat_cols() ~ "**{level}** N =<br>{n} ({style_percent(p)}%)") %>%
                                               bold_labels() %>%
                                               modify_spanning_header(all_stat_cols() ~ heading)

saveRDS(DF, here::here("output", "tables",paste0(name,".rds")))
assign(name,DF,envir = .GlobalEnv)
}                                             
  
full_table<-df_input %>%
  mutate(ctv3_yn = ifelse(is.na(ethnicity_5), "missing", "has value"),
         snomed_yn = ifelse(is.na(ethnicity_snomed_5), "missing", "has value"),
         missing = case_when(ctv3_yn =="missing" & snomed_yn=="missing" ~ "Both",
                             ctv3_yn =="missing" ~ "CTV3",
                             snomed_yn=="missing" ~ "SNOMED",
                             T~"Neither"),
         missing = factor(missing,levels =c("Both","CTV3","SNOMED","Neither") )) %>%
  mutate_at(clinical_covariates, function (x)(ifelse(x==FALSE,"False","True")))


set_table("full_missing",full_table,"snomed_yn","**Missing Ethnicity**")                                               
set_table("full_missing_compare",full_table,"missing","**Missing Ethnicity**")                                               
set_table("full_SNOMED",full_table,"ethnicity_snomed_5","**SNOMED Ethnicity**")                                               
set_table("full_CTV3",full_table,"ethnicity_5","**CTV3 Ethnicity**")                                               

  #### combined SNOMED and CTV3
theme_gtsummary_compact()
ethnicity_compare<-tbl_merge( list(full_SNOMED,full_CTV3),
                   tab_spanner = c("**SNOMED**", "**CTV3**"))
saveRDS(ethnicity_compare, here::here("output", "tables","full_ethnicity_compare.rds"))



##### Registered only
reg_table<-full_table %>%
  filter(registered==T)
set_table("reg_missing",reg_table,"snomed_yn","**Missing Ethnicity**")                                               
set_table("reg_missing_compare",reg_table,"missing","**Missing Ethnicity**")                                               
set_table("reg_SNOMED",reg_table,"ethnicity_snomed_5","**SNOMED Ethnicity**")                                               
set_table("reg_CTV3",reg_table,"ethnicity_5","**CTV3 Ethnicity**")                                               

#### combined SNOMED and CTV3
theme_gtsummary_compact()
ethnicity_compare<-tbl_merge( list(reg_SNOMED,reg_CTV3),
                              tab_spanner = c("**SNOMED**", "**CTV3**"))
saveRDS(ethnicity_compare, here::here("output", "tables","reg_ethnicity_compare.rds"))


#  ################ Ethnicity
# 
# eth_tpp <- df_input %>%
#   mutate(Ethnic_Group=case_when(
#     ethnicity_5 == "1" ~ "White",
#     ethnicity_5 == "2" ~ "Mixed",
#     ethnicity_5 == "3" ~ "Asian",
#     ethnicity_5 == "4" ~ "Black",
#     ethnicity_5 == "5" ~ "Other",))  %>%
#   group_by(region,Ethnic_Group) %>%
#   summarise(N=n()) %>%
#   ungroup %>%
#   group_by(region) %>% 
#   mutate(Total = sum(N),
#          cohort="CTV3",
#          group="5_2001")
# 
# 
# eth_tpp_16 <- df_input %>%
#   mutate(Ethnic_Group=case_when(
#     ethnicity_16 == "1" ~ "White British",
#     ethnicity_16 == "2" ~ "White Irish",
#     ethnicity_16 == "3" ~ "Other White",
#     ethnicity_16 == "4" ~ "White and Black Caribbean",
#     ethnicity_16 == "5" ~ "White and Black African",
#     ethnicity_16 == "6" ~ "White and Asian",
#     ethnicity_16 == "7" ~ "Other Mixed",
#     ethnicity_16 == "8" ~ "Indian",
#     ethnicity_16 == "9" ~ "Pakistani",
#     ethnicity_16 == "10" ~ "Bangladeshi",
#     ethnicity_16 == "11" ~ "Other Asian",
#     ethnicity_16 == "12" ~ "Caribbean",
#     ethnicity_16 == "13" ~ "African",
#     ethnicity_16 == "14" ~ "Other Black",
#     ethnicity_16 == "15" ~ "Chinese",
#     ethnicity_16 == "16" ~ "Any other ethnic group"))  %>%
#   group_by(region,Ethnic_Group) %>%
#   summarise(N=n()) %>%
#   ungroup %>%
#   group_by(region) %>% 
#   mutate(Total = sum(N),
#          cohort="TPP",
#          group="16_2001")
# 
# ethnicity<-eth_tpp_16 %>%
#   bind_rows(eth_tpp) %>%
#   bind_rows(eth_ons) 
# ### Add England
# ethnicity_unrounded <-ethnicity %>%
#   group_by(group,Ethnic_Group,cohort) %>%
#   summarise(N=sum(N)) %>% 
#   group_by(group,cohort) %>%
#   mutate(N=N,
#          Total=sum(N),
#          region="England") %>%
#   bind_rows(ethnicity) 
#   
#   ethnicity2 <- ethnicity_unrounded %>%
#     ## add rounding
#   mutate(N=round(N/5)*5,
#          Total=round(Total/5)*5,
#          percentage=N/Total * 100) 
# 
# write_csv(ethnicity2,here::here("output", "tables","ethnic_group.csv"))
# 
# 
# #### NA removed
# 
# ethnicity_na<-ethnicity_unrounded %>%
#   drop_na(Ethnic_Group) %>%
#   group_by(group,cohort, region) %>%
#   mutate(
#          Total=sum(N),
#          N=round(N/5)*5,
#          Total=round(Total/5)*5,
#          percentage=N/Total * 100) 
# 
# write_csv(ethnicity_na,here::here("output", "tables","ethnic_group_NA.csv"))
