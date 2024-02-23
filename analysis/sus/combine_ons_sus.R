library("tidyverse")
library("here")
library("glue")
library("stringr")
library("scales")
library('magrittr')

## import ONS Census data
eth_ons_input_2001 <- read_csv(here::here("data", "ethnicity_2021_census_2001_5_categories.csv.gz"))
eth_ons_input_2021 <- read_csv(here::here("data", "ethnicity_2021_census_5_categories.csv.gz"))

### Add England to ONS Census data
eth_ons <- eth_ons_input_2001 %>%
  group_by(group, Ethnic_Group, cohort) %>%
  summarise(N = sum(N)) %>%
  group_by(group, cohort) %>%
  mutate(
    N = N,
    Total = sum(N),
    region = "England"
  ) %>%
  bind_rows(eth_ons_input_2001)

eth_ons_2021 <- eth_ons_input_2021 %>%
  group_by(group, Ethnic_Group, cohort) %>%
  summarise(N = sum(N)) %>%
  group_by(group, cohort) %>%
  mutate(
    N = N,
    Total = sum(N),
    region = "England"
  ) %>%
  bind_rows(eth_ons_input_2021)

# get total population per region for OS data
for (codelist in c("new", "ctv3")) {
  ifelse(codelist == "new", ethnicity <- "ethnicity_new_5_filled", ethnicity <- "ethnicity_5_filled")
  # get total population per region for OS data
  assign(glue("population_{codelist}"), read_csv(here::here("output", "sus", "simplified_output", "5_group", "tables", glue("simple_patient_counts_5_group_{codelist}_sus_registered.csv")), col_types = (cols())) %>%
           filter(group == "region" | group == "all") %>%
           summarise(
             subgroup = subgroup,
             !!glue("population_{codelist}") := !!as.name(ethnicity),
             !!glue("population_{codelist}_supp") := any_filled
           ) %>%
           pivot_longer(contains("population"),
                        names_to = c("cohort"),
                        names_pattern = "_(.*)",
                        values_to = "Total"
           ))
}
population <- population_new %>%
  bind_rows(population_ctv3)

# filter OS data to regions

for (codelist in c("new", "ctv3")) {
  ethnicity <-
    read_csv(here::here("output", "sus", "simplified_output", "5_group", "tables", glue("simple_patient_counts_categories_5_group_{codelist}_sus_registered.csv")), col_types = (cols())) %>%
    filter(group == "region" | group == "all") %>%
    select(-population) %>%
    rename_all(tolower)

  assign(glue("ethnicity_2001_{codelist}"), ethnicity %>%
    # prune column headings
    rename_with(~ sub("supplemented", glue("{codelist}supp"), .), contains("supplemented")) %>%
    rename_with(~ sub("ethnicity_", "ctv3_", .), contains("ethnicity_5")) %>%
    rename_with(~ sub("ethnicity_", "", .), contains("ethnicity_")) %>%
    rename_with(~ sub("_5_filled", "", .), contains("_5_filled")) %>%
    # remove unused columns
    select(-contains("filled"), -contains("missing"), -contains("sus")) %>%
    # remove unused columns
    select(-contains("filled"), -contains("missing"), -contains("sus")) %>%
    pivot_longer(
      cols = c(contains("_")),
      names_to = c("ethnicity", "cohort"),
      names_sep = "_",
      values_to = "N"
    ) %>%
    filter(cohort != "any") %>%
    mutate(cohort = case_when(
      cohort == glue("{codelist}supp") ~ glue("{codelist}_supp"),
      T ~ cohort
    )) %>%
    inner_join(population, by = c("subgroup", "cohort")) %>%
    summarise(
      region = case_when(
        subgroup == "with records" ~ "England",
        TRUE ~ subgroup
      ),
      Ethnic_Group = str_to_sentence(ethnicity),
      Ethnic_Group = fct_relevel(
        Ethnic_Group,
        "Asian", "Black", "Mixed", "White", "Other"
      ),
      N = N,
      Total = Total,
      group = 5,
      cohort
    ))
}

ethnicity_2001 <- ethnicity_2001_ctv3 %>%
  bind_rows(ethnicity_2001_new) %>%
  bind_rows(eth_ons) %>%
  mutate(
    N = round(N / 5) * 5,
    Total = round(Total / 5) * 5,
    percentage = N / Total * 100,
    group = as.character(group),
    region = case_when(
      region == "East" ~ "East of England",
      region == "Yorkshire and The Humber" ~ "Yorkshire and the Humber",
      TRUE ~ region
    )
  ) %>%
  filter(region != "Wales")

write_csv(ethnicity_2001, here::here("output", "sus", "simplified_output", "5_group", "tables", "ethnic_group_2021_registered_with_2001_categories.csv"))


### 16 group
## import ONS Census data
eth_ons_input_2001 <- read_csv(here::here("data", "ethnicity_2021_census_2001_16_categories.csv.gz")) %>%
  mutate(
    Ethnic_Group = case_when(
      Ethnic_Group == "English, Welsh, Scottish, Northern Irish or British" ~ "White British",
      Ethnic_Group == "Irish" ~ "White Irish",
      Ethnic_Group == "Arab" ~ "Any other ethnic group",
      Ethnic_Group == "Gypsy or Irish Traveller" ~ "Other White",
      Ethnic_Group == "Roma" ~ "Other White",
      Ethnic_Group == "Other Mixed or Multiple ethnic groups" ~ "Other_Mixed",
      TRUE ~ Ethnic_Group
    )
  )
