import datetime
import itertools
import matplotlib.gridspec as gridspec
import numpy as np
import os
import pandas as pd
import seaborn as sns

from matplotlib import cm
from ebmdatalab import charts
from functools import reduce
from matplotlib import pyplot as plt
from upsetplot import *


def redact_round_table(df_in):
    """Redacts counts <= 7 and rounds counts to nearest 5"""
    df_out = df_in.where(df_in > 7, np.nan).apply(lambda x: 5 * round(x / 5))
    return df_out


def import_clean(
    input_path,
    definitions,
    other_vars,
    demographic_covariates,
    clinical_covariates,
    reg,
    null,
    date_min,
    date_max,
    time_delta,
    output_path,
    grouping,
    code_dict="",
    dates=False,
    registered=True,
    dates_check=True,
):
    # Import
    df_import = pd.read_feather(input_path)

    # Check whether output paths exist or not, create if missing
    path_tables = f"output/{output_path}/{grouping}/tables/"
    path_figures = f"output/{output_path}/{grouping}/figures/"
    li_filepaths = [path_tables, path_figures]

    for filepath in li_filepaths:
        exists = os.path.exists(filepath)
        print(filepath)
        if not exists:
            print(filepath)
            os.makedirs(filepath)

    # restrict to registered as of index date
    if registered == True:
        df_import = df_import[df_import[reg]]

    # Dates
    if dates == True:
        date_vars = [definition + "_date" for definition in definitions]
        # Create variable that captures difference in measurement dates
        date_diff_vars = []
        # Define start and end dates
        start_date = datetime.datetime.strptime(date_min, "%Y-%m-%d")
        end_date = datetime.datetime.strptime(date_max, "%Y-%m-%d")
        for definition in definitions:
            # Remove OpenSAFELY null dates
            df_import.loc[
                df_import[definition + "_date"] == "1900-01-01", definition + "_date"
            ] = np.nan
            # Limit to period of interest
            df_import[definition + "_date"] = pd.to_datetime(
                df_import[definition + "_date"]
            )
            df_import.loc[
                df_import[definition + "_date"] < start_date, definition + "_date"
            ] = np.nan
            df_import.loc[
                df_import[definition + "_date"] > end_date, definition + "_date"
            ] = np.nan
            # Remove the measurement if outside the date parameters
            df_import.loc[df_import[definition + "_date"].isna(), definition] = np.nan
            df_import
            # Create difference between measurement dates
            df_import[definition + "_date"] = (
                df_import[definition + "_date"]
                .dt.to_period(time_delta)
                .dt.to_timestamp()
            )
            df_import = df_import.sort_values(by=["patient_id", definition + "_date"])
            df_import["date_diff_" + definition] = round(
                df_import.groupby("patient_id")[definition + "_date"].diff()
                / np.timedelta64(1, time_delta)
            )
            date_diff_vars.append("date_diff_" + definition)
    else:
        date_vars = []
        date_diff_vars = []
    # Codes
    if code_dict != "":
        for key in code_dict:
            df_import[key] = df_import[key].astype(float)
            df_import[key] = df_import[key].replace(code_dict[key])
    # Subset to relevant columns
    if dates_check:
        dates = [f"{definition}_date" for definition in definitions]
    df_clean = df_import[
        ["patient_id"]
        + definitions
        + other_vars
        + demographic_covariates
        + clinical_covariates
    ]
    # Limit to relevant date range
    df_clean = df_clean.sort_values(by="patient_id").reset_index(drop=True)
    # Set null values to nan
    for definition in definitions:
        df_clean.loc[df_clean[definition].isin(null), definition] = np.nan
    # Create order for categorical variables
    for group in demographic_covariates + clinical_covariates:
        if df_clean[group].dtype.name == "category":
            li_order = sorted(df_clean[group].dropna().unique().tolist())
            df_clean[group] = df_clean[group].cat.reorder_categories(
                li_order, ordered=True
            )
    # Mark patients with value filled/missing for each definition
    li_filled = []
    for definition in definitions:
        df_fill = pd.DataFrame(
            df_clean.groupby("patient_id")[definition].any().astype("int")
        ).rename(columns={definition: definition + "_filled"})
        df_fill[definition + "_missing"] = 1 - df_fill[definition + "_filled"]
        li_filled.append(df_fill)

    df_filled = pd.concat(li_filled, axis=1)
    # Remove list from memory
    del li_filled
    df_clean = df_clean.merge(df_filled, on="patient_id")

    # Flag all filled/all missing
    li_col_filled = [col for col in df_clean.columns if col.endswith("_filled")]
    li_col_missing = [col for col in df_clean.columns if col.endswith("_missing")]

    df_clean["any_filled"] = (df_clean[li_col_filled].sum(axis=1) > 0).astype(int)

    df_clean["all_missing"] = (
        df_clean[li_col_missing].sum(axis=1) == len(definitions)
    ).astype(int)

    df_clean["all_filled"] = (
        df_clean[li_col_filled].sum(axis=1) == len(definitions)
    ).astype(int)

    return df_clean


