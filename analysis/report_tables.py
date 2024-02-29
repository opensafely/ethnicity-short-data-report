import os
import pandas as pd
from itertools import product
import numpy as np


def report_patient_counts(
    definitions,
    group,
    defin,
    input_path,
    output_path,
    code_dict="",
    definition_dict="",
    categories=False,
    missing=False,
):
    suffix = "_filled"
    overlap = "all_filled"
    if missing == True:
        suffix = "_missing"
        overlap = "all_missing"
    if categories:
        # df_population = pd.read_csv(
        #     f"output/{input_path}/simple_patient_counts_registered.csv"
        # ).set_index(["group", "subgroup"])

        df_append = pd.read_csv(
            f"output/{input_path}/{group}_group/tables/simple_patient_counts_categories_{group}_group_{defin}_registered.csv"
        ).set_index(["group", "subgroup"])
        for col in df_append.columns[df_append.columns.str.endswith("supplemented")]:
            df_append = df_append.rename(columns={col: f"{col}_filled"})
        for col in df_append.columns[df_append.columns.str.endswith("any")]:
            df_append = df_append.rename(columns={col: f"{col}_filled"})

        # df_append.drop("population", inplace=True, axis=1)
        for definition in definitions:
            # df_append[f"population_{definition}"] = df_population[definition+"_filled"]
            # ensure definitions[n] in code_dict[definitions[n]] below refers to one of the definitions of interest
            full_definitions = [
                f"{category}_{definition}"
                for category, definition in product(
                    code_dict[definitions[1]].values(), [definition]
                )
            ]
            for full_definition in full_definitions:
                if missing:
                    df_append[full_definition + suffix] = (
                        df_append[f"population_{definition}"]
                        - df_append[full_definition + "_filled"]
                    )
                df_append[full_definition + "_pct"] = round(
                    (df_append[full_definition + suffix].div(df_append[f"population"]))
                    * 100,
                    1,
                )

                df_append[overlap + "_pct"] = round(
                    (df_append[overlap].div(df_append[f"population"])) * 100, 1
                )
                # df_append[full_definition + "_pct"] = round(
                #     (df_append[full_definition + suffix].div(df_append[f"population_{definition}"])) * 100, 1
                # )
                # df_append[overlap + "_pct"] = round(
                #     (df_append[overlap].div(df_append[f"population_{definition}"])) * 100, 1
                # )
                # Combine count and percentage columns
                df_append[full_definition] = (
                    df_append[full_definition + suffix].apply(
                        lambda x: "{:,.0f}".format(x)
                    )
                    + " ("
                    + df_append[full_definition + "_pct"].astype(str)
                    + ")"
                )
                df_append = df_append.drop(
                    columns=[full_definition + suffix, full_definition + "_pct"]
                )
    else:
        df_append = pd.read_csv(
            f"output/{input_path}/{group}_group/tables/simple_patient_counts_{group}_group_{defin}_registered.csv"
        ).set_index(["group", "subgroup"])
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

        for definition in definitions:
            # Percentage increase from adding SUS data
            df_append[definition + "_pp_inc"] = round(
                df_append[definitions[1] + "_pct"] - df_append[definition + "_pct"], 1
            )
            # Combine count and percentage columns
            df_append[definition] = (
                df_append[definition + suffix].apply(lambda x: "{:,.0f}".format(x))
                + " ("
                + df_append[definition + "_pct"].astype(str)
                + ")"
            )
            df_append = df_append.drop(
                columns=[definition + suffix, definition + "_pct"]
            )
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
    if categories:
        full_definitions = [
            f"{category}_{definition}"
            for category, definition in product(
                code_dict[definitions[1]].values(), definitions
            )
        ]
        df_patient_counts = df_append[full_definitions]
    else:
        df_patient_counts = df_append[
            definitions + [overlap] + ["population"] + [definitions[0] + "_pp_inc"]
        ]
    # Final redaction step
    df_patient_counts = df_patient_counts.replace(np.nan, "-")
    df_patient_counts = df_patient_counts.replace("nan (nan)", "- (-)")

    for k, v in definition_dict.items():
        df_patient_counts.columns = df_patient_counts.columns.str.replace(k, v)
    df_patient_counts.columns = df_patient_counts.columns.str.replace("_", " ")

    if categories:
        df_patient_counts.to_csv(
            f"output/{output_path}/report_patient_counts_categories_{group}_{defin}_registered.csv"
        )
        print(
            f"saved: output/{output_path}/report_patient_counts_categories_{group}_{defin}_registered.csv"
        )
    else:
        df_patient_counts.to_csv(
            f"output/{output_path}/report_patient_counts_{group}_{defin}_registered.csv"
        )
        print(
            f"saved: output/{output_path}/report_patient_counts_{group}_{defin}_registered.csv"
        )


