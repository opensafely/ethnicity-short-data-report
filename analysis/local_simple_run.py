import os
import pandas as pd
from itertools import product
import numpy as np

from local_validation_script import *

### CONFIGURE ###
definitions_5 = ['ethnicity_new_5', 'ethnicity_5', 'ethnicity_primis_5']
definitions_16 = ['ethnicity_new_16', 'ethnicity_16', 'ethnicity_primis_16']
definitions_sus = ['ethnicity_new_5','any']
covariates = ['_age_band','_sex','_region','_imd','_dementia','_diabetes','_hypertension','_learning_disability']
input_path_5 = 'from_jobserver/release_2022_11_18'
output_path_16 = 'from_jobserver/release_2022_11_11/16group'
suffixes = ['','_missing']
suffix = ''
code_dict_5 = {
    "imd": {
        0: "Unknown",
        1: "1 Most deprived",
        2: "2",
        3: "3",
        4: "4",
        5: "5 Least deprived",
    },
    "any": {1: "Asian", 2: "Black", 3: "Mixed", 4: "White", 5: "Other"},
    "ethnicity_new_5": {1: "Asian", 2: "Black", 3: "Mixed", 4: "White", 5: "Other"},
    "ethnicity_primis_5": {1: "Asian", 2: "Black", 3: "Mixed", 4: "White", 5: "Other"},
}

# Code dictionary
code_dict_16 = {
    "imd": {
        0: "Unknown",
        1: "1 Most deprived",
        2: "2",
        3: "3",
        4: "4",
        5: "5 Least deprived",
    },
    "ethnicity_16": {
        1: "Indian",
        2: "Pakistani",
        3: "Bangladeshi",
        4: "Other_Asian",
        5: "Caribbean",
        6: "African",
        7: "Other_Black",
        8: "White_and_Black_Caribbean",
        9: "White_and_Black_African",
        10: "White_and_Asian",
        11: "Other_Mixed",
        12: "White_British",
        13: "White_Irish",
        14: "Other_White",
        15: "Chinese",
        16: "Any_other_ethnic_group",
    },
    "ethnicity_new_16": {
        1: "Indian",
        2: "Pakistani",
        3: "Bangladeshi",
        4: "Other_Asian",
        5: "Caribbean",
        6: "African",
        7: "Other_Black",
        8: "White_and_Black_Caribbean",
        9: "White_and_Black_African",
        10: "White_and_Asian",
        11: "Other_Mixed",
        12: "White_British",
        13: "White_Irish",
        14: "Other_White",
        15: "Chinese",
        16: "Any_other_ethnic_group",
    },
    "ethnicity_primis_16": {
        1: "Indian",
        2: "Pakistani",
        3: "Bangladeshi",
        4: "Other_Asian",
        5: "Caribbean",
        6: "African",
        7: "Other_Black",
        8: "White_and_Black_Caribbean",
        9: "White_and_Black_African",
        10: "White_and_Asian",
        11: "Other_Mixed",
        12: "White_British",
        13: "White_Irish",
        14: "Other_White",
        15: "Chinese",
        16: "Any_other_ethnic_group",
    },
}

definition_dict = {
        "ethnicity_new_5": "5 SNOMED:2022",
        "ethnicity_primis_5": "5 PRIMIS:2021",
        "ethnicity_5": "5 CTV3:2020",
        "ethnicity_new_16": "16 SNOMED:2022",
        "ethnicity_primis_16": "16 PRIMIS:2021",
        "ethnicity_16": "16 CTV3:2020",
        "any": "Supplemented"
}

output_path_5 = f'{input_path_5}/made_locally'

exists = os.path.exists(f"output/{output_path_5}")
if not exists:
    os.makedirs(f"output/{output_path_5}")

########################## SPECIFY ANALYSES TO RUN HERE ##############################


def main():
    local_patient_counts(
            definitions_sus, input_path_5, output_path_5,code_dict_5,definition_dict, categories=False,missing=False
        )
    local_patient_counts(
            definitions_sus, input_path_5, output_path_5,code_dict_5,definition_dict, categories=True,missing=False
        )


########################## DO NOT EDIT – RUNS SCRIPT ##############################
if __name__ == "__main__":
    main()
