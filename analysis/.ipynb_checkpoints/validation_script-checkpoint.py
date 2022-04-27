from lib_phenotype_validation import *

############################ CONFIGURE OPTIONS HERE ################################

# Import file
input_path = 'output/data/input.feather'

# Definitions
definitions = ['ethnicity_5', 'ethnicity_new_5', 'ethnicity_primis_5']

# Code dictionary
code_dict = {
    'imd': {0: 'Unknown', 100: '1 Most deprived', 200: '2', 300: '3', 400: '4', 500: '5 Least deprived'},
    'ethnicity_5': {1:'White', 2:'Mixed', 3:'Asian', 4:'Black', 5:'Other'},
    'ethnicity_new_5': {1:'White', 2:'Mixed', 3:'Asian', 4:'Black', 5:'Other'},
    'ethnicity_primis_5': {1:'White', 2:'Mixed', 3:'Asian', 4:'Black', 5:'Other'},
}

# Other variables to include
other_vars = ['asian_count','black_count','mixed_count','other_count','white_count']

# Dates
dates = False
date_min = ''
date_max = ''
time_delta = ''

# Min/max range
min_range = 4
max_range = 200

# Null value – could be multiple values in a list [0,'0',NA]
null = [0,"0"]

# Covariates
demographic_covariates = ['age_band', 'sex', 'region', 'imd']
clinical_covariates = ['dementia', 'diabetes', 'hypertension', 'learning_disability']

########################## SPECIFY ANALYSES TO RUN HERE ##############################

def main():
    df_clean = import_clean(input_path, definitions, other_vars, demographic_covariates, 
                        clinical_covariates, null, date_min, date_max, 
                        time_delta, code_dict, dates)
    # Count patients with records
    patient_counts(df_clean, definitions, demographic_covariates, clinical_covariates)
    # Count patients without records
    patient_counts(df_clean, definitions, demographic_covariates, clinical_covariates, missing=True)
    # Count patients by categories 
    patient_counts(df_clean, definitions, demographic_covariates, clinical_covariates, categories=True)
    # Generate heatmap of overlapping definitions
    display_heatmap(df_clean, definitions)
    # Latest v most common
    latest_common_comparison(df_clean, definitions, other_vars)
    # State change
    state_change(df_clean, definitions, other_vars)
    
########################## DO NOT EDIT – RUNS SCRIPT ##############################

if __name__ == "__main__":
    main()