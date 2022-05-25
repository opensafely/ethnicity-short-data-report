library('tidyverse')
library('sf')

fs::dir_create(here::here("output","tables"))

# # import data
df_input <- read_csv(here::here("output","input_ctv3.csv"),
                     col_types = cols_only(
                      ethnicity_new_5 = col_integer(),
                      ethnicity_ctv3 = col_character()))

df<-df_input %>% 
  filter(is.na(ethnicity_new_5) | ethnicity_new_5 == 0) %>%
  mutate(ethnicity_new_5=case_when(is.na(ethnicity_new_5)~"Missing",
                                   ethnicity_new_5==0~"Unknown")) %>%
  group_by(ethnicity_new_5,ethnicity_ctv3) %>%
  summarise(N=n())  %>% 
  mutate(N=case_when(N>5~N))

df_wide<-df %>%
  pivot_wider(names_from = ethnicity_new_5, values_from = N)
  
write_csv(df_wide,here::here("output","tables","ctv3_check.csv")) 