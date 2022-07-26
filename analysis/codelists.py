from cohortextractor import (
    codelist,
    codelist_from_csv,
)
from itertools import product

definitions_ctv3 = ["ethnicity_5"]
definitions_ctv3_16 = ["ethnicity_16"]

definitions_snomed = ["ethnicity_new_5", "ethnicity_primis_5"]
definitions_snomed_16 = ["ethnicity_new_16", "ethnicity_primis_16"]

other_vars = ["white", "mixed", "asian", "black", "other"]
other_vars_16 = [
    "White_British",
    "White_Irish",
    "Other_White",
    "White_and_Black_Caribbean",
    "White_and_Black_African",
    "White_and_Asian",
    "Other_Mixed",
    "Indian",
    "Pakistani",
    "Bangladeshi",
    "Other_Asian",
    "Caribbean",
    "African",
    "Other_Black",
    "Chinese",
    "Any_other_ethnic_group",
]

ethnicity_combinations_ctv3 = [
    f"{definition}_{other_var}"
    for definition, other_var in product(definitions_ctv3, other_vars)
]
ethnicity_combinations_snomed = [
    f"{definition}_{other_var}"
    for definition, other_var in product(definitions_snomed, other_vars)
]

ethnicity_combinations_ctv3_16 = [
    f"{definition}_{other_var}"
    for definition, other_var in product(definitions_ctv3_16, other_vars_16)
]
ethnicity_combinations_snomed_16 = [
    f"{definition}_{other_var}"
    for definition, other_var in product(definitions_snomed_16, other_vars_16)
]

ethnicity_combinations_ctv3 = (
    ethnicity_combinations_ctv3 + ethnicity_combinations_ctv3_16
)
ethnicity_combinations_snomed = (
    ethnicity_combinations_snomed + ethnicity_combinations_snomed_16
)

codelists_ctv3 = {
    name: codelist_from_csv(f"codelists/{name}.csv", system="ctv3", column="Code",)
    for name in ethnicity_combinations_ctv3
}
locals().update(codelists_ctv3)

codelists_snomed = {
    name: codelist_from_csv(f"codelists/{name}.csv", system="snomed", column="Code",)
    for name in ethnicity_combinations_snomed
}
locals().update(codelists_snomed)


# ----------------
# Ethnicity codes
# ----------------

ethnicity_codes_ctv3 = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)


ethnicity_codes_ctv3_16 = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_16",
)

ethnicity_codes_snomed = codelist_from_csv(
    "codelists/opensafely-ethnicity-snomed-0removed.csv",
    system="snomed",
    column="snomedcode",
    category_column="Grouping_6",
)


ethnicity_codes_snomed_16 = codelist_from_csv(
    "codelists/opensafely-ethnicity-snomed-0removed.csv",
    system="snomed",
    column="snomedcode",
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