def simple_latest_common_comparison(
    df_clean,
    definitions,
    reg,
    other_vars,
    output_path,
    grouping,
    code_dict="",
    missing_check=False,
):
    for definition in definitions:
        if missing_check:
            df_clean = df_clean[df_clean[f"{definition}_date"] == "1900-01-01"]
        vars = [s for s in other_vars if s.startswith(definition)]
        df_subset = df_clean.loc[~df_clean[definition].isna()]
        df_subset = df_subset[
            df_subset[definition].isin(code_dict[definition].values())
        ]
        df_subset = df_subset[[definition] + vars].set_index(definition)
        df_subset = df_subset.replace(0, np.nan)
        # reorder columns
        col_arrange = [
            f"{definition}_asian",
            f"{definition}_black",
            f"{definition}_mixed",
            f"{definition}_white",
            f"{definition}_other",
        ]
        df_subset = df_subset[col_arrange]
        # find column with first instance of the maximum value
        df_subset["max"] = df_subset.astype(float).idxmax(axis=1)
        df_subset2 = df_subset
        # returning 1 for the first column that contains the highest value and 0 for everything else
        for col in df_subset2.columns:
            df_subset2[col] = np.where(df_subset2["max"] == col, 1, 0)
        # drop max column
        df_subset2 = df_subset2[col_arrange]
        df_sum = redact_round_table(df_subset2.groupby(definition).sum())
        if missing_check:
            df_sum.to_csv(
                f"output/{output_path}/{grouping}/tables/simple_latest_common_{definition}_missing_{reg}.csv"
            )
        else:
            df_sum.to_csv(
                f"output/{output_path}/{grouping}/tables/simple_latest_common_{definition}_{reg}.csv"
            )


def simple_state_change(
    df_clean, definitions, reg, other_vars, output_path, grouping, missing_check=False
):
    for definition in definitions:
        if missing_check:
            df_clean = df_clean[df_clean[f"{definition}_date"] == "1900-01-01"]
        vars = [s for s in other_vars if s.startswith(definition)]
        df_subset = (
            df_clean[[definition] + vars]
            .replace(0, np.nan)
            .set_index(definition)
            .reset_index()
        )
        ### sum all 'vars' which are not null
        df_subset[f"{definition}_any"] = df_subset[vars].notnull().sum(axis=1)
        ### all px with a latest ethnicity must have at least 1 defined ethnicity
        ### If they only have 1 recorded ethnicity this must equal the latest ethnicity
        ### replace 1 with NULL and count all with over one recorded ethnicity (i.e. latest plus another ethnicity)
        df_subset[f"{definition}_any"] = df_subset[f"{definition}_any"].replace(
            1, np.nan
        )
        df_subset["n"] = 1
        ### check if any px have latest ethnicity but no recorded ethnicity (this should be impossible!)
        # df_any_check=df_subset
        # df_any_check[f"{definition}_any_check"]=df_any_check[f"{definition}_any"]==0
        # df_any_check[f"{definition}_any_check"]=df_any_check[f"{definition}_any_check"].replace(False, np.nan)
        # df_any_check=df_any_check.groupby(definition).count()
        # df_any_check=df_any_check[f"{definition}_any_check"]
        # df_any_check.to_csv(
        #         f"output/{output_path}/{grouping}/tables/simple_{definition}_any_check.csv"
        #     )

        # Count
        df_subset2 = df_subset.loc[~df_subset[definition].isna()]
        df_subset3 = redact_round_table(
            df_subset2.groupby(definition).count()
        ).reset_index()
        if missing_check:
            df_subset3.to_csv(
                f"output/{output_path}/{grouping}/tables/simple_state_change_{definition}_missing_{reg}.csv"
            )
        else:
            df_subset3.to_csv(
                f"output/{output_path}/{grouping}/tables/simple_state_change_{definition}_{reg}.csv"
            )


