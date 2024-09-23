
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 05_Covariate_ccomedication
| Date (update): July 2024
| Task Purpose : 
|      1. Create Comedication lists using the ICD_10_CT and ICD_9_CT codes
|      2. subgroup analysis
|      3. 00
| Main dataset : (1) min.bs_user_all_v07, (2) tx.medication_ingredient
| Final dataset: 
************************************************************************************/


/************************************************************************************
	STEP 1. Create Comedication lists using the ICD_10_CT and ICD_9_CT codes
************************************************************************************/

* 1.1. metformin users;
/**************************************************
* new table: min.metformin_users_v00
* original table: tx.medication_ingredient;
* description: list up metformin_users from original dataset
**************************************************/

/* the total users among TRINETX dataset */
data min.metformin_users_v00;
	set tx.medication_ingredient;
 	if code = "6809";
run;           /* 69038531 obs */

/* matching with our study population */
proc sql;
    create table min.metformin_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a 
    left join min.metformin_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 204014 -> 227956 obs */

/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.metformin_users_v03
* original table: min.metformin_users_v01
* description: list up metformin_users within inclusion time window
**************************************************/

data min.metformin_users_v01;
	set min.metformin_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = comedi_date;
run;

data min.metformin_users_v02;
   set min.metformin_users_v01;
   format cm_metformin 8.;
   if bs_date - comedi_date ge 0 and bs_date - comedi_date le 365;
   if not missing(comedi_date) then cm_metformin = 1;
   drop unique_id;
run;       /* 44688 -> 52555 obs */


/* Remain unique patients */
/**************************************************
* new table: min.metformin_users_v03
* original table: min.metformin_users_v02
* description: Remain unique patients of metformin_users within inclusion time window
**************************************************/

proc sort data=min.metformin_users_v02;
	by patient_id comedi_date;
run;

data min.metformin_users_v03;
	set min.metformin_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 8059 -> 9441 obs */

data min.metformin_users_v03;
	set min.metformin_users_v03;
 	rename comedi_date = cm_metformin_date;
run;


/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v00
* original table: min.metformin_users_v03
* description: Remain unique patients of metformin_users within inclusion time window
**************************************************/

proc sql;
    create table min.bs_user_comedication_v00 as 
    select a.*, /* Select all columns from table a */
           b.cm_metformin, b.cm_metformin_date 
    from min.bs_glp1_user_38384_v00 as a 
    left join min.metformin_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 -> 38133 obs */

data min.bs_user_comedication_v00;
	set min.bs_user_comedication_v00;
 	if missing(cm_metformin) then cm_metformin = 0;
run;

proc print data=min.bs_user_comedication_v00(obs = 30);
	var patient_id cm_metformin cm_metformin_date;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v00;
	table cm_metformin;
run;

/*
among 38384, 
cm_metformin = 1 | 8059 (21%)
cm_metformin = 0 | 30325
*/



* 1.2. dpp4 users;
/**************************************************
* new table: min.dpp4_users_v00
* original table: tx.medication_ingredient
* description: list up dpp4_users from original dataset
**************************************************/

/* the total users among TRINETX dataset */
data min.dpp4_users_v00;
	set tx.medication_ingredient;
 	if code in ('593411', '1100699', '857974', '1368001', '1992825', '729717', '1598392', '1243019', '2281864', '1727500', '1043562', '2117292', '1368402', '1368384');
run;      /* 24156249 obs */

/* matching with our study population */
proc sql;
    create table min.dpp4_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a 
    left join min.dpp4_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 84288 -> 83761 obs */

data min.dpp4_users_v01;
	set min.dpp4_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = cm_dpp4_date;
run;  


/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.dpp4_users_v02
* original table: min.dpp4_users_v01
* description: list up dpp4_users within inclusion time window
**************************************************/

data min.dpp4_users_v02;
   set min.dpp4_users_v01;
   format cm_dpp4 8.;
   if bs_date - cm_dpp4_date ge 0 and bs_date - cm_dpp4_date le 365;
   if not missing(cm_dpp4_date) then cm_dpp4 = 1;
   drop unique_id;
