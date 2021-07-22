from cohortextractor import (
    codelist,
    codelist_from_csv,
)
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity-uk-categories/516dea7b.csv",
    system="snomed",
    column="code",
)