def simple_patient_counts(
    df_clean,
    definitions,
    reg,
    demographic_covariates,
    clinical_covariates,
    output_path,
    grouping,
    categories=False,
):
    suffix = "_filled"
    subgroup = "with records"
    if categories == True:
        li_cat_def = []
        li_cat = (
            df_clean[definitions[0]]
            .dropna()
            .astype(str)
            .sort_values()
            .unique()
            .tolist()
        )
        for x in li_cat:
            for definition in definitions:
                df_clean.loc[df_clean[definition] == x, f"{x}_{definition}_filled"] = 1
                li_cat_def.append(f"{x}_{definition}")
            df_clean[f"{x}_any"] = (
                df_clean[df_clean.filter(regex=f"{x}").columns].sum(axis=1) > 0
            ).astype(int)
            # Assumes definition[1] is sus and definition[0] is the primary codelist
            df_clean[f"{x}_supplemented"] = (
                (df_clean[f"{x}_{definitions[0]}_filled"] == 1)
                | (
                    df_clean[definitions[0]].isnull()
                    & (df_clean[f"{x}_{definitions[1]}_filled"] == 1)
                )
            ).astype(int)
        definitions = li_cat_def
        li_cat_any = [x + "_any" for x in li_cat]
        li_cat_supplemented = [x + "_supplemented" for x in li_cat]
    # All with measurement
    li_filled = []
    for definition in definitions:
        df_temp = (
            df_clean[["patient_id", definition + suffix]]
            .drop_duplicates()
            .dropna()
            .set_index("patient_id")
        )
        li_filled.append(df_temp)
    if categories == True:
        df_temp = (
            df_clean[
                ["patient_id", "all_filled", "all_missing", "any_filled"]
                + li_cat_any
                + li_cat_supplemented
            ]
            .drop_duplicates()
            .dropna()
            .set_index("patient_id")
        )
    else:
        df_temp = (
            df_clean[["patient_id", "all_filled", "all_missing", "any_filled"]]
            .drop_duplicates()
            .dropna()
            .set_index("patient_id")
        )
    li_filled.append(df_temp)

    df_temp2 = pd.concat(li_filled, axis=1)
    df_temp2["population"] = 1
    # Remove list from memory
    del li_filled
    df_all = pd.DataFrame(df_temp2.sum()).T
    df_all["group"], df_all["subgroup"] = ["all", subgroup]
    df_all = df_all.set_index(["group", "subgroup"])

    # By group
    li_group = []
    for group in demographic_covariates + clinical_covariates:
        li_filled_group = []
        for definition in definitions:
            df_temp = (
                df_clean[["patient_id", definition + suffix, group]]
                .drop_duplicates()
                .dropna()
                .reset_index(drop=True)
            )
            li_filled_group.append(df_temp)
        if categories == True:
            df_temp = (
                df_clean[
                    ["patient_id", "all_filled", "all_missing", "any_filled", group]
                    + li_cat_any
                    + li_cat_supplemented
                ]
                .drop_duplicates()
                .dropna()
                .reset_index(drop=True)
            )
            li_filled_group.append(df_temp)
        else:
            df_temp = (
                df_clean[
                    ["patient_id", "all_filled", "all_missing", "any_filled", group]
                ]
                .drop_duplicates()
                .dropna()
                .reset_index(drop=True)
            )
            li_filled_group.append(df_temp)

        df_reduce = reduce(
            lambda df1, df2: pd.merge(df1, df2, on=["patient_id", group], how="outer"),
            li_filled_group,
        )
        df_reduce["population"] = 1
        # Remove list from memory
        del li_filled_group
        df_reduce2 = (
            df_reduce.sort_values(by=group)
            .drop(columns=["patient_id"])
            .groupby(group)
            .sum()
            .reset_index()
        )
        df_reduce2["group"] = group
        df_reduce2 = df_reduce2.rename(columns={group: "subgroup"})
        li_group.append(df_reduce2)
    df_all_group = pd.concat(li_group, axis=0, ignore_index=True).set_index(
        ["group", "subgroup"]
    )
    # Remove list from memory
    del li_group

    # Redact
    df_append = redact_round_table(df_all.append(df_all_group))
    if categories:
        df_append.to_csv(
            f"output/{output_path}/{grouping}/tables/simple_patient_counts_categories_{grouping}_{reg}.csv"
        )
    else:
        df_append.to_csv(
            f"output/{output_path}/{grouping}/tables/simple_patient_counts_{grouping}_{reg}.csv"
        )


