import itertools
import matplotlib.gridspec as gridspec
import numpy as np
import pandas as pd
import seaborn as sns

#from ebmdatalab import charts
from functools import reduce
from matplotlib import pyplot as plt

pd.options.mode.chained_assignment = None

def preprocess_data(input_path, definitions, demographic_covariates, clinical_covariates, 
                    date_min, date_max, time_delta, num_definitions, null):
    """
    Imports data and creates necessary columns to generate summary tables and figures
    """
    # Limit data to definitions, covariates, and dates of interest
    df_input = pd.read_feather(input_path)
    df_occ = df_input[['patient_id', 'date'] + definitions + demographic_covariates + clinical_covariates]
    df_occ = df_occ.loc[(date_min <= df_occ.date) & (df_occ.date <= date_max)]

    # Create columns for definition overlap
    for def_pair in list(itertools.combinations(definitions, 2)):
        df_occ.loc[(~df_occ[def_pair[0]].isna()) & (~df_occ[def_pair[1]].isna()), "both_" + def_pair[0] + "_" + def_pair[1]] = 1

    # Create flags for all overlapping or all missing
    if null == 0:
        for definition in definitions: 
            df_occ.loc[df_occ[definition] == null, definition] = np.nan
    df_occ['count_missing'] = df_occ[definitions].isna().sum(axis=1)
    df_occ['count_filled'] = num_definitions - df_occ['count_missing']
    df_occ.loc[df_occ['count_filled'] == num_definitions, 'all_filled'] = 1
    df_occ.loc[df_occ['count_missing'] == num_definitions, 'all_missing'] = 1
    
    # Create difference between measurement dates
    df_occ = df_occ.sort_values(by=['patient_id','date'])
    for definition in definitions:
        df_occ['date_diff_' + definition] = round(df_occ.groupby('patient_id')['date'].diff() / np.timedelta64(1, time_delta))
    
    # Create order for categorical variables
    for group in demographic_covariates + clinical_covariates:
        if df_occ[group].dtype.name == 'category':
            li_order = sorted(df_occ[group].dropna().unique().tolist())
            df_occ[group] = df_occ[group].cat.reorder_categories(li_order, ordered=True)
    return df_occ

def redact_round_table(df_in):
    """Redacts counts <= 5 and rounds counts to nearest 5"""
    df_in = df_in.where(df_in > 5, np.nan).apply(lambda x: 5 * round(x/5))
    df_out = df_in.where(~df_in.isna(), '-')
    return df_out

### OCCURRENCE FUNCTIONS ###

# Create unique patient and unique measurement counts by definition and overlapping definitions
def count_unique(df_occ, definitions, time_delta, unit, group=''):        
    """
    Create counts of unique patients/measurements by definition
    """
    if unit == 'patient':
        prefix = 'pat_'
        if group != '':
            groups = ['patient_id', group]
        else:
            groups = 'patient_id'
    elif unit == 'measurement':
        prefix = 'meas_'
        groups = 'date'
        if group != '':
            groups = ['date', group]
        else:
            groups = 'date'
        
    df_occ = df_occ.sort_values(by=['patient_id','date'])
    for definition in definitions:
        df_occ[prefix + definition] = df_occ.groupby(groups)[definition].transform('count')

    li_overlap = []
    for col in df_occ:
        if col.startswith('both') | col.startswith('all'):
            li_overlap.append(col)

    for overlap in li_overlap:
        df_occ[prefix + overlap] = df_occ.groupby(groups)[overlap].transform('count')

    li_prefix = []

    for col in df_occ:
        if col.startswith(prefix):
            li_prefix.append(col)
            
    if group == '':
        df_unique = pd.DataFrame(df_occ[li_prefix].sum(), columns=['counts'])
    else:
        df_unique = df_occ[[group] + li_prefix].groupby(group).sum().sort_index()
    display(redact_round_table(df_unique))