run;       /* 11746 -> 12244 obs */

/* Remain unique patients */
/**************************************************
* new table: min.dpp4_users_v03
* original table: min.dpp4_users_v02
* description: Remain unique patients of dpp4_users within inclusion time window
**************************************************/

proc sort data=min.dpp4_users_v02;
	by patient_id cm_dpp4_date;
run;

data min.dpp4_users_v03;
	set min.dpp4_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 1133 -> 1229 obs */

/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v01
* original table: min.dpp4_users_v03
* description: merge into one dataset
**************************************************/

proc sql;
    create table min.bs_user_comedication_v01 as 
    select a.*, /* Select all columns from table a */
           b.cm_dpp4, b.cm_dpp4_date 
    from min.bs_user_comedication_v00 as a 
    left join min.dpp4_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 -> 38133 obs */

data min.bs_user_comedication_v01;
	set min.bs_user_comedication_v01;
 	if missing(cm_dpp4) then cm_dpp4 = 0;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v01;
	table cm_dpp4;
run;

/*
among 38384, 
cm_dpp4 = 1 | 1133 (2.95%)
cm_dpp4 = 0 | 37251
*/



* 1.3. sglt2 users;
/**************************************************
* new table: min.sglt2_users_v00
* original table: tx.medication_ingredient
* description: list up sglt2_users from original dataset
**************************************************/

data min.sglt2_users_v00;
	set tx.medication_ingredient;
 	if code in ('1545653', '1373458', '1488564', '1992672', '2627044', '2638675', '1664314', '1545149', '1486436', '1992684');
run;      /* 13603886 obs */

/* matching with our study population */
proc sql;
    create table min.sglt2_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a
    left join min.sglt2_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 61269 -> 62005 obs */

data min.sglt2_users_v01;
	set min.sglt2_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = cm_sglt2_date;
run;  

/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.sglt2_users_v02
* original table: min.sglt2_users_v01
* description: list up users within inclusion time window
**************************************************/

data min.sglt2_users_v02;
   set min.sglt2_users_v01;
   format cm_sglt2 8.;
   if bs_date - cm_sglt2_date ge 0 and bs_date - cm_sglt2_date le 365;
   if not missing(cm_sglt2_date) then cm_sglt2 = 1;
   drop unique_id;
run;       /* 4573 -> 5139 obs */

/* Remain unique patients */
/**************************************************
* new table: min.sglt2_users_v03
* original table: min.sglt2_users_v02
* description: Remain unique patients of users within inclusion time window
**************************************************/

proc sort data=min.sglt2_users_v02;
	by patient_id cm_sglt2_date;
run;

data min.sglt2_users_v03;
	set min.sglt2_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 636 -> 731 obs */

/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v02
* original table: min.sglt2_users_v03
* description: merge into one dataset
**************************************************/

proc sql;
    create table min.bs_user_comedication_v02 as 
    select a.*, /* Select all columns from table a */
           b.cm_sglt2, b.cm_sglt2_date 
    from min.bs_user_comedication_v01 as a 
    left join min.sglt2_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 obs */

data min.bs_user_comedication_v02;
	set min.bs_user_comedication_v02;
 	if missing(cm_sglt2) then cm_sglt2 = 0;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v02;
	table cm_sglt2;
run;

/*
among 38384, 
cm_sglt2 = 1 | 636 (1.66%)
cm_sglt2 = 0 | 37748
*/




* 1.4. sulfonylureas users;
/**************************************************
* new table: min.sulfonylureas_users_v00
* original table: tx.medication_ingredient
* description: list up sulfonylureas_users from original dataset
**************************************************/

data min.sulfonylureas_users_v00;
	set tx.medication_ingredient;
 	if code in ('4821','25789','4815','4816','352381','647235','606253','285129');
run;      /* 23763314 obs */

