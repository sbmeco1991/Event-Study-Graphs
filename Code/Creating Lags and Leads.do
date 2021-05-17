global path "D:\RA Work Spring 21\Event Study\Data"


/* Creating lags and leads and verifying with the Anderson dataset */

use "$path\Anderson", replace

sort county_fips year

tset county_fips year


/* In Anderson et al. (2016) they considered the year 1987 as Year 0. Year 1 starts from 1988.
   The data goes till the year 2011. So we have 24 years of post-period data and 10 years of 
   pre-period data. In total we have data over 35 years from 1977 to 2011. */



***Lags***

gen mixed_wet_lg4 = L4.mixed_wet_0
replace mixed_wet_lg4 = 0 if mixed_wet_lg4==.
assert mixed_wet_lg4==mixed_wet_lag4

gen mixed_wet_lg3 = L3.mixed_wet_0
replace mixed_wet_lg3 = 0 if mixed_wet_lg3==.
assert mixed_wet_lg3==mixed_wet_lag3

gen mixed_wet_lg2 = L2.mixed_wet_0
replace mixed_wet_lg2 = 0 if mixed_wet_lg2==.
assert mixed_wet_lg2==mixed_wet_lag2

gen mixed_wet_lg1 = L1.mixed_wet_0
replace mixed_wet_lg1 = 0 if mixed_wet_lg1==.
assert mixed_wet_lg1==mixed_wet_lag1

global x "5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24"

foreach x in $x{
 gen mixed_lag`x' = L`x'.mixed_wet_0
 replace mixed_lag`x' = 0 if mixed_lag`x'==.
}

egen mixed_wet_lg5plus = rowtotal(mixed_lag5 mixed_lag6 mixed_lag7 mixed_lag8 mixed_lag9 mixed_lag10 mixed_lag11 mixed_lag12 mixed_lag13 mixed_lag14 mixed_lag15 mixed_lag16 mixed_lag17 mixed_lag18 mixed_lag19 mixed_lag20 mixed_lag21 mixed_lag22 mixed_lag23 mixed_lag24)

assert mixed_wet_lg5plus==mixed_wet_lag5plus



***Leads***

gen mixed_wet_ld5 = F5.mixed_wet_0
replace mixed_wet_ld5=0 if mixed_wet_ld5==.
assert mixed_wet_ld5==mixed_wet_lead5

gen mixed_wet_ld4 = F4.mixed_wet_0
replace mixed_wet_ld4=0 if mixed_wet_ld4==.
assert mixed_wet_ld4==mixed_wet_lead4

gen mixed_wet_ld3 = F3.mixed_wet_0
replace mixed_wet_ld3=0 if mixed_wet_ld3==.
assert mixed_wet_ld3==mixed_wet_lead3

gen mixed_wet_ld2 = F2.mixed_wet_0
replace mixed_wet_ld2=0 if mixed_wet_ld2==.
assert mixed_wet_ld2==mixed_wet_lead2

gen mixed_wet_ld1 = F1.mixed_wet_0
replace mixed_wet_ld1=0 if mixed_wet_ld1==.
assert mixed_wet_ld1==mixed_wet_lead1



**************************************************************************
/* How to create lag/lead of x and more years in a single variable: x+ lag 
   or x- lead when you have many years of post/pre period data and cannot 
   show all in an event study graph */
**************************************************************************

*Using Anderson et al. 2016 data

*This is the step to follow

/* Create lags/leads for every year after event or before event for which you have data. 
   Then just sum them row wise. That will give you the x+ or x- lag/lead indicator 
   variable. You can only show one side i.e. either x+ or x- */
   
clear

use "$path\Anderson", clear

sort county_fips year

tset county_fips year

global x "5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24"

foreach x in $x{
 gen mixed_lag`x' = L`x'.mixed_wet_0
 replace mixed_lag`x' = 0 if mixed_lag`x'==.
}


egen mixed_5plus = rowtotal(mixed_lag5 mixed_lag6 mixed_lag7 mixed_lag8 mixed_lag9 mixed_lag10 mixed_lag11 mixed_lag12 mixed_lag13 mixed_lag14 mixed_lag15 mixed_lag16 mixed_lag17 mixed_lag18 mixed_lag19 mixed_lag20 mixed_lag21 mixed_lag22 mixed_lag23 mixed_lag24)

assert mixed_5plus==mixed_wet_lag5plus
