def report_over_time(df_occ, definitions, unit, group=''):
    """
    Reports number of patients/measurements over time by definition
    """
    if unit == 'patient':
        prefix = 'pat_'
        if group != '':
            groups = ['patient_id', group]
        else:
            groups = 'patient_id'
    elif unit == 'measurement':
        prefix = 'meas_'
        groups = 'date'
        if group != '':
            groups = ['date', group]
        else:
            groups = 'date'
        
    df_occ = df_occ.sort_values(by=['patient_id','date'])
    for definition in definitions:
        df_occ[prefix + definition] = df_occ.groupby(groups)[definition].transform('count')

    li_prefix = []

    for col in df_occ:
        if col.startswith(prefix):
            li_prefix.append(col)
            
    if group == '':
        df_unique = df_occ[['date'] + li_prefix].groupby('date').sum()
        df_unique_long = pd.melt(df_unique.reset_index(), id_vars='date')
    else:
        df_unique = df_occ[['date'] + [group] + li_prefix].groupby(['date'] + [group]).sum().reset_index()
        df_unique_long = pd.melt(df_unique, id_vars=['date',group])
    
    # Redact and round values
    df_unique_long['value'] = df_unique_long['value'].where(
        df_unique_long['value'] > 5, np.nan).apply(lambda x: 5 * round(x/5) if ~np.isnan(x) else x)
        
    if group == '': 
        fig, ax = plt.subplots(figsize=(12, 8))
        fig.autofmt_xdate()
        sns.lineplot(x = 'date', y = 'value', hue='variable', data = df_unique_long, ax=ax)
        ax.legend().set_title('')
        ax.set_ylabel(f'Count of unique {unit}s')
        plt.show()
    else:
        for definition in definitions:
            fig, ax = plt.subplots(figsize=(12, 8))
            fig.autofmt_xdate()
            df_plot = df_unique_long.loc[df_unique_long.variable == prefix+definition]
            sns.lineplot(x = 'date', y = 'value', hue=group, data = df_plot, ax=ax)
            ax.set_title(f'Count of unique {unit}s ({definition}) by {group}')
            ax.legend().set_title('')
            ax.set_ylabel(f'Count of unique {unit}s ({definition})')
            plt.show()
            
