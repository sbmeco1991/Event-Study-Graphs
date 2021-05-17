global path "D:\RA Work Spring 21\Event Study"


///* Creating an Event Study graph *///

***************************************************
/* Computing an event study graph with FARS data */
***************************************************

clear

/* Doing an event-study analysis of the effect of MMLs on the ln(traffic fatalities per 100,000 population) using the data set that you
   used in Assignment 2. You’re going to have to generate an indicator equal to 1 the year in which medical marijuana was legalized.
   You’re also going to have to generate the leads and lags of this indicator. Include year dummies and state dummies on the right-hand
   side of the regression, but no other controls. */

import excel "$path\Data\FARS_Data.xls", firstrow       /* Importing the FARS dataset */

/* Creating Dependent variable of ln(traffic fatalities per 100,000 population) */

gen pop2 = pop/100000   /* Population per 100000 */
gen fatal_rate = fatals/pop2
gen y = ln(fatal_rate)
label var y "Natural log of the traffic fatality rate per 100,000 population" 

/* Creating indicator variable of MML */

gen MML = 0
replace MML = 1 if (stfips==2 & year>=1999)
replace MML = 1 if (stfips==4 & year>=2011)
replace MML = 1 if (stfips==6 & year>=1996)
replace MML = 1 if (stfips==8 & year>=2001)
replace MML = 1 if (stfips==9 & year>=2014)
replace MML = 1 if (stfips==10 & year>=2015)
replace MML = 1 if (stfips==11 & year>=2013)
replace MML = 1 if (stfips==15 & year>=2000)
replace MML = 1 if (stfips==17 & year>=2015)
replace MML = 1 if (stfips==23 & year>=1999)
replace MML = 1 if (stfips==26 & year>=2008)
replace MML = 1 if (stfips==25 & year>=2013)
replace MML = 1 if (stfips==30 & year>=2004)
replace MML = 1 if (stfips==32 & year>=2001)
replace MML = 1 if (stfips==34 & year>=2012)
replace MML = 1 if (stfips==35 & year>=2007)
replace MML = 1 if (stfips==41 & year>=1998)
replace MML = 1 if (stfips==44 & year>=2006)
replace MML = 1 if (stfips==50 & year>=2004)
replace MML = 1 if (stfips==53 & year>=1998)
label var MML "Indicator for whether MML was legal in state s at year t"


*******************************************************************************

/* Sorting this dataset by state and year */

sort stfips year


/* Setting the panel and time variables */

tset stfips year


/* Cloning mml for year 0 */

clonevar mml = MML
label var mml "0"


/* Creating five-period lags of the indicator variable of MML */

gen mml_lag1 = L.mml
replace mml_lag1 = 0 if mml_lag1==.
label var mml_lag1 "1"

gen mml_lag2 = L2.mml
replace mml_lag2 = 0 if mml_lag2==.
label var mml_lag2 "2"

gen mml_lag3 = L3.mml
replace mml_lag3 = 0 if mml_lag3==.
label var mml_lag3 "3"

gen mml_lag4 = L4.mml
replace mml_lag4 = 0 if mml_lag4==.
label var mml_lag4 "4"

gen mml_lag5 = L5.mml
replace mml_lag5 = 0 if mml_lag5==.
label var mml_lag5 "5"



/* Creating five-period leads of the indicator variable of MML */

gen mml_lead1 = F.mml
replace mml_lead1 = 0 if mml_lead1==.
label var mml_lead1 "-1"

gen mml_lead2 = F2.mml
replace mml_lead2 = 0 if mml_lead2==.
label var mml_lead2 "-2"

gen mml_lead3 = F3.mml
replace mml_lead3 = 0 if mml_lead3==.
label var mml_lead3 "-3"

gen mml_lead4 = F4.mml
replace mml_lead4 = 0 if mml_lead4==.
label var mml_lead4 "-4"

gen mml_lead5 = F5.mml
replace mml_lead5 = 0 if mml_lead5==.
label var mml_lead5 "-5"


*********************************************************************************************************
///* Event-Study analysis of the effect of MMLs on the ln(traffic fatalities per 100,000 population) *///
*********************************************************************************************************

*Running the event study regression

#delimit ;

xi: reg y mml_lead5 mml_lead4 mml_lead3 mml_lead2 mml_lead1 mml mml_lag1 mml_lag2 mml_lag3 
          mml_lag4 mml_lag5 i.stfips i.year, cluster(stfips) ;

#delimit cr

*Storing the coefficients

parmest, label level(90 95) saving("$path\Data\mml_estimates.dta", replace)

*Creating base category for event study graph for the period of "-1"

use "$path\Data\mml_estimates.dta", clear

keep if strpos(parm, "mml")   /* Keeping the event-year coefficients and dropping the control variables */

gen EventYear = _n-6


*Setting the coefficients for the base year

global vars "estimate stderr dof t p min90 max90 min95 max95"

foreach var in $vars {
 replace `var' = 0 if parm=="mml_lead1"
 }
 
 
*Changing the format fo the EventYear variable to make it plottable
 
gen double EventYear2 = EventYear   
drop EventYear
rename EventYear2 EventYear

drop label /* Dropping the label variable */

save "$path\Data\mml_estimates_modified.dta", replace

clear


/*************************************************/
*Trying to plot the event study graph using twoway*
/*************************************************/

use "$path\Data\mml_estimates_modified.dta", clear


#delimit ;

graph twoway 	 (rcap max95 min95 EventYear,  mcolor(black) lcolor(black) lpattern(solid)) 
				 (scatter estimate EventYear, mcolor(black) lcolor(black) lpattern(solid) m(d)  ), 
				 graphregion(fcolor(white) lcolor(white) lwidth(vvvthin) ifcolor(white) ilcolor(white) ilwidth(vvvthin))
				 title( "{stSerif:{bf:Figure 2. {it:Trends in Traffic Fatalities}}}", color(black) size(large)) 
                 xtitle("{stSerif:Years Since Medical Marijuana was Legalized}") xscale(titlegap(2)) 
				 xline(0, lcolor(black) lpattern(dash)) legend(off) 
				 yline(0, lcolor(black) lpattern(dash))
				 yline(-0.1 -0.05 0 0.05 0.1, lwidth(vvvthin) lpattern(dash) lcolor(black)) 
				 xlabel(#17,valuelabel nogrid) 
note("{stSerif:{it:Notes}. OLS coefficient estimates (and their 95% confidence intervals) are reported.}" 
     "{stSerif:            The dependent variable is log of traffic fatalities per 100,000 population in state {it:s} and year {it:t}.}" 
     "{stSerif:            The controls include state and year fixed effects and the data cover the period from 2005 to 2015.}", margin(small)) ;
				 
#delimit cr

graph export "$path\Graphs\Traffic_Fatalities_ES_v1.png", as(png) replace


clear




















