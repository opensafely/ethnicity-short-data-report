# Author: Colm D Andrews
# Date:   14/07/2022
#
################################################################################
library(rlang)
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
library(ggalluvial)
library(ggrepel)

####### NA removed
prop_reg <-
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



prop_reg_plot<-  prop_reg %>%
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
    hjust = 0.5,
    vjust = 0
  )) +
  theme(strip.text.y = element_text(angle = 0)) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of registered TPP patients") +
  guides(fill = "none",alpha=guide_legend("")) +
  theme(legend.position = "bottom")


ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    "prop_reg_plot.png"
  ),
  prop_reg_plot,
  dpi = 600,
  width = 25,
  height = 30,
  units = "cm"
)

######### Categories
prop_reg_cat <-
  read_csv(here::here("output","released","simple_patient_counts_categories_5_group_registered.csv"),col_types =(cols())) %>%
  rename_with(~sub("ethnicity_","",.),contains("ethnicity_")) %>%
  rename_with(~sub("_5_filled","",.),contains("_5_filled")) %>%
  select(-contains("filled"),-contains("missing"),-contains("sus"),-contains("any")) %>%
  mutate(Asian_supplementeddiff=Asian_supplemented-Asian_new,
         Black_supplementeddiff=Black_supplemented-Black_new,
         Mixed_supplementeddiff=Mixed_supplemented-Mixed_new,
         White_supplementeddiff=White_supplemented-White_new,
         Other_supplementeddiff=Other_supplemented-Other_new,) 


prop_reg_cat_pivot <- prop_reg_cat %>%
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

prop_reg_cat_hline_new<-prop_reg_cat_pivot  %>% arrange(ethnicity,group) %>% group_by(ethnicity,codelist) %>% mutate(percentage=first(percentage))  %>% ungroup %>% filter(codelist=="new")
prop_reg_cat_hline_supplemented<-prop_reg_cat_pivot  %>% arrange(ethnicity,group) %>% group_by(ethnicity,codelist) %>% mutate(percentage=first(percentage)) %>% ungroup %>% filter(codelist=="supplemented")

prop_reg_cat_pivot <- prop_reg_cat_pivot %>%
  mutate(codelist=case_when(codelist=="new"~"SNOMED:2022",
                            codelist=="supplementeddiff"~"SNOMED:2022 supplemented with SUS data",
                            T ~ codelist ),
         codelist=fct_relevel(codelist,"supplemented","SNOMED:2022 supplemented with SUS data","SNOMED:2022"))



prop_reg_cat_plot<-  prop_reg_cat_pivot %>%
  filter(codelist!="supplemented",
         subgroup!="missing") %>%
  ggplot(aes(x = subgroup, y = percentage,alpha = codelist, fill = group)) +
  scale_alpha_discrete(range = c(0.2, 1))+
  geom_hline(data=prop_reg_cat_hline_new,
             aes(yintercept=percentage),color="#00468BFF",alpha = 0.6) +
  geom_hline(data=prop_reg_cat_hline_supplemented,
             aes(yintercept=percentage),color="#00468BFF",alpha = 0.1) +
  geom_bar(stat = "identity", position = "stack") +
  facet_grid( group~ethnicity, scales = "free", space = 'free',shrink = FALSE) +
  theme_classic() +
  theme(text = element_text(size = 30)) +
  theme(axis.text.x = element_text(
    size = 25,
    hjust = 0.5,
    vjust = 0
  )) +
  theme(strip.text.y = element_text(angle = 0)) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of registered TPP patients") + 
  guides(fill = "none",alpha=guide_legend("")) +
  theme(legend.position = "bottom", 
        panel.spacing = unit(1.1, "lines"))

prop_reg_cat_plot

ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    "prop_reg_cat_plot.png"
  ),
  prop_reg_cat_plot,
  dpi = 600,
  width = 100,
  height = 60,
  units = "cm"
)



### SUS and New codelist comparison
df_sus_new_cross = read_csv(here::here("output","released","simple_sus_crosstab_long_5_registered.csv")) 


### Get count of patients with unknown ethnicity 
population  <-   read_csv(here::here("output","released","simple_patient_counts_5_sus_registered.csv"),col_types =(cols())) %>%
  filter( group=="all" ) %>%
  summarise(ethnicity_new_5 = "Unknown",
            population= population-ethnicity_new_5_filled) 

