library('tidyverse')
library('sf')
library('data.table')

fs::dir_create(here::here("output", "for_release"))
fs::dir_create(here::here("output", "unredacted"))

files=dir(here::here("output"),pattern = "input")
files<-files[1:10]

df<-NULL
df_comb<-NULL
for (x in files) {
  df<-as.data.table(read.csv(here::here("output",x)))
  df<-melt(df,variable.name = "code", value.name = "snomedcode_count",measure.vars=grep("^eth_", colnames(df)))
  df<-df[, sum(snomedcode_count),by=code]
  df_comb<-rbind(df_comb,df)
}

df_comb<-as_tibble(df_comb) %>%
  mutate(code = str_sub(code,5))   %>%
  rename("snomedcode_count"="V1")

files2=dir(here::here("codelists"),pattern = "group_")

data <- files2 %>%
  map_dfr(function(x)
    read_csv(here::here("codelists",x),
             col_names =c("code","term","group"),
             col_types = cols(col_character(),col_character())))  %>% 
  inner_join(df_comb,by="code") %>% 
  ### remove unused codes
  arrange(as.numeric(group))


write_csv(data,here::here("output","unredacted","snomed_ethnicity_counts.csv"))   

data <- data %>%
  mutate(snomedcode_count=case_when(snomedcode_count<5 ~ as.integer(5),
                                    T ~ snomedcode_count))

write_csv(data,here::here("output","for_release","snomed_ethnicity_counts.csv"))   

