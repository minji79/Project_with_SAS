
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : Table_1
| Date (update): July 2024
| Task Purpose : 
|      1. Categorize variables
|    		age ...
|      2. Reorganize study population (n = 38384)
| Main dataset : (1) min.bs_user_all_v07, (2) min.bs_glp1_user_v03
************************************************************************************/

/**************************************************
              Variable Definition
* table: min.bs_glp1_user_v03
* temporality
*       0  : no glp1_user   (n = 33125)
*       1  : take glp1 before BS   (n = 4151)
*       2  : take glp1 after BS    (n = 5259)
* glp1_expose_period
**************************************************/


/************************************************************************************
	STEP 1. Categorize variables
************************************************************************************/

/**************************************************
* new dataset: min.bs_glp1_user_v04
* original dataset: min.bs_glp1_user_v03
* description: sorted by 'temporality'
**************************************************/

proc sort data=min.bs_glp1_user_v03 out = min.bs_glp1_user_v04;
  by temporality;
run;


* 1.1. Age;

proc means data=min.bs_glp1_user_v03
  n nmiss median mean min max std maxdec=1;
  title "min.bs_glp1_user_v03";
run;

proc means data=min.bs_glp1_user_v04
  n nmiss median mean min max std maxdec=1;
  by temporality;
  title "min.bs_glp1_user_v04";
run;


* 1.2. Age - categorized;
/**************************************************
* new dataset: min.bs_glp1_user_v05
* original dataset: min.bs_glp1_user_v04
* description: Age - categorized
**************************************************/

data min.bs_glp1_user_v05;
  set min.bs_glp1_user_v04;
  format age_cat 8.;
  if 18 <= age_at_bs and age_at_bs < 30 then age_cat=2;
  else if 30 <= age_at_bs and age_at_bs < 40 then age_cat=3;
  else if 40 <= age_at_bs and age_at_bs < 50 then age_cat=4;
  else if 50 <= age_at_bs and age_at_bs < 60 then age_cat=5;
  else if 60 <= age_at_bs and age_at_bs < 70 then age_cat=6;
  else if 70 <= age_at_bs and age_at_bs < 80 then age_cat=7;
  else if 80 <= age_at_bs and age_at_bs      then age_cat=8;  
run;

proc print data = min.bs_glp1_user_v05 (obs=30);
  var age_at_bs age_cat;
  title "min.bs_glp1_user_v05";
run;

/* analysis for total cohort */
proc sort data=min.bs_glp1_user_v05;
  by age_cat;
run;
proc means data=min.bs_glp1_user_v05 
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS age_at_bs;
  by age_cat;
  title "age_cat";
run;


* 1.3. Sex - categorized;
/**************************************************
* new dataset: min.bs_glp1_user_v06
* original dataset: min.bs_glp1_user_v05
* description: sex - categorized
**************************************************/

data min.bs_glp1_user_v06;
  set min.bs_glp1_user_v05;
  format sex_cat 8.;
  if sex = 'M' then sex_cat = 0;
  else sex_cat = 1;
run;
proc print data = min.bs_glp1_user_v06 (obs=30);
  var sex sex_cat;
  title "min.bs_glp1_user_v06";
run;

/* analysis for total cohort */
proc sort data=min.bs_glp1_user_v06;
  by sex_cat;
run;
proc means data=min.bs_glp1_user_v06 
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS sex_cat;
  by sex_cat;
  title "sex_cat";
run;


* 1.4. Race - categorized;
/**************************************************
* new dataset: min.bs_glp1_user_v07
* original dataset: min.bs_glp1_user_v06
* description: race - categorized
**************************************************/

data min.bs_glp1_user_v07;
  set min.bs_glp1_user_v06;
  format race_cat 8.;
  if race = 'White' then race_cat = 1;
  else if race = 'Black or African American' then race_cat = 2;
  else if race = 'Asian' then race_cat = 3;
  else if race = 'Native Hawaiian or Other Pacific Islander' then race_cat = 4;
  else if race = 'American Indian or Alaska Native' then race_cat = 5;
  else if race = 'Other Race' then race_cat = 6;
  else if race = 'Unknown' then race_cat = 7;
  else sex_cat = 8;
