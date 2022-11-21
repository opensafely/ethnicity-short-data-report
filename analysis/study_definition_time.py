from cohortextractor import (
    StudyDefinition,
    patients,
    codelist,
    codelist_from_csv,
    combine_codelists,
)  # NOQA
from create_variables_time import demographic_variables, clinical_variables
from codelists import *
from config import *


study = StudyDefinition(
    index_date=index_date,
    default_expectations={
        "date": {"earliest": "index_date", "latest": "last_day_of_month(index_date)"},
        "rate": "uniform",
        "incidence": 0.65,
    },
    population=patients.satisfying(
        """
        (sex = "M" OR sex = "F")
        """,
    ),
    # Death date (to censor these patients in longitudinal analyses)
    death_date_ons=patients.died_from_any_cause(
        between=["2015-01-01", "2021-12-31"],
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "index_date"}},
    ),
    **demographic_variables,
    **clinical_variables,
)
