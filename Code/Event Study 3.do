global path "D:\RA Work Spring 21\Event Study"


*******************************************************************************************
///* Reproducing Figure 1 of Anderson et al. (2018) by changing the reference category *///
*******************************************************************************************

use "$path\Data\Anderson", clear


/* Seting the time and panel variable */

tset county_fips year


/* Creating reference category */

drop mixed_wet_lead1
gen mixed_wet_lead1 = 0
label var mixed_wet_lead1 "-1"

/* Since we are going to change the reference category to the year before the event 
   happened we also need to change the end-points of the graph as earlier our reference 
   category was year 6 or less. */
   
   
*Creating the lead for 5 minus years

global x "6 7 8 9 10"

foreach x in $x{
 gen mixed_wet_lead`x' = F`x'.mixed_wet_0
 replace mixed_wet_lead`x' = 0 if mixed_wet_lead`x'==.
}

egen mixed_wet_lead5minus = rowtotal(mixed_wet_lead5 mixed_wet_lead6 mixed_wet_lead7 mixed_wet_lead8 mixed_wet_lead9 mixed_wet_lead10)
label var mixed_wet_lead5minus "-5 or less"


*Running the event-study regression

xi: reg ln_on_premise1_per10000 mixed_wet_lead5minus mixed_wet_lead4 ///
mixed_wet_lead3 mixed_wet_lead2 mixed_wet_lead1 mixed_wet_0 ///
mixed_wet_lag1 mixed_wet_lag2 mixed_wet_lag3 ///
mixed_wet_lag4 mixed_wet_lag5plus i.county_fips i.year, cluster(county_fips)


*Storing the estimates from the event-study regression

estimates store leads_lags


*Plotting the event-study graph

#delimit ;

coefplot leads_lags, keep(mixed_wet_lead5minus mixed_wet_lead4 mixed_wet_lead3 mixed_wet_lead2 
                          mixed_wet_lead1 mixed_wet_0 mixed_wet_lag1 mixed_wet_lag2 
						  mixed_wet_lag3 mixed_wet_lag4 mixed_wet_lag5plus)
omitted baselevels
vertical title( "{stSerif:{bf:Figure 1. {it:Trends in On-Premises Alcohol Licenses}}}", color(black) size(large))
         xtitle("{stSerif:Years Since Law Came into Effect}") xscale(titlegap(2)) xline(6, lcolor(black))
yline(-.2 0 .2 .4 .6, lwidth(vvvthin) lpattern(dash) lcolor(black))
note("{stSerif:{it:Notes}. OLS coefficient estimates (and their 95% confidence intervals) are reported. The dependent}"
     "{stSerif:variable is equal to the number of on-premises liquor licences per 1,000 population in county {it:c}}"
     "{stSerif: and year {it:t}. The controls include year fixed effects and the data cover the period 1977-2011.}", margin(small))
graphregion(fcolor(white) lcolor(white) lwidth(vvvthin) ifcolor(white) ilcolor(white)  
ilwidth(vvvthin)) ciopts(lwidth(*3) lcolor(black)) mcolor(black) ;

#delimit cr

graph export "$path\Graphs\Anderson_Fig1_v2.png", as(png) replace


clear


