# Author: Colm D Andrews
# Date:   14/07/2022
#
################################################################################
library(rlang)
library(vctrs)
library(tidyverse)
library(scales)
library(readr)
library(ggsci)
library(ggpubr)
library(ggforce)
library(glue)
library(arrow)
library(hrbrthemes)
library(viridis)
library(stringr)
library(ggplot2)


####### NA removed
ethnicity <-
  read_csv(here::here("output","released","simple_patient_counts_5_sus_registered.csv"),col_types =(cols())) %>%
  select("group","subgroup",starts_with("ethnicity_new_5"),starts_with("any"),"population") %>%
  mutate(ethnicity_new_5_percentage = round(ethnicity_new_5_filled / population *100,1),
         any_percentage = round(any_filled / population *100,1),
         group=case_when(group=="age_band"~"Age\nBand",
                         group=="all"~"All",
                         group=="dementia"~"Dementia",
                         group=="diabetes"~"Diabetes",
                         group=="hypertension"~"Hypertension",
                         group=="imd"~"IMD",
                         group=="learning_disability"~"Learning\nDisability",
                         group=="region"~"Region",
                         group=="sex"~"Sex"),
         group = fct_relevel(group, 
                             "All","Age\nBand","Sex", "Region","IMD",
                             "Dementia","Diabetes","Hypertension","Learning\nDisability"),
         subgroup=case_when(subgroup=="M"~"Male",
                            subgroup=="F"~"Female",
                            TRUE~subgroup),
         across('subgroup', str_replace, 'True', 'Present'),
         across('subgroup', str_replace, 'False', 'Absent')
  ) %>%
  filter(subgroup!="missing") %>%
  mutate(any_percentage=any_percentage-ethnicity_new_5_percentage) %>%
  pivot_longer(
    cols=c(starts_with("ethnicity_new_5"),starts_with("any")),
    names_to = c( "ethnicity",".value"),
    names_pattern = "(.*)_(.*)"
  ) %>%
  mutate(ethnicity=case_when(ethnicity=="ethnicity_new_5"~"SNOMED:2022",
                             ethnicity=="any"~"SNOMED:2022 supplemented with SUS data"),
         ethnicity=fct_relevel(ethnicity,"SNOMED:2022 supplemented with SUS data","SNOMED:2022"))



ethnicity_plot<-  ethnicity %>%
  ggplot(aes(x = subgroup, y = percentage,alpha=ethnicity, fill = group)) +
  scale_alpha_discrete(range = c(0.2, 1))+
  geom_hline(aes(yintercept=percentage[which(group=="All"& ethnicity =="SNOMED:2022")]),color="#00468BFF",alpha = 0.5) +
  geom_hline(aes(yintercept=sum(percentage[which(group=="All")])),color="#00468BFF",alpha = 0.1) +
  geom_bar(stat = "identity", position = "stack") +
  facet_grid( group~., scales = "free_y", space = 'free_y') +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of registered TPP patients") +
  guides(fill = "none",alpha=guide_legend("")) +
  theme(legend.position = "bottom")

ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    "ethnicity_plot.png"
  ),
  ethnicity_plot,
  dpi = 600,
  width = 50,
  height = 65,
  units = "cm"
)

######### Categories
ethnicity_cat <-
  read_csv(here::here("output","released","simple_patient_counts_categories_5_group_registered.csv"),col_types =(cols())) %>%
  rename_with(~sub("ethnicity_","",.),contains("ethnicity_")) %>%
  rename_with(~sub("_5_filled","",.),contains("_5_filled")) %>%
  select(-contains("filled"),-contains("missing"),-contains("sus"),-contains("any")) %>%
  mutate(Asian_supplementeddiff=Asian_supplemented-Asian_new,
         Black_supplementeddiff=Black_supplemented-Black_new,
         Mixed_supplementeddiff=Mixed_supplemented-Mixed_new,
         White_supplementeddiff=White_supplemented-White_new,
         Other_supplementeddiff=Other_supplemented-Other_new,) 


ethnicity_cat_pivot <- ethnicity_cat %>%
  pivot_longer(
    cols = c(contains("_")),
    names_to = c( "ethnicity","codelist"),
    names_pattern = "(.*)_(.*)",
    values_to = "n"
  ) %>%
  mutate(percentage = round(n / population *100,1),
         group=case_when(group=="age_band"~"Age\nBand",
                         group=="all"~"All",
                         group=="dementia"~"Dementia",
                         group=="diabetes"~"Diabetes",
                         group=="hypertension"~"Hypertension",
                         group=="imd"~"IMD",
                         group=="learning_disability"~"Learning\nDisability",
                         group=="region"~"Region",
                         group=="sex"~"Sex"),
         group = fct_relevel(group, 
                             "All","Age\nBand","Sex", "Region","IMD",
                             "Dementia","Diabetes","Hypertension","Learning\nDisability"),
         subgroup=case_when(subgroup=="M"~"Male",
                            subgroup=="F"~"Female",
                            TRUE~subgroup),
         across('subgroup', str_replace, 'True', 'Present'),
         across('subgroup', str_replace, 'False', 'Absent'),
         across('ethnicity', str_replace, '_ethnicity_new_5_filled', '')
  ) %>%
  mutate(
    ethnicity = fct_relevel(ethnicity,
                            "Asian","Black","Mixed", "White","Other")
  )

