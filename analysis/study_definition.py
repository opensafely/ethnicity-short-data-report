from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist,
    combine_codelists,
    codelist_from_csv,
)

from codelists import *

def make_variable(code):
    return {
        f"eth_{code}": (
            patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                on_or_after="2010-01-01",
                returning="number_of_matches_in_period",
                include_date_of_match=False,
                date_format="YYYY-MM-DD",
                return_expectations={
                    "incidence": 0.1,
                    "int": {"distribution": "normal", "mean": 3, "stddev": 1},
                },
            )
        )
    }


def loop_over_codes(code_list):
    variables = {}
    for code in code_list:
        variables.update(make_variable(code))
    return variables


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

SELECT patient_id, code, COUNT(1)
INTO ethcount
FROM CodedEvent
WHERE code IN
(
    ethnicity_codes
)
GROUP BY patient_id, code

)