### Get count of patients per 5 group ethnicity 
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


df_sus_new_cross_nowhite <- df_sus_new_cross %>% 
  filter(ethnicity_new_5!="White",ethnicity_sus_5!="White")


df_sus_new_cross_perc <-df_sus_new_cross %>%
  left_join(ethnicity_cat_pivot,by="ethnicity_new_5") %>%
  mutate(percentage=round(`0`/population*100,1)) %>%
  mutate(ethnicity_new_5 = fct_relevel(ethnicity_new_5,
                                       "Unknown","Other","White","Mixed", "Black","Asian"),
         ethnicity_sus_5=fct_relevel(ethnicity_sus_5,
                                     "Asian","Black","Mixed", "White","Other")
  )
  

sus_heat_perc<- ggplot(df_sus_new_cross_perc, aes( ethnicity_sus_5,ethnicity_new_5, fill= percentage)) + 
  geom_tile() +
  # scale_fill_viridis(discrete=FALSE,direction=-1) +
  # scale_fill_gradient(low="white", high="blue") +
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of primary care ethnicity group") +
  geom_text(aes(label=percentage)) +
  ylab("primary care ethnicity\n") + xlab("\nSecondary care ethnicity") +
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

df_sus_new_cross_perc_unk <- df_sus_new_cross_perc %>%
  filter(ethnicity_new_5!="Unknown",
         ethnicity_sus_5!="Unknown") %>%
  group_by(ethnicity_new_5 ) %>%
  mutate(population = sum(`0`)) %>%
  ungroup() %>%
  mutate(percentage=round(`0`/population*100,1))
  
sus_heat_perc_unk<- ggplot(df_sus_new_cross_perc_unk, aes( ethnicity_sus_5,ethnicity_new_5, fill= percentage)) + 
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

########### 

perc_unk<- df_sus_new_cross_perc_unk %>% mutate(matches=ethnicity_new_5==ethnicity_sus_5) %>% group_by(matches) %>% summarise(N=sum(`0`))


######## primary vs secondary Denom = all patients

df_secondary_new_cross_perc <-df_sus_new_cross %>%
  # mutate(population = population$population[population$group=="all"]) %>%
  # mutate(percentage=round(`0`/population*100,1)) %>%
  mutate(ethnicity_new_5 = fct_relevel(ethnicity_new_5,
                                       "Unknown","Other","White","Mixed", "Black","Asian"),
         ethnicity_sus_5=fct_relevel(ethnicity_sus_5,
                                     "Asian","Black","Mixed", "White","Other")
  )

bennett_pal<-c("#FFB700","#F20D52","#FF369C","#FF7CFE","#9C54E6","#5323B3")

opt1<-c(
"#FFB700",
"#F20D52",
"#FF369C",
"#FF7CFE",
"#9C54E6",
"#5323B3"
)

opt2<-c(
"#FFB700",
"#F20D52",
"#FF369C",
"#9C54E6",
"#5323B3",
"#3FB5FF")

opt3<-c(
"#FFB700",
"#F20D52",
"#FF369C",
"#9C54E6",
"#5323B3",
"#17D7E6")

opt4<-c("#FFB700",
"#F20D52",
"#FF369C",
"#5323B3",
"#5A71F3",
"#3FB5FF")

opt5<-c("#FFB700",
"#F20D52",
"#FF369C",
"#5323B3",
"#5A71F3",
"#17D7E6")

opt6<-c("#FFD23B",
"#F20D52",
"#FF369C",
"#FF7CFE",
"#9C54E6",
"#5323B3")

opt7<-c("#FFD23B",
"#F20D52",
"#FF369C",
"#9C54E6",
"#5323B3",
"#3FB5FF")

opt8<-c("#FFD23B",
"#F20D52",
"#FF369C",
"#9C54E6",
"#5323B3",
"#17D7E6")

opt9<-c(
"#FFD23B",
"#F20D52",
"#FF369C",
"#5323B3",
"#5A71F3",
"#3FB5FF")

opt10<-c("#FFD23B",
"#F20D52",
"#FF369C",
"#5323B3",
"#5A71F3",
"#17D7E6")

