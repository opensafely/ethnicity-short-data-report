from cohortextractor import (
    patients,
)
from codelists import *
from datetime import date, timedelta

clinical_variables = dict(
    # ----
    # Ethnicity_CTV3
    # ----
    # Ethnicity using CTV3 codes - returns latest in period
    ethnicity_5=patients.with_these_clinical_events(
                ethnicity_codes,
                returning="category",
                find_last_match_in_period=True,
                include_date_of_match=False,
                return_expectations={
                    "category": {
                        "ratios": {"1": 0.2, "2": 0.2, "3": 0.2, "4": 0.2, "5": 0.2}
                    },
                    "incidence": 1,
                },
            ),  

    # Ethnicity using SNOMED codes - returns latest in period
    ethnicity_snomed_5=patients.categorised_as(
            {
                "Missing": "DEFAULT",
                "1": """ eth2001=1 """,
                "2": """ eth2001=2 """,
                "3": """ eth2001=3 """,
                "4": """ eth2001=4 """,
                "5": """ eth2001=5 """,
                "0": """ non_eth2001_dat OR eth_notgiptref_dat OR eth_notstated_dat OR eth_norecord_dat""",
            },
            return_expectations={
                "rate": "universal",
                "category": {
                    "ratios": {
                        "0": 0.3,
                        "1": 0.2,
                        "2": 0.2,
                        "3": 0.1,
                        "4": 0.1,
                        "5": 0.1,
                    }
                },
            },
            eth2001=patients.with_these_clinical_events(
                eth2001,
                returning="category",
                find_last_match_in_period=True,
                on_or_before="index_date",
                return_expectations={
                    "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
                    "incidence": 0.75,
                },
            ),
            # Any other ethnicity code
            non_eth2001_dat=patients.with_these_clinical_events(
                non_eth2001,
                returning="date",
                find_last_match_in_period=True,
                on_or_before="index_date",
                date_format="YYYY-MM-DD",
            ),
            # Ethnicity not given - patient refused
            eth_notgiptref_dat=patients.with_these_clinical_events(
                eth_notgiptref,
                returning="date",
                find_last_match_in_period=True,
                on_or_before="index_date",
                date_format="YYYY-MM-DD",
            ),
            # Ethnicity not stated
            eth_notstated_dat=patients.with_these_clinical_events(
                eth_notstated,
                returning="date",
                find_last_match_in_period=True,
                on_or_before="index_date",
                date_format="YYYY-MM-DD",
            ),
            # Ethnicity no record
            eth_norecord_dat=patients.with_these_clinical_events(
                eth_norecord,
                returning="date",
                find_last_match_in_period=True,
                on_or_before="index_date",
                date_format="YYYY-MM-DD",
            ),
        ),

    # -------------------
    # Clinical conditions
    # -------------------
    # Chronic cardiac disease
    chronic_cardiac_disease=patients.with_these_clinical_events(
        chronic_cardiac_dis_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Chronic kidney disease
    chronic_kidney_disease=patients.with_these_clinical_events(
        chronic_kidney_dis_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Chronic liver disease
    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_dis_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Chronic respiratory disease
    chronic_respiratory_disease=patients.with_these_clinical_events(
        chronic_respiratory_dis_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Cancer (Haemotological)
    cancer_haem=patients.with_these_clinical_events(
        cancer_haem_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Cancer (Lung)
    cancer_lung=patients.with_these_clinical_events(
        cancer_lung_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Cancer (Other)
    cancer_other=patients.with_these_clinical_events(
        cancer_other_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Dementia
    dementia=patients.with_these_clinical_events(
        dementia_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Diabetes
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Housebound
    housebound=patients.with_these_clinical_events(
        housebound_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Hypertension
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        between=["index_date - 2 years", "index_date - 1 day"],
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Learning disability
    learning_disability=patients.with_these_clinical_events(
        wider_ld_codes,
        on_or_before="index_date - 1 day",
        returning="binary_flag",
        return_expectations={"incidence": 0.01, },
    ),
    # Severe obesity
    sev_obesity=patients.with_these_clinical_events(
        sev_obesity_codes,
        between=["index_date - 2 years", "index_date - 1 day"],
        returning="date",
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.01, },
    ),
)

demographic_variables = dict(
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
    # Sex
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.5, "F": 0.5}},
        }
    ),
    # Practice
    practice=patients.registered_practice_as_of(
        "index_date",
        returning="pseudo_id",
        return_expectations={
            "int": {
                "distribution": "normal", "mean": 25, "stddev": 5
            }, "incidence": 0.5}
    ),
    # Region
    region=patients.registered_practice_as_of(
        "index_date",
        returning="nuts1_region_name",
        return_expectations={"category": {"ratios": {
            "North East": 0.1,
            "North West": 0.1,
            "Yorkshire and the Humber": 0.1,
            "East Midlands": 0.1,
            "West Midlands": 0.1,
            "East of England": 0.1,
            "London": 0.2,
            "South East": 0.2, }}}
    ),
    # IMD
    imd=patients.address_as_of(
        "index_date",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "100": 0.2,
                    "200": 0.2,
                    "300": 0.2,
                    "400": 0.2,
                    "500": 0.2
                }
            },
        },
    ),
)
