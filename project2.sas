/***** Project 2 The potential impact of menthol on transitions from cigarettes to e-cigarettes: PATH Study *****
Project Description: Prevalence of smoking cigarette has decrease throughout the years; however, menthol-cigarette usage has continued to increase, especially in young ages and non-Hispanic black group. Moreover, with the increase popularity of e-cigarette usage, there is an increase trend of e-cigarette usage in the young ages. References showed that menthol-cigarette may lead to higher dependency of nicotine, while e-cigarette may help adults quit or reduce smoking habit. In this study, impact of menthol flavoring cigarettes on transition of cigarette to e-cigarette were being assessed, as well as other demographic factors that might impact the transition.
Study Design: Data were collected from the PATH (Population Assessment of Tobacco and Health) study. There were total around 49,000 people age 12 years and older participated in this study, the study spanned from wave 1 (2013) to wave 4 (2017), information regarding to tobacco usage, age, gender, education, income, health conditions were also collected for each individual in each wave.
Statistical Analysis: To focus on cigarette to e-cigarette transitions, trajectory analysis and logistic regression were conducted targeting the participants who started as cigarette but non-e-cigarette users at wave 1, developments of their e-cigarette usage through wave 2 to wave 4 were assessed. ROC analysis was also assessed to check logistic regression model performance.
*********************************************************************************************************/

libname pj "C:\Users\mandyho\Desktop";
proc contents data = pj.proj2; run;
proc print data = pj.proj2; where PERSONID = 'P000113106'; run;

/* DATA CLEANING */
data tdata; set pj.proj2; 
*R02_A_PWGTt = input(R02_A_PWGT,8.);
*R03_A_SWGTt = input(R03_A_SWGT,8.);
*R03_A_AWGTt = input(R03_A_AWGT,8.);
*R04_A_A01WGTt = input(R04_A_A01WGT,8.);
*R04_A_S01WGTt = input(R04_A_S01WGT,8.);

if respondent_type = "Continuing Adult" then respondent_type_dummy = 0;
if respondent_type = "Aged up Adult" then respondent_type_dummy = 1;
if cigs_everysome_ESTD = "established everyday or some days" then cigs = 1;
if cigs_everysome_ESTD = "none" then cigs = 0; 
if ecigs_everysome = "none" then ecigs = 0;
if ecigs_everysome = "ever" then ecigs = 1;
if educat = "Less than HS" then educat_dummy = 0;
if educat = "HS degree/GED" then educat_dummy = 1;
if educat = "Some college" then educat_dummy = 2;
if educat = "College or mo" then educat_dummy = 3;
if income = "1 = Less than $10,000" then income_dummy = 0;
if income = "2 = $10,000 to $24,999" then income_dummy = 1;
if income = "3 = $25,000 to $49,999" then income_dummy = 2;
if income = "4 = $50,000 to $99,999" then income_dummy = 3;
if income = "5 = $100,000 or more" then income_dummy = 4;
if cigs_everysome_ESTD = "none" and menthol_cig = . then menthol_cig_dummy = 0;
if cigs_everysome_ESTD = "established everyday or some days" and menthol_cig = 1 then menthol_cig_dummy = 1;
if cigs_everysome_ESTD = "established everyday or some days" and menthol_cig = 0 then menthol_cig_dummy = 0;
run;



/* extarct ID that presents in all waves using wave 4 all waves weight;
data ID; set tdata;
keep PERSONID;
where R04_A_A01WGT is not null;
run;


/* 1. frequency one way*/
%macro freq_oneway(var, weight);
title "One way frequency: &var, &weight";
proc surveyfreq data = tdata; 
strata VARSTRAT;
cluster VARPSU;
table &var/chisq cl; 
weight &weight;
run;
%mend;


ods pdf file = "table1_freq_one_way_wave1.pdf";
%freq_oneway(income, R01_A_PWGT);
%freq_oneway(educat, R01_A_PWGT);
%freq_oneway(RE, R01_A_PWGT);
%freq_oneway(agegrp, R01_A_PWGT);
%freq_oneway(male, R01_A_PWGT);
%freq_oneway(ecigs_everysome, R01_A_PWGT);
%freq_oneway(cigs_everysome_ESTD, R01_A_PWGT);
%freq_oneway(menthol_cig_dummy, R01_A_PWGT);
ods pdf close;

/* 2. frequency two way */
%macro freq_oneway_by_two(var1, var2, weight);
title "two way freq: &var2 by &var1, &weight";
proc sort data = tdata; by &var1; 
proc surveyfreq data = tdata;
strata VARSTRAT;
cluster VARPSU;
by &var1;
table &var2/chisq cl;
weight &weight;
run;
%mend;


ods pdf file = "appendix_table1&2_menthol_ecig_by_age_race.pdf";
%freq_freq_oneway_by_two(RE, menthol_cig_dummy, R01_A_PWGT);
%freq_freq_oneway_by_two(agegrp, menthol_cig_dummy, R01_A_PWGT);
%freq_freq_oneway_by_two(RE, ecigs_everysome, R01_A_PWGT);
%freq_freq_oneway_by_two(agegrp, ecigs_everysome, R01_A_PWGT);
ods pdf close;

/* 3. chisquare test between ecig, menthol-cig & race, age*/
%macro freq_twoway(var1, var2);
proc surveyfreq data = tdata;
strata VARSTRAT;
cluster VARPSU;
table &var1*&var2 / chisq;
weight R01_A_PWGT;
run;
%mend;