alluvial_func<-function(palette){
alluvial<- ggplot(as.data.frame(df_secondary_new_cross_perc),
       aes(y = `0`, axis1 = ethnicity_new_5, axis2 = ethnicity_sus_5)) +
  geom_alluvium(aes(fill = ethnicity_new_5)) +
  geom_stratum(aes(fill = ethnicity_sus_5)) +
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) +
  scale_x_discrete(limits = c("ethnicity_new_5", "ethnicity_sus_5"), expand = c(.05, .05)) +
  scale_fill_manual(values=rev(get(palette)), na.value = NA) +
  theme_minimal() +
  ggtitle("")

#   scale_fill_manual(values=rev(c("#FFD23B","#F20D52","#FF7CFE","#5323B3","#3FB5FF","#17D7E6"))) +
  
  ggsave(filename = here::here(
    "output",
    "released",
    "made_locally",
    glue("alluvial_{palette}.png")
  ),
  alluvial,
  dpi = 600,
  width = 50,
  height = 30,
  units = "cm"
  )
}

for(i in 1:10){
alluvial_func(glue("opt{i}"))
}
  secondary_heat_perc_all_patients<- ggplot(df_secondary_new_cross_perc, aes( ethnicity_sus_5,ethnicity_new_5, fill= percentage)) + 
  geom_tile() +
  # scale_fill_viridis(discrete=FALSE,direction=-1) +
  # scale_fill_gradient(low="white", high="blue") +
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of all TPP patients") +
  geom_text(aes(label=percentage)) +
  ylab("Primary care ethnicity\n") + xlab("\nSecondary Care ethnicity") +
  theme_ipsum()
  
  ggsave(filename = here::here(
    "output",
    "released",
    "made_locally",
    "second_care_all_pts.png"
  ),
  secondary_heat_perc_all_patients,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
  )
  

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
df_lat_comm = read_csv(here::here("output","released","simple_latest_common_ethnicity_new_5_registered.csv"))           

df_lat_comm<-df_lat_comm %>%
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


latest_common<- ggplot(df_lat_comm, aes(common, latest, fill= val)) + 
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
    "made_locally",
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
ons_na_removed <-
  read_csv(here::here("output","released","made_locally",  "ethnic_group_2021_registered_with_2001_categories.csv")) %>%
  mutate(
    cohort = case_when(cohort=="ONS"~"2021 Census\n[amended to 2001 grouping]",
                       cohort=="new"~"SNOMED:2022",
                       cohort=="supplemented"~"SNOMED:2022 supplemented with SUS data"),
    cohort = fct_relevel(cohort, "2021 Census\n[amended to 2001 grouping]","SNOMED:2022", "SNOMED:2022 supplemented with SUS data"),
    Ethnic_Group = fct_relevel(Ethnic_Group,
                               "Asian","Black","Mixed", "White","Other"))


## create difference in percentage between ONS and TPP (for plotting)
ons_ethnicity_plot_na_diff <- ons_na_removed %>%
  group_by(Ethnic_Group,region,group) %>%
  arrange(cohort) %>%
  mutate(diff = percentage - first(percentage)) %>%
  select(region,Ethnic_Group,cohort,diff,group)

ons_na_removed <-ons_na_removed %>% 
  left_join(ons_ethnicity_plot_na_diff, by=c("region","Ethnic_Group","cohort","group"))
## 5 group ethnicity plot NA removed for Regions
ons_ethnicity_plot_na <- ons_na_removed %>%
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
  geom_text(aes(x=Ethnic_Group,y=percentage,label=ifelse(cohort=="2021 Census\n[amended to 2001 grouping]","",paste0(round(diff,digits =1),"%"))), size=3.4, position =position_dodge(width=0.9), vjust=0.3,hjust = -0.2) 


ggsave(
  filename =here::here("output","released","made_locally",  "ONS_ethnicity_regions_2021_with_2001_regions.png"),
  ons_ethnicity_plot_na,
  dpi = 600,
  width = 50,
  height = 30,
  units = "cm"
)


## 5 group ethnicity plot NA removed for England
ons_ethnicity_plot_eng_na <- ons_na_removed %>%
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
  geom_text(aes(x=Ethnic_Group,y=percentage,label=ifelse(cohort=="2021 Census\n[amended to 2001 grouping]","",paste0(round(diff,digits =1),"%"))), size=3.4, position =position_dodge(width=0.9), vjust=0.3 ,hjust = -0.2)

