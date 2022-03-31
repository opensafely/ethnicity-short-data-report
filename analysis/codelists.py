from cohortextractor import (
    codelist,
    codelist_from_csv,
)
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity-uk-categories.csv",
    system="snomed",
    column="code",
)

group1 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group1.csv",
    system="snomed",
    column="code",
)

group2 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group2.csv",
    system="snomed",
    column="code",
)

group3 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group3.csv",
    system="snomed",
    column="code",
)

group4 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group4.csv",
    system="snomed",
    column="code",
)

group5 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group5.csv",
    system="snomed",
    column="code",
)

group6 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group6.csv",
    system="snomed",
    column="code",
)

group7 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group7.csv",
    system="snomed",
    column="code",
)

group8 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group8.csv",
    system="snomed",
    column="code",
)

group9 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group9.csv",
    system="snomed",
    column="code",
)

group10 = codelist_from_csv(
    "codelists/user-rohini-mathur-ethnicity_group10.csv",
    system="snomed",
    column="code",
)

# ----------------
# Ethnicity codes
# ----------------

ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)


ethnicity_codes_16 = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_16",
)

# Ethnicity codes
eth2001 = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth2001.csv",
    system="snomed",
    column="code",
    category_column="grouping_6_id",
)

eth2001_16 = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth2001.csv",
    system="snomed",
    column="code",
    category_column="grouping_16_id",
)

# Any other ethnicity code
non_eth2001 = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-non_eth2001.csv",
    system="snomed",
    column="code",
)

# Ethnicity not given - patient refused
eth_notgiptref = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth_notgiptref.csv",
    system="snomed",
    column="code",
)

# Ethnicity not stated
eth_notstated = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth_notstated.csv",
    system="snomed",
    column="code",
)

# Ethnicity no record
eth_norecord = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth_norecord.csv",
    system="snomed",
    column="code",
)

# --------------------
# Clinical conditions
# --------------------
# Chronic cardiac disease
chronic_cardiac_dis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease-snomed.csv",
    system="snomed",
    column="id",
)
# Chronic kidney disease
chronic_kidney_dis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-kidney-disease-snomed.csv",
    system="snomed",
    column="id",
)
# Chronic liver disease
chronic_liver_dis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-liver-disease-snomed.csv",
    system="snomed",
    column="id",
)
# Chronic respiratory disease
chronic_respiratory_dis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-respiratory-disease-snomed.csv",
    system="snomed",
    column="id",
)
# Cancer (Haemotological)
cancer_haem_codes = codelist_from_csv(
    "codelists/opensafely-haematological-cancer-snomed.csv",
    system="snomed",
    column="id",
)
# Cancer (Lung)
cancer_lung_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer-snomed.csv", system="snomed", column="id"
)
# Cancer (Other)
cancer_other_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological-snomed.csv",
    system="snomed",
    column="id",
)
# Dementia
dementia_codes = codelist_from_csv(
    "codelists/opensafely-dementia-snomed.csv", system="snomed", column="id"
)
# Diabetes
diabetes_codes = codelist_from_csv(
    "codelists/opensafely-diabetes-snomed.csv", system="snomed", column="id"
)
# Housebound
housebound_codes = codelist_from_csv(
    "codelists/opensafely-housebound.csv", system="snomed", column="code"
)
# Hypertension
hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension-snomed.csv", system="snomed", column="id"
)
# Learning disability
wider_ld_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-learndis.csv", system="snomed", column="code"
)
# Severe obesity
sev_obesity_codes = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-sev_obesity.csv",
    system="snomed",
    column="code",
)


##### custom ethnicity
white = codelist_from_csv(
    "codelists/user-candrews-white.csv",
    system="ctv3",
    column="code",
)

black = codelist_from_csv(
    "codelists/user-candrews-black.csv",
    system="ctv3",
    column="code",
)

asian = codelist_from_csv(
    "codelists/user-candrews-asian.csv",
    system="ctv3",
    column="code",
)

other = codelist_from_csv(
    "codelists/user-candrews-other.csv",
    system="ctv3",
    column="code",
)

mixed = codelist_from_csv(
    "codelists/user-candrews-mixed.csv",
    system="ctv3",
    column="code",
)