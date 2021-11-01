/*==============================================================================
DO FILE NAME:			02_attach_ethnicity_categories
PROJECT:				Ethnicity short data report
DATE: 					14 Oct 2021
AUTHOR:					R  Mathur 
DESCRIPTION OF FILE:	RM to attach her initial categorization of ethnicity codes for review
DATASETS USED:			./output/snomed_ethnicity_counts.csv

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
log using ./logs/02_attach_ethnicity_categories, replace t

*create stata version of codelists for merging
import delimited ./released_outputs/output/snomed_ethnicity_counts.csv, clear
format snomedcode %25.0f
drop _merge ethnicity include group
*drop if snomedcode_count==0
tostring snomedcode_count, replace
gen unique= term + snomedcode_count
duplicates drop unique, force
save ./codelists/snomed_ethnicity_codelist_sep20.dta, replace

*attach codes that I handwrote myself - snomed code column has lost precision
insheet using ./released_outputs/output/snomed_ethnicity_counts_categorized.csv, clear
drop snomedcode
*drop if snomedcode_count==0
tostring snomedcode_count, replace
gen unique= term + snomedcode_count
merge m:1  unique using ./codelists/snomed_ethnicity_codelist_sep20.dta
order snomedcode eth16 eth5
sort eth5 eth16

drop unique


split eth16, p(-)
drop eth16
ren eth161 eth16
ren eth162 eth16_term
destring eth16, replace

replace eth16_term= eth16_term + eth163 if eth163!=""
replace eth16_term=subinstr(eth16_term, "  ", " ",.)
drop eth163

gen eth5_term="White" if eth5==1
replace eth5_term="Mixed" if eth5==2
replace eth5_term="South Asian" if eth5==3
replace eth5_term="Black" if eth5==4
replace eth5_term="Other" if eth5==5
replace eth5_term="Unknown" if eth16==20
replace eth5_term="remove" if eth16==21
drop _m 
drop if snomedcode==.
order snomedcode eth5* eth16* term *count

replace eth5=22 if eth5==.
replace eth16=22 if eth16==.

replace eth5_term="zero count in TPP" if eth5==22
replace eth16_term="zero count in TPP" if eth16==22

save ./output/snomed_ethnicity_codelist_forupload_Oct19.dta, replace

export delimited using ./output/snomed_ethnicity_codelist_forupload_Oct19.csv, replace 