/* matching with our study population */
proc sql;
    create table min.sulfonylureas_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a
    left join min.sulfonylureas_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 76371 -> 76415 obs */

data min.sulfonylureas_users_v01;
	set min.sulfonylureas_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = cm_su_date;
run;  

/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.sulfonylureas_users_v02
* original table: min.sulfonylureas_users_v01
* description: list up users within inclusion time window
**************************************************/

data min.sulfonylureas_users_v02;
   set min.sulfonylureas_users_v01;
   format cm_su 8.;
   if bs_date - cm_su_date ge 0 and bs_date - cm_su_date le 365;
   if not missing(cm_su_date) then cm_su = 1;
   drop unique_id;
run;       /* 9470 -> 10432 obs */

/* Remain unique patients */
/**************************************************
* new table: min.sulfonylureas_users_v03
* original table: min.sulfonylureas_users_v02
* description: Remain unique patients of users within inclusion time window
**************************************************/

proc sort data=min.sulfonylureas_users_v02;
	by patient_id cm_su_date;
run;

data min.sulfonylureas_users_v03;
	set min.sulfonylureas_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 1883 -> 1975 obs */

/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v03
* original table: min.sulfonylureas_users_v03
* description: merge into one dataset
**************************************************/

proc sql;
    create table min.bs_user_comedication_v03 as 
    select a.*, /* Select all columns from table a */
           b.cm_su, b.cm_su_date 
    from min.bs_user_comedication_v02 as a 
    left join min.sulfonylureas_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 obs */

data min.bs_user_comedication_v03;
	set min.bs_user_comedication_v03;
 	if missing(cm_su) then cm_su = 0;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v03;
	table cm_su;
run;

/*
among 38384, 
cm_su = 1 | 1883 (4.91%)
cm_su = 0 | 36501
*/


* 1.5. thiazo users;
/**************************************************
* new table: min.thiazo_users_v00
* original table: tx.medication_ingredient
* description: list up thiazo_users from original dataset
**************************************************/

data min.thiazo_users_v00;
	set tx.medication_ingredient;
 	if code in ('33738', '84108', '607999', '614348');
run;      /* 4927094 obs */

/* matching with our study population */
proc sql;
    create table min.thiazo_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a
    left join min.thiazo_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 45554 -> 44269 obs */

data min.thiazo_users_v01;
	set min.thiazo_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = cm_thiaz_date;
run;  

/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.thiazo_users_v02
* original table: min.thiazo_users_v01
* description: list up users within inclusion time window
**************************************************/

data min.thiazo_users_v02;
   set min.thiazo_users_v01;
   format cm_thiaz 8.;
   if bs_date - cm_thiaz_date ge 0 and bs_date - cm_thiaz_date le 365;
   if not missing(cm_thiaz_date) then cm_thiaz = 1;
   drop unique_id;
run;       /* 1774 -> 1854 obs */

/* Remain unique patients */
/**************************************************
* new table: min.thiazo_users_v03
* original table: min.thiazo_users_v02
* description: Remain unique patients of users within inclusion time window
**************************************************/

proc sort data=min.thiazo_users_v02;
	by patient_id cm_su_date;
run;

data min.thiazo_users_v03;
	set min.thiazo_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 348 -> 372 obs */

/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v04
* original table: min.thiazo_users_v03
* description: merge into one dataset
**************************************************/

proc sql;
    create table min.bs_user_comedication_v04 as 
    select a.*, /* Select all columns from table a */
           b.cm_thiaz, b.cm_thiaz_date 
    from min.bs_user_comedication_v03 as a 
    left join min.thiazo_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 obs */

data min.bs_user_comedication_v04;
	set min.bs_user_comedication_v04;
 	if missing(cm_thiaz) then cm_thiaz = 0;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v04;
	table cm_thiaz;
run;

/*
among 38384, 
cm_thiaz = 1 | 348 (0.91%)
cm_thiaz = 0 | 38036
*/


* 1.6. insulin users;
/**************************************************
* new table: min.insulin_users_v00
* original table: tx.medication_ingredient
* description: list up insulin_users from original dataset
**************************************************/

