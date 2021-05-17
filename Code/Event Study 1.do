global path "D:\RA Work Spring 21\Event Study"


///* Creating an Event Study graph *///

use "$path\Data\Anderson", clear

****************************************************
/* Reproducing Figure 1 of Anderson et al. (2018) */
****************************************************

*Creating a reference category for 6 years or less. This is the same reference group used by Anderson et al. 2016

gen mixed_wet_lead6minus = 0
label var mixed_wet_lead6minus "6 or less"

*However, we will not use the reference category in the event study graph since Figure 1 of Andersen et al. 2016
*do not show any reference category. The idea is to replicate the exact figure.

*First running the event study regression

#delimit ;

xi: reg ln_on_premise1_per10000 mixed_wet_lead6minus mixed_wet_lead5 mixed_wet_lead4 mixed_wet_lead3 
        mixed_wet_lead2 mixed_wet_lead1 mixed_wet_0 mixed_wet_lag1 mixed_wet_lag2 
		mixed_wet_lag3 mixed_wet_lag4 mixed_wet_lag5plus i.county_fips i.year, cluster(county_fips);

#delimit cr


*Then storing the estimates

estimates store leads_lags


*Finally plotting the event study graph using coefplot

#delimit ;

coefplot leads_lags, keep(mixed_wet_lead5 mixed_wet_lead4 mixed_wet_lead3 mixed_wet_lead2 
                          mixed_wet_lead1 mixed_wet_0 mixed_wet_lag1 mixed_wet_lag2 
						  mixed_wet_lag3 mixed_wet_lag4 mixed_wet_lag5plus)
vertical title( "{stSerif:{bf:Figure 1. {it:Trends in On-Premises Alcohol Licenses}}}", color(black) size(large))
         xtitle("{stSerif:Years Since Law Came into Effect}") xscale(titlegap(2)) xline(6, lcolor(black))
yline(-.2 0 .2 .4 .6, lwidth(vvvthin) lpattern(dash) lcolor(black))
note("{stSerif:{it:Notes}. OLS coefficient estimates (and their 95% confidence intervals) are reported. The dependent}"
     "{stSerif:variable is equal to the number of on-premises liquor licences per 1,000 population in county {it:c}}"
     "{stSerif: and year {it:t}. The controls include year fixed effects and the data cover the period 1977-2011.}", margin(small))
graphregion(fcolor(white) lcolor(white) lwidth(vvvthin) ifcolor(white) ilcolor(white)  
ilwidth(vvvthin)) ciopts(lwidth(*3) lcolor(black)) mcolor(black) ;

#delimit cr

graph export "$path\Graphs\Anderson_Fig1_v1.png", as(png) replace



clear








