run;
proc print data = min.bs_glp1_user_v07 (obs=30);
  var race race_cat;
  title "min.bs_glp1_user_v07";
run;

/* analysis for total cohort */
proc sort data=min.bs_glp1_user_v07;
  by race_cat;
run;
proc means data=min.bs_glp1_user_v07 
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS race_cat;
  by race_cat;
  title "race_cat";
run;

* 1.5. Ethnicity - categorized;
/**************************************************
* new dataset: min.bs_glp1_user_v08
* original dataset: min.bs_glp1_user_v07
* description: Ethnicity - categorized
**************************************************/

data min.bs_glp1_user_v08;
  set min.bs_glp1_user_v07;
  format ethnicity_cat 8.;
  if ethnicity = 'Hispanic or Latino' then ethnicity_cat = 1;
  else if ethnicity = 'Not Hispanic or Latino' then ethnicity_cat = 2;
  else if ethnicity = 'Unknown' then ethnicity_cat = 3;
  else ethnicity_cat = 4;
run;
proc print data = min.bs_glp1_user_v08 (obs=30);
  var ethnicity ethnicity_cat;
  title "min.bs_glp1_user_v08";
run;

/* analysis for total cohort */
proc sort data=min.bs_glp1_user_v08;
  by ethnicity_cat;
run;
proc means data=min.bs_glp1_user_v08
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS ethnicity_cat;
  by ethnicity_cat;
  title "ethnicity_cat";
run;


* 1.6. Marital status - categorized;
/**************************************************
* new dataset: min.bs_glp1_user_v09
* original dataset: min.bs_glp1_user_v08
* description: Marital status - categorized
**************************************************/

data min.bs_glp1_user_v09;
  set min.bs_glp1_user_v08;
  format marital_cat 8.;
  if marital_status = 'Married' then marital_cat = 1;
  else if marital_status = 'Single' then marital_cat = 2;
  else if marital_status = 'Unknown' then marital_cat = 3;
  else ethnicity_cat = 4;
run;
proc print data = min.bs_glp1_user_v09 (obs=30);
  var marital_status marital_cat;
  title "min.bs_glp1_user_v09";
run;

/* analysis for total cohort */
proc sort data=min.bs_glp1_user_v09;
  by marital_cat;
run;
proc means data=min.bs_glp1_user_v09
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS marital_cat;
  by marital_cat;
  title "marital_cat";
run;


* 1.7. Regional location - categorized;
/**************************************************
* new dataset: min.bs_glp1_user_v10
* original dataset: min.bs_glp1_user_v09
* description: Regional location - categorized
**************************************************/

data min.bs_glp1_user_v10;
  set min.bs_glp1_user_v09;
  format regional_cat 8.;
  if patient_regional_location = 'Northeast' then regional_cat = 1;
  else if patient_regional_location = 'Midwest' then regional_cat = 2;
  else if patient_regional_location = 'South' then regional_cat = 3;
  else if patient_regional_location = 'West' then regional_cat = 4;
  else regional_cat = 5;
run;
proc print data = min.bs_glp1_user_v10 (obs=30);
  var patient_regional_location regional_cat;
  title "min.bs_glp1_user_v10";
run;

/* analysis for total cohort */
proc sort data=min.bs_glp1_user_v10;
  by regional_cat;
run;
proc means data=min.bs_glp1_user_v10
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS regional_cat;
  by regional_cat;
  title "regional_cat";
run;


* 1.8. BS_type - categorized;
/**************************************************
* new dataset: min.bs_glp1_user_v11
* original dataset: min.bs_glp1_user_v10
* description: BS_type - categorized;
**************************************************/

