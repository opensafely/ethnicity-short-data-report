from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv, combine_codelists  # NOQA
from create_variables import demographic_variables, clinical_variables
from codelists import *

study = StudyDefinition(
    index_date="2015-01-01",
    default_expectations={
        "date": {"earliest": "index_date", "latest": "last_day_of_month(index_date)"},
        "rate": "uniform",
        "incidence": 0.65,
    },
    population=patients.satisfying(
        """
        registered AND
        (sex = "M" OR sex = "F")
        """,
        # Looking at registered patients yearly
        registered=patients.registered_with_one_practice_between(
            "index_date", "last_day_of_month(index_date)",
            return_expectations={"incidence": 0.9},
        )
    ),

    # Deregistration date (to censor these patients in longitudinal analyses)
    dereg_date=patients.date_deregistered_from_all_supported_practices(
        between=["2015-01-01", "2021-12-31"],
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "index_date"}},
    ),

    # Death date (to censor these patients in longitudinal analyses)
    died_date_ons=patients.died_from_any_cause(
        between=["2015-01-01", "2021-12-31"],
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "index_date"}},
    ),

    **demographic_variables,
    **clinical_variables,

)