%freq_twoway(ecigs_everysome, RE);
%freq_twoway(ecigs_everysome, agegrp);
%freq_twoway(menthol_cig_dummy, RE);
%freq_twoway(menthol_cig_dummy, agegrp);



/* 4. Data extraction: to see the development of cig = 1 and ecig = 0 subjects through wave 2 ~ 4*/
* (1) extract wave 1: cig = 0 and ecig = 0;
proc sql;
create table wave1_ID_cig1 as
select *
from tdata
where wave = 1 and cigs = 1 and ecigs = 0
order by PERSONID;
quit;

* (2) extract ID exist in wave1_ID_cig0;
%macro cig_extract(val, table_name);
proc sql;
create table &table_name as
select *
from tdata
where wave = &val and PERSONID in (select PERSONID from wave1_ID_cig1)
order by PERSONID;
quit;
%mend;
%cig_extract(2, wave2_ID_cig1);
%cig_extract(3, wave3_ID_cig1);
%cig_extract(4, wave4_ID_cig1);

* (3) freq across wave 2-4;
%macro freq_extract(table_name, weight);
title "cig, ecig, menthol development: &table_name";
proc surveyfreq data = &table_name;
strata VARSTRAT;
cluster VARPSU;
table cigs ecigs menthol_cig_dummy/ cl;
weight &weight;
run;
%mend;

ods pdf file = 'appendix_table3_cig_ecig_menthol_develop.pdf';
title "whole data cig, ecig development: wave 1";
%freq_extract(tdata, R01_A_PWGT);
%freq_extract(tdata, R02_A_PWGT);
%freq_extract(tdata, R03_A_AWGT);
%freq_extract(tdata, R04_A_A01WGT);
ods pdf close;


ods pdf file = 'appendix_table4_cig1_ecig0_menthol_develop.pdf';
title "cig, ecig development: wave 1";
%freq_extract(wave1_ID_cig1, R01_A_PWGT);
%freq_extract(wave2_ID_cig1, R02_A_PWGT);
%freq_extract(wave3_ID_cig1, R03_A_AWGT);
%freq_extract(wave4_ID_cig1, R04_A_A01WGT);
ods pdf close;

/* 5. create outcome: ecig = 1 & cig = 0 in wave2 or wave3 or wave4--> initiate = 1 */
proc sql;
create table wave2_initiate as
select *
from wave2_ID_cig1
where cigs = 0 and ecigs = 1;
quit;

proc sql;
create table wave3_initiate as
select *
from wave3_ID_cig1
where cigs = 0 and ecigs = 1;
quit;

proc sql;
create table wave4_initiate as
select *
from wave4_ID_cig1
where cigs = 0 and ecigs = 1;
quit;

proc sql;
create table wave1_initiate_outcome as
select *,
case when PERSONID in (select PERSONID from wave2_initiate) then 1
	when PERSONID in (select PERSONID from wave3_initiate) then 1
	when PERSONID in (select PERSONID from wave4_initiate) then 1
	else 0 end as initiate
from wave1_ID_cig1;
quit;


/* 6. Logistic regression: initiation of cig to e-cig during wave 2 ~ 4 (for users starting as cigarette users) */

ods pdf file = "LR_results.pdf";
* Frequency table of initiation;
title "outcome freq from wave 1";
proc surveyfreq data = wave1_initiate_outcome;
cluster VARSTRAT;
strata VARPSU;
table ecigs cigs menthol_cig_dummy initiate;
weight R01_A_PWGT;
run;

* Logistic regression on cig ecig, menthol development
* (1) Model 1: LR unadjusted model;
title "LR unadjusted model";
proc surveylogistic data = wave1_initiate_outcome;
strata VARSTRAT;
cluster VARPSU;
class menthol_cig_dummy(ref = '0');
model initiate(event = '1') = menthol_cig_dummy/expb;
output out=pred_ds_model1 p=phat;
weight R01_A_PWGT;
run;

* delete missing value in phat;
data pred_ds_model1_nomissing; set pred_ds_model1;
if phat = . then delete;
run;

title "ROC curve for unadjusted model";
proc logistic data=pred_ds_model1_nomissing;
weight R01_A_PWGT; 
baseline_model:model initiate(event = '1')= ;
roc 'Surveylogistic Unadjusted Model' pred=phat; 
ods select ROCOverlay ROCAssociation;
run;

* (2) LR adjusted model;
title "LR adjusted model";
proc surveylogistic data = wave1_initiate_outcome;
strata VARSTRAT;
cluster VARPSU;
class menthol_cig_dummy(ref = '0') educat(ref = "Less than HS") RE(ref = "Hispanic") income(ref = "1 = Less than $10,000") agegrp(ref = "18-24");
model initiate(event = '1') = menthol_cig_dummy educat RE income agegrp;
output out=pred_ds_model2 p=phat;
weight R01_A_PWGT;
run;

* delete missing value in phat;
data pred_ds_model2_nomissing; set pred_ds_model2;
if phat = . then delete;
run;

title "ROC curve for unadjusted model";
proc logistic data=pred_ds_model2_nomissing;
weight R01_A_PWGT; 
baseline_model:model initiate(event = '1')= ;
roc 'Surveylogistic Adjusted Model' pred=phat; 
ods select ROCOverlay ROCAssociation;
run;

ods pdf close;





