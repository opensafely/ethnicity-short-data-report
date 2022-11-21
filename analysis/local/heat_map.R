library(arrow)
library(hrbrthemes)
library(viridis)
library(stringr)
library('glue')

# data<-read_feather(here::here("output","data","input.feather"))


df_sum = read_csv(here::here("output","from_jobserver","release_2022_11_11","simple_latest_common_ethnicity_new_5_registered.csv"))           

df_sum2 <-df_sum %>%
  ungroup() %>%
  # mutate(across(-1)/rowSums(across(-1))) %>%
  mutate(latest=ethnicity_new_5) %>%
  select(-ethnicity_new_5) %>% 
  pivot_longer(cols=starts_with("ethnicity_new_5"),names_prefix ="ethnicity_new_5_",names_to = "common",values_to="val") %>%
  filter(latest!="White_British",latest!="White_Irish",latest!="Other_White",common!="White_British",common!="White_Irish",common!="Other_White") %>%
  mutate(common=str_to_title(common)) 


ggplot(df_sum2, aes(latest, common, fill= val)) + 
  geom_tile() +
  scale_fill_viridis(discrete=FALSE) 


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
         )  #%>%
# filter(latest!="White_British",latest!="White_Irish",latest!="Other_White",common!="White_British",common!="White_Irish",common!="Other_White")


latest_common<- ggplot(df_sum2, aes(common, latest, fill= val)) + 
  geom_tile() +
  # scale_fill_viridis(discrete=FALSE,direction=-1) +
  # scale_fill_gradient(low="white", high="blue") +
  scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of 'Latest Ethnicity'") +
  geom_text(aes(label = round(val, 1))) +
  ylab("Latest Ethnicity\n") + xlab("\nMost Frequent Ethnicity") +
  theme_ipsum()


ggsave(
  filename = here::here(
    "output",
    "local",
    "latest_common.png"
  ),
  latest_common,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)

#### 16 group
df_sum = read_csv(here::here("output","from_jobserver","release_2022_11_11","16_group","simple_latest_common_ethnicity_new_16_registered.csv"))           

df_sum2<-df_sum %>%
  ungroup() %>%
  # mutate(across(-1)/rowSums(across(-1))) %>%
  mutate(latest=ethnicity_new_16) %>%
  select(-ethnicity_new_16) %>% 
  pivot_longer(cols=starts_with("ethnicity_new_16"),names_prefix ="ethnicity_new_16_",names_to = "common",values_to="val") %>%
  filter(latest!="White_British",latest!="White_Irish",latest!="Other_White",common!="White_British",common!="White_Irish",common!="Other_White")



ggplot(df_sum2, aes(latest, common, fill= val)) + 
  geom_tile() +
  scale_fill_viridis(discrete=FALSE) 


df_sum2<-df_sum %>%
  ungroup() %>%
  mutate(across(-1)/rowSums(across(-1),na.rm = T)) %>%
  mutate(latest=ethnicity_new_16) %>%
  select(-ethnicity_new_16) %>% 
  pivot_longer(cols=starts_with("ethnicity_new_16"),names_prefix ="ethnicity_new_16_",names_to = "common",values_to="val") #%>%
  # filter(latest!="White_British",latest!="White_Irish",latest!="Other_White",common!="White_British",common!="White_Irish",common!="Other_White")


ggplot(df_sum2, aes(common, latest, fill= val)) + 
  geom_tile() +
  scale_fill_viridis(discrete=FALSE) +
  geom_text(aes(label = round(val, 2))) 
