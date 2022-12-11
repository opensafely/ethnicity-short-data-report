from cohortextractor import (
    StudyDefinition,
    patients,
    codelist,
    codelist_from_csv,
    combine_codelists,
)  # NOQA
from create_variables import demographic_variables, clinical_variables, ethnicity_overtime_variables
from codelists import *
from config import *

definitions = [
    "ethnicity_5",
    "ethnicity_new_5",
    "ethnicity_primis_5",
]
definitions_16 = [
    "ethnicity_16",
    "ethnicity_new_16",
    "ethnicity_primis_16",
]
other_vars = ["asian", "black", "mixed", "other", "white"]
other_vars_16 = [
    "White_British",
    "White_Irish",
    "Other_White",
    "White_and_Black_Caribbean",
    "White_and_Black_African",
    "White_and_Asian",
    "Other_Mixed",
    "Indian",
    "Pakistani",
    "Bangladeshi",
    "Other_Asian",
    "Caribbean",
    "African",
    "Other_Black",
    "Chinese",
    "Any_other_ethnic_group",
]

ethnicity_combinations_5 = [
    f"{definition}_{other_var}"
    for definition, other_var in product(definitions, other_vars)
]
ethnicity_combinations_16 = [
    f"{definition}_{other_var}"
    for definition, other_var in product(definitions_16, other_vars_16)
]
ethnicity_combinations = ethnicity_combinations_5 + ethnicity_combinations_16

codelists = {
    name: patients.with_these_clinical_events(
        globals()[name],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 6, "stddev": 3},
            "incidence": 0.1,
        },
    )
    for name in ethnicity_combinations
}

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
    **ethnicity_overtime_variables,
    **demographic_variables,
    **clinical_variables,
    **codelists,
)
