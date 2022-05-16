from cohortextractor import (
    patients,
)
from codelists import *
from config import *

clinical_variables = dict(
    # ----
    # Ethnicity_CTV3
    # ----
    # Ethnicity using CTV3 codes - returns latest in period
    ethnicity_5=patients.with_these_clinical_events(
                ethnicity_codes_ctv3,
                returning="category",
                find_last_match_in_period=True,
                include_date_of_match=False,
                return_expectations={
                    "category": {
                        "ratios": {"1": 0.2, "2": 0.2, "3": 0.2, "4": 0.2, "5": 0.2}
                    },
                    "incidence": 0.75,
                },
            ),  
    ethnicity_5_date=patients.with_these_clinical_events(
        ethnicity_codes_ctv3,
        returning="date",
        find_first_match_in_period=True,
        return_expectations={"date": {"earliest": "1900-01-01", "latest": "2022-01-01"}},
    ),
    ethnicity_16=patients.with_these_clinical_events(
            ethnicity_codes_ctv3_16,
            returning="category",
            find_last_match_in_period=True,
            include_date_of_match=False,
            return_expectations={
                "category": {
                                   "ratios": {
                    "1": 0.0625,
                    "2": 0.0625,
                    "3": 0.0625,
                    "4": 0.0625,
                    "5": 0.0625,
                    "6": 0.0625,
                    "7": 0.0625,
                    "8": 0.0625,
                    "9": 0.0625,
                    "10": 0.0625,
                    "11": 0.0625,
                    "12": 0.0625,
                    "13": 0.0625,
                    "14": 0.0625,
                    "15": 0.0625,
                    "16": 0.0625,
                }
                },
                "incidence": 0.75,
            },
        ),  
    ethnicity_16_date=patients.with_these_clinical_events(
        ethnicity_codes_ctv3_16,
        returning="date",
        find_first_match_in_period=True,
        return_expectations={"date": {"earliest": "1900-01-01", "latest": "2022-01-01"}},
    ),

    ethnicity_new_5=patients.with_these_clinical_events(
                ethnicity_codes_snomed,
                returning="category",
                find_last_match_in_period=True,
                include_date_of_match=False,
                return_expectations={
                    "category": {
                        "ratios": {"1": 0.2, "2": 0.2, "3": 0.2, "4": 0.2, "5": 0.2}
                    },
                    "incidence": 0.75,
                },
            ),  
    ethnicity_new_5_date=patients.with_these_clinical_events(
        ethnicity_codes_snomed,
        returning="date",
        find_first_match_in_period=True,
        return_expectations={"date": {"earliest": "1900-01-01", "latest": "2022-01-01"}},
    ),
    ethnicity_new_16=patients.with_these_clinical_events(
                ethnicity_codes_snomed_16,
                returning="category",
                find_last_match_in_period=True,
                include_date_of_match=False,
                return_expectations={
                    "category": {
                    "ratios": {
                        "1": 0.0625,
                        "2": 0.0625,
                        "3": 0.0625,
                        "4": 0.0625,
                        "5": 0.0625,
                        "6": 0.0625,
                        "7": 0.0625,
                        "8": 0.0625,
                        "9": 0.0625,
                        "10": 0.0625,
                        "11": 0.0625,
                        "12": 0.0625,
                        "13": 0.0625,
                        "14": 0.0625,
                        "15": 0.0625,
                        "16": 0.0625,
                }
                    },
                    "incidence": 0.75,
                },
            ),  
    ethnicity_new_16_date=patients.with_these_clinical_events(
        ethnicity_codes_snomed_16,
        returning="date",
        find_first_match_in_period=True,
        return_expectations={"date": {"earliest": "1900-01-01", "latest": "2022-01-01"}},
    ),
    # Ethnicity using SNOMED codes - returns latest in period
    ethnicity_primis_5 = patients.with_these_clinical_events(
                eth2001,
                returning="category",
                find_last_match_in_period=True,
                include_date_of_match=False,
                return_expectations={
                    "category": {
                        "ratios": {"1": 0.2, "2": 0.2, "3": 0.2, "4": 0.2, "5": 0.2}
                    },
                    "incidence": 0.75,
                },
            ),  
# # Any other ethnicity code
# non_eth2001_dat=patients.with_these_clinical_events(
#     non_eth2001,
#     returning="date",
#     find_last_match_in_period=True,
#     on_or_before="index_date",
#     date_format="YYYY-MM-DD",
# ),
# # Ethnicity not given - patient refused
# eth_notgiptref_dat=patients.with_these_clinical_events(
#     eth_notgiptref,
#     returning="date",
#     find_last_match_in_period=True,
#     on_or_before="index_date",
#     date_format="YYYY-MM-DD",
# ),
# # Ethnicity not stated
# eth_notstated_dat=patients.with_these_clinical_events(
#     eth_notstated,
#     returning="date",
#     find_last_match_in_period=True,
#     on_or_before="index_date",
#     date_format="YYYY-MM-DD",
# ),
# # Ethnicity no record
# eth_norecord_dat=patients.with_these_clinical_events(
#     eth_norecord,
#     returning="date",
#     find_last_match_in_period=True,
#     on_or_before="index_date",
#     date_format="YYYY-MM-DD",
# ),
# ),

    ethnicity_primis_5_date=patients.with_these_clinical_events(
        eth2001,
        returning="date",
        find_first_match_in_period=True,
        return_expectations={"date": {"earliest": "1900-01-01", "latest": "2022-01-01"}},
    ),

    ethnicity_primis_16 = patients.with_these_clinical_events(
        eth2001_16,
        returning = "category",
        find_last_match_in_period = True,
        include_date_of_match = False,
        return_expectations = {
            "category": {
                "ratios": {
                    "1": 0.0625,
                    "2": 0.0625,
                    "3": 0.0625,
                    "4": 0.0625,
                    "5": 0.0625,
                    "6": 0.0625,
                    "7": 0.0625,
                    "8": 0.0625,
                    "9": 0.0625,
                    "10": 0.0625,
                    "11": 0.0625,
                    "12": 0.0625,
                    "13": 0.0625,
                    "14": 0.0625,
                    "15": 0.0625,
                    "16": 0.0625,
                }
            },
            "incidence": 0.75,
        },
    ),

    ethnicity_primis_16_date=patients.with_these_clinical_events(
        eth2001_16,
        returning="date",
        find_first_match_in_period=True,
        return_expectations={"date": {"earliest": "1900-01-01", "latest": "2022-01-01"}},
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
    imd = patients.categorised_as(
            {
                "0": "DEFAULT",
                "1": """index_of_multiple_deprivation >=1 AND index_of_multiple_deprivation < 32844*1/5""",
                "2": """index_of_multiple_deprivation >= 32844*1/5 AND index_of_multiple_deprivation < 32844*2/5""",
                "3": """index_of_multiple_deprivation >= 32844*2/5 AND index_of_multiple_deprivation < 32844*3/5""",
                "4": """index_of_multiple_deprivation >= 32844*3/5 AND index_of_multiple_deprivation < 32844*4/5""",
                "5": """index_of_multiple_deprivation >= 32844*4/5 """,
            },
            index_of_multiple_deprivation = patients.address_as_of(
                "index_date",
                returning = "index_of_multiple_deprivation",
                round_to_nearest = 100,
            ),
            return_expectations = {
                "rate": "universal",
                "category": {
                    "ratios": {
                        "0": 0.01,
                        "1": 0.20,
                        "2": 0.20,
                        "3": 0.20,
                        "4": 0.20,
                        "5": 0.19,
                    }
                },
            },
        ),
    # registered
    registered= patients.registered_as_of(index_date),
)
