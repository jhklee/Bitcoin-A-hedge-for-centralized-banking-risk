clear all
cd "C:\Users\dlwhd\Desktop\UT Austin\2023 Spring\Time Series\final_project\code\data"
cd
//import data
import delimited "merge_outcome_weekly_2010_222.csv"
// change gvkey data format from str4 to int
foreach x of varlist formatted_date-developing_cds_mean{
	destring `x', replace
}
// date to datetime
gen date2 = date(formatted_date, "YMD")
format date2 %td
gen time = _n
// timseries data
tsset time
// use 10 years of data from 20130401 to 20230401
drop if date2 < mdy(3, 30, 2021)

// use 10 years of data from 20110101 to 20201231
// drop if date2 > mdy(1, 1, 2021)


{ // DATA
// Generate Variables
// Bitcoin prices, gold prices, S&P 500, WTI, Dollar Index, and the Online Price Index are log-differenced. 
//The VIX, expected inflation, the one-year Treasury bill rate, and the Economic Policy Uncertainty Index are in level.

// bitcoin 
destring btc, replace ignore(",")
gen ln_btc = log(btc)
gen d_ln_btc = d.ln_btc *100
// gold : Gold Futures
gen ln_gold = log(gold)
gen d_ln_gold = d.ln_gold *100
// spy 
gen ln_spy = log(spy)
gen d_ln_spy = d.ln_spy *100
// wti : DCOILWTICO
gen ln_wti = log(wti)
gen d_ln_wti = d.ln_wti *100
// dollarindex : DTWEXBGS
gen ln_dollarindex = log(dollarindex)
gen d_ln_dollarindex= d.ln_dollarindex *100
// VIX: CBOE Volatility Index: VIX (VIXCLS)
gen ln_vix = log(vix)
gen d_ln_vix = d.ln_vix *100
// Economic Policy Uncertainty Index: usepuindxd
gen ln_epu= log(usepuindxd)
gen d_ln_epu = d.ln_epu *100
// one year treasury: dgs1
gen ln_dgs1= log(dgs1)
gen d_ln_dgs1 = d.ln_dgs1 *100
// us_cds_5y: USA credit default swap EUR 5y
gen ln_us_cds_5y= log(us_cds_5y)
gen d_ln_us_cds_5y= d.ln_us_cds_5y *100
// china_cds_5y: USA credit default swap EUR 5y
gen ln_china_cds_5y= log(china_cds_5y)
gen d_ln_china_cds_5y= d.ln_china_cds_5y *100
// real_estate etf: Vanguard Real Estate Index Fund (VGSIX)
gen ln_real_estate= log(real_estate)
gen d_ln_real_estate= d.ln_real_estate *100
// inflation expectation: T5YIFR
gen ln_t5yie= log(t5yie)
gen d_ln_t5yie= d.ln_t5yie *100
}


{ //plot graph 
tsset date2
// the natural logarithm is taken to bitcoin, gold, S&P, WTI, Dollar index
tsline ln_btc, tlabel(, format(%tdyy)) title("Log Bitcoin Price",size(medsmall)) xtitle("") ytitle("") 
tsline ln_gold,tlabel(, format(%tdyy)) title("Log Glod Price",size(medsmall)) xtitle("") ytitle("")
tsline ln_spy,tlabel(, format(%tdyy)) title("Log S&P500 Price",size(medsmall)) xtitle("") ytitle("")
tsline ln_wti,tlabel(, format(%tdyy)) title("Log WTI",size(medsmall)) xtitle("") ytitle("")
tsline ln_dollarindex,tlabel(, format(%tdyy)) title("Log Dollar Index",size(medsmall)) xtitle("") ytitle("")
tsline ln_real_estate,tlabel(, format(%tdyy)) title("Log Real Estate ETF Price",size(medsmall)) xtitle("") ytitle("")
tsline ln_us_cds_5y,tlabel(, format(%tdyy)) title("Log US CDS (5 year)",size(medsmall)) xtitle("") ytitle("")
tsline ln_china_cds_5y,tlabel(, format(%tdyy)) title("Log CHINA CDS (5 year)",size(medsmall)) xtitle("") ytitle("")

tsline dgs1,tlabel(, format(%tdyy)) title("1 year T-Bill rate",size(medsmall)) xtitle("") ytitle("")
tsline vix,tlabel(, format(%tdyy)) title("VIX",size(medsmall)) xtitle("") ytitle("")
tsline usepuindxd,tlabel(, format(%tdyy)) title("Economic Policy Uncertainty Index",size(medsmall)) xtitle("") ytitle("")
tsline t5yie,tlabel(, format(%tdyy)) title("Expectation Inflation",size(medsmall)) xtitle("") ytitle("")

// two line graphs 
// btc and cds
twoway (line ln_btc date2, ytitle("ln_btc")) (line ln_us_cds_5y date2, yaxis(2) ytitle("ln_btc"))
// btc and expt inflation
twoway (line ln_btc date2, ytitle("ln_btc")) (line t5yie date2, yaxis(2) ytitle("ln_btc"))
// gold and cds
twoway (line ln_gold date2, ytitle("ln_btc")) (line ln_us_cds_5y date2, yaxis(2) ytitle("ln_gold"))
// gold and expectation inflation
twoway (line ln_gold date2, ytitle("ln_btc")) (line t5yie date2, yaxis(2) ytitle("ln_gold"))

// gold and real_estate
twoway (line ln_gold date2, ytitle("ln_gold")) (line ln_real_estate date2, yaxis(2))

// real_estate and expectation inflation
twoway (line ln_real_estate date2, ytitle("ln_real_estate")) (line t5yie date2, yaxis(2))


}


{ // summary statistics 
estpost tabstat ln_spy t5yie dgs1 ln_us_cds_5y ln_dollarindex ln_gold ln_btc, listwise statistics(mean med max min sd)
esttab, cells("ln_spy t5yie dgs1 ln_us_cds_5y ln_dollarindex ln_gold ln_btc") nomtitle nonumber  noobs

esttab, cells("ln_spy(fmt(%8.2f)) t5yie(fmt(%8.2f)) dgs1(fmt(%8.2f)) ln_us_cds_5y(fmt(%8.2f)) ln_dollarindex(fmt(%8.2f)) ln_gold(fmt(%8.2f)) ln_btc(fmt(%8.2f))") nomtitle nonumber tex


est store A

esttab A using "try.tex", replace
}


cd "C:\Users\dlwhd\Desktop\UT Austin\2023 Spring\Time Series\final_project\code\data\robust_results\step50"
cd


{ // short run VAR

** Run VAR on transofrmed series
*Short Run Restrictions; A as lower triangular
matrix A = (1,0,0,0,0,0\ .,1,0,0,0,0 \ .,.,1,0,0,0 \ .,.,.,1,0,0 \ .,.,.,.,1,0 \.,.,.,.,.,1)
matrix A2 = (1,0,0,0,0,0,0\ .,1,0,0,0,0,0 \ .,.,1,0,0,0,0 \ .,.,.,1,0,0,0 \ .,.,.,.,1,0,0 \.,.,.,.,.,1,0\.,.,.,.,.,.,1)
* B2 is the structural variance covariance matrix
matrix B = (.,0,0,0,0,0\0,.,0,0,0,0\0,0,.,0,0,0\0,0,0,.,0,0 \0,0,0,0,.,0 \0,0,0,0,0,.)
matrix B2 = (.,0,0,0,0,0,0\0,.,0,0,0,0,0 \0,0,.,0,0,0,0\0,0,0,.,0,0,0\0,0,0,0,.,0,0 \0,0,0,0,0,.,0\ 0,0,0,0,0,0,.)

gen trend =_n
gen trend_2 =trend^2






irf cgraph (svar1 ln_us_cds_5y dgs1 sirf, level(85)), title ("Irfs of 1Y T-Bill", size(small)) 
graph export my_notrend_dollarindex_1123_cds_3var_85_tbill.png




// order1 
svar ln_spy t5yie dgs1 ln_china_cds_5y ln_dollarindex ln_gold ln_btc, lags(1/2) level(85) aeq(A2) beq(B2)
irf create svar1, set(myGraph1, replace) step(20)
// graph cds > bit 
irf cgraph (svar1 ln_spy ln_btc sirf, level(85)) (svar1 ln_china_cds_5y ln_btc sirf, level(85)) (svar1 t5yie ln_btc sirf, level(85)) (svar1 dgs1 ln_btc sirf, level(85)), title ("Irfs of Bitcoin", size(small)) 
graph export my_notrend_bit_1123_cds_3var_85_chi.png
// graph cds > gold 
irf cgraph (svar1 ln_spy ln_gold sirf, level(85)) (svar1 ln_china_cds_5y ln_gold sirf, level(85)) (svar1 t5yie ln_gold sirf, level(85)) (svar1 dgs1 ln_gold sirf, level(85)), title ("Irfs of Gold", size(small)) 
graph export my_notrend_gold_1123_cds_3var_85_chi.png
// graph cds > dollarindex 
irf cgraph (svar1 ln_spy ln_dollarindex sirf, level(85)) (svar1 ln_china_cds_5y ln_dollarindex sirf, level(85)) (svar1 t5yie ln_dollarindex sirf, level(85)) (svar1 dgs1 ln_dollarindex sirf, level(85)), title ("Irfs of Dollar Index", size(small)) 
graph export my_notrend_dollarindex_1123_cds_3var_85_chi.png


******************
// order1 
svar ln_spy t5yie dgs1 ln_us_cds_5y ln_dollarindex ln_gold ln_btc, lags(1/2) level(85) aeq(A2) beq(B2)
irf create svar1, set(myGraph1, replace) step(20)

// graph cds > bit 
irf cgraph (svar1 ln_spy ln_btc sirf, level(85)), title ("Irfs of Bitcoin", size(small)) 
graph export results_1123_cds_3var_85_chi_spy_bit.png
//
irf cgraph (svar1 ln_us_cds_5y ln_btc sirf, level(85)), title ("Irfs of Bitcoin", size(small)) 
graph export results_1123_cds_3var_85_chi_cds_bit.png
//
irf cgraph (svar1 t5yie ln_btc sirf, level(85)), title ("Irfs of Bitcoin", size(small)) 
graph export results_1123_cds_3var_85_chi_t5yie_bit.png
//
irf cgraph (svar1 dgs1 ln_btc sirf, level(85)), title ("Irfs of Bitcoin", size(small)) 
graph export results_1123_cds_3var_85_chi_dgs1_bit.png



// graph cds > gold 
irf cgraph (svar1 ln_spy ln_gold sirf, level(85)), title ("Irfs of Gold", size(small)) 
graph export results_1123_cds_3var_85_chi_spy_gold.png
//
irf cgraph (svar1 ln_us_cds_5y ln_gold sirf, level(85)), title ("Irfs of Bitcoin", size(small)) 
graph export results_1123_cds_3var_85_chi_cds_gold.png
//
irf cgraph (svar1 t5yie ln_gold sirf, level(85)), title ("Irfs of Bitcoin", size(small)) 
graph export results_1123_cds_3var_85_chi_t5yie_gold.png
//
irf cgraph (svar1 dgs1 ln_gold sirf, level(85)), title ("Irfs of Bitcoin", size(small)) 
graph export results_1123_cds_3var_85_chi_dgs1_gold.png


// inflation hedge
irf cgraph (svar1 t5yie ln_spy sirf, level(85)), title ("Irfs of Gold", size(small)) 
graph export results_1123_cds_3var_85_inflation_spy.png

// inflation hedge
irf cgraph (svar1 t5yie ln_dollarindex sirf, level(85)), title ("Irfs of Gold", size(small)) 
graph export results_1123_cds_3var_85_inflation_dollarindex.png

// inflation hedge
irf cgraph (svar1 t5yie dgs1 sirf, level(85)), title ("Irfs of Gold", size(small)) 
graph export results_1123_cds_3var_85_inflation_dgs1.png


// credit risk hedge
irf cgraph (svar1 ln_us_cds_5y ln_spy sirf, level(85)), title ("Irfs of Gold", size(small)) 
graph export results_1123_cds_3var_85_creditrisk_spy.png

// credit risk hedge
irf cgraph (svar1 ln_us_cds_5y dgs1 sirf, level(85)), title ("Irfs of Gold", size(small)) 
graph export results_1123_cds_3var_85_creditrisk_dgs1.png

// credit risk hedge
irf cgraph (svar1 ln_us_cds_5y ln_dollarindex sirf, level(85)), title ("Irfs of Gold", size(small)) 
graph export results_1123_cds_3var_85_creditrisk_dollarindex.png


}





