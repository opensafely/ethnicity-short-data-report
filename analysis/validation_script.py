from lib_phenotype_validation import *

############################ CONFIGURE OPTIONS HERE ################################

# Import file
input_path = 'output/data/input.feather'

# Definitions
definitions = ['ethnicity_5', 'ethnicity_new_5', 'ethnicity_primis_5']

# Code dictionary
code_dict = {
    'imd': {0: 'Unknown', 1: '1 Most deprived', 2: '2', 3: '3', 4: '4', 5: '5 Least deprived'},
    'ethnicity_5': {1:'White', 2:'Mixed', 3:'Asian', 4:'Black', 5:'Other'},
    'ethnicity_new_5': {1:'White', 2:'Mixed', 3:'Asian', 4:'Black', 5:'Other'},
    'ethnicity_primis_5': {1:'White', 2:'Mixed', 3:'Asian', 4:'Black', 5:'Other'},
}

# Other variables to include
other_vars = ['white','mixed','asian','black','other']
other_vars_combined = [x+'_'+y for x in definitions for y in other_vars]

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

# Output filepath
output_path = 'phenotype_validation_ethnicity/5'

########################## SPECIFY ANALYSES TO RUN HERE ##############################
 
def main():
    # combine defintions and other_vars  
    df_clean = import_clean(input_path, definitions, other_vars_combined, demographic_covariates, 
                        clinical_covariates, null, date_min, date_max, 
                        time_delta, output_path, code_dict, dates)
    # Count patients with records
    patient_counts(df_clean, definitions, demographic_covariates, clinical_covariates, output_path)
    # Count patients without records
    patient_counts(df_clean, definitions, demographic_covariates, clinical_covariates, output_path, missing=True)
    # Count patients by categories 
    patient_counts(df_clean, definitions, demographic_covariates, clinical_covariates, output_path, categories=True)
    # Generate heatmap of overlapping definitions
    display_heatmap(df_clean, definitions, output_path)
    # Latest v most common
    latest_common_comparison(df_clean, definitions, other_vars_combined, output_path)
    # State change
    state_change(df_clean, definitions, other_vars_combined, output_path)
    
########################## DO NOT EDIT – RUNS SCRIPT ##############################

if __name__ == "__main__":
    main()