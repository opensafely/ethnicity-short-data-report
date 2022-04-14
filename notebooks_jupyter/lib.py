import itertools
import matplotlib.gridspec as gridspec
import numpy as np
import pandas as pd
import seaborn as sns

from ebmdatalab import charts
from functools import reduce
from matplotlib import pyplot as plt

plt.rcParams.update({'figure.max_open_warning': 0})

def redact_round_table(df_in):
    """Redacts counts <= 5 and rounds counts to nearest 5"""
    df_out = df_in.where(df_in > 5, np.nan).apply(lambda x: 5 * round(x/5))
    return df_out

def import_clean(input_path, definitions, other_vars, demographic_covariates, clinical_covariates, null, time_delta, dates=False):
    # Import
    df_import = pd.read_feather(input_path)
    if dates==True:
        date_vars = [definition+'_date' for definition in definitions]
        for definition in definitions:
            df_import[definition+'_date'] = df_import[definition+'_date'].dt.to_period('M').dt.to_timestamp()
        # Create difference between measurement dates
        for definition in definitions:
            df_clean = df_clean.sort_values(by=['patient_id',definition+'_date'])
            df_clean['date_diff_' + definition] = round(df_clean.groupby('patient_id')[definition+'_date'].diff() / np.timedelta64(1, time_delta))
    else: 
        date_vars = []
    # Subset to relevant columns
    df_clean = df_import[['patient_id'] + definitions + other_vars + date_vars + demographic_covariates + clinical_covariates]
    # Limit to relevant date range
    df_clean = df_clean.sort_values(by='patient_id').reset_index(drop=True)
    # Set null values to nan
    for definition in definitions: 
        df_clean.loc[df_clean[definition].isin(null), definition] = np.nan
     # Create order for categorical variables
    for group in demographic_covariates + clinical_covariates:
        if df_clean[group].dtype.name == 'category':
            li_order = sorted(df_clean[group].dropna().unique().tolist())
            df_clean[group] = df_clean[group].cat.reorder_categories(li_order, ordered=True)
    # Mark patients with value filled/missing for each definition
    li_filled = []
    for definition in definitions:
        df_fill = pd.DataFrame(df_clean.groupby("patient_id")[definition].any().astype('int')).rename(
            columns={definition:definition+'_filled'}
        )
        df_fill[definition+'_missing'] = 1-df_fill[definition+'_filled']
        li_filled.append(df_fill)

    df_filled = pd.concat(li_filled, axis=1)
    df_clean = df_clean.merge(df_filled, on='patient_id')
    
    # Flag all filled/all missing
    li_col_filled = [col for col in df_clean.columns if col.endswith('_filled')]
    li_col_missing = [col for col in df_clean.columns if col.endswith('_missing')]
    df_clean['all_filled'] = (df_clean[li_col_filled].sum(axis=1) == len(definitions)).astype(int)
    df_clean['all_missing'] = (df_clean[li_col_missing].sum(axis=1) == len(definitions)).astype(int)
    
    return df_clean

