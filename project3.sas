/* Project 3 Survival analysis in HNSCC patients */

libname pj3 "C:\Users\mandyho\Desktop";

* format age to four age group;
proc univariate data = pj3.cancer; var how_old; run;

data cancer; set pj3.cancer; 
if aspirin = 1 then drug = 1;
if statin = 1 then drug = 2;
if metformin = 1 then drug = 3;
if insulin = 1 then drug = 4;  

* categorize to agegrp: Q1: 52, Q2: 59 Q3: 68;
if .z < how_old <= 52 then agegrp = 1;
else if 52 < how_old <= 59 then agegrp = 2;
else if 59 < how_old <= 68 then agegrp = 3;
else if how_old > 68 then agegrp = 4;

label deathstatus = "Death status"
	  recurstatus = "Recurrence status"
	  stime = "Survival time"
	  rtime = "Recurrence time"
	  drug = "Comorbidity medication"
	  agegrp = "Age group";

run;


proc format;
*value drugfmt 1 = 'Aspirin' 2 = 'Statin' 3 = 'Metformin' 4 = 'Insulin';
value sitefmt 1 = "Larynx" 2 = "Oral Cavity" 3 = "Oropharynx" 4 = "Other";
value binaryfmt 1 = 'YES' 0 = 'NO';
value agegrpfmt 1 = 'age <= 52' 2 = '52 < age <= 59' 3 = '59 < age <= 68' 4 = 'age > 68';
run;

* check age group;
proc freq data = cancer; table agegrp; format agegrp agegrpfmt.; run;

proc contents data = cancer; run;

/* 1. demo descriptive statistics */
ods pdf file = "table1_demo.pdf";
proc freq data = cancer;
table gender race smoker drinker hpvstat site aspirin statin metformin insulin stage agegrp/chisq binomial;
run;
ods pdf close;

/* 2. survival rate (NOT USED) */
ods pdf file = "table2_death.pdf";
proc freq data = cancer;
table deathstatus deathstatus*recurstatus deathstatus*aspirin deathstatus*statin deathstatus*metformin deathstatus*insulin 
deathstatus*site deathstatus*stage deathstatus*hpvstat deathstatus*drinker deathstatus*smoker deathstatus*gender deathstatus*race deathstatus*agegrp/ chisq;
run;
ods pdf close; 


ods pdf file = "table2_by_death.pdf";
proc sort data = cancer; by deathstatus; run;
proc freq data = cancer;
by deathstatus;
table recurstatus aspirin statin metformin insulin site hpvstat smoker drinker gender race agegrp/ chisq;
run;
ods pdf close; 

/* modify survival plot */
* display template name;
%grtitle(path =  Stat.Lifetest.Graphics.ProductLimitSurvival2);

* display template, find the statement indicate graph title: 
if number of strata = 1: change Lifetest_ProductLimitSurvival22
else change Lifetest_ProductLimitSurvival24 ;
proc template;
source Stat.Lifetest.Graphics.ProductLimitSurvival2;
run;


/* 3. overall survival */
%macro median_survival(catname, catvar, catfmt, test);
ods graphics on / width= 8in height = 6in outputfmt=png imagename = "OS_curve_&catname";
ODS EXCLUDE ProductLimitEstimates LogrankHomCov WilcoxonHomCov;
title "survival test strata by &catname";
proc lifetest data = cancer plots=survival(cb=hw test atrisk(maxlen=13 outside(0.15))); 
time stime*deathstatus(0);
strata &catvar / test = &test;
format &catvar &catfmt;
run;
%mend;


ODS TRACE ON;
ODS PDF FILE = "C:\Users\mandyho\Desktop\table2_OS.pdf";
ODS EXCLUDE ProductLimitEstimates LogrankHomCov WilcoxonHomCov;
ODS LISTING GPATH= "C:\Users\mandyho\Desktop";
ods graphics on / width= 8in height = 6in outputfmt=png imagename = "OS_curve";
title "survival test";
%let Lifetest_ProductLimitSurvival22 = Overall Survival; * change title;
proc lifetest data = cancer PLOT = survival(cb = hw atrisk(maxlen=13 outside(0.15))); 
time stime*deathstatus(0);
run;


