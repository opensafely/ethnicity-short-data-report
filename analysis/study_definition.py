from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist,
    combine_codelists,
    codelist_from_csv,
)

from codelists import *

## STUDY POPULATION


## STUDY POPULATION
# Defines both the study population and points to the important covariates

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1970-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.2,
    },

    # STUDY POPULATION
   population=patients.registered_with_one_practice_between("2021-07-01","2021-07-01"),

SELECT patient_id,  code, COUNT(1)
INTO ethcount
FROM CodedEvent
WHERE code IN
(
    ethnicity_codes
)
GROUP BY patient_id, code

)