data min.insulin_users_v00;
	set tx.medication_ingredient;
 	if code in ('253182', '1008501', '1008509', '1605101');
run;      /* 140460403 obs */

/* matching with our study population */
proc sql;
    create table min.insulin_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a
    left join min.insulin_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 771551 -> 508384 obs */

data min.insulin_users_v01;
	set min.insulin_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = cm_insul_date;
run;  

/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.insulin_users_v02
* original table: min.insulin_users_v01
* description: list up users within inclusion time window
**************************************************/

data min.insulin_users_v02;
   set min.insulin_users_v01;
   format cm_insul 8.;
   if bs_date - cm_insul_date ge 0 and bs_date - cm_insul_date le 365;
   if not missing(cm_insul_date) then cm_insul = 1;
   drop unique_id;
run;       /* 164975 -> 120299 obs */

/* Remain unique patients */
/**************************************************
* new table: min.insulin_users_v03
* original table: min.insulin_users_v02
* description: Remain unique patients of users within inclusion time window
**************************************************/

proc sort data=min.insulin_users_v02;
	by patient_id cm_insul_date;
run;

data min.insulin_users_v03;
	set min.insulin_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 9140 -> 7914 obs */

/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v05
* original table: min.insulin_users_v03
* description: merge into one dataset
**************************************************/

proc sql;
    create table min.bs_user_comedication_v05 as 
    select a.*, /* Select all columns from table a */
           b.cm_insul, b.cm_insul_date 
    from min.bs_user_comedication_v04 as a 
    left join min.insulin_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 obs */

data min.bs_user_comedication_v05;
	set min.bs_user_comedication_v05;
 	if missing(cm_insul) then cm_insul = 0;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v05;
	table cm_insul;
run;

/*
among 38384, 
cm_insul = 1 | 9140 (23.81%)
cm_insul = 0 | 29244
*/


* 1.7. Antidepressants users;
/**************************************************
* new table: min.antidepressant_users_v00
* original table: tx.medication_ingredient
* description: list up Antidepressants users from original dataset
**************************************************/

data min.antidepressant_users_v00;
	set tx.medication_ingredient;
 	if code in ('704', '7531', '5691', '3247', '3634', '3638', '2597', '321988', '2556', '32937', '4493', '36437', '72625', '39786', '30121', '8123', '10737', '31565', '15996', '6646', '6929');
run;      /* 91868375 obs */

/* matching with our study population */
proc sql;
    create table min.antidepressant_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a
    left join min.antidepressant_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 768959 -> 742897 obs */

data min.antidepressant_users_v01;
	set min.antidepressant_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = cm_depres_date;
run;  

/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.antidepressant_users_v02
* original table: min.antidepressant_users_v01
* description: list up users within inclusion time window
**************************************************/

data min.antidepressant_users_v02;
   set min.antidepressant_users_v01;
   format cm_depres 8.;
   if bs_date - cm_depres_date ge 0 and bs_date - cm_depres_date le 365;
   if not missing(cm_depres_date) then cm_depres = 1;
   drop unique_id;
run;       /* 111067 -> 102926 obs */

/* Remain unique patients */
/**************************************************
* new table: min.antidepressant_users_v03
* original table: min.antidepressant_users_v02
* description: Remain unique patients of users within inclusion time window
**************************************************/

proc sort data=min.antidepressant_users_v02;
	by patient_id cm_depres_date;
run;

data min.antidepressant_users_v03;
	set min.antidepressant_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 10343 -> 10634 obs */

/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v06
* original table: min.antidepressant_users_v03
* description: merge into one dataset
**************************************************/

proc sql;
    create table min.bs_user_comedication_v06 as 
    select a.*, /* Select all columns from table a */
           b.cm_depres, b.cm_depres_date 
    from min.bs_user_comedication_v05 as a 
    left join min.antidepressant_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 obs */

