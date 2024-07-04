
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 04_Covariate_comorbidity
| Date (update): July 2024
| Task Purpose : 
|      1. Create Comorbidity lists using the ICD_10_CT and ICD_9_CT codes
|      2. 
|      3. Remain distinct observation by one patients with comorbidity information
| Main dataset : (1) min.bs_user_all_v07, (2) tx.diagnosis
| Final dataset: 
************************************************************************************/


/* 
how to delete table
proc datasets library=min nolist;
    delete bs_glp1_user_v03_1;
quit;
*/

/************************************************************************************
	STEP 1. Create Comorbidity lists using the ICD_10_CT and ICD_9_CT codes
************************************************************************************/

* 1.1. explore procedure dataset + list up all of the value of code_system;

proc print data=tx.diagnosis (obs=40);
    title "tx.diagnosis";
run;                      
proc contents data=tx.diagnosis;
    title "tx.diagnosis";
run;              

/**************************************************
* new table: min.diagnosis_codelist
* original table: tx.diagnosis
* description: select comorbidities from tx.diagnosis
**************************************************/

proc sql;
  create table min.diagnosis_codelist as
  select distinct code_system
  from tx.diagnosis;
quit; 
proc print data=min.diagnosis_codelist; 
  title "min.diagnosis_codelist";
run;


/**************************************************/**************************************************/**************************************************/**************************************************/**************************************************/

* 1.2. stack diagnosis information for individuals in 'min.bs_user_all_v07';

/**************************************************
* new table: min.bs_user_comorbidity_v00
* original table: min.bs_user_all_v07 & tx.diagnosis
* description: stack diagnosis information for individuals in 'min.bs_user_all_v07'
**************************************************/

/* it doesn't work due to the large size of dataset - need more efficient codes */

proc SQL;    
  create table min.bs_user_comorbidity_v00 as
  select a.*, b.*
  from min.bs_user_all_v07 as a left join tx.diagnosis as b
  on a.patient_id = b.patient_id;
quit;

proc print data=min.bs_user_comorbidity_v00 (obs=30); 
  title "min.bs_user_comorbidity_v00";
run;


* 1.3. list up comorbidities;

/**************************************************
* new table: min.bs_user_comorbidity_v01
* original table: min.bs_user_comorbidity_v00
* description: list up comorbidities;
**************************************************/


%let cc_t2db=%str('E11%', '250.00', '250.02');  /* type 2 diabetes - I don;t use 'E08-E13' */
%let cc_obs=%str('E66%', '278.0%');  /* obesity */
%let cc_htn=%str('I10%', '401.1', '401.9');  /* hypertentsion */
%let cc_dyslip=%str('E78%', '272%');  /* Dyslipidemia */
%let cc_osa=%str('G47.33', '327.23');  /* Obstructive sleep apnea */
%let cc_cad=%str('I25%', '414%');  /* Chronic coronary artery disease */
%let cc_hf=%str('I50%', '428%');  /* Heart failure */
%let cc_af=%str('I48%', '427.3');  /* Atrial fibrillation and flutter */
%let cc_asthma=%str('J45%', '493%');  /* Asthma */
%let cc_liver=%str('K76.0%', 'K75.81%', '571.8');  /* Fatty liver disease & nonalcoholic steatohepatitis */
%let cc_ckd=%str('N18%', '585%');  /* Chronic kidney disease */
%let cc_pos=%str('E28.2%', '256.4');  /* Polycystic ovarian syndrome */
%let cc_infertility=%str('N97%', 'N46%'. '628%', '606%');  /* Infertility */
%let cc_gerd=%str('K21%', '530.81%');  /* Gastroesophageal reflux disease */


/*
proc print data = tx.diagnosis (obs=40);
  where code like 'E11%' or code in ('250.00', '250.02');
run;
*/