%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Recurrence Status; * change title;
%median_survival(recur, recurstatus, binaryfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Clinical Staging; * change title;
%median_survival(stage, stage,, wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Aspirin Use; * change title;
%median_survival(aspirin, aspirin, binaryfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Metformin Use; * change title;
%median_survival(metformin, metformin, binaryfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Statin Use; * change title;
%median_survival(statin, statin, binaryfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Insulin Use; * change title;
%median_survival(insulin, insulin, binaryfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Age Group; * change title;
%median_survival(agegrp, agegrp, agegrpfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Tumor Site; * change title;
%median_survival(site, site, , wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Gender; * change title;
%median_survival(gender, gender,, wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Drinking Status; * change title;
%median_survival(drinker, drinker, wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Overall Survival stratum by Smoking Status; * change title;
%median_survival(smoker, smoker,, wilcoxon);


ODS PDF CLOSE;
ODS TRACE OFF;



/* 4. progression-free survival */
%macro PFS(catname, catvar, catfmt, test);
ods graphics on / width= 8in height = 6in outputfmt=png imagename = "PFS_curve_&catname";
ODS EXCLUDE ProductLimitEstimates LogrankHomCov WilcoxonHomCov;
title "survival test strata by &catname";
proc lifetest data = cancer plots=survival(cb=hw test atrisk(maxlen=13 outside(0.15))); 
time rtime*recurstatus(0);
strata &catvar / test = &test;
format &catvar &catfmt;
run;
%mend;


ODS TRACE ON;
ODS PDF FILE = "C:\Users\mandyho\Desktop\table2_PFS.pdf";
ODS EXCLUDE ProductLimitEstimates LogrankHomCov WilcoxonHomCov;
ODS LISTING GPATH= "C:\Users\mandyho\Desktop";
ods graphics on / width= 8in height = 6in outputfmt=png imagename = "PFS_curve";
title "survival test";

%let Lifetest_ProductLimitSurvival22 = Progression-Free Survival; * change title;
proc lifetest data = cancer PLOT = survival(cb = hw atrisk(maxlen=13 outside(0.15))); 
time rtime*recurstatus(0);
run;


%let Lifetest_ProductLimitSurvival24 = Progression-Free Survival stratum by Clinical Staging; * change title;
%PFS(stage, stage,, wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Progression-Free Survival stratum by Aspirin Use; * change title;
%PFS(aspirin, aspirin, binaryfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Progression-Free Survival stratum by Metformin Use; * change title;
%PFS(metformin, metformin, binaryfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Progression-Free Survival stratum by Statin Use; * change title;
%PFS(statin, statin, binaryfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Progression-Free Survival stratum by Insulin Use; * change title;
%PFS(insulin, insulin, binaryfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Progression-Free Survival stratum by Age Group; * change title;
%PFS(agegrp, agegrp, agegrpfmt., wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Progression-Free Survival stratum by Tumor Site; * change title;
%PFS(site, site, , wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Progression-Free Survival stratum by Gender; * change title;
%PFS(gender, gender,, wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Progression-Free Survival stratum by Drinking Status; * change title;
%PFS(drinker, drinker,,wilcoxon);
%let Lifetest_ProductLimitSurvival24 = Progression-Free Survival stratum by Smoking Status; * change title;
%PFS(smoker, smoker,, wilcoxon);


ODS PDF CLOSE;
ODS TRACE OFF;



/***** 5. COX time independent model**********
covariate of interest: aspirin metformin statin insulin
adjusting for recurrent status, tumor sites
**********************************************/

ods pdf file = "table3_cox.pdf";
ODS TRACE ON;
ODS EXCLUDE ClassLevelInformation CensoredSummary;
title "stratified on variable not following PH assumptions";
proc phreg data = cancer2;
class recurstatus(ref = 'NO') agegrp(ref = '1') sex(ref = '0') smoke(ref = '0') drink(ref = '0') site_num(ref = 'Other') stage(ref = '0')
		aspirin(ref = 'NO') metformin(ref = 'NO') statin(ref = 'NO') insulin(ref = 'NO');
strata agegrp sex smoke drink stage;
model stime*deathstatus(0) = recurstatus site_num aspirin metformin statin insulin / ties = EFRON RISKLIMITS;
format recurstatus aspirin metformin statin insulin binaryfmt.;
format site_num sitefmt.;
*proportionality test can only test continous paramter;
freq deathstatus; *count ties (not working);
run;



/******* 6. COX time varying model ******
* time varying variable: recurrence status
* time-varying for recurrence status two time point:
t1: recurring time
t2: survival time
*****************************************/

* * data formulation;
data cancer2; set cancer;
if gender = 'Male' then sex = 1;
else if gender = 'Female' then sex = 0;

if site = "Larynx" then site_num = 1;
else if site = "Oral Cavity" then site_num = 2;
else if site = "Oropharynx" then site_num = 3;
else if site = "Other (HP or other)" then site_num = 4;

if smoker = "current in past 12 mos" then smoke = 2;
else if smoker = "former smoker > 12 mos" then smoke = 1;
else if smoker = "never" then smoke = 0;

if drinker = "current" then drink = 2;
else if drinker = "former drinker > 12 mos" then drink = 1;
else if drinker = "never" then drink = 0;

if recurstatus = 1 then do;
    t1 = 0; t2 = rtime; recurrence = 0; death_new = 0; output; * time till recurrence;
    t1 = rtime; t2 = stime; recurrence = 1; death_new = deathstatus; output; * time from recurrence to dead/cencer;
end;
else do;
    t1 = 0; t2 = stime; recurrence = 0; death_new = deathstatus; output; * time till dead/cancer, no recurrance;
end;
run;

ODS EXCLUDE ClassLevelInformation CensoredSummary;
title "time varying model(condition on recurrence time): stratied by variables not meeting PH assumption";
proc phreg data = cancer2;
class recurstatus(ref = 'NO') agegrp(ref = '1') sex(ref = '0') smoke(ref = '0') drink(ref = '0') site_num(ref = 'Other') stage(ref = '0')
		aspirin(ref = 'NO') metformin(ref = 'NO') statin(ref = 'NO') insulin(ref = 'NO');
strata agegrp sex smoke drink stage;
model (t1 t2)*death_new(0) = recurstatus site_num aspirin metformin statin insulin / ties = EFRON RISKLIMITS;
format recurstatus aspirin metformin statin insulin binaryfmt.;
format site_num sitefmt.;
*proportionality test can only test continous paramter;
freq deathstatus; *count ties (not working);
run;

ODS TRACE OFF;
ods pdf close;



/******** 7. Cox time dependent model ***********
time dependent: log scale the time for parameters
               that failed to meet PH assumpation,
(age, sex, stage, smoking status,drinking status,
               aspirin, metformin, statin)
however, this will cause categorical variables will
        convert to continuous, so NOT USED,
*************************************************/

title "time dependent covariates";
proc phreg data = cancer2;
model stime*deathstatus(0) = recurstatus_t agegrp_t sex_t smoke_t drink_t site_num_t stage_t aspirin_t metformin_t statin_t insulin / ties = EFRON RISKLIMITS;
* time dependent covariates;
recurstatus_t = recurstatus*log(stime);
agegrp_t = agegrp*log(stime);
sex_t = sex*log(stime);
smoke_t = smoke*log(stime);
drink_t = drink*log(stime);
site_num_t = site_num*log(stime);
stage_t = stage*log(stime);
aspirin_t = aspirin*log(stime);
metformin_t = metformin*log(stime);
statin_t = statin*log(stime);
*proportionality test;
proportionality_test: test recurstatus_t, agegrp_t, sex_t, site_num_t, smoke_t, drink_t, stage_t, aspirin_t, metformin_t, statin_t, insulin; 
freq deathstatus; *count ties (not working);
run;



/***** 8. Cox time varying + dependent model (NOT USED)****
1. time varying: recurrent status
2. time dependent: age, sex, stage, smoking status,
drinking status, aspirin, metformin, statin
*************************************************/


title "time varying model: condition on recurrence time (categorical variables will convert to continuous)";
proc phreg data = cancer2;
* time-varying model;
model (t1 t2)*death_new(0) = recurrence agegrp_t sex_t smoke_t drink_t site_num_t stage_t aspirin_t metformin_t statin_t insulin / ties = EFRON RISKLIMITS;
* time dependent covariates;
agegrp_t = agegrp*log(stime);
sex_t = sex*log(stime);
site_num_t = site_num*log(stime);
stage_t = stage*log(stime);
smoke_t = smoke*log(stime);
drink_t = drink*log(stime);
aspirin_t = aspirin*log(stime);
metformin_t = metformin*log(stime);
statin_t = statin*log(stime);
*proportionality test;
proportionality_test: test recurrence, agegrp_t, sex_t, site_num_t, smoke_t, drink_t, stage_t, aspirin_t, metformin_t, statin_t, insulin; 
freq deathstatus; *count ties;
run;
