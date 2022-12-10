from cohortextractor import (
    codelist,
    codelist_from_csv,
)


ethnicity_ctv3_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv", system="ctv3", column="Code",
)


ethnicity_new_codes = codelist_from_csv(
    "codelists/user-candrews-full_ethnicity_coded.csv",
    system="snomed",
    category_column="Grouping_6",
    column="snomedcode",
)

ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity-uk-categories.csv", system="snomed", column="code",
)

group1 = codelist_from_csv(
    "codelists/group_1.csv",
    system="snomed",
    column="snomedcode",
)

group2 = codelist_from_csv(
    "codelists/group_2.csv",
    system="snomed",
    column="snomedcode",
)

group3 = codelist_from_csv(
    "codelists/group_3.csv",
    system="snomed",
    column="snomedcode",
)

group4 = codelist_from_csv(
    "codelists/group_4.csv",
    system="snomed",
    column="snomedcode",
)

group5 = codelist_from_csv(
    "codelists/group_5.csv",
    system="snomed",
    column="snomedcode",
)

group6 = codelist_from_csv(
    "codelists/group_6.csv",
    system="snomed",
    column="snomedcode",
)

group7 = codelist_from_csv(
    "codelists/group_7.csv",
    system="snomed",
    column="snomedcode",
)

group8 = codelist_from_csv(
    "codelists/group_8.csv",
    system="snomed",
    column="snomedcode",
)

group9 = codelist_from_csv(
    "codelists/group_9.csv",
    system="snomed",
    column="snomedcode",
)

group10 = codelist_from_csv(
    "codelists/group_10.csv",
    system="snomed",
    column="snomedcode",
)