data min.bs_user_comedication_v06;
	set min.bs_user_comedication_v06;
 	if missing(cm_depres) then cm_depres = 0;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v06;
	table cm_depres;
run;

/*
among 38384, 
cm_depres = 1 | 10343 (26.95%)
cm_depres = 0 | 28041
*/




* 1.8. Antipsychotics  users;
/**************************************************
* new table: min.antipsychotics_users_v00
* original table: tx.medication_ingredient
* description: list up Antipsychotics  users from original dataset
**************************************************/

data min.antipsychotics_users_v00;
	set tx.medication_ingredient;
 	if code in ('7019', '5093', '8076', '89013', '115698', '1040028', '679314', '73178', '784649', '46303', '51272', '35636', '41996', '2626', '61381');
run;      /* 30609157 obs */

/* matching with our study population */
proc sql;
    create table min.antipsychotics_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a
    left join min.antipsychotics_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 263939 -> 231768 obs */

data min.antipsychotics_users_v01;
	set min.antipsychotics_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = cm_psycho_date;
run;  

/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.antipsychotics_users_v02
* original table: min.antipsychotics_users_v01
* description: list up users within inclusion time window
**************************************************/

data min.antipsychotics_users_v02;
   set min.antipsychotics_users_v01;
   format cm_psycho 8.;
   if bs_date - cm_psycho_date ge 0 and bs_date - cm_psycho_date le 365;
   if not missing(cm_psycho_date) then cm_psycho = 1;
   drop unique_id;
run;       /* 51260 -> 49691 obs */

/* Remain unique patients */
/**************************************************
* new table: min.antipsychotics_users_v03
* original table: min.antipsychotics_users_v02
* description: Remain unique patients of users within inclusion time window
**************************************************/

proc sort data=min.antipsychotics_users_v02;
	by patient_id cm_psycho_date;
run;

data min.antipsychotics_users_v03;
	set min.antipsychotics_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 8164 -> 8884 obs */

/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v07
* original table: min.antipsychotics_users_v03
* description: merge into one dataset
**************************************************/

proc sql;
    create table min.bs_user_comedication_v07 as 
    select a.*, /* Select all columns from table a */
           b.cm_psycho, b.cm_psycho_date 
    from min.bs_user_comedication_v06 as a 
    left join min.antipsychotics_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 obs */

data min.bs_user_comedication_v07;
	set min.bs_user_comedication_v07;
 	if missing(cm_psycho) then cm_psycho = 0;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v07;
	table cm_psycho;
run;

/*
among 38384, 
cm_psycho = 1 | 8164 (21.27%)
cm_psycho = 0 | 30220
*/



* 1.9. Anticonvulsants  users;
/**************************************************
* new table: min.anticonvulsants_users_v00
* original table: tx.medication_ingredient
* description: list up Antipsychotics  users from original dataset
**************************************************/

data min.anticonvulsants_users_v00;
	set tx.medication_ingredient;
 	if code in ('38404', '39998', '28439', '114477', '31914', '32624', '25480', '187832', '40254', '2002');
run;      /* 89574604 obs */

/* matching with our study population */
proc sql;
    create table min.anticonvulsants_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a
    left join min.anticonvulsants_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 748436 obs */

data min.anticonvulsants_users_v01;
	set min.anticonvulsants_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = cm_convul_date;
run;  

/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.anticonvulsants_users_v02
* original table: min.anticonvulsants_users_v01
* description: list up users within inclusion time window
**************************************************/

data min.anticonvulsants_users_v02;
   set min.anticonvulsants_users_v01;
   format cm_convul 8.;
   if bs_date - cm_convul_date ge 0 and bs_date - cm_convul_date le 365;
   if not missing(cm_convul_date) then cm_convul = 1;
   drop unique_id;
run;       /* 124991 obs */

/* Remain unique patients */
/**************************************************
* new table: min.anticonvulsants_users_v03
* original table: min.anticonvulsants_users_v02
* description: Remain unique patients of users within inclusion time window
**************************************************/

proc sort data=min.anticonvulsants_users_v02;
	by patient_id cm_convul_date;