def report_update_frequency(df_occ, definitions, time_delta, num_definitions, group=''):
    """
    Plots histogram or boxplot of update frequency and reports average update frequency
    """
    if group == '':
        if num_definitions == 1:
            for definition in definitions: 
                avg_update_freq = df_occ.agg(
                    avg_diff = (f'date_diff_{definition}', 'mean'),
                    count = (f'date_diff_{definition}' , 'count')
                )
                if avg_update_freq.loc['count'][0] > 6:
                    avg_update_freq.loc['count'][0] = 5 * round(avg_update_freq.loc['count'][0]/5)
                    print(f'Average update frequency of {definition} by {time_delta}:\n')
                    display(avg_update_freq)
                    fig, ax = plt.subplots(figsize=(12, 8))
                    plt.hist(df_occ['date_diff_' + definition])
                    plt.title('Update frequency of ' + definition + f" by {time_delta}")
                    plt.show()
                else:
                    print('Table and plot redacted due to low counts.')
        else:
            cols = ['date_diff_' + x for x in definitions]
            df_bp = df_occ[cols]
            avg_update = pd.DataFrame(df_bp.mean(),columns=['avg_diff'])
            ct_update = pd.DataFrame(df_bp.count(),columns=['count'])
            avg_update_freq = avg_update.merge(ct_update, left_index=True, right_index=True)
            # Redact and round values
            avg_update_freq['count'] = avg_update_freq['count'].where(
                avg_update_freq['count'] > 5, np.nan).apply(lambda x: 5 * round(x/5) if ~np.isnan(x) else x)
            print(f'Average update frequency by {time_delta}:\n')
            display(avg_update_freq)    
            fig, ax = plt.subplots(figsize=(12, 8))
            null_index = avg_update_freq[avg_update_freq['count'] == '-'].index.tolist()
            sns.boxplot(data=df_bp.drop(columns=null_index), showfliers=False)
            plt.title(f"Update frequency by {time_delta}")
            plt.show()
          
    else:
        if num_definitions == 1:
            for definition in definitions: 
                df_bp = df_occ[[group]+ ['date_diff_' + definition]]
                avg_update_freq = df_occ.groupby(group).agg(
                    avg_diff = ('date_diff_' + definition, 'mean'),
                    count = ('date_diff_' + definition, 'count')
                ).reset_index()
                # Redact and round values
                avg_update_freq['count'] = avg_update_freq['count'].where(
                    avg_update_freq['count'] > 5, np.nan).apply(lambda x: 5 * round(x/5) if ~np.isnan(x) else x)
                avg_update_freq.loc[avg_update_freq['count'].isna(), ['count','avg_diff']] = ['-','-']
                print(f'Average update frequency by {group} and {time_delta}:\n')
                display(avg_update_freq)    
                null_index = avg_update_freq[avg_update_freq['count'] == '-'].index.tolist()
                fig, ax = plt.subplots(figsize=(12, 8))
                sns.boxplot(x=group, y='date_diff_'+definition, data=df_bp.loc[~df_bp[group].isin(null_index)].sort_index())
                plt.title(f"Update frequency by {group} and {time_delta}")
                plt.show()
        else:
            if df_occ[group].dtype == 'bool':
                df_occ[group] = df_occ[group].apply(lambda x: str(x))
            df_occ = df_occ.loc[~df_occ[group].isna()] # Drop nan categories
            cols = ['date_diff_' + x for x in definitions]
            df_sub = df_occ[[group] + cols]
            avg_update = df_sub.groupby(group).mean().add_prefix("avg_")
            ct_update = df_sub.groupby(group).count().add_prefix("ct_")
            avg_update_freq = avg_update.merge(ct_update, left_on=group, right_on=group).sort_index()
            for definition in definitions:
                # Redact and round values
                avg_update_freq['ct_date_diff_'+definition] = avg_update_freq['ct_date_diff_'+definition].where(
                    avg_update_freq['ct_date_diff_'+definition] > 5, np.nan).apply(lambda x: 5 * round(x/5) if ~np.isnan(x) else x)
                avg_update_freq.loc[avg_update_freq['ct_date_diff_'+definition].isna(), 
                                    ['ct_date_diff_'+definition,'avg_date_diff_'+definition]] = ['-','-']
            # Sort by index
            print(f'Average update frequencies by {time_delta}:\n')
            display(avg_update_freq)
            for definition in definitions:
                null_index = []
                null_index = avg_update_freq[avg_update_freq['ct_date_diff_'+definition] == '-'].index.tolist()
                df_sub.loc[df_sub[group].isin(null_index),'date_diff_'+definition] = np.nan
            fig, ax = plt.subplots(figsize=(12, 8))
            df_plot = df_sub.melt(id_vars=group, value_vars=cols)
            sns.boxplot(x=group, y='value', hue='variable', data=df_plot)
            plt.title(f'Update frequencies by {group} and {time_delta}')
            plt.show()

### VALUE FUNCTIONS ###            

