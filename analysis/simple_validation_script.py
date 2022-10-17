from lib_phenotype_validation import *

############################ CONFIGURE OPTIONS HERE ################################

# Import file
input_path = "output/data/input.feather"

# Definitions
definitions = [
    "ethnicity_5",
    "ethnicity_new_5",
    "ethnicity_primis_5",
]

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
    "ethnicity_5": {1: "White", 2: "Mixed", 3: "Asian", 4: "Black", 5: "Other"},
    "ethnicity_new_5": {1: "White", 2: "Mixed", 3: "Asian", 4: "Black", 5: "Other"},
    "ethnicity_primis_5": {1: "White", 2: "Mixed", 3: "Asian", 4: "Black", 5: "Other"},
}

# Other variables to include
other_vars = ["white", "mixed", "asian", "black", "other"]
other_vars_combined = [x + "_" + y for x in definitions for y in other_vars]

# Restrict to registered as of index date
registered = False
reg = "fullset"
if registered == True:
    reg = "registered"

# Dates
dates = True
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
output_path = "simplified_output"
grouping = "5_group"

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
        dates_check=True,
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
    # # Generate upset plot of overlapping definitions
    # upset(df_clean_reg, output_path, definitions[1], definitions[0])
    # upset_cat(df_clean, output_path, definitions[1], definitions[0], other_vars)
    # Latest v most common
    simple_latest_common_comparison(
        df_clean, definitions,reg, other_vars_combined, output_path,grouping,
    )
    simple_latest_common_comparison(
        df_clean, definitions,reg, other_vars_combined, output_path,grouping, missing_check=True,
    )
    # State change
    simple_state_change(df_clean, definitions,reg, other_vars_combined, output_path,grouping,)
    simple_state_change(
        df_clean, definitions,reg, other_vars_combined, output_path,grouping, missing_check=True
    )
    # records over time
    records_over_time(
        df_clean, definitions, demographic_covariates, clinical_covariates, output_path, "",grouping,reg
        )

########################## DO NOT EDIT – RUNS SCRIPT ##############################

if __name__ == "__main__":
    main()

registered = False
reg = "fullset"

if __name__ == "__main__":
    main()