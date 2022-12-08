from lib_phenotype_validation_sus import *

############################ CONFIGURE OPTIONS HERE ################################

# Import file
input_path = "output/extract/input.feather"

# Definitions
definitions = ["ethnicity_new_16", "ethnicity_sus_16"]

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
    "ethnicity_sus_16": {
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
reg = "fullset"
if registered == True:
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
output_path = "sus/simplified_output"
grouping = "16_group"

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
        grouping,
        code_dict,
        dates=False,
        registered = registered,
        dates_check=False,
    )
    # Count patients with records
    simple_patient_counts(
        df_clean, definitions,reg, demographic_covariates, clinical_covariates, output_path,grouping,
    )

    # Count patients by categories
    simple_patient_counts(
        df_clean,
        definitions,
        reg,
        demographic_covariates,
        clinical_covariates,
        output_path,
        grouping,
        categories=True,
    )
    # Latest v most common
    simple_latest_common_comparison(
        df_clean, definitions,reg, other_vars_combined, output_path,grouping,
    )
    simple_latest_common_comparison(
        df_clean, definitions,reg, other_vars_combined, output_path,grouping, missing_check=False,
    )
    # State change
    simple_state_change(df_clean, definitions,reg, other_vars_combined, output_path,grouping,)
    # # records over time
    # records_over_time_perc(
    #     df_clean, definitions, demographic_covariates, clinical_covariates, output_path, "",grouping,reg
    #     )

########################## DO NOT EDIT – RUNS SCRIPT ##############################

if __name__ == "__main__":
    main()

# registered = False
# reg = "fullset"

# if __name__ == "__main__":
#     main()