def upset(
    df_clean,
    output_path,
    comparator_1,
    comparator_2,
    grouping,
):
    # create csv for output checking
    upset_output_check = df_clean[[comparator_1, comparator_2]]
    upset_output_check[comparator_1] = df_clean[comparator_1].fillna("Unknown")
    upset_output_check[comparator_2] = df_clean[comparator_2].fillna("Unknown")
    upset_output_check = pd.crosstab(
        upset_output_check[comparator_1], upset_output_check[comparator_2]
    )
    upset_output_check.to_csv(f"output/{output_path}/figures/upset_output_check.csv")
    del upset_output_check

    upset_df = df_clean.set_index(~df_clean[comparator_1].isnull())
    upset_df = upset_df.set_index(~upset_df[comparator_2].isnull(), append=True)

    upset_df[comparator_1] = upset_df[comparator_1].fillna("Unknown")
    upset = UpSet(upset_df, intersection_plot_elements=0)

    upset.add_stacked_bars(
        by=comparator_1, colors=cm.Pastel1, title="Count by ethnicity", elements=10
    )

    upset.plot()
    plt.savefig(
        f"output/{output_path}/{grouping}/figures/upset_{comparator_1}_{comparator_2}.png"
    )


def upset_cat(
    df_clean,
    output_path,
    comparator_1,
    comparator_2,
    other_vars,
    grouping,
):
    upset_cat_df = pd.DataFrame(df_clean[comparator_1])
    for definition in [comparator_1, comparator_2]:
        for var in other_vars:
            upset_cat_df[f"{var}_{definition}"] = (
                df_clean[definition].str.lower() == var
            )

    for definition in [comparator_1, comparator_2]:
        for var in other_vars:
            if var == other_vars[0] and definition == comparator_1:
                upset_cat_df = upset_cat_df.set_index(
                    upset_cat_df[f"{var}_{definition}"] == True
                )
            else:
                upset_cat_df = upset_cat_df.set_index(
                    upset_cat_df[f"{var}_{definition}"] == True, append=True
                )
            upset_cat_df.drop([f"{var}_{definition}"], axis=1, inplace=True)

    upset_cat_df[comparator_1] = upset_cat_df[comparator_1].fillna("Unknown")
    upset_cat = UpSet(upset_cat_df, intersection_plot_elements=0)

    upset_cat.add_stacked_bars(
        by=comparator_1, colors=cm.Pastel1, title="Count by ethnicity", elements=10
    )

    upset_cat.plot()
    plt.savefig(
        f"output/{output_path}/{grouping}/figures/upset_category_{comparator_1}_{comparator_2}.png"
    )


