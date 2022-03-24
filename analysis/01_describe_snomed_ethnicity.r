library('tidyverse')
library('sf')
library('data.table')

files=dir(here::here("output"),pattern = "input")
files<-files[1:10]

df<-NULL
df_comb<-NULL
for (x in files) {
  df<-as.data.table(read.csv(here::here("output",x)))
  df<-melt(df,variable.name = "snomedcode", value.name = "snomedcode_count",measure.vars=grep("^eth_", colnames(df)))
  df<-df[, sum(snomedcode_count),by=snomedcode]
  df_comb<-rbind(df_comb,df)
}

df_comb<-as_tibble(df_comb) %>%
  rename("snomedcode_count"="V1")

files2=dir(here::here("codelists"),pattern = "group_")

data <- files2 %>%
  map_dfr(function(x)
    read_csv(here::here("codelists",x),
             col_names =c("snomedcode","term","group"),
             col_types = cols(col_character(),col_character())))  %>% 
  inner_join(df_comb,by="snomedcode") %>% 
  ### remove unused codes
  filter(snomedcode_count!=0) %>%
  arrange(as.numeric(group)) %>%
  select("snomedcode","term")

fs::dir_create(here::here("output", "for_release"))
write_csv(data,here::here("output","for_release","snomed_ethnicity_counts.csv"))   


# 
# View(dataInp)
# View(df_comb)
