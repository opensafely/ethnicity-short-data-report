import pandas as pd
from itertools import product
import numpy as np


def local_patient_counts(
    definitions,input_path, output_path, code_dict="",definition_dict="", categories=False, missing=False,quietly =False
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
            f"output/{input_path}/simple_patient_counts_categories_registered.csv"
        ).set_index(["group", "subgroup"])
        for col in df_append.columns[df_append.columns.str.endswith('any')]:
            df_append=df_append.rename(columns={col: f"{col}_filled"})

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
                        df_append[f"population_{definition}"] - df_append[full_definition + "_filled"]
                    )  
                df_append[full_definition + "_pct"] = round(
                    (df_append[full_definition + suffix].div(df_append[f"population"])) * 100, 1
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
                    df_append[full_definition + suffix].apply(lambda x: "{:,.0f}".format(x))
                    + " ("
                    + df_append[full_definition + "_pct"].astype(str)
                    + ")"
                )
                df_append = df_append.drop(columns=[full_definition + suffix, full_definition + "_pct"])
    else:
        df_append = pd.read_csv(
            f"output/{input_path}/simple_patient_counts_registered.csv"
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
        df_patient_counts = df_append[definitions + [overlap] + ["population"]]
    # Final redaction step
    df_patient_counts = df_patient_counts.replace(np.nan, "-")
    df_patient_counts = df_patient_counts.replace("nan (nan)", "- (-)")
    for k, v in definition_dict.items():
        df_patient_counts.columns = df_patient_counts.columns.str.replace(k,v) 
    df_patient_counts.columns = df_patient_counts.columns.str.replace("_", " ")
   
    if categories:
        df_patient_counts.to_csv(
                f"output/{output_path}/local_patient_counts_categories_registered.csv"
            )
    else:
        df_patient_counts.to_csv(
                f"output/{output_path}/local_patient_counts_registered.csv"
            )

########################################################
########################################################
def local_state_change(
    definitions, input_path,output_path, code_dict="", definition_dict="",
):
    for definition in definitions:
            lowerlist_5 = [x.lower() for x in (list(code_dict[definition].values()))]
            df_state_change = pd.read_csv(f'output/{input_path}/simple_state_change_{definition}_registered.csv').set_index(definition)
            df_state_change.columns = df_state_change.columns.str.replace(definition + "_", "")
            #resort rows
            df_state_change = df_state_change.reindex(list(code_dict[definition].values()))
            df_state_change = df_state_change.reset_index()
            
            df_state_change[definition]=df_state_change[definition]+": " +df_state_change["n"].apply(lambda x: "{:,.0f}".format(x))
            df_state_change = df_state_change.set_index(definition)

            for item in lowerlist_5 + list(["any"]):
                df_state_change[item + "_pct"]= round(
                        (df_state_change[item].div(df_state_change["n"])) * 100, 1
                    )
            
                df_state_change[item] = (
                        df_state_change[item].apply(lambda x: "{:,.0f}".format(x))
                        + " ("
                        + df_state_change[item + "_pct"].astype(str)
                        + ")"
                    )
            df_state_change=df_state_change[lowerlist_5 + list(["any"])]
            df_state_change = df_state_change.replace("nan (nan)", "- (-)")
            df_state_change = df_state_change.reset_index()
            df_state_change = df_state_change.rename(definition_dict, axis='columns')
            df_state_change.rename(columns={f'{definition_dict[definition]}':f'Latest Ethnicity-\n{definition_dict[definition]}'}, inplace=True)
            df_state_change = df_state_change.set_index(f'Latest Ethnicity-\n{definition_dict[definition]}')
            df_state_change.to_csv(
                f"output/{output_path}/local_state_change_{definition}_registered.csv"
            )


def local_latest_common(definitions, input_path,output_path, code_dict="", definition_dict="",suffix="",
):
    for definition in definitions:
            if code_dict != "":
                lowerlist_5 = [x.lower() for x in (list(code_dict[definition].values()))]
            df_sum = pd.read_csv(f'output/{input_path}/simple_latest_common_{definition}{suffix}_registered.csv').set_index(definition)
            # sort rows by category index
            df_sum.columns = df_sum.columns.str.replace(definition + "_", "")
            df_sum.columns = df_sum.columns.str.lower()
            df_sum = df_sum.reindex(list(code_dict[definition].values()))
            df_sum = df_sum[lowerlist_5]
            ### daisy
            df_counts = pd.DataFrame(
                np.diagonal(df_sum),
                index=df_sum.index,
            #   columns=[f"matching (n={np.diagonal(df_sum).sum()})"],
            )

            df_sum2 = df_sum.copy(deep=True)
            np.fill_diagonal(df_sum2.values, 0)
            df_diag = pd.DataFrame(
                df_sum2.sum(axis=1),
            )
            df_out = df_counts.merge(df_diag, right_index=True, left_index=True)
            columns=round(df_out.sum()/df_out.sum(axis=1).sum()*100,1)

            df_out.columns=[f"matching ({columns[0]}%)",f"not matching ({columns[1]}%)"]
            df_out = df_out.reset_index()
            df_out = df_out.rename(definition_dict, axis='columns')
            df_out.rename(columns={f'{definition_dict[definition]}':f'Latest Ethnicity-\n{definition_dict[definition]}'}, inplace=True)
            df_out = df_out.set_index(f'Latest Ethnicity-\n{definition_dict[definition]}')
            df_out = df_out.replace(np.nan, "-")
            df_out.to_csv(
                f"output/{output_path}/local_latest_common_{definition}_registered.csv"
            )
            
            if code_dict != "":
                lowerlist_5 = [x.lower() for x in (list(code_dict[definition].values()))]
                df_sum = df_sum[lowerlist_5]
            else:
                df_sum = df_sum.reindex(sorted(df_sum.columns), axis=1)

            # Combine count and percentage columns
            df_sum["population"]=df_sum.sum(axis = 1)
            for item in lowerlist_5:
                df_sum[item + "_pct"]= round(
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
            df_sum = df_sum.rename(definition_dict, axis='columns')
            df_sum.rename(columns={f'{definition_dict[definition]}':f'Latest Ethnicity-\n{definition_dict[definition]}'}, inplace=True)
            df_sum = df_sum.set_index(f'Latest Ethnicity-\n{definition_dict[definition]}')
            df_sum.to_csv(
                f"output/{output_path}/local_latest_common_{definition}_expanded_registered.csv"
            )