def report_latest_common(
    definitions,
    input_path,
    output_path,
    group,
    defin,
    code_dict="",
    definition_dict="",
    suffix="",
):
    for definition in definitions:
        if code_dict != "":
            lowerlist_5 = [x.lower() for x in (list(code_dict[definition].values()))]
        df_sum = pd.read_csv(
            f"output/{input_path}/{group}_group/tables/simple_latest_common_{definition}{suffix}_registered.csv"
        ).set_index(definition)
        # sort rows by category index
        df_sum.columns = df_sum.columns.str.replace(definition + "_", "")
        df_sum.columns = df_sum.columns.str.lower()
        df_sum = df_sum.reindex(list(code_dict[definition].values()))
        df_sum = df_sum[lowerlist_5]
        df_counts = pd.DataFrame(
            np.diagonal(df_sum),
            index=df_sum.index,
            columns=[f"matching (n={np.diagonal(df_sum).sum()})"],
        )

        df_sum2 = df_sum.copy(deep=True)
        np.fill_diagonal(df_sum2.values, 0)
        df_diag = pd.DataFrame(
            df_sum2.sum(axis=1),
        )
        df_out = df_counts.merge(df_diag, right_index=True, left_index=True)
        # columns=round(df_out.sum()/df_out.sum(axis=1).sum()*100,1)

        df_out.loc["Total"] = df_out.sum()
        df_out.columns = [f"matching", f"not matching"]
        df_out["matching_pct"] = round(
            df_out["matching"]
            / (df_out[["matching", "not matching"]].sum(axis=1))
            * 100,
            1,
        )
        df_out["not matching_pct"] = round(
            df_out["not matching"]
            / (df_out[["matching", "not matching"]].sum(axis=1))
            * 100,
            1,
        )
        for item in ["matching", "not matching"]:
            df_out[item] = (
                df_out[item].apply(lambda x: "{:,.0f}".format(x))
                + " ("
                + df_out[item + "_pct"].astype(str)
                + ")"
            )
        df_out = df_out[["matching", "not matching"]]
        df_out = df_out.reset_index()
        df_out = df_out.rename(definition_dict, axis="columns")
        df_out.rename(
            columns={
                f"{definition_dict[definition]}": f"Latest Ethnicity-\n{definition_dict[definition]}"
            },
            inplace=True,
        )
        df_out = df_out.set_index(f"Latest Ethnicity-\n{definition_dict[definition]}")
        df_out = df_out.replace(np.nan, "-")
        df_out.to_csv(
            f"output/{output_path}/report_latest_common_{definition}_registered.csv"
        )

        if code_dict != "":
            lowerlist_5 = [x.lower() for x in (list(code_dict[definition].values()))]
            df_sum = df_sum[lowerlist_5]
        else:
            df_sum = df_sum.reindex(sorted(df_sum.columns), axis=1)

        # Combine count and percentage columns
        df_sum["population"] = df_sum.sum(axis=1)
        for item in lowerlist_5:
            df_sum[item + "_pct"] = round(
                (df_sum[item].div(df_sum["population"])) * 100, 1
            )
            df_sum[item] = (
                df_sum[item].apply(lambda x: "{:,.0f}".format(x))
                + " ("
                + df_sum[item + "_pct"].astype(str)
                + ")"
            )
        df_sum = df_sum[lowerlist_5]
        df_sum = df_sum.reset_index()
        df_sum = df_sum.replace("nan (nan)", "- (-)")
        df_sum = df_sum.rename(definition_dict, axis="columns")
        df_sum.rename(
            columns={
                f"{definition_dict[definition]}": f"Latest Ethnicity-\n{definition_dict[definition]}"
            },
            inplace=True,
        )
        df_sum = df_sum.set_index(f"Latest Ethnicity-\n{definition_dict[definition]}")
        df_sum.to_csv(
            f"output/{output_path}/report_latest_common_{defin}_{group}_expanded_registered.csv"
        )


