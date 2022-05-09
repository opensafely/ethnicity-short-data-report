from cohortextractor import (
    codelist,
    codelist_from_csv,
)
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity-uk-categories.csv",
    system="snomed",
    column="code",
)

group1 = codelist_from_csv(
    "codelists/group_1.csv",
    system="snomed",
    column="code",
)

group2 = codelist_from_csv(
    "codelists/group_2.csv",
    system="snomed",
    column="code",
)

group3 = codelist_from_csv(
    "codelists/group_3.csv",
    system="snomed",
    column="code",
)

group4 = codelist_from_csv(
    "codelists/group_4.csv",
    system="snomed",
    column="code",
)

group5 = codelist_from_csv(
    "codelists/group_5.csv",
    system="snomed",
    column="code",
)

group6 = codelist_from_csv(
    "codelists/group_6.csv",
    system="snomed",
    column="code",
)

group7 = codelist_from_csv(
    "codelists/group_7.csv",
    system="snomed",
    column="code",
)

group8 = codelist_from_csv(
    "codelists/group_8.csv",
    system="snomed",
    column="code",
)

group9 = codelist_from_csv(
    "codelists/group_9.csv",
    system="snomed",
    column="code",
)

group10 = codelist_from_csv(
    "codelists/group_10.csv",
    system="snomed",
    column="code",
)

group11 = codelist_from_csv(
    "codelists/group_11.csv",
    system="snomed",
    column="code",
)