def records_over_time(
    df_clean,
    definitions,
    demographic_covariates,
    clinical_covariates,
    output_path,
    filepath,
    grouping,
    reg,
):
    """
    Count the number of records over time

    Arguments:
        df_clean: a dataframe that has been cleaned using import_clean()
        definitions: a list of derived variables to be evaluated
        demographic_covariates: a list of demographic covariates
        clinical_covariates: a list of clinical covariates
        output_path: filepath to the output folder
        filepath: filepath to the output file

    Returns:
        .csv file (underlying data)
        .png file (line plot)
    """
    li_df = []
    for definition in definitions:
        df_grouped = (
            df_clean[[definition + "_date", definition]]
            .groupby(definition + "_date")
            .count()
            .reset_index()
            .rename(columns={definition + "_date": "date"})
            .set_index("date")
        )
        li_df.append(redact_round_table(df_grouped))
    df_all_time = (
        pd.concat(li_df)
        .stack()
        .reset_index()
        .rename(columns={"level_1": "variable", 0: "value"})
    )
    del li_df

    fig, ax = plt.subplots(figsize=(12, 8))
    fig.autofmt_xdate()
    sns.lineplot(
        x="date", y="value", hue="variable", data=df_all_time, ax=ax
    ).set_title("New records by month")
    ax.legend().set_title("")
    if len(df_all_time) > 0:
        df_all_time.to_csv(
            f"output/{output_path}/{grouping}/tables/records_over_time{filepath}_{reg}.csv"
        )
        plt.savefig(
            f"output/{output_path}/{grouping}/figures/records_over_time{filepath}_{reg}.png"
        )

    for group in demographic_covariates + clinical_covariates:
        for definition in definitions:
            df_grouped = (
                df_clean[[definition + "_date", definition, group]]
                .groupby([definition + "_date", group])
                .count()
                .reset_index()
                .rename(columns={definition + "_date": "date"})
                .set_index(["date", group])
            )
            df_time = redact_round_table(df_grouped).reset_index()
            fig, ax = plt.subplots(figsize=(12, 8))
            fig.autofmt_xdate()
            sns.lineplot(
                x="date", y=definition, hue=group, data=df_time, ax=ax
            ).set_title(f"{definition} recorded by {group} and month")
            ax.legend().set_title("")
            if len(df_time) > 0:
                df_time.to_csv(
                    f"output/{output_path}/{grouping}/tables/records_over_time_{definition}_{group}{filepath}_{reg}.csv"
                )
                plt.savefig(
                    f"output/{output_path}/{grouping}/figures/records_over_time_{definition}_{group}{filepath}_{reg}.png"
                )


def records_over_time_perc(
    df_clean,
    definitions,
    demographic_covariates,
    clinical_covariates,
    output_path,
    filepath,
    grouping,
    reg,
):
    """
    Count the number of records over time as a percentage of all records

    Arguments:
        df_clean: a dataframe that has been cleaned using import_clean()
        definitions: a list of derived variables to be evaluated
        demographic_covariates: a list of demographic covariates
        clinical_covariates: a list of clinical covariates
        output_path: filepath to the output folder
        filepath: filepath to the output file

    Returns:
        .csv file (underlying data)
        .png file (line plot)
    """
    li_df = []
    for definition in definitions:
        df_grouped = (
            df_clean[[definition + "_date", definition]]
            .groupby(definition + "_date")
            .count()
            .reset_index()
            .rename(columns={definition + "_date": "date"})
            .set_index("date")
        )
        li_df.append(redact_round_table(df_grouped))
    df_all_time = (
        pd.concat(li_df)
        .stack()
        .reset_index()
        .rename(columns={"level_1": "variable", 0: "value"})
    )
    df_all_time["sum"] = df_all_time.groupby("variable", sort=False)["value"].transform(
        "sum"
    )
    df_all_time["value"] = df_all_time["value"] / df_all_time["sum"]
    del li_df

    fig, ax = plt.subplots(figsize=(12, 8))
    fig.autofmt_xdate()
    sns.lineplot(
        x="date", y="value", hue="variable", data=df_all_time, ax=ax
    ).set_title("New records by month")
    ax.legend().set_title("")
    if len(df_all_time) > 0:
        df_all_time.to_csv(
            f"output/{output_path}/{grouping}/tables/records_over_time{filepath}_{reg}.csv"
        )
        plt.savefig(
            f"output/{output_path}/{grouping}/figures/records_over_time{filepath}_{reg}.png"
        )

    for group in demographic_covariates + clinical_covariates:
        for definition in definitions:
            df_grouped = (
                df_clean[[definition + "_date", definition, group]]
                .groupby([definition + "_date", group])
                .count()
                .reset_index()
                .rename(columns={definition + "_date": "date"})
                .set_index(["date", group])
            )
            df_time = redact_round_table(df_grouped).reset_index()
            df_time["sum"] = df_time.groupby(group, sort=False)[definition].transform(
                "sum"
            )
            df_time[definition] = df_time[definition] / df_time["sum"] * 100
            fig, ax = plt.subplots(figsize=(12, 8))
            fig.autofmt_xdate()
            sns.lineplot(
                x="date", y=definition, hue=group, data=df_time, ax=ax
            ).set_title(f"{definition} recorded by {group} and month")
            ax.legend().set_title("")
            if len(df_time) > 0:
                df_time.to_csv(
                    f"output/{output_path}/{grouping}/tables/records_over_time_{definition}_{group}{filepath}_{reg}.csv"
                )
                plt.savefig(
                    f"output/{output_path}/{grouping}/figures/records_over_time_{definition}_{group}{filepath}_{reg}.png"
                )