ggsave(
  filename =here::here("output","released","made_locally", "ONS_ethnicity_eng_2021_with_2001_regions.png"
  ),
  ons_ethnicity_plot_eng_na,
  dpi = 600,
  width = 30,
  height = 15,
  units = "cm"
)



#### in progress
library(ggpattern)

ggplot(df_sus_new_cross_perc, aes( ethnicity_sus_5,ethnicity_sus_5)) +
  geom_bar(stat = "identity", aes(width = population, fill = ethnicity_new_5), col = "Black") +
  geom_text(aes(label = as.character(var1), x = var1Center, y = 1.05)) 


df_sus_new_cross_perc_1 <- df_sus_new_cross_perc %>%
  mutate(highlight = case_when(ethnicity_sus_5 == ethnicity_new_5  ~ "yes", 
                               TRUE ~ "no"),
         type=case_when(ethnicity_new_5 == "White"  ~ "yes", 
                           TRUE ~ "no"),
         ethnicity_new_5 = fct_relevel(ethnicity_new_5,
                                      "Asian","Black","Mixed","White", "Other","Unknown"))


strip <- strip_themed(background_x = elem_list_rect(fill = rev(c("#80796BFF","#374E55FF","#6A6599FF","#B24745FF","#00A1D5FF"))))

marimekko_nw <- ggplot(df_sus_new_cross_perc_1 %>% filter(ethnicity_new_5!="White"),
                    aes(x = ethnicity_new_5, y = percentage, width = population, fill = ethnicity_sus_5,alpha = highlight,colour = highlight)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_color_manual(values = c( "yes" = "black","no" = "white"), guide = "none") +
  scale_alpha_discrete(range = c(0.8, 0.9)) +
  geom_label_repel(aes(label = round(percentage,1)), position = position_fill(vjust = 0.5), direction = "x", size = 8/.pt,show.legend=FALSE) + # if labels are desired
  facet_grid2(type~ethnicity_new_5, scales = "fixed", space = "fixed",strip = strip) +
  scale_fill_manual(values=rev(c("#80796BFF","#374E55FF","#DF8F44FF","#6A6599FF","#B24745FF","#00A1D5FF")),guide="none") +
  # theme(panel.spacing.x = unit(0, "npc")) + # if no spacing preferred between bars
  theme_void()  +
  theme(
    strip.text.y = element_blank()) +
  scale_x_discrete(
    expand = expansion(add = 0.5)
  ) + 
  theme(panel.spacing = unit(0.1, "lines")) +
  theme(
    strip.background = element_rect(
      color="black", fill=, linetype="solid"
    )
  ) +
  guides(fill = guide_legend(""),alpha="none",colour="none")

strip_white <- strip_themed(background_x = elem_list_rect(fill = c("#DF8F44FF")))

marimekko_white <- ggplot(df_sus_new_cross_perc_1 %>% filter(ethnicity_new_5=="White"),
                       aes(x = ethnicity_new_5, y = percentage, width = population, fill = ethnicity_sus_5,alpha = highlight,colour = highlight)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_color_manual(values = c( "yes" = "black","no" = "white"), guide = "none") +
  scale_alpha_discrete(range = c(0.8, 0.9)) +
  geom_label_repel(aes(label = round(percentage,1)), position = position_fill(vjust = 0.5), direction = "x", size = 8/.pt,show.legend=FALSE) + # if labels are desired
  facet_grid2(type~ethnicity_new_5, scales = "fixed", space = "fixed",strip = strip_white) +
  scale_fill_manual(values=rev(c("#80796BFF","#374E55FF","#DF8F44FF","#6A6599FF","#B24745FF","#00A1D5FF")),guide=T) +
  # theme(panel.spacing.x = unit(0, "npc")) + # if no spacing preferred between bars
  theme_void()  +
  theme(
    strip.text.y = element_blank() )+
  scale_x_discrete(
    expand = expansion(add = 0.5)
  ) + 
  theme(panel.spacing = unit(0.1, "lines")) +
  guides(fill = guide_legend(""),alpha="none",colour="none") 


marimekko <- ggarrange(marimekko_nw, marimekko_white,nrow=2, common.legend = TRUE, legend="bottom")

ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    "marimekko.png"
  ),
  marimekko,
  dpi = 600,
  width = 20,
  height = 20,
  units = "cm"
)

View(df_sus_new_cross_perc_1)

