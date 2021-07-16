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
                on_or_after=pandemic_start,
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


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "index_date", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.05,
        "int": {"distribution": "normal", "mean": 25, "stddev": 5},
        "float": {"distribution": "normal", "mean": 25, "stddev": 5},
    },
    index_date="2010-01-01",
    population=patients.satisfying(
        "registered AND (sex = 'M' OR sex = 'F')",
        registered=patients.registered_as_of("index_date"),
    ),

    ethnicity=patients.with_these_clinical_events(
        ethnicity_code,
        return_expectations={"incidence": 1.00},
    ),
    first_ethnicity_date=patients.with_these_clinical_events(
        ethnicity_code,
        returning="date",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"incidence": 1.0, "date": {"earliest": "index_date"}},
    ),
    **loop_over_codes(ethnicity_code),
    first_ethnicity_code=patients.with_these_clinical_events(
        ethnicity_code,
        returning="code",
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.05,
            "category": {
            },
        },
    ),
    
)
