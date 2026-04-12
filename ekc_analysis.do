clear all
set more off
cd .
import excel "EKC_Data.xlsx", firstrow clear

drop I-AA

rename State state
rename Year year
rename PM25 pm25
rename GDP gdp
rename Vechiles vehicles
rename Electricity electricity
rename Factories factories
rename ForestCover forestcover

destring electricity, replace force
destring forestcover, replace force 

keep if year >= 2004 & year <= 2020
drop if state == "Andhra Pradesh"
drop if state == "Telangana"

encode state, gen(state_id)
xtset state_id year 

gen log_pm25 = log(pm25)
gen log_gdp = log(gdp)
gen log_vehicles = log(vehicles)
gen log_electricity = log(electricity)
gen log_factories = log(factories)
gen log_forest = log(forestcover)

summarize log_gdp
gen log_gdp_c = log_gdp - r(mean)
gen log_gdp_sq_c = log_gdp_c^2

xtsum pm25 gdp vehicles electricity factories forestcover
xtsum log_pm25 log_gdp_c log_gdp_sq_c log_vehicles log_electricity log_factories log_forest

xtreg log_pm25 log_gdp log_gdp_sq log_vehicles log_electricity log_factories log_forest, fe vce(cluster state_id)

xtreg log_pm25 log_gdp log_gdp_sq log_vehicles log_electricity log_factories log_forest, fe
estimates store fixed

xtreg log_pm25 log_gdp log_gdp_sq log_vehicles log_electricity log_factories log_forest, re
estimates store random

hausman fixed random

corr log_gdp_c log_gdp_sq_c

predict resid, e
histogram resid
sktest resid

xtreg log_pm25 log_gdp_c log_gdp_sq_c log_vehicles log_electricity log_factories log_forest i.year, fe vce(cluster state_id)