def report_out_of_range(df_occ, definitions, min_range, max_range, num_definitions, null, group=''):
    """
    Reports number of measurements outside of defined range
    """
    
    def q25(x):
        return x.quantile(0.25)
    def q75(x):
        return x.quantile(0.75)
    
    li_dfs = []
    
    df_oor = df_occ
    for definition in definitions: 
        df_oor.loc[(df_oor[definition] < min_range) | (df_oor[definition] > max_range), "out_of_range_"+definition] = 1
        # Make definitions null if not out of range or empty
        df_oor["oor_" + definition] = df_oor[definition]
        df_oor.loc[(df_oor["out_of_range_"+definition] != 1) | (df_oor[definition] == null), "oor_" + definition] = np.nan
        if group == '':
            try:
                df_out = df_oor.agg(
                                    count = ("oor_" + definition, 'count'),
                                    mean  = ("oor_" + definition, 'mean'),
                                    pct25 = ("oor_" + definition,q25),
                                    pct75 = ("oor_" + definition,q75),
                                    )
            except:
                df_out = pd.DataFrame([['count', 0],['mean',np.nan],
                                       ['pct25',np.nan],['pct75',np.nan]], 
                                      columns=['index',"oor_" + definition]).set_index('index')
            if df_out.loc['count']["oor_" + definition] > 6:
                df_out.loc['count']["oor_" + definition] = 5 * round(df_out.loc['count']["oor_" + definition]/5)
            else:
                df_out["oor_" + definition] = '-'
        else:
            df_out = df_oor.groupby(group).agg(
                                                count = ("oor_" + definition, 'count'),
                                                mean  = ("oor_" + definition, 'mean'),
                                                pct25 = ("oor_" + definition, q25),
                                                pct75 = ("oor_" + definition, q75),
                                              ).add_suffix("_"+definition)
            df_out.loc[df_out["count_" + definition] > 5, "count_" + definition] = 5 * round(df_out["count_" + definition]/5)
            df_out.loc[df_out["count_" + definition] < 6, 
                       ["count_" + definition, "mean_" + definition,
                       "pct25_" + definition, "pct75_" + definition]] = ['-','-','-','-']
        li_dfs.append(df_out)    
    
    if num_definitions == 1:    
        display(df_out)
        if group == '': 
            if df_out["oor_" + definition]['count'] != '-':
                df_plot = df_oor["oor_" + definition]
                fig, ax = plt.subplots(figsize=(12, 8))
                plt.hist(df_plot)
                plt.title('Distribution of out of range ' + definition)
                plt.show()
            else:
                print('Plot redacted due to low counts.')
        else:
            df_oor = df_oor.loc[~df_oor[group].isna()]
            for definition in definitions: 
                null_index = df_out[df_out['count_'+definition] == '-'].index.tolist()
                df_oor.loc[df_oor[group].isin(null_index),'oor_'+definition] = np.nan
                df_bp = df_oor[[group]+ ["oor_" + definition]]
                if df_bp["oor_" + definition].sum() > 0:
                    fig, ax = plt.subplots(figsize=(12, 8))
                    sns.boxplot(x=group, y="oor_" + definition, data=df_bp)
                    plt.title(f"Distribution of out of range values by {group}")
                    plt.show()
                else:
                    print('Plot redacted due to low counts.')
    else:
        df_merged = reduce(lambda left,right: pd.merge(left,right,left_index=True, right_index=True), li_dfs)
        display(df_merged)
        if group == '':    
            cols = ["oor_" + definition for definition in definitions]
            df_bp = df_oor[cols]
            if df_merged["oor_" + definition]['count'] == '-':
                df_bp["oor_" + definition] = np.nan
            try:
                fig, ax = plt.subplots(figsize=(12, 8))
                sns.boxplot(data=df_bp)
                plt.title('Distribution of out of range values')
                plt.show()
            except: 
                print('Plot redacted due to low counts.')
        else:
            df_oor = df_oor.loc[~df_oor[group].isna()]
            for definition in definitions: 
                null_index = df_merged[df_merged['count_'+definition] == '-'].index.tolist()
                df_oor.loc[df_oor[group].isin(null_index),'oor_'+definition] = np.nan
            if df_oor[group].dtype == 'bool':
                df_oor[group] = df_oor[group].apply(lambda x: str(x))
            cols = ["oor_" + definition for definition in definitions]
            df_bp = df_oor[[group] + cols]
            df_plot = df_bp.melt(id_vars=group, value_vars=cols)
            if df_plot['value'].sum() > 0:
                fig, ax = plt.subplots(figsize=(12, 8))
                sns.boxplot(x=group, y='value', hue='variable', data=df_plot)
                plt.title(f'Distribution of out of range values by {group}')
                plt.show()
            else: 
                print('Plot redacted due to low counts.')
        
