import pandas as pd
from itertools import product


def local_patient_counts(
    definitions, output_path, code_dict="", categories=False, missing=False,
):
    import pandas as pd

    suffix = "_filled"
    overlap = "all_filled"
    if missing == True:
        suffix = "_missing"
        overlap = "all_missing"
    if categories:
        df_append = pd.read_csv(
            f"../output/{output_path}/simple_patient_counts_categories.csv"
        ).set_index(["group", "subgroup"])
        # ensure definitions[n] in code_dict[definitions[n]] below refers to one of the definitions of interest
        definitions = [
            f"{category}_{definition}"
            for category, definition in product(
                code_dict[definitions[1]].values(), definitions
            )
        ]
    else:
        df_append = pd.read_csv(
            f"../output/{output_path}/simple_patient_counts.csv"
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
    df_append["population"] = df_append["population"].apply(
        lambda x: "{:,.0f}".format(x)
    )
    df_append = df_append.drop(columns=[overlap + "_pct"])
    df_patient_counts = df_append[definitions + [overlap] + ["population"]]
    # Final redaction step
    df_patient_counts = df_patient_counts.replace("nan", "-")
    df_patient_counts = df_patient_counts.replace("nan (nan)", "- (-)")
    df_patient_counts.columns = df_patient_counts.columns.str.replace("_", " ")
    display(df_patient_counts)