data min.bs_glp1_user_v11;
  set min.bs_glp1_user_v10;
  format bs_type_cat 8.;
  if bs_type = 'rygb' then bs_type_cat = 1;
  else if bs_type = 'sg' then bs_type_cat = 2;
  else if bs_type = 'agb' then bs_type_cat = 3;
  else if bs_type = 'sadi_s' then bs_type_cat = 4;
  else if bs_type = 'bpd' then bs_type_cat = 5;
  else if bs_type = 'vbg' then bs_type_cat = 6;
  else bs_type_cat = 7;
run;
proc print data = min.bs_glp1_user_v11 (obs=30);
  var bs_type bs_type_cat;
  title "min.bs_glp1_user_v11";
run;

/* analysis for total cohort */
proc sort data=min.bs_glp1_user_v11;
  by bs_type_cat;
run;
proc means data=min.bs_glp1_user_v11
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS bs_type_cat;
  by bs_type_cat;
  title "bs_type_cat";
run;


* 1.9. swt_glp1 - categorized;
/**************************************************
* new dataset: min.bs_glp1_user_v12
* original dataset: min.bs_glp1_user_v11
* description: swt_glp1 - categorized
**************************************************/

proc sort data=min.bs_glp1_user_v12;
  by temporality;
run;
proc means data=min.bs_glp1_user_v12
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS swt_glp1;
  by temporality;
  title "swt_glp1";
run;


* 1.10. glp1_type_cat - categorized;
/**************************************************
* new dataset: min.bs_glp1_user_v13
* original dataset: min.bs_glp1_user_v12
* description: glp1_type_cat - categorized
**************************************************/

data min.bs_glp1_user_v13;
  set min.bs_glp1_user_v12;
  format glp1_type_cat 8.;
  if Molecule = "Semaglutide" then glp1_type_cat = 1;
  else if Molecule = "Liraglutide" then glp1_type_cat = 2;
  else if Molecule = "Dulaglutide" then glp1_type_cat = 3;
  else if Molecule = "Exenatide" then glp1_type_cat = 4;
  else if Molecule = "Lixisenatide" then glp1_type_cat = 5;
  else if Molecule = "Tirzepatide" then glp1_type_cat = 6;
run;


/************************************************************************************
	STEP 2. Reorganize study population (n = 38384)
************************************************************************************/

/**************************************************
* new dataset: min.bs_glp1_user_38384_v00
* original dataset: min.bs_glp1_user_v13
* description: remain only 38384
**************************************************/

data min.bs_glp1_user_38384_v00;
	set min.bs_glp1_user_v13;
 	if temporality ne 1;
run;             /* 38384 obs */


/************************************************************************************
	STEP 3. re-do all of the statistics with p value with 38384
************************************************************************************/

/***********************************************************
1. continuous variables

/* Perform a t-test for continuous variables */
proc ttest data=mydata;
   class group;
   var bmi;
   ods output TTests=ttest_results;
run;

/* Extract the p-value from the t-test result */
data ttest_pvalue;
    set ttest_results;
    where Method = "Pooled";
    pvalue_bmi = ProbT;
    keep pvalue_bmi;
run;

2. categorical variables

/* Perform a Chi-Square Test for categorical variables */
proc freq data=mydata;
   tables group*gender / chisq;
   ods output ChiSq=chisq_results;
run;

/* Extract the p-value from the chi-square result */
data chisq_pvalue;
    set chisq_results;
    where Statistic = "Chi-Square";
    pvalue_gender = Prob;
    keep pvalue_gender;
run;
************************************************************/

* 3.1. Age - continuous;
/* updated total */
proc means data=min.bs_glp1_user_38384_v00
  n nmiss median mean min max std maxdec=1;
  title "min.bs_glp1_user_38384_v00";
run;

/* p-value */
proc ttest data=min.bs_glp1_user_38384_v00;
   class temporality;
   var age_at_bs;
   ods output TTests=ttest_results;
run;
data ttest_pvalue;
    set ttest_results;
    where Method = "Pooled";
    pvalue_age = ProbT;
    keep pvalue_age;
run;
proc print data=ttest_pvalue;
run;

* 3.2. Age - categorical;
/* updated total */
proc sort data=min.bs_glp1_user_38384_v00;
  by age_cat;
