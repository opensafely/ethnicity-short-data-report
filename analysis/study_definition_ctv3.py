from cohortextractor import (
    StudyDefinition,
    Measure,
    patients,
    codelist,
    combine_codelists,
    codelist_from_csv,
)

from codelists import *

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1970-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.2,
    },
    # STUDY POPULATION
    population=patients.all(),
    ethnicity_ctv3=patients.with_these_clinical_events(
        ethnicity_ctv3_codes,
        returning="code",
        find_last_match_in_period=True,
        include_date_of_match=False,
        return_expectations={
            "category": {
                "ratios": {
                    "Y9930": 0.2,
                    "XacvH": 0.2,
                    "XacvI": 0.2,
                    "XaJSg": 0.2,
                    "XaFwz": 0.2,
                }
            },
            "incidence": 0.75,
        },
    ),
    ethnicity_new_5=patients.with_these_clinical_events(
        ethnicity_new_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=False,
        return_expectations={
            "category": {
                "ratios": {"0": 0.1, "1": 0.5, "2": 0.1, "3": 0.1, "4": 0.1, "5": 0.1}
            },
            "incidence": 0.75,
        },
    ),
)

