# BIOS-699-Analysis-of-Biostatistical-Investigations
University of Michigan Department of Biostatistics course
##### NOTE: Due to data confidentiality, only R or SAS codes are presented in this repo, not the results.
## Project 1: Investigation of Glucose Variability Indices in Type II Diabetes Patients
### I. Project Description
Diabetes has been the seventh leading cause of death in United States over the past five years, therefore, the use of continuous glucose monitoring (CGM) of tracking real-time blood glucose level became an important indices to control diabetes progression.   

In this study, we assessed the following seven glucose variability indices: glucose mean, glucose standard deviation (SD), glucose coefficient of variation (CV), time in range (TIR, % of readings in 70-180 mg/dL), time above range (TAR, % of readings > 180 mg/dL), time above range (TBR, % of readings < 70 mg/dL), and additionally, low blood glucose index (LBGI) in evaluating the effectiveness of two types of existed diabetic drugs (drug X, drug Y) in type II diabetes patients.

### II. Study Design
CGM data collected from 25 (out of 45) subjects in a single-centered, randomized, single- blinded, open-label phase IV cross-over clinical trial. Subjects were randomized to two group, with group A started drug X treatment in the first 12 weeks, followed by a 2-week wash out period, then started drug Y treatment for another 12 weeks; treatment for subjects in group B was in reverse order. Glucose variability indices were calculated in daily bases (per day) for each participant. 

### III. Statistical Analysis
Parametric (two sample t-test) and non-parametric test (Wilcoxon test) were used to conduct univariate association of drug effect and the indices.  

To take account for repeated measures, linear mixed model were conducted to determine the association of drug and glucose variability indices, allowing subjects to have their own trajectories. Carry-over effects and baseline parameters (Age, HbA1c, SBP, DBP) were also adjusted in the model. Wald test p-values were used to access the significance of drug effect and to check if carry-over effect exist in the model. Akaike’s Information Criterion (AIC) was used for selecting the preference of random intercept or random intercept/slope model, with the lower the better.


## Project 2: The potential impact of menthol on transitions from cigarettes to e-cigarettes: PATH Study
### I. Project Description
Prevalence of smoking cigarette has decrease throughout the years; however, menthol-cigarette usage has continued to increase, especially in young ages and non-Hispanic black group. Moreover, with the increase popularity of e-cigarette usage, there is an increase trend of e-cigarette usage in the young ages. References showed that menthol-cigarette may lead to higher dependency of nicotine, while e-cigarette may help adults quit or reduce smoking habit.    

In this study, impact of menthol flavoring cigarettes on transition of cigarette to e-cigarette were being assessed, as well as other demographic factors that might impact the transition.

### II. Study Design
Data were collected from the PATH (Population Assessment of Tobacco and Health) study. There were total around 49,000 people age 12 years and older participated in this study, the study spanned from wave 1 (2013) to wave 4 (2017), information regarding to tobacco usage, age, gender, education, income, health conditions were also collected for each individual in each wave.

### III. Statistical Analysis
To focus on cigarette to e-cigarette transitions, trajectory analysis and logistic regression were conducted targeting the participants who started as cigarette but non-e-cigarette users at wave 1, developments of their e-cigarette usage through wave 2 to wave 4 were assessed. ROC analysis was also assessed to check logistic regression model performance.

## Project 3: Investigation of common chronic medication use and tumor sites in head and neck squamous cell carcinoma (HNSCC)
### I. Project Description
Head and neck squamous cell carcinoma (HNSCC) are cancer that mostly originate from lip, oral cavity, hypopharynx, oropharynx, nasopharynx or larynx. Prior research has identified several important associations between comorbidities medications with cancer outcome. However, there are lack of studies on how comorbidities drugs effect cancer outcome in rarer cancer such as HNSCC.   

The goal for this study is to determine if common chronic medications (aspirin, metformin, statin, insulin) as well as different tumor sites (larynx, oropharynx, oral cavity) are associated with HNSCC patient’s survival outcomes.

### II. Study Design
Data were collected on N = 1642 HNSCC patients from the University of Michigan Specialized Program of Research Excellence (SPORE). Eligibility criteria including participants greater than 18 years of age, must be English speaker, no barriers which affect study compliance, incident of cancer must be no HNSCC diagnosed last 5 years and no previous treatment. Information were collected through patient interviews, pretreatment surveys, medical record extractions, annual chart reviews and follow up surveys, survival time and recurrence time were also collected throughout the study. 

### III. Statistical Analysis
Missing data were imputed using Random Forest Imputation. Overall survival and progression-free survival were being assessed using Kaplan-Meier Estimators. Log-rank test was assessed to compare survival curves for covariates of interest that met proportional hazard assumptions, while Wilcoxon test was assessed to compare survival curves that violated proportional hazard assumptions.   

Multivariate Cox Hazard models were built to evaluate the association between comorbidity drugs and tumor sites with HNSCC patient’s survival time. Additionally, Schoenfeld’s global test was assessed to test proportional hazard assumption in the Cox model, if the global proportional hazard assumption was violated (p < 0.05), risk factors that violated the proportional hazard assumption will be stratified in the model instead of including in the model as confounders.  

## Project 4: Power Analysis for Needle Biopsy Deflection in Prostate Cancer Patients
### I. Project Description 
Prostate cancer is the second most frequent malignancy in men worldwide as well as the second leading cause of death by cancer in men (after lung cancer). Currently, only needle biopsies are the standard of care to confirm prostate cancer’s presence. A new needle tip for prostate cancer biopsy has been developed to reduce the deflection comparing to standard needle tip.  

In this study, our primary objective is to simulate a randomized clinical trial to show that by using 500 new needles, there is an 80% power with 5% Type 1 error to detect at least 40% deflection reduction, comparing to standard needles. Moreover, we are also interested in knowing the level of deflection reduction if the number of new needles increase to 600, under 80% power and 5% Type 1 error.

### II. Simulation Design 
* Prespecify distribution of standard needles:  
1. Random tissue ~ N (1.34, 1.22).   
2. Targeted tissue ~ N (10.6, 1.52).  
* Two types of simulations were designed to test the power of needle effects on mean deflection reduction:  
1. Test mean of reduction in deflections between standard and new needle using one sample t test with p = 0.05 level.   
2. Fit multivariate linear regression with GEE, conduct Wald test to test needle effect on reduction in mean deflection between standard and new needles with p = 0.05 level.   