def display_heatmap(df_clean, definitions, output_path):
    # All with measurement
    li_filled = []
    for definition in definitions:
        df_temp = df_clean[["patient_id"]].drop_duplicates().set_index("patient_id")
        df_temp[definition + "_filled"] = 1
        df_temp = (
            df_clean[["patient_id", definition + "_filled"]]
            .drop_duplicates()
            .dropna()
            .set_index("patient_id")
        )
        li_filled.append(df_temp)

    # Prepare data for heatmap input
    df_temp2 = pd.concat(li_filled, axis=1)
    # Remove list from memory
    del li_filled
    df_transform = df_temp2.replace(np.nan, 0)
    df_dot = redact_round_table(df_transform.T.dot(df_transform))

    # Create mask to eliminate duplicates in heatmap
    mask = np.triu(np.ones_like(df_dot))
    np.fill_diagonal(mask[::1], 0)

    # Draw the heatmap with the mask
    fig, ax = plt.subplots(figsize=(12, 8))
    sns.heatmap(df_dot, annot=True, mask=mask, fmt="g", cmap="YlGnBu", vmin=0)
    # plt.show()
    plt.savefig(f"output/{output_path}/figures/heatmap.png")


def simple_sus_crosstab(df_clean, output_path, grouping, reg):
    df_clean.ethnicity_new_5 = df_clean.ethnicity_new_5.fillna(" Unknown")
    df_clean.ethnicity_sus_5 = df_clean.ethnicity_sus_5.fillna(" Unknown")
    data_crosstab = pd.crosstab(
        df_clean.ethnicity_new_5, df_clean.ethnicity_sus_5, margins=False
    )
    data_crosstab = redact_round_table(data_crosstab)
    data_crosstab.to_csv(
        f"output/{output_path}/{grouping}/tables/simple_sus_crosstab_{reg}.csv"
    )

    df_clean = df_clean[["ethnicity_new_5", "ethnicity_sus_5"]]
    data_crosstab_long = pd.DataFrame(
        df_clean.groupby(["ethnicity_new_5", "ethnicity_sus_5"]).size()
    )
    data_crosstab_long = redact_round_table(data_crosstab_long)
    data_crosstab_long.to_csv(
        f"output/{output_path}/{grouping}/tables/simple_sus_crosstab_long_{reg}.csv"
    )


def simple_ctv3_sus_crosstab(df_clean, output_path, grouping, reg):
    df_clean.ethnicity_5 = df_clean.ethnicity_5.fillna(" Unknown")
    df_clean.ethnicity_sus_5 = df_clean.ethnicity_sus_5.fillna(" Unknown")
    data_crosstab = pd.crosstab(
        df_clean.ethnicity_5, df_clean.ethnicity_sus_5, margins=False
    )
    data_crosstab = redact_round_table(data_crosstab)
    data_crosstab.to_csv(
        f"output/{output_path}/{grouping}/tables/simple_sus_crosstab_{reg}.csv"
    )

    df_clean = df_clean[["ethnicity_5", "ethnicity_sus_5"]]
    data_crosstab_long = pd.DataFrame(
        df_clean.groupby(["ethnicity_5", "ethnicity_sus_5"]).size()
    )
    data_crosstab_long = redact_round_table(data_crosstab_long)
    data_crosstab_long.to_csv(
        f"output/{output_path}/{grouping}/tables/simple_ctv3_sus_crosstab_long_{reg}.csv"
    )
