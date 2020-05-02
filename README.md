# BIOS-699-Analysis-of-Biostatistical-Investigations
University of Michigan Department of Biostatistics course

## Project 1: Investigation of Glucose Variability Indices in Type II Diabetes Patients
### I. Project Description
Diabetes has been the seventh leading cause of death in United States over the past five years, therefore, the use of continuous glucose monitoring (CGM) of tracking real-time blood glucose level became an important indices to control diabetes progression.   

In this study we assessed the following seven glucose variability indices: glucose mean, glucose standard deviation (SD), glucose coefficient of variation (CV), time in range (TIR, % of readings in 70-180 mg/dL), time above range (TAR, % of readings > 180 mg/dL), time above range (TBR, % of readings < 70 mg/dL), and additionally, low blood glucose index (LBGI) in evaluating the effectiveness of two types of existed diabetic drugs (drug X, drug Y) in type II diabetes patients.

### II. Study Design
CGM data collected from 25 (out of 45) subjects in a single-centered, randomized, single- blinded, open-label phase IV cross-over clinical trial. Subjects were randomized to two group, with group A started drug X treatment in the first 12 weeks, followed by a 2-week wash out period, then started drug Y treatment for another 12 weeks; treatment for subjects in group B was in reverse order. Glucose variability indices were calculated in daily bases (per day) for each participant. 

### III. Statistical Analysis
Parametric (two sample t-test) and non-parametric test (Wilcoxon test) were used to conduct univariate association of drug effect and the indices. To take account for repeated measures, linear mixed model were conducted to determine the association of drug and glucose variability indices, allowing subjects to have their own trajectories. Carry-over effects and baseline parameters (Age, HbA1c, SBP, DBP) were also adjusted in the model. Wald test p-values were used to access the significance of drug effect and to check if carry-over effect exist in the model. Akaike’s Information Criterion (AIC) was used for selecting the preference of random intercept or random intercept/slope model, with the lower the better.


## Project 2: The potential impact of menthol on transitions from cigarettes to e-cigarettes: PATH Study
### I. Project Description
Prevalence of smoking cigarette has decrease throughout the years; however, menthol-cigarette usage has continued to increase, especially in young ages and non-Hispanic black group. Moreover, with the increase popularity of e-cigarette usage, there is an increase trend of e-cigarette usage in the young ages. References showed that menthol-cigarette may lead to higher dependency of nicotine, while e-cigarette may help adults quit or reduce smoking habit. In this study, impact of menthol flavoring cigarettes on transition of cigarette to e-cigarette were being assessed, as well as other demographic factors that might impact the transition.
### II. Study Design
Data were collected from the PATH (Population Assessment of Tobacco and Health) study. There were total around 49,000 people age 12 years and older participated in this study, the study spanned from wave 1 (2013) to wave 4 (2017), information regarding to tobacco usage, age, gender, education, income, health conditions were also collected for each individual in each wave.
### III. Statistical Analysis
To focus on cigarette to e-cigarette transitions, trajectory analysis and logistic regression were conducted targeting the participants who started as cigarette but non-e-cigarette users at wave 1, developments of their e-cigarette usage through wave 2 to wave 4 were assessed. ROC analysis was also assessed to check logistic regression model performance.

## Project 3

## Project 4
