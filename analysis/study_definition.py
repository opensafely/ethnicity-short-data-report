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
        f"snomed_{code}": (
            patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                on_or_after="2010-01-01",
                returning="number_of_matches_in_period",
                include_date_of_match=True,
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
   population=patients.registered_with_one_practice_between(
        "2020-07-01", "2021-07-01"
   ),

    dereg_date=patients.date_deregistered_from_all_supported_practices(
        on_or_before="2021-07-01", 
        date_format="YYYY-MM",
        return_expectations={"date": {"earliest": "2010-01-01"}},

    ),

    ## DEMOGRAPHIC COVARIATES
    # AGE
    age=patients.age_as_of(
        "2021-07-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),

    # SEX
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        return_expectations={"incidence": 0.50},
    ),

    first_ethnicity_date=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.1, "date": {"earliest": "2010-01-01"}},
    ),
    **loop_over_codes(ethnicity_codes),
    first_ethnicity_code=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="code",
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.05,
            "category": {
                "ratios": {
                    "1325161000000102": 0.2,
                    "1325181000000106": 0.2,
                    "1325021000000106": 0.3,
                    "1325051000000101": 0.2,
                    "1325061000000103": 0.1,
                }
            },
        },
    ),
)