run;

data min.anticonvulsants_users_v03;
	set min.anticonvulsants_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 14428 -> 14385 obs */

/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v08
* original table: min.anticonvulsants_users_v03
* description: merge into one dataset
**************************************************/

proc sql;
    create table min.bs_user_comedication_v08 as 
    select a.*, /* Select all columns from table a */
           b.cm_convul, b.cm_convul_date 
    from min.bs_user_comedication_v07 as a 
    left join min.anticonvulsants_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 obs */

data min.bs_user_comedication_v08;
	set min.bs_user_comedication_v08;
 	if missing(cm_convul) then cm_convul = 0;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v08;
	table cm_convul;
run;

/*
among 38384, 
cm_convul = 1 | 14428 (37.59%)
cm_convul = 0 | 23956
*/



* 1.10. anti-obesity medication users;
/**************************************************
* new table: min.anti_ob_users_v00
* original table: tx.medication_ingredient
* description: list up Antipsychotics  users from original dataset
**************************************************/

data min.anti_ob_users_v00;
  set tx.medication_ingredient;
  format comedi_antiob 8. comedi_antiob_type $32. comedi_antiob_start_date yymmdd10.;
  where code in ("7243", "1551467", "37925", "8152", "1302826", "2469247");
  if code = "7243" then comedi_antiob_type = "naltrexone";
  else if code = "1551467" then comedi_antiob_type = "naltrexone/bupropion";
  else if code = "37925" then comedi_antiob_type = "orlistat";
  else if code = "8152" then comedi_antiob_type = "phentermine";
  else if code = "1302826" then comedi_antiob_type = "phentermine/topiramate";
  else if code = "2469247" then comedi_antiob_type = "setmelanotide";
  comedi_antiob = 1;
  comedi_antiob_start_date = input(start_date, yymmdd8.);
  drop start_date;
run;        /* 3913651 obs */

/* matching with our study population */
proc sql;
    create table min.anti_ob_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a
    left join min.anti_ob_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 97517 obs */


data min.anti_ob_users_v01;
	set min.anti_ob_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename comedi_antiob_start_date = cm_ob_date;
run;  

/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.anti_ob_users_v02
* original table: min.anti_ob_users_v01
* description: list up users within inclusion time window
**************************************************/

data min.anti_ob_users_v02;
   set min.anti_ob_users_v01;
   format cm_ob 8.;
   if bs_date - cm_ob_date ge 0 and bs_date - cm_ob_date le 365;
   if not missing(cm_ob_date) then cm_ob = 1;
   drop unique_id;
run;       /* 9662 obs */

/* Remain unique patients */
/**************************************************
* new table: min.anti_ob_users_v03
* original table: min.anti_ob_users_v02;
* description: Remain unique patients of users within inclusion time window
**************************************************/

proc sort data=min.anti_ob_users_v02;
	by patient_id cm_ob_date;
run;

data min.anti_ob_users_v03;
	set min.anti_ob_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 1642 obs */

/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v09
* original table: min.antiobes_users_v03
* description: merge into one dataset
**************************************************/

proc sql;
    create table min.bs_user_comedication_v09 as 
    select a.*, /* Select all columns from table a */
           b.cm_ob, b.cm_ob_date 
    from min.bs_user_comedication_v08 as a 
    left join min.anti_ob_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 obs */

data min.bs_user_comedication_v09;
	set min.bs_user_comedication_v09;
 	if missing(cm_ob) then cm_ob = 0;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v09;
	table cm_ob;
run;

/*
among 38384, 
cm_ob = 1 | 1642 (4.28%)
cm_ob = 0 | 36742
*/



/************************************************************************************
	STEP2. Subgroup analysis
************************************************************************************/

proc sort data=min.bs_user_comedication_v09;
	by temporality;
run;

/*
cm_metformin
cm_dpp4
cm_sglt2
cm_su
cm_thiaz
cm_insul
cm_depres
cm_psycho
cm_convul
cm_ob
*/

