/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 07_create outcomes dates, initiation, and censoring
| Date (update): July 2024
| Task Purpose : 
|      1. Exclude people who did not undergo BS (no time origin) & had GLP-1 exposure before BS date  (N = 38384)
|      2. Generate study entry variable to account for the late entry - we don't have late entry based on study design
|      3. Generate study exit variable - (1) event | glp1_initation, (2) censor_date | censoring scenario
|         Generate variable for the event status : event = 1, censoring = 0 
| Main dataset : 
| Final dataset : min.time_to_glp1_v06
************************************************************************************/

/**************************************************
              Variable Name and Definition
* study entry
*   	entry_date | BS date (time origin)
* study exit
*   event
* 	init_glp1_event | 0 = censored, 1 = event
* 	init_glp1_date | the first GLP-1 initiation date
*   censoring
* 	0) exit_date
* 	0) exit_type
*   	1) death_date | competing risk 1 - death 
*   	4) study_end_date | administrative censoring (2023.12.31)
**************************************************/


/************************************************************************************
	STEP 1. Exclude people who did not undergo BS (no time origin) & had GLP-1 exposure before BS date  (N = 38384)
************************************************************************************/
/************************************************************************************
	STEP 2. Generate study entry variable to account for the late entry - we don't have late entry based on study design
************************************************************************************/

/**************************************************
* new dataset: min.time_to_glp1_v00
* original dataset: min.bs_glp1_user_v12
* description: Exclude people who did not undergo BS (no time origin) & had GLP-1 exposure before BS date
**************************************************/

data min.time_to_glp1_v00;
  set min.bs_glp1_user_v12;  /* use categorized covariates */
  format entry_date yymmdd10.;
  entry_date = bs_date;
  if temporality ne 1;
run;        /* 38384 obs + 44 var -> confirm n= 38384 */

proc print data=min.time_to_glp1_v00 (obs=30);
	var patient_id entry_date bs_date glp1_initiation_date temporality;
 	where temporality =2;
	title "min.time_to_glp1_v00";
run;


/************************************************************************************
	STEP 3. Generate study exit variable - (1) event | glp1_initation, (2) censor_date | censoring scenario
 		Generate variable for the event status : event = 1, censoring = 0 
************************************************************************************/

* 3.1. initiation of glp1 | generate "event" variable ;
/**************************************************
* new dataset: min.time_to_glp1_v01
* original dataset: min.time_to_glp1_v00
* description: add init_glp1_date & init_glp1_event
**************************************************/

data min.time_to_glp1_v01;
  set min.time_to_glp1_v00;
  format study_end_date init_glp1_date yymmdd10. init_glp1_event 8.;
  study_end_date = "31DEC2023"d;
  if temporality = 0 then init_glp1_event = 0;
  else if glp1_initiation_date > study_end_date then do;
    init_glp1_date = .;
    init_glp1_event = 0;
  end;
  else do;
    init_glp1_date = glp1_initiation_date;
    init_glp1_event = 1;
  end;
run;    /* 38384 obs + 48 var */

proc print data =min.time_to_glp1_v01 (obs =30);
	var patient_id glp1_initiation_date init_glp1_date init_glp1_event;
 	where init_glp1_event = 1;
	title "min.time_to_glp1_v01";
run;


* 3.2. all-cause death date;
/**************************************************
* new dataset: min.time_to_glp1_v02
* original dataset: min.time_to_glp1_v01
* description: add death_date
**************************************************/

proc print data =min.time_to_glp1_v01 (obs =30);
	var patient_id month_year_death death_date_source_id study_end_date;
	title "min.time_to_glp1_v01";
run;

/* assume that the death occurred in the middle of the month */
data min.time_to_glp1_v02;
  set min.time_to_glp1_v01;
  death_year = input(substr(month_year_death, 1, 4), 4.);
  death_month = input(substr(month_year_death, 5, 2), 2.);
  death_date = mdy(death_month,15,death_year);
  format death_date yymmdd10.;
run;

proc print data=min.time_to_glp1_v02 (obs=30);
	var patient_id month_year_death death_year death_month death_date study_end_date;
	title "min.time_to_glp1_v02";
run;

* 3.3. administrative censoring;
* we already set study_end_date = "31DEC2023"d;


* 3.4. identify 'censor_date' and 'censor_type' among the several censoring endpoints;
/**************************************************
* new dataset: min.time_to_glp1_v03
* original dataset: min.time_to_glp1_v02
* description: identify 'exit_date' and 'exit_type' among the several censoring endpoints
**************************************************/

proc contents data=min.time_to_glp1_v02;
run;

data min.time_to_glp1_v03;
  set min.time_to_glp1_v02;
  format exit_type $32. exit_date yymmdd10. exit_type_cat 8.;
  	exit_date = min(init_glp1_date, death_date, study_end_date);  

  	/* define exit type */
 	if exit_date = init_glp1_date then do;
  		exit_type = "event";
    		exit_type_cat = 1;
      	end;
	else if exit_date = death_date then do;
 		exit_type = "death";
 		exit_type_cat = 2;
   	end;
	else if exit_date = study_end_date then do;
 		exit_type = "administrative censored";
   		exit_type_cat = 3;
	end;
 
run;

proc print data=min.time_to_glp1_v03 (obs=30);
	var patient_id entry_date init_glp1_event init_glp1_date exit_date exit_type death_date study_end_date;
 	where temporality = 2 and exit_type = 'death';
	title "min.time_to_glp1_v03";
run;   /* 131 obs have death date prior to their glp1 initiation */

proc freq data=min.time_to_glp1_v03;
	table exit_type;
 	where temporality = 2;
run;

proc means data=min.time_to_glp1_v03 n max min nmiss;
	var death_date;
run;

* 3.6. see distribution of 'censor_date' and 'censor_type';

proc freq data=min.time_to_glp1_v03;
	table init_glp1_event;
run;

proc sort data=min.time_to_glp1_v03;
	by exit_type_cat;
run;
proc means data=min.time_to_glp1_v03 n nmiss;
	var exit_type_cat;
 	by exit_type_cat;
  	title "Summary Statistics by Censoring Type";
run;


/*
1. death = 5858
2. administrative censored = 27380
5. glp1 initiation = 5146
total = 38384
*/
