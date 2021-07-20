/*==============================================================================
DO FILE NAME:			00_describe_snomed_ethnicity
PROJECT:				Ethnciity short data report
DATE: 					20 July 2021
AUTHOR:					R  Mathur 
DESCRIPTION OF FILE:	generate counts of each ethnicity SNOMED code in TPP 
DATASETS USED:			input.csv

DATASETS CREATED: 		snomed_ethnicity_counts.dta
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)								
==============================================================================*/
sysdir set PLUS ./analysis/adofiles
adopath + ./analysis/adofiles
sysdir

* Open a log file
cap log close
log using ./logs/00_describe_snomed_ethnicity, replace t

*create stata version of codelists for merginng
import delimited ./codelists/opensafely-ethnicity-uk-categories_formerge.csv, clear
format snomedcode %20.0f
tostring snomedcode, replace format(%20.0g)
save ./output/opensafely-ethnicity-uk-categories_formerge.dta, replace

clear
import delimited ./output/input.csv


order patient_id

*collapse count of each ethincity code 
collapse (sum) eth_*

*reshape long
gen ethnicity=1
reshape long eth_, i(ethnicity) j(snomedcode)
ren eth_ snomedcode_count

format snomedcode %20.0f
tostring snomedcode, replace format(%20.0g)

*merge with codelist for descriptors
merge 1:1 snomedcode using ./output/opensafely-ethnicity-uk-categories_formerge.dta

gen include=0
replace include=1 if _merge==3
replace include=0 if snomedcode_count==0
tab include
drop code
save ./output/snomed_ethnicity_counts.dta, replace

log close
