** Code by @Viquibarone

** FIGURE 2 

use "panel_1990_2007", clear
ge om_year = 0 // I add this variable as a place holder for later graph. Stata will ommit it
areg ln_takeup_proxy1_dmn hityear_m11_m17_dmn hityear_m10_dmn-hityear_m2_dmn om_year ///
	 hityear_dmn hityear_p1_dmn-hityear_p10_dmn hityear_p11_p17_dmn ///
	if panel9007 == 1, absorb(state_year) cluster(state)
		

preserve
local pre_dummies = 10
local post_dummies = 12 
local time_zero = 11 
regsave, ci level(95)
drop if var == "_cons" 
ge event_time = _n - `time_zero' // egen event time
lab define event_time -`pre_dummies' "-`pre_dummies' " `post_dummies' " `post_dummies' " 
lab values event_time event_time


				 
** Using rcap options for confidence intervals 
graph twoway 	 (rcap ci_upper ci_lower event_time,  color(reddish)) ///
				 (scatter coef event_time, mc(reddish) lcolor(reddish) lpattern(solid) m(d)  ), ///
				 xlabel(#17,valuelabel nogrid) ylabel(-0.05(0.05)0.15,) yline(0, lp(solid)) ///
				 xline(0, lp(solid))  legend(off) scheme(plotplain) ///
				 ytitle("Effect and 95% CI",size(small)) xtitle("Event time " ,size(small))  
restore	
	 
** Dashed lines for CI and do not link the 0  				 
graph twoway 	 (line ci_upper event_time if event_time<=-1 , lpattern(dash) color(reddish)) ///
				 (line ci_lower event_time if event_time<=-1 , lpattern(dash) color(reddish)) ///
				 (line ci_upper event_time if event_time>=1 , lpattern(dash) color(reddish)) ///
				 (line ci_lower event_time if event_time>=1 , lpattern(dash) color(reddish)) ///
				 (scatter coef event_time, mc(reddish) lcolor(reddish) lpattern(solid) m(D) connect(l) lwidth(thick) ), ///
				 xlabel(#17,valuelabel nogrid) ylabel(-0.05(0.05)0.15, ) yline(0, lp(solid)) xline(0, lp(solid))  legend(off) scheme(plotplain) ///
				 ytitle("log policies per capita",size(small)) xtitle("Event time " ,size(small)) 				 					 
restore


** FIGURE 3 

areg ln_takeup_proxy1_dmn hityear_m11_m17_dmn hityear_m10_dmn-hityear_m2_dmn om_year hityear_dmn ///
		hityear_p1_dmn-hityear_p10_dmn hityear_p11_p17_dmn ddyear_m11_m17_dmn ///
		ddyear_m10_dmn-ddyear_m2_dmn om_year ddyear_dmn	ddyear_p1_dmn-ddyear_p10_dmn ddyear_p11_p17_dmn ///
		if panel9007 == 1, absorb(state_year) cluster(state)
		
		
preserve
local pre_dummies = 10
local post_dummies = 12 
local time_zero = 11 
local n_hit = `pre_dummies'+`post_dummies'+1
regsave, ci level(95)
drop if var == "_cons" 	
ge hit = ( _n<=(`n_hit') )
ge event_time = _n - `time_zero' if hit ==1 
replace event_time = _n - `n_hit' - `time_zero'  if hit ==0


** Using rcap options for confidence intervals 
graph twoway 	 (rcap ci_upper ci_lower event_time if hit == 1,  color(turquoise)) ///
				 (scatter coef event_time if hit ==1 , mc(turquoise) lcolor(turquoise) lpattern(solid) m(o)  ) ///
				 (rcap ci_upper ci_lower event_time if hit == 0,  color(orangebrown)) ///
				 (scatter coef event_time if hit ==0 , mc(orangebrown) lcolor(orangebrown) lpattern(solid) m(s)  ), ///
				 xlabel(#17,valuelabel nogrid) ylabel(-0.05(0.05)0.15,) yline(0, lp(solid)) xline(0, lp(solid))   scheme(plotplain) ///
				 ytitle("Effect and 95% CI",size(small)) xtitle("Event time " ,size(small)) ///
				  legend (label(1 " CI ") label(2 "Hit community") label(3 "CI ") label(4 "Nonhit community")  position(6) rows(1))
