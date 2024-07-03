# Author: Colm D Andrews
# Date:   14/07/2022
#
################################################################################
library(tidyverse)
library(scales)
library(readr)
library(glue)
library(arrow)
library(ggplot2)
library(ggalluvial)

### Point 1. Why is there weirdness with lower N in the grouped compared to overall England


ethnicity <-
  read_csv(here::here("output","released","simple_patient_counts_categories_5_group_registered.csv"),col_types =(cols())) %>% 
  filter(group=="region") %>%
  summarise(N=sum(Asian_ethnicity_new_5_filled))

# Adding all regions gives 1706020 compared to 1708430 total ethnicities for Asian New codelist



#######################################################

ons_na_removed <-
  read_csv(here::here("output", "released", "made_locally", "ethnic_group_2021_registered_with_2001_categories.csv")) %>%
  mutate(
    cohort = fct_relevel(cohort, "ONS", "new", "supplemented"),
    Ethnic_Group = fct_relevel(
      Ethnic_Group,
      "Asian", "Black", "Mixed", "White", "Other"
    )
  )

ons_england<-ons_na_removed %>%
  filter(region!="England") %>%
  group_by(Ethnic_Group,cohort) %>%
  summarise(
    region="England",
    N_sumregion = sum(N),
    Total_sumregion=sum(Total))

ons_na_removed_compare <-ons_na_removed %>%
  select("Ethnic_Group","region","cohort","N","Total")%>%
  inner_join(ons_england) %>%
  mutate(N_diff = N- N_sumregion,
         total_diff = Total - Total_sumregion, 
         perc_diff = N_diff / N *100)
### some weirdness with lower N in the grouped* See point 1 above



ons_england_remix <- ons_england %>%
  summarise(
            region,
            Ethnic_Group,
            Total = Total_sumregion,
            N = N_sumregion,
            group = 5,
            cohort=cohort,
            percentage = N/Total *100)

#### Is only White overrepresented in England?
ons_ethnicity_plot_na_diff <- ons_england_remix %>%
  group_by(Ethnic_Group, region) %>%
  arrange(cohort) %>%
  mutate(diff = percentage - first(percentage)) %>%
  select(region, Ethnic_Group, cohort, diff)


## create difference in percentage between ONS and TPP (for plotting)
ons_ethnicity_plot_na_diff <- ons_na_removed %>%
  group_by(Ethnic_Group, region, group) %>%
  arrange(cohort) %>%
  mutate(diff = percentage - first(percentage)) %>%
  filter(Ethnic_Group=="White",
         cohort=="new"| cohort=="ONS") %>%
  select(N, Total,cohort,region,percentage) %>%
  pivot_wider(names_from = cohort,values_from = c(N,Total,percentage))

# step 2: check England isa above ONS
step2 <- ons_ethnicity_plot_na_diff %>% filter(region!="England") %>%
  group_by(Ethnic_Group) %>%
  summarise(perc_ONS = sum(N_ONS)/sum(Total_ONS),
            perc_new = sum(N_new)/sum(Total_new))

## Why is it above
coverage<- ons_ethnicity_plot_na_diff %>%
  filter(region!="England") %>%
  mutate(
    diff = percentage_new - percentage_ONS,
    sign=case_when(
              diff>0 ~"positive",
              diff<0 ~"negative"),
         coverage= Total_new / Total_ONS
         )

totals<-coverage %>% 
  select(region,N_ONS,N_new,Total_ONS,Total_new,sign) %>%
  group_by(sign) %>%
  summarise(N_ONS = sum(N_ONS),
            Total_ONS = sum(Total_ONS),
            N_new= sum (N_new),
            Total_new = sum(Total_new),
            perc_ONS = N_ONS / Total_ONS*100,
            perc_new = N_new / Total_new*100,
            diff = perc_new - perc_ONS,
            coverage= Total_new / Total_ONS) 

# does this agree with step2?
totals %>%
  select(N_ONS,N_new,Total_ONS,Total_new) %>%
  mutate(group=1) %>%
  group_by(group) %>%
  summarise(N_ONS = sum(N_ONS),
            Total_ONS = sum(Total_ONS),
            N_new= sum (N_new),
            Total_new = sum(Total_new),
            perc_ONS = N_ONS / Total_ONS*100,
            perc_new = N_new / Total_new*100)

step2

### Does ONS discrepancy widen as -> 100%
ons_discrepancy<- ons_ethnicity_plot_na_diff %>%
  mutate(diff=percentage_new - percentage_ONS) 
View(ons_discrepancy)




