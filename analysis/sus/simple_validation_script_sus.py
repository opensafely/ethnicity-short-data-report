from lib_phenotype_validation_sus import *

############################ CONFIGURE OPTIONS HERE ################################

# Import file
input_path = "output/extract_5/input_5.feather"

# Definitions
definitions = [
    "ethnicity_5",
    "ethnicity_new_5",
    "ethnicity_sus_5",
]

definitions_new = [
    "ethnicity_new_5",
    "ethnicity_sus_5",
]

definitions_ctv3 = [
    "ethnicity_5",
    "ethnicity_sus_5",
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
    "ethnicity_new_5": {1: "White", 2: "Mixed", 3: "Asian", 4: "Black", 5: "Other"},
    "ethnicity_5": {1: "White", 2: "Mixed", 3: "Asian", 4: "Black", 5: "Other"},
    "ethnicity_sus_5": {1: "White", 2: "Mixed", 3: "Asian", 4: "Black", 5: "Other"},
}

# Other variables to include
other_vars = ["white", "mixed", "asian", "black", "other"]
other_vars_combined_new = [x + "_" + y for x in definitions_new for y in other_vars]
other_vars_combined_ctv3 = [x + "_" + y for x in definitions_ctv3 for y in other_vars]
other_vars_combined = other_vars_combined_new + other_vars_combined_ctv3
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
        registered=registered,
        dates_check=False,
    )
    # Count patients with records
    simple_patient_counts(
        df_clean,
        definitions_new,
        reg,
        "new_sus",
        demographic_covariates,
        clinical_covariates,
        output_path,
        grouping,
    )

    simple_patient_counts(
        df_clean,
        definitions_ctv3,
        reg,
        "ctv3_sus",
        demographic_covariates,
        clinical_covariates,
        output_path,
        grouping,
    )

    # Count patients by categories
    simple_patient_counts(
        df_clean,
        definitions_new,
        reg,
        "new_sus",
        demographic_covariates,
        clinical_covariates,
        output_path,
        grouping,
        categories=True,
    )

    simple_patient_counts(
        df_clean,
        definitions_ctv3,
        reg,
        "ctv3_sus",
        demographic_covariates,
        clinical_covariates,
        output_path,
        grouping,
        categories=True,
    )

    simple_sus_crosstab(df_clean, output_path, definitions_new, grouping, "new", reg)

    simple_sus_crosstab(df_clean, output_path, definitions_ctv3, grouping, "ctv3", reg)

    # # Latest v most common
    # simple_latest_common_comparison(
    #     df_clean,
    #     definitions_new,
    #     reg,
    #     other_vars_combined_ctv3,
    #     output_path,
    #     grouping,
    #     code_dict,
    # )

    # # State change
    # simple_state_change(
    #     df_clean,
    #     definitions_new,
    #     reg,
    #     other_vars_combined_ctv3,
    #     output_path,
    #     grouping,
    # )
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
