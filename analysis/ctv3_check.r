library('tidyverse')
library('sf')

fs::dir_create(here::here("output","tables"))

# # import data
df_input <- read_csv(here::here("output","input_ctv3.csv"))
df_input$ethnicity_ctv3[which(df_input$ethnicity_ctv3=="Y9930"& df_input$ethnicity_new_5=="0")]<-NA
df<-df_input %>% 
  mutate(ethnicity_new_5=case_when(is.na(ethnicity_new_5)~"Missing",
                                   ethnicity_new_5==0~"Unknown")) %>%
  drop_na(ethnicity_new_5) %>%
  group_by(ethnicity_new_5,ethnicity_ctv3) %>%
  summarise(N=n())  %>% 
  mutate(N=case_when(N>5~N))

df_wide<-df %>%
  pivot_wider(names_from = ethnicity_new_5, values_from = N)
  
write_csv(df_wide,here::here("output","tables","ctv3_check.csv")) 