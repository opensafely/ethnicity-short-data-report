from cohortextractor import (
    codelist,
    codelist_from_csv,
)
ethnicity_codes = codelist_from_csv(
    "codelists/ethnicity-uk-categories/3d6551e9.csv",
    system="snomed",
    column="code",
)
