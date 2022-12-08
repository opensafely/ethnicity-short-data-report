library(tidyverse)
library(scales)
library(readr)
library(ggsci)
library(ggpubr)
library(lubridate)

fs::dir_create(here::here("output", "time"))

input<-arrow::read_feather(here::here("output","extract","input.feather"))

counts_first <- input %>%
  group_by(month = lubridate::floor_date(ethnicity_new_5_first, "month")) %>%
  count(month) %>%
  mutate(
    measure = "First")
  



counts <- input %>%
  group_by(month = floor_date(ethnicity_new_5_date, "month")) %>%
  count(month) %>%
  mutate(
    measure = "last") %>%
  bind_rows(counts_first) %>%
  mutate(Date=as_date(month)) %>%
  drop_na(Date) %>%
  mutate(n = case_when(n>7~round(n/5,0)*5))%>%
  ungroup %>%
  complete( Date = seq(min(Date,na.rm = T), max(Date,na.rm = T), by = "months"),measure) %>%
  select(-month) %>%
  replace_na(list(n = 0)) %>%
  drop_na


write_csv(counts,here::here("output", "time","across_time_months.csv"))

counts_first_year <- input %>%
  group_by(year = lubridate::floor_date(ethnicity_new_5_first, "year")) %>%
  count(year) %>%
  mutate(
    measure = "First")




counts_year <- input %>%
  group_by(year = floor_date(ethnicity_new_5_date, "year")) %>%
  count(year) %>%
  mutate(
    measure = "last") %>%
  bind_rows(counts_first_year) %>%
  mutate(Date=as_date(year)) %>%
  drop_na(Date) %>%
  mutate(n = case_when(n>7~round(n/5,0)*5))%>%
  ungroup %>%
  complete( Date = seq(min(Date,na.rm = T), max(Date,na.rm = T), by = "years"),measure) %>%
  select(-year) %>%
  replace_na(list(n = 0)) %>%
  drop_na


write_csv(counts,here::here("output", "time","across_time_years.csv"))


counts_plot <-counts %>%
  ggplot(aes(x=Date,y= n,colour=measure))+
  geom_line(stat="identity") + 
  ylim(0, max(counts$n,na.rm = T)) +
  scale_x_date(date_labels = "%Y", 
               breaks = seq.Date(from = as.Date("1900-01-01"), 
                                                     to = as.Date("2022-01-01"), 
                                                     by = "20 years")) +
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust=0.5), 
        panel.grid.minor = element_blank())  + 
  scale_color_lancet() 

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



counts_plot_year <-counts_year %>%
  ggplot(aes(x=Date,y= n,colour=measure))+
  geom_line(stat="identity") + 
  ylim(0, max(counts$n,na.rm = T)) +
  scale_x_date(date_labels = "%Y", 
               breaks = seq.Date(from = as.Date("1900-01-01"), 
                                 to = as.Date("2022-01-01"), 
                                 by = "20 years")) +
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust=0.5), 
        panel.grid.minor = element_blank())  + 
  scale_color_lancet() 

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
  df<-input %>% 
    group_by(year = floor_date(ethnicity_new_5_date, "year")) %>%
    group_by_at(i) %>% 
    count(year) %>%
    mutate(
          n = case_when(n>7~round(n/5,0)*5),
          Date=as.Date(year)) %>%
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