ethnicityhline_new<-ethnicity_cat_pivot  %>% arrange(ethnicity,group) %>% group_by(ethnicity,codelist) %>% mutate(percentage=first(percentage))  %>% ungroup %>% filter(codelist=="new")
ethnicityhline_supplemented<-ethnicity_cat_pivot  %>% arrange(ethnicity,group) %>% group_by(ethnicity,codelist) %>% mutate(percentage=first(percentage)) %>% ungroup %>% filter(codelist=="supplemented")

ethnicity_cat_pivot <- ethnicity_cat_pivot %>%
  mutate(codelist=case_when(codelist=="new"~"SNOMED:2022",
                            codelist=="supplementeddiff"~"SNOMED:2022 supplemented with SUS data"),
         codelist=fct_relevel(codelist,"supplemented","SNOMED:2022 supplemented with SUS data","SNOMED:2022"))



ethnicity_cat_plot<-  ethnicity_cat_pivot %>%
  filter(codelist!="supplemented") %>%
  ggplot(aes(x = subgroup, y = percentage,alpha = codelist, fill = group)) +
  scale_alpha_discrete(range = c(0.2, 1))+
  geom_hline(data=ethnicityhline_new,
             aes(yintercept=percentage),color="#00468BFF",alpha = 0.6) +
  geom_hline(data=ethnicityhline_supplemented,
             aes(yintercept=percentage),color="#00468BFF",alpha = 0.1) +
  geom_bar(stat = "identity", position = "stack") +
  facet_grid( group~ethnicity, scales = "free", space = 'free') +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0.5,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of registered TPP patients") + 
  guides(fill = "none",alpha=guide_legend("")) +
  theme(legend.position = "bottom", 
        panel.spacing = unit(1.1, "lines"))

ethnicity_cat_plot

ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    "ethnicity_cat_plot.png"
  ),
  ethnicity_cat_plot,
  dpi = 600,
  width = 90,
  height = 65,
  units = "cm"
)


# data<-read_feather(here::here("output","data","input.feather"))
population  <-   read_csv(here::here("output","released","simple_patient_counts_5_sus_registered.csv"),col_types =(cols())) %>%
  filter( group=="all" ) %>%
  summarise(ethnicity_new_5 = "Unknown",
            population= population-ethnicity_new_5_filled) 

ethnicity_cat <-
  read_csv(here::here("output","released","simple_patient_counts_categories_5_sus_registered.csv"),col_types =(cols())) %>%
  rename_with(~sub("ethnicity_","",.),contains("ethnicity_")) %>%
  rename_with(~sub("_5_filled","",.),contains("_5_filled")) %>%
  select(-contains("filled"),-contains("missing"),-contains("sus")) %>%
  mutate(Asian_anydiff=Asian_any-Asian_new,
         Black_anydiff=Black_any-Black_new,
         Mixed_anydiff=Mixed_any-Mixed_new,
         White_anydiff=White_any-White_new,
         Other_anydiff=Other_any-Other_new,) 



# select("group","subgroup",ends_with("_5_filled"),"population")


ethnicity_cat_pivot <- ethnicity_cat %>%
  pivot_longer(
    cols = c(contains("_")),
    names_to = c( "ethnicity","codelist"),
    names_pattern = "(.*)_(.*)",
    values_to = "n"
  ) %>%
  filter(codelist=="new",group=="all") %>%
  summarise(ethnicity_new_5 =ethnicity,
            population=n) %>%
  bind_rows(population)



df_sum = read_csv(here::here("output","released","simple_sus_crosstab_long_5_registered.csv")) 

latest_common<- ggplot(df_sum, aes(ethnicity_new_5, ethnicity_sus_5, fill= `0`)) + 
  geom_tile() +
  # scale_fill_viridis(discrete=FALSE,direction=-1) +
  # scale_fill_gradient(low="white", high="blue") +
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of 'Latest Ethnicity'") +
  geom_text(aes(label=scales::label_comma(accuracy = 1)(`0`))) +
  ylab("SNOMED\n") + xlab("\nSUS") +
  theme_ipsum()