def report_state_change(
    definitions,
    input_path,
    output_path,
    group,
    defin,
    code_dict="",
    definition_dict="",
):
    for definition in definitions:
        lowerlist = [x.lower() for x in (list(code_dict[definition].values()))]
        df_state_change = pd.read_csv(
            f"output/{input_path}/{group}_group/tables/simple_state_change_{definition}_registered.csv"
        ).set_index(definition)
        df_state_change.columns = df_state_change.columns.str.replace(
            definition + "_", ""
        )
        # resort rows
        df_state_change = df_state_change.reindex(list(code_dict[definition].values()))
        df_state_change = df_state_change.reset_index()

        df_state_change[definition] = (
            df_state_change[definition]
            + ": "
            + df_state_change["n"].apply(lambda x: "{:,.0f}".format(x))
        )
        df_state_change = df_state_change.set_index(definition)
        df_state_change.columns = map(str.lower, df_state_change.columns)

        for item in lowerlist + list(["any"]):
            df_state_change[item + "_pct"] = round(
                (df_state_change[item].div(df_state_change["n"])) * 100, 1
            )

            df_state_change[item] = (
                df_state_change[item].apply(lambda x: "{:,.0f}".format(x))
                + " ("
                + df_state_change[item + "_pct"].astype(str)
                + ")"
            )
        df_state_change = df_state_change[lowerlist + list(["any"])]
        df_state_change = df_state_change.replace("nan (nan)", "- (-)")
        df_state_change = df_state_change.reset_index()
        df_state_change = df_state_change.rename(definition_dict, axis="columns")
        df_state_change.rename(
            columns={
                f"{definition_dict[definition]}": f"Latest Ethnicity-\n{definition_dict[definition]}"
            },
            inplace=True,
        )
        df_state_change = df_state_change.set_index(
            f"Latest Ethnicity-\n{definition_dict[definition]}"
        )
        df_state_change.to_csv(
            f"output/{output_path}/report_state_change_{defin}_{group}_registered.csv"
        )


### CONFIGURE ###
definitions_5 = ["ethnicity_new_5", "ethnicity_5"]
definitions_16 = ["ethnicity_new_16", "ethnicity_16"]
definitions_sus_5 = ["ethnicity_new_5", "any"]
definitions_sus_5_ctv3 = ["ethnicity_5", "any"]
definitions_sus_16 = ["ethnicity_new_16", "any"]
definitions_sus_16_ctv3 = ["ethnicity_16", "any"]