def patient_counts(df_clean, definitions, demographic_covariates, clinical_covariates, categories=False, missing=False):
    suffix = '_filled'
    subgroup = 'with records'
    overlap = 'all_filled'
    if missing == True:
        suffix = '_missing'
        subgroup = 'missing records'
        overlap = 'all_missing'
    if categories == True:
        li_cat_def = []
        for definition in definitions:
            li_cat = df_clean[definition].dropna().astype(str).sort_values().unique().tolist()
            for x in li_cat:
                df_clean.loc[df_clean[definition] == x, f'{definition}_{x}_filled'] = 1 
                li_cat_def.append(f'{definition}_{x}')
        definitions = li_cat_def

    # All with measurement
    li_filled = []
    for definition in definitions:
        df_temp = df_clean[['patient_id', definition+suffix]].drop_duplicates().dropna().set_index('patient_id')
        li_filled.append(df_temp)

    df_temp = df_clean[['patient_id', overlap]].drop_duplicates().dropna().set_index('patient_id')
    li_filled.append(df_temp)
    
    df_temp2 = pd.concat(li_filled, axis=1)
    df_all = pd.DataFrame(df_temp2.sum()).T
    df_all['group'],df_all['subgroup'] = ['population',subgroup]
    df_all = df_all.set_index(['group','subgroup'])
    
    # By group
    li_group = []
    for group in demographic_covariates + clinical_covariates:
        li_filled_group = []
        for definition in definitions:
            df_temp = df_clean[['patient_id', definition+suffix, group]].drop_duplicates().dropna().reset_index(drop=True)
            li_filled_group.append(df_temp)
            
        df_temp = df_clean[['patient_id', overlap, group]].drop_duplicates().dropna().reset_index(drop=True)
        li_filled_group.append(df_temp)
        
        df_reduce = reduce(lambda df1, df2: pd.merge(df1, df2,on=['patient_id',group],how='outer'), li_filled_group)
        df_reduce2 = df_reduce.sort_values(by=group).drop(columns=['patient_id']).groupby(group).sum().reset_index()
        df_reduce2['group'] = group
        df_reduce2 = df_reduce2.rename(columns={group:'subgroup'})
        li_group.append(df_reduce2)
    df_all_group = pd.concat(li_group, axis=0, ignore_index=True).set_index(['group','subgroup'])
    
    # All population
    li_pop = []
    for definition in definitions:
        df_temp = df_clean[['patient_id']].drop_duplicates().set_index('patient_id')
        df_temp[definition] = 1
        li_pop.append(df_temp)

    df_temp = df_clean[['patient_id']].drop_duplicates().set_index('patient_id')
    df_temp[overlap] = 1
    li_pop.append(df_temp)

    df_temp0 = pd.concat(li_pop)
    df_pop = pd.DataFrame(df_temp0.sum()).T
    df_pop['group'],df_pop['subgroup'] = ['population','N']
    df_pop = df_pop.set_index(['group','subgroup'])

    # Redact
    df_pop = redact_round_table(df_pop)
    df_append = redact_round_table(df_all.append(df_all_group))

    # Create percentage columns 
    for definition in definitions:
        df_append[definition+'_pct'] = round((df_append[definition+suffix].div(df_append[definition+suffix][0]))*100,1)
    df_append[overlap+'_pct'] = round((df_append[overlap].div(df_append[overlap][0]))*100,1)

    # Final redaction step
    df_append = df_append.where(~df_append.isna(), '-')  

    # Combine count and percentage columns
    for definition in definitions:
        df_append[definition] = df_append[definition+suffix].astype(str) + " (" + df_append[definition+'_pct'].astype(str) + ")" 
        df_append = df_append.drop(columns=[definition+suffix,definition+'_pct'])
    df_append[overlap] = df_append[overlap].astype(str) + " (" + df_append[overlap+'_pct'].astype(str) + ")" 
    df_append = df_append.drop(columns=[overlap+'_pct'])

    if categories == False:
        df_all_redact = df_pop.append(df_append)
    if categories == True:
        df_all_redact = df_append
    
    # Column order
    li_col_order = []
    for definition in definitions:
        li_col_order.append(definition)
    li_col_order.append(overlap)

    df_all_redact = df_all_redact[li_col_order]
    
    return df_all_redact

def display_heatmap(df_clean, definitions):
    # All with measurement
    li_filled = []
    for definition in definitions:
        df_temp = df_clean[['patient_id']].drop_duplicates().set_index('patient_id')
        df_temp[definition+'_filled'] = 1
        df_temp = df_clean[['patient_id', definition+'_filled']].drop_duplicates().dropna().set_index('patient_id')
        li_filled.append(df_temp)

    # Prepare data for heatmap input
    df_temp2 = pd.concat(li_filled, axis=1)
    df_transform = df_temp2.replace(np.nan,0)
    df_dot = redact_round_table(df_transform.T.dot(df_transform))
    
    # Create mask to eliminate duplicates in heatmap
    mask = np.triu(np.ones_like(df_dot))
    np.fill_diagonal(mask[::1], 0)

    # Draw the heatmap with the mask
    fig, ax = plt.subplots(figsize=(12, 8))
    sns.heatmap(df_dot, annot=True, mask=mask, fmt='g', cmap="YlGnBu", vmin=0)
    plt.show()

