import os 
import pandas as pd
import numpy as np

from datetime import datetime
from glob import glob

# Append monthly files 
li = []

for file in glob('output/data/input_sdr_*.feather'):
    df_temp = pd.read_feather(file)
    # Create date variable
    df_temp['date'] = datetime.strptime(file.rsplit("_",1)[-1].split(".")[0], '%Y-%m-%d')
    li.append(df_temp)
    
df_input = pd.concat(li, axis=0).reset_index(drop=True)

# Output as file
df_input.to_feather('output/data/input_all.feather')