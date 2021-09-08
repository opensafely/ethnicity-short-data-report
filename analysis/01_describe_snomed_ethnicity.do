/*==============================================================================
DO FILE NAME:			00_describe_snomed_ethnicity
PROJECT:				Ethnicity short data report
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
log using ./logs/01_describe_snomed_ethnicity, replace t

*create stata version of codelists for merging
import delimited ./codelists/opensafely-ethnicity-uk-categories.csv, clear
format code %20.0f
tostring code, gen(snomedcode) format(%20.0g)
save ./output/opensafely-ethnicity-uk-categories_formerge.dta, replace

clear

*import csv for each group and save as dta
import delimited using ./output/input.csv, clear
gen group=1
save ./output/input1.dta, replace

forvalues i=2/10 {
	 import delimited ./output/input_`i'.csv, clear
	 gen group=`i'
	save ./output/input`i'.dta, replace
}

forvalues i=1/10 {
	use ./output/input`i'.dta, clear
	
	*collapse count of each ethnicity code 
	collapse (sum) eth_* (min) group

	*reshape long
	gen ethnicity=1
	reshape long eth_ , i(ethnicity) j(snomedcode)
	ren eth_ snomedcode_count

	format snomedcode %20.0f
	tostring snomedcode, replace format(%20.0g)

	*merge with codelist for descriptors
	merge 1:1 snomedcode using ./output/opensafely-ethnicity-uk-categories_formerge.dta, keep(match)

	gen include=0
	replace include=1 if _merge==3
	replace include=0 if snomedcode_count==0
	tab include
	drop code
	save ./output/snomed_ethnicity_count_`i'.dta, replace
}

*append all 10 files
use ./output/snomed_ethnicity_count_1.dta
forvalues i=2/10 {
	 append using ./output/snomed_ethnicity_count_`i'.dta
}

gsort -include snomedcode

order snomedcode
tab group
tab include
export delimited using ./output/snomed_ethnicity_counts.csv, replace
log close