def report_distribution(df_occ, definitions, num_definitions, group=''):
    """
    Plots histogram or boxplots of distribution
    """
    
    if group == '':
        if num_definitions == 1:
            for definition in definitions: 

                avg_value = df_occ.agg(
                    avg = (definition, 'mean'),
                    count = (definition, 'count')
                )
                if avg_value.loc['count'][0] > 6:
                    avg_value.loc['count'][0] = 5 * round(avg_value.loc['count'][0]/5)
                    print(f'Average {definition}:\n')
                    display(avg_value)
                    fig, ax = plt.subplots(figsize=(12, 8))
                    plt.hist(df_occ[definition])
                    plt.title('Distribution of ' + definition)
                    plt.show()
                else:
                    print('Table and plot redacted due to low counts.')
                    
        else:
            df_bp = df_occ[definitions]
            avg = pd.DataFrame(df_bp.mean(),columns=['mean'])
            ct = pd.DataFrame(df_bp.count(),columns=['count'])
            avg_value = avg.merge(ct, left_index=True, right_index=True)
            # Redact and round values
            avg_value['count'] = avg_value['count'].where(
                avg_value['count'] > 5, np.nan).apply(lambda x: 5 * round(x/5) if ~np.isnan(x) else x)
            print('Averages:\n')
            display(avg_value)
            fig, ax = plt.subplots(figsize=(12, 8))
            sns.boxplot(data=df_bp)
            plt.title("Distributions of values")
            plt.show()
    else:
        if num_definitions == 1:
            for definition in definitions: 
                df_bp = df_occ[[group]+ [definition]]
                avg_value = df_bp.groupby(group).agg(
                    mean = (definition, 'mean'),
                    count = (definition, 'count')
                )
                # Redact and round values
                avg_value['count'] = avg_value['count'].where(
                    avg_value['count'] > 5, np.nan).apply(lambda x: 5 * round(x/5) if ~np.isnan(x) else x)
                avg_value.loc[avg_value['count'].isna(), ['count','mean']] = ['-','-']
                print(f'Averages by {group}:\n')
                display(avg_value)    
                null_index = avg_value[avg_value['count'] == '-'].index.tolist()
                fig, ax = plt.subplots(figsize=(12, 8))
                sns.boxplot(x=group, y=definition, data=df_bp.loc[~df_bp[group].isin(null_index)])
                plt.title(f"Distributions by {group}")
                plt.show()
        else:
            if df_occ[group].dtype == 'bool':
                df_occ[group] = df_occ[group].apply(lambda x: str(x))
            df_occ = df_occ.loc[~df_occ[group].isna()] # Drop nan categories
            df_bp = df_occ[[group] + definitions]
            avg = df_bp.groupby(group).mean().add_prefix("avg_")
            ct = df_bp.groupby(group).count().add_prefix("ct_")
            avg_value = avg.merge(ct, left_on=group, right_on=group)
            for definition in definitions:
                # Redact and round values
                avg_value['ct_'+definition] = avg_value['ct_'+definition].where(
                    avg_value['ct_'+definition] > 5, np.nan).apply(lambda x: 5 * round(x/5) if ~np.isnan(x) else x)
                avg_value.loc[avg_value['ct_'+definition].isna(), 
                                    ['ct_'+definition,'avg_'+definition]] = ['-','-']
            print(f'Averages by {group}:\n')
            display(avg_value)
            for definition in definitions:
                null_index = []
                null_index = avg_value[avg_value['ct_'+definition] == '-'].index.tolist()
                df_bp.loc[df_bp[group].isin(null_index),definition] = np.nan
            fig, ax = plt.subplots(figsize=(12, 8))
            df_plot = df_bp.melt(id_vars=group, value_vars=definitions)
            sns.boxplot(x=group, y='value', hue='variable', data=df_plot)
            plt.title(f'Distributions by {group}')
            plt.show()
            
            
