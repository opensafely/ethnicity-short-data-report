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
library('ggalluvial')

fs::dir_create(here::here("output","tables"))
fs::dir_create(here::here("output","plots"))
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
  
matches<-df_input %>% 
  gather(common, cnt, ends_with("count")) %>% 
  group_by(patient_id) %>% 
  filter(cnt == max(cnt)) %>% # top_n(cnt, n = 1) also works
  arrange(patient_id) %>%
  ungroup() %>%
  mutate(common = gsub("\\_.*", "", common),
         match=ifelse(common==tolower(ethnicity_snomed_5),"Not matching","Matching")) 

matches_table <- matches %>%
  select(match,ethnicity_snomed_5) %>%
  tbl_summary(by= match,
              label = ethnicity_snomed_5 ~ "Latest SNOMED") %>%
  bold_labels()
saveRDS(matches_table, here::here("output", "tables","matches.rds"))

matches_full_table <- matches %>%
  select(common,ethnicity_snomed_5) %>%
  tbl_summary(by= common,
              label = list(ethnicity_snomed_5 ~ "Latest",common ~ "Most frequent")) %>%
  bold_labels()
saveRDS(matches_full_table, here::here("output", "tables","matches_expanded.rds"))

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
eth_ons<-read_csv(here::here("data","ethnicity_ons.csv.gz"))  

eth_tpp <- df_input %>%
  rename("Ethnic_Group"="ethnicity_snomed_5") %>%
  group_by(region,Ethnic_Group) %>%
  summarise(N=n()) %>%
  ungroup %>%
  group_by(region) %>%
  mutate(Total = sum(N),
         cohort="SNOMED",
         group="5_2001") 

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
ethnicity<-  eth_tpp %>%
  bind_rows(eth_ons) %>%
  mutate(
    region=case_when(region=="East"~as.character("East of England"),
                     region=="Yorkshire and The Humber"~as.character("Yorkshire and the Humber"),
                     T~as.character(region)))


# %>%
#  bind_rows(eth_tpp_16)

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

write_csv(ethnicity2,here::here("output", "tables","ethnic_group.csv"))



#### NA removed

ethnicity_na<-ethnicity_unrounded %>%
  drop_na(Ethnic_Group) %>%
  group_by(group,cohort, region) %>%
  mutate(
         Total=sum(N),
         N=round(N/5)*5,
         Total=round(Total/5)*5,
         percentage=N/Total * 100)
write_csv(ethnicity_na,here::here("output", "tables","ethnic_group_NA.csv"))


ethnicity_plot <- ethnicity_na %>%
  filter(region != "England", group == "5_2001") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap( ~ region) +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip() +
  xlab("") + ylab("Percentage of all ethnicities")

ggsave(
  filename = here::here("output", "plots", "ethnicity_count.png"),
  ethnicity_plot,
  dpi = 600,
  width = 45,
  height = 30,
  units = "cm"
)

#### ggalluvial
alluvial<-df_input %>% 
  gather(common, cnt, ends_with("count")) %>% 
  group_by(patient_id) %>% 
  top_n(cnt, n = 5) %>%
  arrange(patient_id,-cnt) %>% 
  group_by(patient_id) %>%
  mutate(rank=row_number()) %>%
  mutate(common=ifelse(cnt==0,NA,common)) %>%
  fill(common) %>%
  drop_na(common) %>%
  select(common,rank,patient_id) %>%
ggplot(
       aes(x = rank, stratum = common, alluvium = patient_id,
           fill = common, label = common)) +
  scale_fill_brewer(type = "qual", palette = "Set2") +
  geom_flow(stat = "alluvium", lode.guidance = "frontback",
            color = "darkgray") +
  geom_alluvium(aes(fill=common,alpha=0.5)) +
  geom_stratum() +
  theme(legend.position = "bottom") +
  ggtitle("Ethnicity")

ggsave(
  filename = here::here("output", "plots", "alluvium.png"),
  alluvial,
  dpi = 200,
  width = 30,
  height = 15,
  units = "cm"
)
