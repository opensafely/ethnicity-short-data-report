library('tidyverse')
library('sf')

files=dir(here::here("output"),pattern = "input")
files<-files[1:10]
print(files)
dataInp <- files %>%
  map_dfr(function(x)
    # # import data
    read_csv(here::here("output",x)) %>%
      select(starts_with("eth_")) %>%
      pivot_longer(
        cols = starts_with("eth_"),
        names_to = "snomedcode",
        names_prefix = "eth_",
        values_to = "count",
        values_drop_na = TRUE
      ) %>%
      group_by(snomedcode) %>%
      summarise(snomedcode_count=sum(count)))


files2=dir(here::here("codelists"),pattern = "group_")

data <- files2 %>%
  map(function(x)
    read_csv(here::here("codelists",x),
             col_names =c("snomedcode","term","group"),
             col_types = cols(col_character(),col_character())))  %>% 
  # combines in one tibble
  reduce(rbind) %>%
  inner_join(dataInp,by="snomedcode") %>% 
  ### remove unused codes
  filter(snomedcode_count!=0) %>%
  arrange(as.numeric(group)) %>%
  select("snomedcode","term")

fs::dir_create(here::here("output", "for_release"))
write_csv(data,here::here("output","for_release","snomed_ethnicity_counts.csv"))   


# df<-NULL
# df_comb<-NULL
# for (x in files) {
#   df<-as.data.table(read.csv(here::here("output",x)))
#   df<-melt(df,measure.vars=grep("^eth_", colnames(df)))
#   df<-df[, sum(value),by=variable]
#   df_comb<-rbind(df_comb,df)
# }
# 
# View(dataInp)
# View(df_comb)