proc freq data=min.bs_user_comedication_v09;
	tables temporality*cm_metformin;
 	title "cm_metformin";
run;

proc freq data=min.bs_user_comedication_v09;
	tables temporality*cm_dpp4;
 	title "cm_dpp4";
run;

proc freq data=min.bs_user_comedication_v09;
	tables temporality*cm_sglt2;
 	title "cm_sglt2";
run;

proc freq data=min.bs_user_comedication_v09;
	tables temporality*cm_su;
 	title "cm_su";
run;

proc freq data=min.bs_user_comedication_v09;
	tables temporality*cm_thiaz;
 	title "cm_thiaz";
run;

proc freq data=min.bs_user_comedication_v09;
	tables temporality*cm_insul;
 	title "cm_insul";
run;

proc freq data=min.bs_user_comedication_v09;
	tables temporality*cm_depres;
 	title "cm_depres";
run;

proc freq data=min.bs_user_comedication_v09;
	tables temporality*cm_psycho;
 	title "cm_psycho";
run;

proc freq data=min.bs_user_comedication_v09;
	tables temporality*cm_convul;
 	title "cm_convul";
run;

proc freq data=min.bs_user_comedication_v09;
	tables temporality*cm_ob;
 	title "cm_ob";
run;



/**************************************************/**************************************************/**************************************************/

/**************************************************
* new table: min.bs_user_comedi_v00
* original table: tx.medication_ingredient;
* description: list up comedications
**************************************************/

%let list1 = %str('6809');  /* cm_metformin */
%let list2 = %str('593411', '1100699', '857974', '1368001', '1992825', '729717', '1598392', '1243019', '2281864', '1727500', '1043562', '2117292', '1368402', '1368384'); /* cm_dpp4 */
%let list3 = %str('1545653', '1373458', '1488564', '1992672', '2627044', '2638675', '1664314', '1545149', '1486436', '1992684');  /* cm_sglt2 */
%let list4 = %str('4821','25789','4815','4816','352381','647235','606253','285129');    /* cm_sulfonylureas */
%let list5 = %str('33738', '84108', '607999', '614348');     /* cm_thiazo */
%let list6 = %str('253182', '1008501', '1008509', '1605101');       /* cm_insulin */

* 1.7. Antidepressants users;
%let list7 = %str('704', '7531', '5691', '3247', '3634', '3638', '2597') /* cm_tca */
%let list8 = %str('321988', '2556', '32937', '4493', '36437') /* cm_ssri */
%let list9 = %str('72625', '39786')  /* cm_snri */
%let list10 = %str('30121', '8123') /* cm_maoi */
%let list8 = %str('10737', '31565', '15996', '6646', '6929') /* cm_antidepressants_others */

* 1.8. Antipsychotics users;
%let list8 = %str('7019', '5093', '8076')  /* cm_antipsy_typical */
%let list8 = %str('89013', '115698', '1040028', '679314', '73178', '784649', '46303', '51272', '35636', '41996', '2626', '61381') /* cm_antipsy_Atypical */
 

%let list8 = %str('38404', '39998', '28439', '114477', '31914', '32624', '25480', '187832', '40254', '2002')  /* cm_anticonv */



/* cm_lithium */


proc sql;
    create table min.bs_user_comedi_v00 as 
    select a.patient_id, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a 
    left join tx.medication_ingredient as b
    on a.patient_id = b.patient_id;
quit;


data min.bs_user_comedi_v01;
  set min.bs_user_comedi_v00;
  format cm_metformin cm_dpp4 cm_sglt2 cm_su cm_thia cm_insul 8.;

    cm_metformin =0;
    cm_dpp4 =0;
    cm_sglt2 =0;
    cm_su =0;
    cm_thia =0;
    cm_insul=0;
    
    if code in (&list1) then cm_metformin = 1;
    else if code in (&list2) then cm_dpp4 = 1;
    else if code in (&list3) then cm_sglt2 = 1;



    
    else delete;

run;