df_sum_nowhite <- df_sum %>% 
  filter(ethnicity_new_5!="White",ethnicity_sus_5!="White")


ggplot(df_sum_nowhite, aes(ethnicity_new_5, ethnicity_sus_5, fill= `0`)) + 
  geom_tile() +
  scale_fill_gradient2(limits=c(0,max(df_sum_nowhite$`0`)),midpoint = max(df_sum_nowhite$`0`)/3, high = "navyblue",
                       mid = "indianred", low = "ivory1",na.value = "white") 


df_sum_perc <-df_sum %>%
  left_join(ethnicity_cat_pivot,by="ethnicity_new_5") %>%
  mutate(percentage=round(`0`/population*100,1)) %>%
  mutate(ethnicity_new_5 = fct_relevel(ethnicity_new_5,
                                       "Unknown","Other","White","Mixed", "Black","Asian"),
         ethnicity_sus_5=fct_relevel(ethnicity_sus_5,
                                     "Asian","Black","Mixed", "White","Other")
  )
  

sus_heat_perc<- ggplot(df_sum_perc, aes( ethnicity_sus_5,ethnicity_new_5, fill= percentage)) + 
  geom_tile() +
  # scale_fill_viridis(discrete=FALSE,direction=-1) +
  # scale_fill_gradient(low="white", high="blue") +
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of SNOMED:2022") +
  geom_text(aes(label=percentage)) +
  ylab("SNOMED:2022\n") + xlab("\nSUS") +
  theme_ipsum()

ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    "sus_heat_perc.png"
  ),
  sus_heat_perc,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)

df_sum_perc_unk <- df_sum_perc %>%
  filter(ethnicity_new_5!="Unknown",
         ethnicity_sus_5!="Unknown") %>%
  group_by(ethnicity_new_5 ) %>%
  mutate(population = sum(`0`)) %>%
  ungroup() %>%
  mutate(percentage=round(`0`/population*100,1))
  
sus_heat_perc_unk<- ggplot(df_sum_perc_unk, aes( ethnicity_sus_5,ethnicity_new_5, fill= percentage)) + 
  geom_tile() +
  # scale_fill_viridis(discrete=FALSE,direction=-1) +
  # scale_fill_gradient(low="white", high="blue") +
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of SNOMED:2022") +
  geom_text(aes(label=percentage)) +
  ylab("SNOMED:2022\n") + xlab("\nSUS") +
  theme_ipsum()

ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    "sus_heat_perc_unk.png"
  ),
  sus_heat_perc_unk,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)



latest_common_nowhite<- ggplot(df_sum_nowhite , aes(ethnicity_new_5, ethnicity_sus_5, fill= `0`)) + 
  geom_tile() +
  # scale_fill_viridis(discrete=FALSE,direction=-1) +
  # scale_fill_gradient(low="white", high="blue") +
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of 'Latest Ethnicity'") +
  geom_text(aes(label=scales::label_comma(accuracy = 1)(`0`))) +
  ylab("SNOMED:2022\n") + xlab("\nSUS") +
  theme_ipsum()

########### 

perc_unk<- df_sum_perc_unk %>% mutate(matches=ethnicity_new_5==ethnicity_sus_5) %>% group_by(matches) %>% summarise(N=sum(`0`))

############ state change

# data<-read_feather(here::here("output","data","input.feather"))
state_change  <-   read_csv(here::here("output","released","simple_state_change_ethnicity_new_5_registered.csv"),col_types =(cols())) %>%
  select(-...1) %>%
  rename("latest"="ethnicity_new_5")

state_change_long <- state_change %>%
  pivot_longer(cols=starts_with("ethnicity_new_5"),
               names_prefix ="ethnicity_new_5_",
               names_to = "ethnicity",
               values_to="val") %>%
  mutate(percentage = round(val / n *100,1),
         ethnicity = str_to_title(ethnicity),
         ethnicity = case_when(ethnicity=="Any"~"Any discordant ethnicity",
                               T ~ ethnicity),
         latest = fct_relevel(latest,
                                       "Other","White","Mixed", "Black","Asian"),
         ethnicity=fct_relevel(ethnicity,
                                     "Asian","Black","Mixed", "White","Other","Any discordant ethnicity")
  )
         
               
              

plot_state_change <- ggplot(state_change_long, aes(ethnicity,latest, fill= percentage)) + 
  geom_tile() +
  # scale_fill_viridis(discrete=FALSE,direction=-1) +
  # scale_fill_gradient(low="white", high="blue") +
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of 'Latest Ethnicity'") +
  geom_text(aes(label=percentage)) +
  ylab("Latest recorded ethnicity\n") + xlab("\nAny recorded ethnicity") +
  theme_ipsum()