data min.bs_user_comorbidity_v01;
  set min.bs_user_comorbidity_v00;
  format cc_t2db cc_obs cc_htn cc_dyslip cc_osa cc_cad cc_hf cc_af cc_asthma cc_liver cc_ckd cc_pos cc_infertility cc_gerd 8.;

  if _N_ = 1 then do;
    cc_t2db =0;
    cc_obs =0;
    cc_htn =0;
    cc_dyslip =0;
    cc_osa =0;
    cc_cad =0;
    cc_hf =0;
    cc_af =0;
    cc_asthma =0;
    cc_liver =0;
    cc_ckd =0;
    cc_pos =0;
    cc_infertility =0;
    cc_gerd =0;
  end;
  
  if code like 'E11%' or code in ('250.00', '250.02') then do;
    cc_t2db = 1;
  end;
  else if code like 'E66%' or code like '278.0%' then do;
    cc_obs = 1;
  end;
  else if code like 'I10%' or code in ('401.1', '401.9') then do;
    cc_htn = 1;
  end;
  else if code like 'E78%' or code like '272%' then do;
    cc_dyslip = 1;
  end;
  else if code in ('G47.33', '327.23') then do;
    cc_osa = 1;
  end;
  else if code like 'I25%' or code like '414%' then do;
    cc_cad = 1;
    comorbidity = comorbidity + 1;
  end;
  else if code like 'I50%' or code like '428%' then do;
    cc_hf = 1;
  end;
  else if code like 'I48%' or code = '427.3' then do;
    cc_af = 1;
  end;
  else if code like 'J45%' or code like '493%' then do;
    cc_asthma = 1;
  end;
  else if code like 'K76.0%' or code like 'K75.81%' or code = '571.8' then do;
    cc_liver = 1;
  end;
  else if code like 'N18%' or code like '585%' then do;
    cc_ckd = 1;
  end;
  else if code like 'E28.2%' or code = '256.4' then do;
    cc_pos = 1;
  end;
  else if code like 'N97%' or code like 'N46%' or code like '628%' or code like '606%' then do;
    cc_infertility = 1;
  end;
  else if code like 'K21%' or code like '530.81%' then do;
    cc_gerd = 1;
  end;
  
run;

proc print data=min.bs_user_comorbidity_v01 (obs=30);
  title "min.bs_user_comorbidity_v01";
run;


* 1.4. alternative way to select t2db patients;

/* it also doesn't work due to the large size of dataset - need more efficient codes */

/**************************************************
* new table: min.comorbidity_t2db_v00
* original table: tx.diagnosis
* description: list up t2db from original dataset
**************************************************/

data min.comorbidity_t2db_v00;
  set tx.diagnosis;
  format cc_t2db 8.;
  if substr(code, 1, 3) = 'E11' or code in ('250.00', '250.02') then do;
    cc_t2db = 1;
  end;
  else delete;
run;

proc print data=min.comorbidity_t2db_v00 (obs=30);
title "min.comorbidity_t2db_v00";
run;

/**************************************************
* new table: min.bs_user_comorbidity_t2db_v00
* original table: min.bs_user_all_v07 + min.comorbidity_t2db_v00
* description: stack t2db information for individuals in 'min.bs_user_all_v07';
**************************************************/

proc SQL;
  create table min.bs_user_comorbidity_t2db_v00 as
  select a.*, b.*
  from min.bs_user_all_v07 as a left join tx.diagnosis as b
  on a.patient_id = b.patient_id;
quit;




/************************************************************************************
	STEP 2. Remain comorbidity diagnosed within 1 yr before the surgery
************************************************************************************/

* 2.1. merge min.bs_user_comorbidity_v01 + min.bs_user_all_v07;

/**************************************************
* new table: min.bs_user_comorbidity_v02
* original table: min.bs_user_comorbidity_v01 + min.bs_user_all_v07
* description: merge min.bs_user_comorbidity_v01 + min.bs_user_all_v07
**************************************************/

proc sort data=min.bs_user_comorbidity_v01 out=min.bs_user_comorbidity_v01 nodupkey;	by _all_;	run;

proc SQL;
  create table min.bs_user_comorbidity_v02 as
  select a.*, b.code, b.date, b.cc_t2db, b.cc_obs, b.cc_htn, b.cc_dyslip, b.cc_osa, b.cc_cad, b.cc_hf, b.cc_af, b.cc_asthma, b.cc_liver, b.cc_ckd, b.cc_pos, b.cc_infertility, b.cc_gerd
  from min.bs_user_all_v07 as a left join min.bs_user_comorbidity_v01 as b
  on a.patient_id = b.patient_id;
quit;

proc sort data=min.bs_user_comorbidity_v02 out=min.bs_user_comorbidity_v02 nodupkey;	by _all_;	run;


* 2.2. Remain comorbidity diagnosed within 1 yr before the surgery;

/**************************************************
* new table: min.bs_user_comorbidity_v03
* original table: min.bs_user_comorbidity_v02
* description: Remain comorbidity diagnosed within 1 yr before the surgery
**************************************************/

data min.bs_user_comorbidity_v02;
  set min.bs_user_comorbidity_v02;
  date_num = input(date, yymmdd8.);
  format date_num yymmdd10.;
  drop date;
  rename data_num = como_date;
run;

data min.bs_user_comorbidity_v03;
   set min.bs_user_comorbidity_v02;
   if bs_date - como_date ge 0 and bs_date - como_date le 365;
run;

proc print data=min.bs_user_comorbidity_v03 (obs=30);
  title "min.bs_user_comorbidity_v03";
run;



/************************************************************************************
	STEP 3. Remain distinct observation by one patients with comorbidity information
************************************************************************************/

/**************************************************
* new table: min.bs_user_comorbidity_v04
* original table: min.bs_user_comorbidity_v03
* description: Remain distinct observation by one patients with comorbidity information
**************************************************/