run;
proc means data=min.bs_glp1_user_38384_v00
n nmiss median mean min max std;
  var age_at_bs;
  by age_cat;
  title "age_cat";
run;

/* p-value */
proc freq data=min.bs_glp1_user_38384_v00;
   tables temporality*age_cat / chisq;
run;


* 3.3. Sex - categorized;
/* updated total */
proc sort data=min.bs_glp1_user_38384_v00;
  by sex_cat;
run;
proc means data=min.bs_glp1_user_38384_v00
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS sex_cat;
  by sex_cat;
  title "sex_cat";
run;

/* p-value */
proc freq data=min.bs_glp1_user_38384_v00;
   tables temporality*sex_cat / chisq;
run;


* 3.4. race - categorized;
/* updated total */
proc sort data=min.bs_glp1_user_38384_v00;
  by race_cat;
run;
proc means data=min.bs_glp1_user_38384_v00
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS race_cat;
  by race_cat;
  title "race_cat";
run;

/* p-value */
proc freq data=min.bs_glp1_user_38384_v00;
   tables temporality*race_cat / chisq;
run;


* 3.5. ethnicity - categorized;
/* updated total */
proc sort data=min.bs_glp1_user_38384_v00;
  by ethnicity_cat;
run;
proc means data=min.bs_glp1_user_38384_v00
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS ethnicity_cat;
  by ethnicity_cat;
  title "ethnicity_cat";
run;

/* p-value */
proc freq data=min.bs_glp1_user_38384_v00;
   tables temporality*ethnicity_cat / chisq;
run;


* 3.6. marital - categorized;
/* updated total */
proc sort data=min.bs_glp1_user_38384_v00;
  by marital_cat;
run;
proc means data=min.bs_glp1_user_38384_v00
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS marital_cat;
  by marital_cat;
  title "marital_cat";
run;

/* p-value */
proc freq data=min.bs_glp1_user_38384_v00;
   tables temporality*marital_cat / chisq;
run;


* 3.7. regional - categorized;
/* updated total */
proc sort data=min.bs_glp1_user_38384_v00;
  by regional_cat;
run;
proc means data=min.bs_glp1_user_38384_v00
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS regional_cat;
  by regional_cat;
  title "regional_cat";
run;

/* p-value */
proc freq data=min.bs_glp1_user_38384_v00;
   tables temporality*regional_cat / chisq;
run;


* 3.8. BS type - categorized;
/* updated total */
proc sort data=min.bs_glp1_user_38384_v00;
  by bs_type_cat;
run;
proc means data=min.bs_glp1_user_38384_v00
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS bs_type_cat;
  by bs_type_cat;
  title "bs_type_cat";
run;

/* p-value */
proc freq data=min.bs_glp1_user_38384_v00;
   tables temporality*bs_type_cat / chisq;
run;


* 3.9. glp1 type - categorized;
/* updated total */
proc sort data=min.bs_glp1_user_38384_v00;
  by glp1_type_cat;
run;
proc means data=min.bs_glp1_user_38384_v00
n nmiss median mean min max std;
  var glp1_after_BS glp1_before_BS glp1_type_cat;
  by glp1_type_cat;
  title "glp1_type_cat";
run;


* 3.10. BMI at the index time;
/* updated total : Among 42,535, Only 15,324 individuals (36%) have BMI_index*/
proc freq data=min.bs_glp1_bmi_v01_18937;
	table temporality;
 	title "min.bs_glp1_bmi_v01_18937";
run;

data min.bs_glp1_bmi_index_16844_v01;
	set min.bs_glp1_bmi_v01_18937;
 	if temporality ne 1;
run;

proc means data=min.bs_glp1_bmi_index_16844_v01
	n nmiss mean std min max median p25 p75;
 	var bmi_index;
  	title "distribution of bmi_index";
run;

/* p-value */
proc ttest data=min.bs_glp1_bmi_index_16844_v01;
   class temporality;
   var bmi_index;
run;







