
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 07_create outcomes dates, initiation, and censoring
| Date (update): July 2024
| Task Purpose : 
|      1. 
|      2. 
|      3. 
| Main dataset : (1) min.bs_user_all_v07, (2) tx.medication_ingredient, (3) tx.medication_drug (adding quantity_dispensed + days_supply)
| Final dataset : min.bs_glp1_user_v03 (with duplicated indiv)
************************************************************************************/

/**************************************************
              Variable Definition
* study entry = BS date (time origin)
* censoring (study exit)
*   1) event = the first GLP-1 initiation
*   2) lost to FU = the last encounter date
*   3) competing risk = death or switching to other type of anti-obesity medication
*   4) administrative censoring (2023.12.31)
**************************************************/

/************************************************************************************
	STEP 1. Exclude people who did not undergo BS (no time origin) & had GLP-1 exposure before BS date
************************************************************************************/
/************************************************************************************
	STEP 2. Generate study entry variable to account for the late entry - we don't have late entry based on study design
************************************************************************************/

/**************************************************
* new dataset: min.time_to_glp1_v00
* original dataset: min.bs_glp1_user_v12
* description: Exclude people who did not undergo BS (no time origin) & had GLP-1 exposure before BS date
**************************************************/

* min.bs_glp1_user_v12 확인해보고 진행하기;

data min.time_to_glp1_v00;
  set min.bs_glp1_user_v12;  /* use categorized covariates */
  format entry_date yymmdd10.;
  entry_date = bs_date;
  if temporality ne 1;
run;


/************************************************************************************
	STEP 3. Generate study exit variable - censoring scenario
************************************************************************************/

* 3.1. initiation of glp1 | generate "event" variable ;
/**************************************************
* new dataset: min.time_to_glp1_v01
* original dataset: min.time_to_glp1_v00
* description: add event_date & init_glp1 (event)
**************************************************/

data min.time_to_glp1_v01;
  set min.time_to_glp1_v00;
  format study_end_date event_date yymmdd10. init_glp1 8.;
  study_end_date = "2023-12-31"d;
  if glp1_initation_date > study_end_date then do;
    event_date = .;
    init_glp1 = 0;
  end;
  else do;
    event_date = glp1_initation_date;
    init_glp1 = 1;
  end;
run;

* 3.1. all-cause death date;
/**************************************************
* new dataset: min.time_to_glp1_v02
* original dataset: min.time_to_glp1_v01
* description: add death_date
**************************************************/

data min.time_to_glp1_v02;
  set min.time_to_glp1_v01;
  format death_date_source_id_num death_date yymmdd10.;
  death_date_source_id_num = input(death_date_source_id, yymmdd8.);
  if death_date_source_id_num > study_end_date then death_date = .;
  else death_date = death_date_source_id_num;
run;

* 3.2. lost to follow-up | identify the last date of encounter by patients;
* last_visit_date YYMMDD10.;

/**************************************************
* new dataset: min.time_to_glp1_v02
* original dataset: min.time_to_glp1_v01
* description: add death_date
**************************************************/

proc print data=tx.encounter (obs=30);
    title "tx.encounter";
run;

proc contents data=tx.encounter;
    title "tx.encounter";
run;

proc SQL;
  create table min.time_to_glp1_v02 as
  select a.* b.
  from min.time_to_glp1_v01 as a tx.encounter as b
  where a.patient_id = b.patient_id;
quit;

proc sort data=min.time_to_glp1_v02 ;
  by patient_id;
run;

* 3.2. select the earliest date among the several censoring end points;
/**************************************************
* new dataset: min.time_to_glp1_v01
* original dataset: min.time_to_glp1_v00
* description: identify several censored date
**************************************************/

data min.time_to_glp1_v01;
  set min.time_to_glp1_v00;
  format study_end_date exit_date yymmdd10.;
  death_date = input(death_date_source_id, yymmdd8.);      /* competing risk - death */
	format death_date yymmdd10.;
  drop death_date_source_id;

  /* var or the lost to follow-up */
  
  study_end_date = 2023-12-31;
  exit_date = min(glp1_initiation_date, death_date, last_visit_date, adm_censor_date);
run;
  

/************************************************************************************
	STEP 4. Generate duration of follow-up variable | time_to_event = last date(exit time point) – BS date
************************************************************************************/

data min.time_to_glp1_v01;
  set min.time_to_glp1_v01;
  format time_to_ 
run;

/************************************************************************************
	STEP 5. Generate variable for the event status : event = 1, censoring = 0 
************************************************************************************/


/************************************************************************************
	STEP 6. select covariable for further adjustment
************************************************************************************/

/**************************************************
              Covariables
* 
* censoring (study exit)
*   1) event = the first GLP-1 initiation
*   2) lost to FU = the last encounter date
*   3) competing risk = death or switching to other type of anti0obesity medication
*   4) administrative censoring (2023.12.31)
**************************************************/








