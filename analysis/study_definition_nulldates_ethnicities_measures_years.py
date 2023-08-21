from cohortextractor import (
    StudyDefinition,
    patients,
    codelist_from_csv,
    codelist,
    Measure,
    params
)

from config import *
from datetime import date


ethnicity_codes_snomed = codelist_from_csv(
    "codelists/opensafely-ethnicity-snomed-0removed.csv",
    system="snomed",
    column="snomedcode",
    category_column="Grouping_6",
)

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
        registered 
        """,
    ),

    registered=patients.registered_as_of(
            "index_date",
            return_expectations={"incidence": 0.9},
        ),

    null_date=patients.with_these_clinical_events(
        ethnicity_codes_snomed,
        returning="binary_flag",
        between=["1900-01-01", "1900-01-01"],
        return_expectations={"incidence": 0.01,}
    ),
     
    died = patients.died_from_any_cause(
        on_or_before="index_date",
        returning="binary_flag",
        return_expectations={"incidence": 0.1}
        ),
    population_living=patients.satisfying(
        """
        registered AND
        (NOT died)
        """,
    ),
    # Age
    age=patients.age_as_of(
        "index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
   # Age band
    age_band=patients.categorised_as(
        {
            "missing": "DEFAULT",
            "0-19": """ age >= 0 AND age < 20""",
            "20-29": """ age >=  20 AND age < 30""",
            "30-39": """ age >=  30 AND age < 40""",
            "40-49": """ age >=  40 AND age < 50""",
            "50-59": """ age >=  50 AND age < 60""",
            "60-69": """ age >=  60 AND age < 70""",
            "70-79": """ age >=  70 AND age < 80""",
            "80+": """ age >=  80 AND age < 120""",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "0-19": 0.125,
                    "20-29": 0.125,
                    "30-39": 0.125,
                    "40-49": 0.125,
                    "50-59": 0.125,
                    "60-69": 0.125,
                    "70-79": 0.125,
                    "80+": 0.125,
                }
            },
        },
    ),

)

#### Measures
measures = [ ]


### ethncicity measures
measures.extend([
    Measure(
    id=f"nulldate_age_band_rate",
    numerator="null_date",
    denominator="population_living",
    group_by=["age_band"]
)
])

measures.extend([
    Measure(
    id=f"nulldate_age_band_allpt_rate",
    numerator="null_date",
    denominator="population",
    group_by=["age_band"]
)
])

measures.extend([
    Measure(
    id=f"nulldate_rate",
    numerator='null_date',
    denominator="population_living",
    group_by=["population"]
)
])