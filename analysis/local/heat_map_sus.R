library(arrow)
library(hrbrthemes)
library(viridis)
library(stringr)
library('glue')

# data<-read_feather(here::here("output","data","input.feather"))
population  <-   read_csv(here::here("output","from_jobserver","release_2022_11_18","simple_patient_counts_registered.csv"),col_types =(cols())) %>%
  filter( group=="all" ) %>%
  summarise(ethnicity_new_5 = "Unknown",
            population= population-ethnicity_new_5_filled) 

ethnicity_cat <-
  read_csv(here::here("output","from_jobserver","release_2022_11_18","simple_patient_counts_categories_registered.csv"),col_types =(cols())) %>%
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



df_sum = read_csv(here::here("output","from_jobserver","release_2022_11_18","simple_sus_crosstab_long_registered.csv")) 

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
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of 'SNOMED'") +
  geom_text(aes(label=percentage)) +
  ylab("SNOMED\n") + xlab("\nSUS") +
  theme_ipsum()

ggsave(
  filename = here::here(
    "output",
    "from_jobserver",
    "release_2022_11_18",
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
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of 'SNOMED'") +
  geom_text(aes(label=percentage)) +
  ylab("SNOMED\n") + xlab("\nSUS") +
  theme_ipsum()

ggsave(
  filename = here::here(
    "output",
    "from_jobserver",
    "release_2022_11_18",
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
  ylab("SNOMED\n") + xlab("\nSUS") +
  theme_ipsum()

########### 

perc_unk<- df_sum_perc_unk %>% mutate(matches=ethnicity_new_5==ethnicity_sus_5) %>% group_by(matches) %>% summarise(N=sum(`0`))