# def mean_over_time(df_occ, definitions, group=''):
#     """
#     Report means over time
#     """
#     if group == '':
#         for definition in definitions:
#             df_means = df_occ[['date']+definition].groupby('date').mean().reset_index()
#             #df_means_long = pd.melt(df_means,'date')
#             fig, ax = plt.subplots()
#             charts.deciles_chart(
#                     df=df_means_long,
#                     period_column="date",
#                     column=definition,
#                     ax=ax,
#             )
#             ax.legend().set_title('')
#             ax.set_ylabel('Mean')
#     else: 
#         for definition in definitions:
#             df_means = df_occ[['date',group,definition]].groupby(['date',group]).mean().reset_index()
#             fig, ax = plt.subplots()
            
#             sns.lineplot(x='date', y=definition, hue=group, data=df_means, ax=ax)
#             ax.legend().set_title('')
#             ax.set_ylabel(f'Mean ({definition})')
#             ax.set_title(f'By {group}')
#             plt.show()

def measure_over_time(df_occ, definitions, group=''):
    """
    Genearte decile charts of measure over time
    """
    for definition in definitions:
        if group == '':
            n_groups = 1
            fig = plt.figure(figsize=(12, 8 * n_groups))
            fig.autofmt_xdate()
            layout = gridspec.GridSpec(n_groups, 1, figure=fig)

            df_plot = df_occ[['date',definition]]
            ax = plt.subplot(layout[0])
            title = f'{definition.replace("_"," ").title()}'
            charts.deciles_chart(
                df=df_plot,
                period_column="date",
                column=definition,
                title=title,
                ax=ax,
            )
        else: 
            group_values = df_occ[group].dropna().drop_duplicates().sort_values()
            n_groups = len(group_values)
            fig = plt.figure(figsize=(12, 8 * n_groups))
            fig.autofmt_xdate()
            layout = gridspec.GridSpec(n_groups, 1, figure=fig)
            df_plot = df_occ[['date',group,definition]]
            for groupval, lax in zip(group_values, layout):
                ax = plt.subplot(lax)
                title = (
                    f'{definition.replace("_"," ").title()}'
                    + f" - {group.title()}:{groupval}"
                )
                charts.deciles_chart(
                    df=df_plot[df_plot[group] == groupval],
                    period_column="date",
                    column=definition,
                    title=title,
                    ax=ax,
                    )

def compare_value(df_occ, definitions, group=''):
    """
    Compares values between two populated measurements (number of equal, different, mean difference)
    """
    li_comparison = []
    if group == '':
        groups = ['comparison']
    else:
        groups = ['comparison', group]
    
    for def_pair in list(itertools.combinations(definitions, 2)):
        overlap = def_pair[0] + "_" + def_pair[1]
        df_filled = df_occ.loc[df_occ['both_' + overlap] == 1]
        df_filled.loc[df_filled[def_pair[0]] == df_filled[def_pair[1]], 'num_equal'] = 1
        df_filled.loc[df_filled[def_pair[0]] != df_filled[def_pair[1]], 'num_diff'] = 1
        df_filled['diff'] = abs(df_filled[def_pair[0]]-df_filled[def_pair[1]])
        df_filled['comparison'] = overlap
        
        df_value_agg = df_filled.groupby(groups).agg(
                           num_equal = ('num_equal', 'sum'),
                           num_diff  = ('num_diff', 'sum'),
                           avg_diff = ('diff','mean'),
                      ).reset_index()
        li_comparison.append(df_value_agg)
            
    df_value_compare = pd.concat(li_comparison).reset_index(drop=True)
    display(df_value_compare)
        
    # Boxplot
    fig, ax = plt.subplots(figsize=(12, 8))
    if group == '':
        df_bp = df_occ[definitions]
        sns.boxplot(data=df_bp)
        plt.title("Comparison of Measured Values Across Definitions")
        plt.show()
    else:
        if df_occ[group].dtype == 'bool':
            df_occ[group] = df_occ[group].apply(lambda x: str(x))
        df_occ = df_occ.loc[~df_occ[group].isna()] # Drop nan categories
        df_bp = df_occ[[group] + definitions]
        df_plot = df_bp.melt(id_vars=group, value_vars=definitions)
        sns.boxplot(x=group, y='value', hue='variable', data=df_plot)
        plt.title(f"Comparison of Measured Values Across Definitions by {group}")
        plt.show()