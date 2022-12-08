from lib_phenotype_validation import *

############################ CONFIGURE OPTIONS HERE ################################

# Import file
input_path = "output/extract/input.feather"

# Definitions
definitions = ["ethnicity_16", "ethnicity_new_16", "ethnicity_primis_16"]

# Code dictionary
code_dict = {
    "imd": {
        0: "Unknown",
        1: "1 Most deprived",
        2: "2",
        3: "3",
        4: "4",
        5: "5 Least deprived",
    },
    "ethnicity_16": {
        1: "White_British",
        2: "White_Irish",
        3: "Other_White",
        4: "White_and_Black_Caribbean",
        5: "White_and_Black_African",
        6: "White_and_Asian",
        7: "Other_Mixed",
        8: "Indian",
        9: "Pakistani",
        10: "Bangladeshi",
        11: "Other_Asian",
        12: "Caribbean",
        13: "African",
        14: "Other_Black",
        15: "Chinese",
        16: "Any_other_ethnic_group",
    },
    "ethnicity_new_16": {
        1: "White_British",
        2: "White_Irish",
        3: "Other_White",
        4: "White_and_Black_Caribbean",
        5: "White_and_Black_African",
        6: "White_and_Asian",
        7: "Other_Mixed",
        8: "Indian",
        9: "Pakistani",
        10: "Bangladeshi",
        11: "Other_Asian",
        12: "Caribbean",
        13: "African",
        14: "Other_Black",
        15: "Chinese",
        16: "Any_other_ethnic_group",
    },
    "ethnicity_primis_16": {
        1: "White_British",
        2: "White_Irish",
        3: "Other_White",
        4: "White_and_Black_Caribbean",
        5: "White_and_Black_African",
        6: "White_and_Asian",
        7: "Other_Mixed",
        8: "Indian",
        9: "Pakistani",
        10: "Bangladeshi",
        11: "Other_Asian",
        12: "Caribbean",
        13: "African",
        14: "Other_Black",
        15: "Chinese",
        16: "Any_other_ethnic_group",
    },
}


# Other variables to include
other_vars = [
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
other_vars_combined = [x + "_" + y for x in definitions for y in other_vars]

# Restrict to registered as of index date
registered = True
reg = "registered"

# Dates
dates = False
date_min = ""
date_max = ""
time_delta = ""

# Min/max range
min_range = 4
max_range = 200

# Null value – could be multiple values in a list [0,'0',NA]
null = [0, "0"]

# Covariates
demographic_covariates = ["age_band", "sex", "region", "imd"]
clinical_covariates = ["dementia", "diabetes", "hypertension", "learning_disability"]

# Output filepath
output_path = "phenotype_validation_ethnicity/16"
if registered:
    output_path = output_path + "/registered"

########################## SPECIFY ANALYSES TO RUN HERE ##############################


def main():
    # combine defintions and other_vars
    df_clean = import_clean(
        input_path,
        definitions,
        other_vars_combined,
        demographic_covariates,
        clinical_covariates,
        reg,
        null,
        date_min,
        date_max,
        time_delta,
        output_path,
        code_dict,
        dates,
        registered,
    )
    # Count patients with records
    patient_counts(
        df_clean, definitions, demographic_covariates, clinical_covariates, output_path
    )
    # Count patients without records
    patient_counts(
        df_clean,
        definitions,
        demographic_covariates,
        clinical_covariates,
        output_path,
        missing=True,
    )
    # Count patients by categories
    patient_counts(
        df_clean,
        definitions,
        demographic_covariates,
        clinical_covariates,
        output_path,
        code_dict,
        categories=True,
    )
    # Generate heatmap of overlapping definitions
    display_heatmap(df_clean, definitions, output_path)
    # Latest v most common
    latest_common_comparison(
        df_clean, definitions, other_vars_combined, output_path, code_dict
    )
    # State change
    state_change(df_clean, definitions, other_vars_combined, output_path, code_dict)


########################## DO NOT EDIT – RUNS SCRIPT ##############################

if __name__ == "__main__":
    main()
