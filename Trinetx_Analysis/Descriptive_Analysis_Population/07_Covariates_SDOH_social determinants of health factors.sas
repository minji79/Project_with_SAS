
/****************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 07_Covariates_SDOH_social determinants of health factors
| Date (update): August 2024
| Task Purpose : 
|      1. Create social determinants of health factors (SDOH) lists using the ICD_10 codes
| Main dataset : (1) tx.vitals_signs
****************************************************************************/


proc contents data =tx.procedure;
run;


socioeconomic and psychosocial circumstances

/************************************************************************************
	STEP 1. Create social determinants of health factors (SDOH) lists using the ICD_10 codes
************************************************************************************/

* 1.1. stack diagnosis information for individuals in 'min.bs_user_all_v07';
/**************************************************
* new table: min.bs_user_sdoh_v00
* original table: min.bs_user_all_v07 & tx.procedure
* description: stack sdoh information for individuals in 'min.bs_user_all_v07'
**************************************************/

proc sql;
    create table min.bs_user_sdoh_v00 as 
    select a.patient_id, 
           b.*  
    from min.bs_glp1_user_38384_v00 as a 
    left join tx.procedure as b
    on a.patient_id = b.patient_id;
quit;

proc print data=min.bs_user_sdoh_v00 (obs=30); 
  title "min.bs_user_sdoh_v00";
run;

* 1.2. list up all SDOH;
/**************************************************
* new table: min.bs_user_sdoh_v01
* original table: min.bs_user_sdoh_v00
* description: list up all SDOH
**************************************************/

/*
sdoh_total | Z55-Z65 | Persons with potential health hazards related to socioeconomic and psychosocial circumstances
sdoh_edu | Z55 | Problems related to education and literacy
sdoh_employ | Z56 | Problems related to employment and unemployment
sdoh_economic | Z59 | Problems related to housing and economic circumstances
*/

proc print data = min.bs_user_sdoh_v00 (obs = 30);
  where code = "Z55-Z65";
run;


data min.bs_user_sdoh_v01;
    set min.bs_user_sdoh_v00;
    format sdoh_total sdoh_edu sdoh_employ sdoh_economic 8.;
    
        sdoh_total = 0;
        sdoh_edu =0;
        sdoh_employ =0;
        sdoh_economic =0;

    if code = "Z55-Z65" then sdoh_total =1;
    else if code = "Z55" then sdoh_edu =1;
    else if code = "Z56" then sdoh_employ =1;
    else if code = "Z59" then sdoh_economic =1;
run;


* 1.3. add patient's bs_date and temporality;
/**************************************************
* new table: min.bs_user_sdoh_v02
* original table: min.bs_user_sdoh_v01 + min.bs_glp1_user_38384_v00
* description: list up all sdoh regardless types of the diseases
**************************************************/

proc sql;
    create table min.bs_user_sdoh_v02 as 
    select a.*, 
           b.temporality, b.bs_date
    from min.bs_user_sdoh_v01 as a 
    left join min.bs_glp1_user_38384_v00 as b
    on a.patient_id = b.patient_id;
quit;   /*  obs */

proc print data=min.bs_user_sdoh_v02 (obs=30);
	where  sdoh_total = 1;
  title "min.bs_user_sdoh_v02";
run;



/************************************************************************************
	STEP 2. Remain sdoh diagnosed within 1 yr before the surgery
************************************************************************************/

* 2.1. convert the format of the date;

data min.bs_user_sdoh_v02;
	set min.bs_user_shod_v02;
 	date_num = input(date, yymmdd8.);
  	format date_num yymmdd10.;
 	drop date;
  	rename date_num = sdoh_date;
run;


* 2.2. Remain SDOH factors diagnosed within 1 yr before the surgery;
/**************************************************
* new table: min.bs_user_sdoh_v03
* original table: min.bs_user_sdoh_v02
* description: Remain SDOH diagnosed within 1 yr before the surgery
**************************************************/

data min.bs_user_sdoh_v03;
   set min.bs_user_sdoh_v02;
   if bs_date - sdoh_date ge 0 and bs_date - sdoh_date le 365;
run;      /*  obs */

proc sql;
  create table distinct_patient_count as 
  select count(distinct patient_id) as num_patients
  from min.bs_user_sdoh_v03;
quit;
proc print data=distinct_patient_count;
run;   /*  distinct patients have SDOH factors */

proc sort data=min.bs_user_sdoh_v03;
	by patient_id;
run;


/************************************************************************************
	STEP 3. calculate the distribution of each SDOH factor
************************************************************************************/

* 3.1. Persons with potential health hazards related to socioeconomic and psychosocial circumstances;
/**************************************************
* sdoh_total
* new table: min.bs_user_sdoh_total
* original table: min.bs_user_sdoh_v03
**************************************************/

data min.bs_user_sdoh_total;
	set min.bs_user_sdoh_v03;
 	where sdoh_total =1;
  	by patient_id;
  	if first.patient_id;
run;        /* obs */

proc freq data=min.bs_user_sdoh_total;
	table temporality;
 	title "SDOH factors | total | among 38384";
run;


/*
sdoh_total | Z55-Z65 | Persons with potential health hazards related to socioeconomic and psychosocial circumstances
sdoh_edu | Z55 | Problems related to education and literacy
sdoh_employ | Z56 | Problems related to employment and unemployment
sdoh_economic | Z59 | Problems related to housing and economic circumstances
*/






