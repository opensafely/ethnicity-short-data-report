import os
import pandas as pd
from itertools import product
import numpy as np

def local_patient_counts(
    definitions, output_path, code_dict="", categories=False, missing=False,quietly =False
    ):
    

    suffix = "_filled"
    overlap = "all_filled"
    if missing == True:
        suffix = "_missing"
        overlap = "all_missing"
    if categories:
        df_append = pd.read_csv(
            f"output/{output_path}/simple_patient_counts_categories_registered.csv"
        ).set_index(["group", "subgroup"])
        
        if output_path == output_path_5:
            global df_append_cat_5
            df_append_cat_5 = df_append

        if output_path == output_path_16:
            global df_append_cat_16
            df_append_cat_16 = df_append

        # ensure definitions[n] in code_dict[definitions[n]] below refers to one of the definitions of interest
        definitions = [
            f"{category}_{definition}"
            for category, definition in product(
                code_dict[definitions[1]].values(), definitions
            )
        ]
    else:
        df_append = pd.read_csv(
            f"output/{output_path}/simple_patient_counts_registered.csv"
        ).set_index(["group", "subgroup"])
        global total
        total =  df_append
    for definition in definitions:
        if missing:
            df_append[definition + suffix] = (
                df_append["population"] - df_append[definition + "_filled"]
            )    
        df_append[definition + "_pct"] = round(
            (df_append[definition + suffix].div(df_append["population"])) * 100, 1
        )
        df_append[overlap + "_pct"] = round(
            (df_append[overlap].div(df_append["population"])) * 100, 1
        )

        # Combine count and percentage columns
        df_append[definition] = (
            df_append[definition + suffix].apply(lambda x: "{:,.0f}".format(x))
            + " ("
            + df_append[definition + "_pct"].astype(str)
            + ")"
        )
        df_append = df_append.drop(columns=[definition + suffix, definition + "_pct"])
    df_append[overlap] = (
        df_append[overlap].apply(lambda x: "{:,.0f}".format(x))
        + " ("
        + df_append[overlap + "_pct"].astype(str)
        + ")"
    )
    df_append = df_append.reset_index()
    df_append = df_append.replace("True", "Yes")
    df_append = df_append.replace("False", "No")
    df_append = df_append.set_index(["group", "subgroup"])
    df_append = df_append.drop(columns=[overlap + "_pct"])
    df_patient_counts = df_append[definitions + [overlap] + ["population"]]
    # Final redaction step
    df_patient_counts = df_patient_counts.replace(np.nan, "-")
    df_patient_counts = df_patient_counts.replace("nan (nan)", "- (-)")
    for k, v in definition_dict.items():
        df_patient_counts.columns = df_patient_counts.columns.str.replace(k,v) 
    df_patient_counts.columns = df_patient_counts.columns.str.replace("_", " ")
    
    if categories:
        df_patient_counts.to_csv(
                f"{filepath}/local_patient_counts_categories_registered.csv"
            )
    

### CONFIGURE ###
definitions_5 = ['ethnicity_new_5','ethnicity_5', 'ethnicity_primis_5']
definitions_16 = ['ethnicity_new_16', 'ethnicity_16', 'ethnicity_primis_16']
covariates = ['_age_band','_sex','_region','_imd','_dementia','_diabetes','_hypertension','_learning_disability']
output_path_5 = 'from_jobserver/release_2022_11_11'
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
    "ethnicity_5": {1: "Asian", 2: "Black", 3: "Mixed", 4: "White", 5: "Other"},
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
}

filepath = f'output/{output_path_5}/made_locally'
os.makedirs(filepath)

local_patient_counts(
         definitions_5,  output_path_5,code_dict_5, categories=True,missing=False
    )