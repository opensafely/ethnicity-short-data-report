from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv, combine_codelists  # NOQA
from create_variables import demographic_variables, clinical_variables
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
    died_date_ons=patients.died_from_any_cause(
        between=["2015-01-01", "2021-12-31"],
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "index_date"}},
    ),

    **demographic_variables,
    **clinical_variables,
    white_count = patients.with_these_clinical_events(
                white,
                on_or_before="index_date",
                returning="number_of_matches_in_period",
                return_expectations={
        "int": {"distribution": "normal", "mean": 6, "stddev": 3},
        "incidence": 0.8,
    },
    ),

        black_count = patients.with_these_clinical_events(
                black,
                on_or_before="index_date",
                returning="number_of_matches_in_period",
    return_expectations={
        "int": {"distribution": "normal", "mean": 6, "stddev": 3},
        "incidence": 0.1,
    },
    ),

        asian_count = patients.with_these_clinical_events(
                asian,
                on_or_before="index_date",
                returning="number_of_matches_in_period",
    return_expectations={
        "int": {"distribution": "normal", "mean": 6, "stddev": 3},
        "incidence": 0.1,
    },
    ),

        other_count = patients.with_these_clinical_events(
                other,
                on_or_before="index_date",
                returning="number_of_matches_in_period",
    return_expectations={
        "int": {"distribution": "normal", "mean": 6, "stddev": 3},
        "incidence": 0.1,
    },
    ),

        mixed_count = patients.with_these_clinical_events(
                mixed,
                on_or_before="index_date",
                returning="number_of_matches_in_period",
    return_expectations={
        "int": {"distribution": "normal", "mean": 6, "stddev": 3},
        "incidence": 0.1,
    },
    ),
)
