library(tidyverse)
library(scales)
library(readr)
library(ggsci)
library(ggpubr)
library(lubridate)

fs::dir_create(here::here("output", "time"))

input<-arrow::read_feather(here::here("output","extract_time","input_time.feather")) %>%
  mutate(ethnicity_new_5_first=case_when(ethnicity_new_5_first<as.Date("1900-01-01") ~ as.Date("1899-12-01"),
                                         ethnicity_new_5_first>as.Date("2022-12-21")~as.Date("2023-01-01"),
                                         T~as.Date(ethnicity_new_5_first)))

counts_first <- input %>%
  group_by(month = lubridate::floor_date(ethnicity_new_5_first, "month")) %>%
  count(month) %>%
  mutate(
    measure = "First")
  



counts <- input %>%
  group_by(month = floor_date(ethnicity_new_5_latest, "month")) %>%
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
  scale_color_lancet()   +
  guides(colour=guide_legend(title=""))

ggsave(
  filename = here::here(
    "output",
    "time",
    "first_last_plot_month.png"),
  counts_plot,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)


write_csv(counts,here::here("output", "time","across_time_months.csv"))

counts_first_year <- input %>%
  group_by(year = floor_date(ethnicity_new_5_first, "year")) %>%
  count(year) %>%
  mutate(
    measure = "First")




counts_year <- input %>%
  group_by(year = floor_date(ethnicity_new_5_latest, "year")) %>%
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



write_csv(counts_year,here::here("output", "time","across_time_years.csv"))





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
  scale_color_lancet()   +
  guides(colour=guide_legend(title=""))

ggsave(
  filename = here::here(
    "output",
    "time",
    "first_last_plot_year.png"),
  counts_plot_year,
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
    group_by(year = floor_date(ethnicity_new_5_latest, "year")) %>%
    group_by_at(i) %>% 
    count(year) %>%
    mutate(
          Date=as.Date(year)) %>%
    rename(subgroup=i) %>%
    ungroup() %>%
    complete( Date = seq(min(Date,na.rm = T), max(Date,na.rm = T), by = "year"),subgroup) %>%
    replace_na(list(n = 0)) %>%
    mutate(
      group=i,
      subgroup=as.character(subgroup)) %>%
    drop_na

  
  
  df_group <-df_group %>%
      bind_rows(df)
  

  
  assign(paste0("df_",i),df)
  
  plot_i <- df %>%   ggplot(aes(x=Date,y= n,colour=subgroup))+
  geom_line(stat="identity") +
  guides(color=guide_legend(title=i))

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

df_group_round<- df_group %>%
  mutate(n = case_when(n>7~round(n/5,0)*5))

write_csv(df_group_round,here::here("output", "time","across_time_covariates_rounded.csv"))
