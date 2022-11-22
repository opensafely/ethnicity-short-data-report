library(tidyverse)
library(scales)
library(readr)
library(ggsci)
library(ggpubr)


fs::dir_create(here::here("output", "time"))

input<-arrow::read_feather(here::here("output","time","data","input_time.feather"))

counts_first <- input %>%
  count(ethnicity_new_5_first) %>%
  mutate(measure = "First" ) %>% 
  rename( "Date"="ethnicity_new_5_first")

counts <- input %>%
  count(ethnicity_new_5_last) %>%
  mutate(measure = "Last" ) %>% 
  rename( "Date"="ethnicity_new_5_last") %>%
  bind_rows(counts_first) %>%
  mutate(n = case_when(n>7~round(n/5,0)*5),
         Date=as.Date(Date)) %>%
  complete( Date = seq(min(Date,na.rm = T), max(Date,na.rm = T), by = "day"),measure) %>%
  replace_na(list(n = 0)) %>%
  drop_na


write_csv(counts,here::here("output", "time","across_time_first_last.csv"))


counts_plot <-counts %>%
  ggplot(aes(x=as.Date(Date),y= n,colour=measure))+
  geom_line(stat="identity") + 
  ylim(0, max(counts$n,na.rm = T))


ggsave(
  filename = here::here(
    "output",
    "time",
    "first_last_plot.png"),
    counts_plot,
    dpi = 600,
    width = 30,
    height = 10,
    units = "cm"
  )



#### by group
demographic_covariates = c("age_band", "sex", "region", "imd")
clinical_covariates = c("dementia", "diabetes", "hypertension", "learning_disability")
covariates =c(demographic_covariates,clinical_covariates)

df_group <- as.data.frame(NULL)

for (i in covariates){
  df<-input %>% group_by_at(i) %>%  count(ethnicity_new_5_last) %>% 
  rename( "Date"="ethnicity_new_5_last") %>%
    mutate(
          n = case_when(n>7~round(n/5,0)*5),
          Date=as.Date(Date)) %>%
    rename(subgroup=i) %>%
    ungroup() %>%
    complete( Date = seq(min(Date,na.rm = T), max(Date,na.rm = T), by = "day"),subgroup) %>%
    replace_na(list(n = 0)) %>%
    mutate(
      group=i,
      subgroup=as.character(subgroup)) %>%
    drop_na
  
  df_group <-df_group %>%
      bind_rows(df)
  
  
  assign(paste0("df_",i),df)
  
  plot_i <- df %>%   ggplot(aes(x=Date,y= n,colour=subgroup))+
  geom_line(stat="identity") 

  assign(paste0("plot_",i),plot_i)
  
  ggsave(
    filename = here::here(
      "output",
      "time",
      paste0(i,"_plot.png"
    )),
    plot_i,
    dpi = 600,
    width = 30,
    height = 10,
    units = "cm"
  )
  
}

write_csv(df_group,here::here("output", "time","across_time_covariates.csv"))


