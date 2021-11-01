from cohortextractor import (
    codelist,
    codelist_from_csv,
)
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity-uk-categories.csv",
    system="snomed",
    column="code",
)

ethnicity_categories = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity-2021.csv",
    system="snomed",
    column="snomedcode",
)

group1 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group1.csv",
    system="snomed",
    column="code",
)

group2 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group2.csv",
    system="snomed",
    column="code",
)

group3 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group3.csv",
    system="snomed",
    column="code",
)

group4 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group4.csv",
    system="snomed",
    column="code",
)

group5 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group5.csv",
    system="snomed",
    column="code",
)

group6 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group6.csv",
    system="snomed",
    column="code",
)

group7 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group7.csv",
    system="snomed",
    column="code",
)

group8 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group8.csv",
    system="snomed",
    column="code",
)

group9 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group9.csv",
    system="snomed",
    column="code",
)

group10 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group10.csv",
    system="snomed",
    column="code",
)
