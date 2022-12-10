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


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1970-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.2,
    },

    # STUDY POPULATION
    population=patients.satisfying(
        """
        (sex = "M" OR sex = "F") AND
        registered
        """,
        # registered
        registered=patients.registered_as_of("2022-01-01"),
        
        # SEX
        sex=patients.sex(
            return_expectations={
                "rate": "universal",
                "category": {"ratios": {"M": 0.49, "F": 0.51}},
            }
        ),
    ),

    ethnicity=patients.with_these_clinical_events(
        group8,
        return_expectations={"incidence": 0.50},
    ),

    **loop_over_codes(group8),
    first_ethnicity_code=patients.with_these_clinical_events(
        group8,
        returning="code",
        find_first_match_in_period=True,
        return_expectations={
            "incidence": 0.05,
            "category": {
                "ratios": {
                    "1024701000000100": 0.2,
                    "110751000000108": 0.2,
                    "110791000000100": 0.3,
                    "13440006": 0.2,
                    "14999008": 0.1,
                }
            },
        },
    ),
)