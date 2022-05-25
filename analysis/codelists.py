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