def records_over_time(df_clean, definitions, demographic_covariates, clinical_covariates):
    li_df = []
    for definition in definitions:
        df_grouped = df_clean[[definition+'_date',definition]].groupby(definition+'_date').count().reset_index().rename(columns={definition+'_date':'date'}).set_index('date')
        li_df.append(redact_round_table(df_grouped))
    df_all_time = pd.concat(li_df).stack().reset_index().rename(columns={'level_1':'variable',0:'value'})
    fig, ax = plt.subplots(figsize=(12, 8))
    fig.autofmt_xdate()
    sns.lineplot(x = 'date', y = 'value', hue='variable', data = df_all_time, ax=ax).set_title('New records by month')
    ax.legend().set_title('')

    for group in demographic_covariates + clinical_covariates:
        for definition in definitions:
            df_grouped = df_clean[[definition+'_date',definition,group]].groupby(
                                  [definition+'_date',group]).count().reset_index().rename(columns={definition+'_date':'date'}).set_index(['date', group])
            df_time=redact_round_table(df_grouped).reset_index()
            fig, ax = plt.subplots(figsize=(12, 8))
            fig.autofmt_xdate()
            sns.lineplot(x = 'date', y = definition, hue=group, data = df_time, ax=ax).set_title(f'{definition} recorded by {group} and month')
            ax.legend().set_title('')
            
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
            
def latest_common_comparison(df_clean, definitions, other_vars):
    for definition in definitions:
        df_clean[definition] = df_clean[definition].astype(float)
        df_subset = df_clean.loc[~df_clean[definition].isna()]
        df_subset[definition] = df_subset[definition].astype(int)
        df_subset=df_subset[[definition]+other_vars].set_index(definition)

        df_subset2 = df_subset.where(df_subset.eq(df_subset.max(1),axis=0))
        df_subset_3 = df_subset2.notnull().astype('int').reset_index()
        df_sum = redact_round_table(df_subset_3.groupby(definition).sum())
        df_sum = df_sum.where(~df_sum.isna(), '-')

        df_counts = pd.DataFrame(np.diagonal(df_sum),index=df_sum.index,columns=[f'matching (n={np.diagonal(df_sum).sum()})'])

        df_sum2 = df_sum.copy(deep=True)
        np.fill_diagonal(df_sum2.values, 0)
        df_diag = pd.DataFrame(df_sum2.sum(axis=1), columns=[f'not_matching (n={df_sum2.sum(axis=1).sum()})'])
        df_out = df_counts.merge(df_diag,right_index=True,left_index=True)
        display(df_out)

        df_sum = redact_round_table(df_subset_3.groupby(definition).sum())
        df_sum = df_sum.where(~df_sum.isna(), '-')

        for col in df_sum.columns:
            df_sum = df_sum.rename(columns = {col:f'{col} (n={df_sum[col].sum()})'})
        display(df_sum)
            
def state_change(df_clean, other_vars, definitions):
    for definition in definitions:
        df_subset = df_clean[
            [definition]+other_vars
        ].replace(0,np.nan).set_index(definition).reset_index()
        # Convert categories to float (SHOULD BE DONE IN PREPROCESSING?)
        df_clean[definition] = df_clean[definition].astype(float)
        df_subset2 = df_subset.loc[~df_subset[definition].isna()]
        # Convert float code values to int for formatting
        df_subset2[definition] = df_subset2[definition].astype(int)
        df_subset3 = df_subset2.groupby(definition).count()
        # Fill in n
        df_counts = pd.DataFrame(np.diagonal(df_subset3),index=df_subset3.index,columns=['n'])
        df_out = redact_round_table(df_subset3.merge(df_counts,right_index=True,left_index=True)).reset_index()
        df_out = df_out.where(~df_out.isna(), '-')
        df_out['index'] = df_out[definition].astype(str) + " (n = " + df_out['n'].astype(str) + ")"
        df_out = df_out.drop(columns=[definition,'n']).rename(columns = {'index':definition}).set_index(definition)
        display(df_out)