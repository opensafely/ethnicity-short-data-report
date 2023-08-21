library(tidyverse)
library(scales)
library(readr)
library(ggsci)
library(ggpubr)
library(lubridate)
library(glue)

demographic_covariates = c("age_band", "sex", "region", "imd")
clinical_covariates = c("dementia", "diabetes", "hypertension", "learning_disability")
covariates =c(demographic_covariates,clinical_covariates)

fs::dir_create(here::here("output", "time"))


for (covar in covariates){

  input<-read_csv(here::here("output","yearly",glue("measure_ethnicity_{covar}_rate.csv"))) 
  input<-input %>% mutate(ethnicity_new_5_month = case_when(ethnicity_new_5_month > 7 ~ round(ethnicity_new_5_month/5,0)*5),
                          population = case_when(population > 7 ~ round(population/5,0)*5),
                          value = ethnicity_new_5_month / population)

  ifelse(covar %in% clinical_covariates,
    input<-input %>%   mutate(covariant := 
               case_when(get(covar) == TRUE ~ "Present",
                         get(covar)== FALSE ~ "Absent"))
    ,
    input<-input %>%   mutate(covariant := 
                         case_when(get(covar) == "F" ~ "Female",
                                   get(covar)== "M" ~ "Male",
                                   get(covar)==0~"Unknown",
                                   get(covar)==1~"1: Most deprived",
                                   get(covar)==5~"5: Least deprived",
                                   T~as.character(get(covar))))
  )
  
  

  write_csv(input,here::here("output", "time",glue("{covar}_rate.csv")))
  
  counts_plot <-input %>%
    ggplot(aes(x=date,y= value,colour=factor(covariant)))+
    geom_line(stat="identity") +
    ylim(0, 1) +
    scale_x_date(date_labels = "%Y",
                 breaks = seq.Date(from = as.Date("1900-01-01"),
                                   to = as.Date("2022-01-01"),
                                   by = "5 years")) +
    theme_bw()+
    theme(axis.text.x = element_text(angle = 90, vjust=0.5),
          panel.grid.minor = element_blank())  +
    scale_color_lancet()   +
    guides(colour=guide_legend(title=""))

  ggsave(
    filename = here::here(
      "output",
      "time",
      glue("{covar}_rate.png")),
    counts_plot,
    dpi = 600,
    width = 30,
    height = 10,
    units = "cm"
  )
}

eth_5<-c("asian","black","mixed","white","other","month")

df<-tibble()
for (eth in eth_5){
  
  input<-read_csv(here::here("output","yearly",glue("measure_ethnicity_new_5_{eth}_rate.csv")))
  input<- input %>%
    rename(N=!!glue("ethnicity_new_5_{eth}")) %>%
    mutate(ethnicity=eth)
  if (eth == "month"){
    input<- input %>%
    mutate(ethnicity = "all")
  }
  df<-df %>% bind_rows(input)  
  
  
}
df<-df %>% mutate(N = case_when(N > 7 ~ round(N/5,0)*5),
                        population = case_when(population > 7 ~ round(population/5,0)*5),
                        value = N / population)
write_csv(df,here::here("output", "time","ethnicity_5_rate.csv"))

counts_plot <-df %>%
  ggplot(aes(x=date,y= value,colour=factor(ethnicity)))+
  geom_line(stat="identity") +
  ylim(0, 1) +
  scale_x_date(date_labels = "%Y",
               breaks = seq.Date(from = as.Date("1900-01-01"),
                                 to = as.Date("2022-01-01"),
                                 by = "5 years")) +
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust=0.5),
        panel.grid.minor = element_blank())  +
  scale_color_lancet()   +
  guides(colour=guide_legend(title=""))

ggsave(
  filename = here::here(
    "output",
    "time",
    "ethnicity_rate.png"),
  counts_plot,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)


input<-read_csv(here::here("output","yearly","nulldates","measure_nulldate_rate.csv"))
input<-input %>% mutate(population_living = case_when(population_living > 7 ~ round(population_living/5,0)*5),
                        population = case_when(population > 7 ~ round(population/5,0)*5),
                        value = population_living / population)
write_csv(input,here::here("output", "time","nulldate_rate.csv"))

input<-read_csv(here::here("output","yearly","nulldates","measure_nulldate_age_band_rate.csv"))
input<-input %>% mutate(null_date = case_when(null_date > 7 ~ round(null_date/5,0)*5),
                        population_living = case_when(population_living > 7 ~ round(population_living/5,0)*5),
                        value = null_date / population_living)
write_csv(input,here::here("output", "time","nulldate_age_band_rate.csv"))

input<-read_csv(here::here("output","yearly","nulldates","measure_nulldate_age_band_allpt_rate.csv"))
input<-input %>% mutate(null_date = case_when(null_date > 7 ~ round(null_date/5,0)*5),
                        population = case_when(population > 7 ~ round(population/5,0)*5),
                        value = null_date / population)
write_csv(input,here::here("output", "time","nulldate_age_band_allpts_rate.csv"))
