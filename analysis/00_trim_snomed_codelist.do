/*==============================================================================
DO FILE NAME:			00_trim_snomed_codeslit
PROJECT:				Ethnicity short data report
DATE: 					20 July 2021
AUTHOR:					R  Mathur 
DESCRIPTION OF FILE:	generate smaller csv files 
DATASETS USED:			opensafely-ethnicity-uk-categories.csv

DATASETS CREATED: 		smaller codelist csvs
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)								
==============================================================================*/

* Open a log file
cap log close
log using ./logs/00_trim_snomed_codelist, replace t

import delimited ./codelists/opensafely-ethnicity-uk-categories.csv, clear
save ./codelists/opensafely-ethnicity-uk-categories.dta, replace

*gen groups of 50 codes
tostring code, replace
format code %20.0f
gen group=[_n]
replace group=group/61
replace group=ceil(group)
tab group

 preserve 
 foreach i of num 1/10 {
         keep if group == `i'
		 drop group
		 tostring code, replace
         export delimited ./codelists/group`i'.csv, replace novarnames
         restore, preserve 
 }

 log close
