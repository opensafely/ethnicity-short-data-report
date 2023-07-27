from cohortextractor import (
    StudyDefinition,
    patients,
    codelist_from_csv,
    codelist,
    Measure,
    params
)
from create_variables import demographic_variables, clinical_variables, ethnicity_5_variables
from codelists import *
from config import *
from datetime import date

other_vars = ["asian", "black", "mixed", "other", "white"]
demographic_covariates = ["age_band", "sex", "region", "imd"]
clinical_covariates = ["dementia", "diabetes", "hypertension", "learning_disability"]

ethnicity_combinations_5 = [
    f"ethnicity_new_5_{other_var}"
    for other_var in other_vars
]

codelists = {
    name: patients.with_these_clinical_events(
        globals()[name],
        returning="binary_flag",
        on_or_before = "index_date",
        return_expectations={
            "int": {"distribution": "normal", "mean": 6, "stddev": 3},
            "incidence": 0.1,
        },
    )
    for name in ethnicity_combinations_5
}


# Specifiy study definition
study = StudyDefinition(
    index_date=index_date,
    default_expectations={
        "date": {"earliest": "index_date", "latest": "last_day_of_month(index_date)"},
        "rate": "exponential_increase",
        "incidence": 0.1,
    },
    
    population=patients.satisfying(
        """
        registered AND
        (NOT died) AND
        (NOT null_date)
        """,
    ),

    # registered=patients.registered_as_of(
    #         "index_date",
    #         return_expectations={"incidence": 0.9},
    #     ),

    null_date=patients.with_these_clinical_events(
        ethnicity_codes_snomed,
        returning="binary_flag",
        between=["1900-01-01", "1900-01-01"],
        return_expectations={"incidence": 0.01,}
    ),

    ethnicity_new_5_month=patients.with_these_clinical_events(
        ethnicity_codes_snomed,
        returning="binary_flag",
        find_last_match_in_period=True,
        include_date_of_match=False,
        on_or_before = "index_date",
        return_expectations={
            "category": {"ratios": {"1": 0.6, "2": 0.1, "3": 0.1, "4": 0.1, "5": 0.1}},
            "incidence": 0.75,
        },
    ),
     
    died = patients.died_from_any_cause(
        on_or_before="index_date",
        returning="binary_flag",
        return_expectations={"incidence": 0.1}
        ),
    **ethnicity_5_variables,
    **codelists,
    **demographic_variables,
    **clinical_variables,
    ##### SRO measures

)
#### Measures

measures = [ ]


### ethncicity measures
for measure in ethnicity_combinations_5 + ['ethnicity_new_5_month']:
    measure
    measures.extend([
        Measure(
        id=f"{measure}_rate",
        numerator=measure,
        denominator="population",
        group_by=["population"]
    )
    ])

for covar in demographic_covariates + clinical_covariates:
    measure
    measures.extend([
        Measure(
        id=f"ethnicity_{covar}_rate",
        numerator=measure,
        denominator="population",
        group_by=[covar]
    )
    ])