eth_ons_input_2021 <- read_csv(here::here("data", "ethnicity_2021_census_16_categories.csv.gz")) %>%
  mutate(
    Ethnic_Group = case_when(
      Ethnic_Group == "English, Welsh, Scottish, Northern Irish or British" ~ "White British",
      Ethnic_Group == "Irish" ~ "White Irish",
      Ethnic_Group == "Arab" ~ "Any other ethnic group",
      Ethnic_Group == "Gypsy or Irish Traveller" ~ "Other White",
      Ethnic_Group == "Roma" ~ "Other White",
      Ethnic_Group == "Other Mixed or Multiple ethnic groups" ~ "Other_Mixed",
      TRUE ~ Ethnic_Group
    )
  )

### Add England to ONS Census data
eth_ons_16 <- eth_ons_input_2001 %>%
  group_by(group, Ethnic_Group, cohort) %>%
  summarise(N = sum(N)) %>%
  group_by(group, cohort) %>%
  mutate(
    N = N,
    Total = sum(N),
    region = "England",
  ) %>%
  bind_rows(eth_ons_input_2001)

eth_ons_2021 <- eth_ons_input_2021 %>%
  group_by(group, Ethnic_Group, cohort) %>%
  summarise(N = sum(N)) %>%
  group_by(group, cohort) %>%
  mutate(
    N = N,
    Total = sum(N),
    region = "England"
  ) %>%
  bind_rows(eth_ons_input_2021)

for (codelist in c("new", "ctv3")) {
  ifelse(codelist == "new", ethnicity <- "ethnicity_new_16_filled", ethnicity <- "ethnicity_16_filled")
  # get total population per region for OS data
  assign(glue("population_{codelist}"), read_csv(here::here("output", "sus", "simplified_output", "16_group", "tables", glue("simple_patient_counts_16_group_{codelist}_sus_registered.csv")), col_types = (cols())) %>%
    filter(group == "region" | group == "all") %>%
    summarise(
      subgroup = subgroup,
      !!glue("population_{codelist}") := !!as.name(ethnicity),
      !!glue("population_{codelist}_supp") := any_filled
    ) %>%
    pivot_longer(contains("population"),
      names_to = c("cohort"),
      names_pattern = "_(.*)",
      values_to = "Total"
    ))
}
population <- population_new %>%
  bind_rows(population_ctv3)


# filter OS data to regions

for (codelist in c("new", "ctv3")) {
  ethnicity <-
    read_csv(here::here("output", "sus", "simplified_output", "16_group", "tables", glue("simple_patient_counts_categories_16_group_{codelist}_sus_registered.csv")), col_types = (cols())) %>%
    filter(group == "region" | group == "all") %>%
    select(-population)

  assign(glue("ethnicity_2001_{codelist}"), ethnicity %>%
    # prune column headings
    rename_with(~ sub("supplemented", glue("{codelist}supp"), .), contains("supplemented")) %>%
    rename_with(~ sub("ethnicity_", "ctv3_", .), contains("ethnicity_16")) %>%
    rename_with(~ sub("ethnicity_", "", .), contains("ethnicity_")) %>%
    rename_with(~ sub("_16_filled", "", .), contains("_16_filled")) %>%
    # remove unused columns
    select(-contains("filled"), -contains("missing"), -contains("sus")) %>%
    pivot_longer(
      cols = c(contains("_")),
      names_to = c("ethnicity", "cohort"),
      names_pattern = "(^.*)_(.*)",
      values_to = "N"
    ) %>%
    filter(cohort != "any") %>%
    mutate(cohort = case_when(
      cohort == glue("{codelist}supp") ~ glue("{codelist}_supp"),
      T ~ cohort
    )) %>%
    inner_join(population, by = c("subgroup", "cohort")) %>%
    summarise(
      region = case_when(
        subgroup == "with records" ~ "England",
        TRUE ~ subgroup
      ),
      Ethnic_Group = fct_relevel(
        ethnicity,
        "Indian", "Pakistani", "Bangladeshi", "Other_Asian", "Caribbean", "African", "Other_Black", "White_and_Black_Caribbean", "White_and_Black_African", "White_and_Asian", "Other_Mixed", "White_British", "White_Irish", "Other_White", "Chinese", "Any_other_ethnic_group"
      ),
      N = N,
      Total = Total,
      group = 16,
      cohort
    ))
}

ethnicity_2001 <- ethnicity_2001_ctv3 %>%
  bind_rows(ethnicity_2001_new) %>%
  bind_rows(eth_ons_16) %>%
  mutate(
    N = round(N / 5) * 5,
    Total = round(Total / 5) * 5,
    percentage = N / Total * 100,
    group = as.character(group),
    region = case_when(
      region == "East" ~ "East of England",
      region == "Yorkshire and The Humber" ~ "Yorkshire and the Humber",
      TRUE ~ region
    )
  ) %>%
  filter(region != "Wales")

write_csv(ethnicity_2001, here::here("output", "sus", "simplified_output", "16_group", "tables", "ethnic_group_2021_registered_with_2001_categories.csv"))