plot_state_change

ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    "state_change.png"
  ),
  plot_state_change,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)

### latest common 2023
df_sum = read_csv(here::here("output","released","simple_latest_common_ethnicity_new_5_registered.csv"))           

df_sum2<-df_sum %>%
  ungroup() %>%
  mutate(across(-1)/rowSums(across(-1),na.rm = T)*100) %>%
  mutate(latest=ethnicity_new_5) %>%
  select(-ethnicity_new_5) %>% 
  pivot_longer(cols=starts_with("ethnicity_new_5"),names_prefix ="ethnicity_new_5_",names_to = "common",values_to="val") %>%
  mutate(common=str_to_title(common),
         common = fct_relevel(common,
                              "Asian","Black","Mixed", "White","Other"),
         latest = fct_relevel(latest,
                              "Other","White","Mixed", "Black","Asian")
  )  %>%
  filter(latest!="Unknown")
# filter(latest!="White_British",latest!="White_Irish",latest!="Other_White",common!="White_British",common!="White_Irish",common!="Other_White")


latest_common<- ggplot(df_sum2, aes(common, latest, fill= val)) + 
  geom_tile() +
  # scale_fill_viridis(discrete=FALSE,direction=-1) +
  # scale_fill_gradient(low="white", high="blue") +
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of 'Latest Ethnicity'") +
  geom_text(aes(label = round(val, 1))) +
  ylab("Latest Ethnicity\n") + xlab("\nMost Frequent Ethnicity") +
  theme_ipsum()

latest_common

ggsave(
  filename = here::here(
    "output",
    "released",
    "latest_common.png"
  ),
  latest_common,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)

### ONS comparison
####### NA removed
# read ethnicity produced by combine_ONS_sus.R
ethnicity_na <-
  read_csv(here::here("output","released","made_locally",  "ethnic_group_2021_registered_with_2001_categories.csv")) %>%
  mutate(
    cohort = case_when(cohort=="ONS"~"2021 Census",
                       cohort=="new"~"SNOMED:2022",
                       cohort=="supplemented"~"SNOMED:2022 supplemented with SUS data"),
    cohort = fct_relevel(cohort, "2021 Census","SNOMED:2022", "SNOMED:2022 supplemented with SUS data"),
    Ethnic_Group = fct_relevel(Ethnic_Group,
                               "Asian","Black","Mixed", "White","Other"))


## create difference in percentage between ONS and TPP (for plotting)
ethnicity_plot_na_diff <- ethnicity_na %>%
  group_by(Ethnic_Group,region,group) %>%
  arrange(cohort) %>%
  mutate(diff = percentage - first(percentage)) %>%
  select(region,Ethnic_Group,cohort,diff,group)

ethnicity_na <-ethnicity_na %>% 
  left_join(ethnicity_plot_na_diff, by=c("region","Ethnic_Group","cohort","group"))
## 5 group ethnicity plot NA removed for Regions
ethnicity_plot_na <- ethnicity_na %>%
  filter(region != "England", group == "5") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap( ~ region) +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 12,
    hjust = 0.75,
    vjust = 0
  )) +
  coord_flip()  +  scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#925E9FFF")) +
  xlab("") + ylab("\nProportion of ethnicities")  +
  theme(legend.position="bottom",
        legend.title=element_blank()) +
  geom_text(aes(x=Ethnic_Group,y=percentage,label=ifelse(cohort=="2021 Census","",paste0(round(diff,digits =1),"%"))), size=3.4, position =position_dodge(width=0.9), vjust=0.3,hjust = -0.2) 


ggsave(
  filename =here::here("output","released","made_locally",  "ONS_ethnicity_regions_2021.png"),
  ethnicity_plot_na,
  dpi = 600,
  width = 50,
  height = 30,
  units = "cm"
)


## 5 group ethnicity plot NA removed for England
ethnicity_plot_eng_na <- ethnicity_na %>%
  filter(region == "England", group == "5") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#925E9FFF")) +
  xlab("") + ylab("\nProportion of ethnicities") +
  theme(legend.position="bottom",
        legend.title=element_blank()) +
  geom_text(aes(x=Ethnic_Group,y=percentage,label=ifelse(cohort=="2021 Census","",paste0(round(diff,digits =1),"%"))), size=3.4, position =position_dodge(width=0.9), vjust=0.3 ,hjust = -0.2)

ggsave(
  filename =here::here("output","released","made_locally", "ONS_ethnicity_eng_2021.png"
  ),
  ethnicity_plot_eng_na,
  dpi = 600,
  width = 30,
  height = 15,
  units = "cm"
)