covariates = [
    "_age_band",
    "_sex",
    "_region",
    "_imd",
    "_dementia",
    "_diabetes",
    "_hypertension",
    "_learning_disability",
]
input_path_sus = "sus/simplified_output"
input_path_new = "simplified_output"
# output_path_16 = 'from_jobserver/released
suffixes = ["", "_missing"]
suffix = ""
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
    "supplemented": {1: "Asian", 2: "Black", 3: "Mixed", 4: "White", 5: "Other"},
    "ethnicity_new_5": {1: "Asian", 2: "Black", 3: "Mixed", 4: "White", 5: "Other"},
    "ethnicity_5": {1: "Asian", 2: "Black", 3: "Mixed", 4: "White", 5: "Other"},
    "ethnicity_primis_5": {1: "Asian", 2: "Black", 3: "Mixed", 4: "White", 5: "Other"},
}
lowerlist_5 = [x.lower() for x in (list(code_dict_5["ethnicity_new_5"].values()))]
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
    "any": {
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
    "supplemented": {
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
definition_dict_new_ctv3 = {
    "ethnicity_new_5": "5 SNOMED:2022",
    "ethnicity_primis_5": "5 PRIMIS:2021",
    "ethnicity_5": "5 CTV3:2020",
    "ethnicity_new_16": "16 SNOMED:2022",
    "ethnicity_primis_16": "16 PRIMIS:2021",
    "ethnicity_16": "16 CTV3:2020",
    "any": "Both CTV3 and Snomed",
    "supplemented": "Both CTV3 and Snomed",
}
definition_dict_new = {
    "ethnicity_new_5": "5 SNOMED:2022",
    "ethnicity_primis_5": "5 PRIMIS:2021",
    "ethnicity_5": "5 CTV3:2020",
    "ethnicity_new_16": "16 SNOMED:2022",
    "ethnicity_primis_16": "16 PRIMIS:2021",
    "ethnicity_16": "16 CTV3:2020",
    "any": "SNOMED:2022 Supplemented",
    "supplemented": "SNOMED:2022 Supplemented",
}

definition_dict_ctv3 = {
    "ethnicity_new_5": "5 SNOMED:2022",
    "ethnicity_primis_5": "5 PRIMIS:2021",
    "ethnicity_5": "5 CTV3:2020",
    "ethnicity_new_16": "16 SNOMED:2022",
    "ethnicity_primis_16": "16 PRIMIS:2021",
    "ethnicity_16": "16 CTV3:2020",
    "any": "CTV3 Supplemented",
    "supplemented": "CTV3 Supplemented",
}

output_path = f"report_tables"
group_5 = "5"
group_16 = "16"

exists = os.path.exists(f"output/{output_path}")
if not exists:
    os.makedirs(f"output/{output_path}")


def main():
    report_patient_counts(
        definitions_sus_5,
        group_5,
        "new_sus",
        input_path_sus,
        output_path,
        code_dict_5,
        definition_dict_new,
        categories=False,
        missing=False,
    )
    report_patient_counts(
        definitions_sus_5,
        group_5,
        "new_sus",
        input_path_sus,
        output_path,
        code_dict_5,
        definition_dict_new,
        categories=True,
        missing=False,
    )
    report_patient_counts(
        definitions_sus_5_ctv3,
        group_5,
        "ctv3_sus",
        input_path_sus,
        output_path,
        code_dict_5,
        definition_dict_ctv3,
        categories=False,
        missing=False,
    )
    report_patient_counts(
        definitions_5,
        group_5,
        "new_ctv3",
        input_path_new,
        output_path,
        code_dict_5,
        definition_dict_new_ctv3,
        categories=False,
        missing=False,
    )
    report_patient_counts(
        definitions_sus_5_ctv3,
        group_5,
        "ctv3_sus",
        input_path_sus,
        output_path,
        code_dict_5,
        definition_dict_ctv3,
        categories=True,
        missing=False,
    )

    #### 16 group
    report_patient_counts(
        definitions_sus_16,
        group_16,
        "new_sus",
        input_path_sus,
        output_path,
        code_dict_16,
        definition_dict_new,
        categories=False,
        missing=False,
    )
    report_patient_counts(
        definitions_sus_16_ctv3,
        group_16,
        "ctv3_sus",
        input_path_sus,
        output_path,
        code_dict_16,
        definition_dict_ctv3,
        categories=False,
        missing=False,
    )
    report_patient_counts(
        definitions_16,
        group_16,
        "new_ctv3",
        input_path_new,
        output_path,
        code_dict_16,
        definition_dict_new_ctv3,
        categories=False,
        missing=False,
    )
    report_patient_counts(
        definitions_sus_16_ctv3,
        group_16,
        "ctv3_sus",
        input_path_sus,
        output_path,
        code_dict_16,
        definition_dict_ctv3,
        categories=True,
        missing=False,
    )

    report_patient_counts(
        definitions_sus_16,
        group_16,
        "new_sus",
        input_path_sus,
        output_path,
        code_dict_16,
        definition_dict_new,
        categories=True,
        missing=False,
    )
    #  Most recent vs most common
    report_latest_common(
        ["ethnicity_new_5"],
        input_path_new,
        output_path,
        group_5,
        "new",
        code_dict_5,
        definition_dict_new,
        suffix,
    )
    report_latest_common(
        ["ethnicity_new_16"],
        input_path_new,
        output_path,
        group_16,
        "new",
        code_dict_16,
        definition_dict_new,
        suffix,
    )
    report_latest_common(
        ["ethnicity_5"],
        input_path_new,
        output_path,
        group_5,
        "ctv3",
        code_dict_5,
        definition_dict_ctv3,
        suffix,
    )
    report_latest_common(
        ["ethnicity_16"],
        input_path_new,
        output_path,
        group_16,
        "ctv3",
        code_dict_16,
        definition_dict_ctv3,
        suffix,
    )
    #  Most recent vs any
    report_state_change(
        ["ethnicity_new_5"],
        input_path_new,
        output_path,
        group_5,
        "new",
        code_dict_5,
        definition_dict_new,
    )
    report_state_change(
        ["ethnicity_new_16"],
        input_path_new,
        output_path,
        group_16,
        "new",
        code_dict_16,
        definition_dict_new,
    )
    report_state_change(
        ["ethnicity_5"],
        input_path_new,
        output_path,
        group_5,
        "ctv3",
        code_dict_5,
        definition_dict_new,
    )
    report_state_change(
        ["ethnicity_16"],
        input_path_new,
        output_path,
        group_16,
        "ctv3",
        code_dict_16,
        definition_dict_new,
    )


########################## DO NOT EDIT – RUNS SCRIPT ##############################
if __name__ == "__main__":
    main()
