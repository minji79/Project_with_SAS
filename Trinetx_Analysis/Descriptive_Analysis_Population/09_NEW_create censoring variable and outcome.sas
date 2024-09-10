
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 09_NEW_create censoring variable and outcome.sas

| Date (update): SEP 2024
| Task Purpose : 
|      1. Generate duration of follow-up variable | time_to_event = exit_date – entry_date(bs_date)
|      2. 
|      3. 
| Main dataset : (1) min.bs_user_all_v07, (2) tx.medication_ingredient, (3) tx.medication_drug (adding quantity_dispensed + days_supply)
| Final dataset : min.bs_glp1_user_v03 (with duplicated indiv)
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
/*
1. death = 5858
2. administrative censored = 27380
5. glp1 initiation = 5146
total = 38384
*/


/************************************************************************************
	STEP 1. Generate duration of follow-up variable | time_to_event = exit_date – entry_date(bs_date)
************************************************************************************/

* 1.1. Generate duration of follow-up variable;
/**************************************************
* new dataset: min.time_to_glp1_v04
* original dataset: min.time_to_glp1_v03
* description: time_to_exit ( = person-time )
**************************************************/
 
data min.time_to_glp1_v04;
	set min.time_to_glp1_v03;
	format person_time;
 	time_to_exit = exit_date - entry_date;
run;

* 1.2. see distribution of "time_to_exit" = duration of follow-up ;
proc univariate data=min.time_to_glp1_v04; var time_to_exit; histogram; run;

proc means data=min.time_to_glp1_v04 n median p25 p75 min max nmiss;
	var person_time;
 	title "distribution of person_time";
run;


* 1.3. negative value in time_to_event?? ; 

proc print data=min.time_to_glp1_v04 (obs=100);
	var patient_id init_glp1_date exit_date exit_type exit_date bs_date time_to_exit ;
	where time_to_exit <0;
run;   

proc sql;
    select count(distinct patient_id) as negative_PT
    from min.time_to_glp1_v04
    where time_to_exit < 0;
quit;    /* 679 of negative values in time_to_exit variables */

proc freq data=min.time_to_glp1_v04;
    tables exit_type_cat / list missing;
    where time_to_exit < 0;
run;      /* 679 of negative values in time_to_exit variables : 679 = death */

/* see death data with other dataset */
data min.bs_glp1_user_v13;
  set min.bs_glp1_user_v12;
  death_year = input(substr(month_year_death, 1, 4), 4.);
  death_month = input(substr(month_year_death, 5, 2), 2.);
  death_date = mdy(death_month,15,death_year);
  format death_date yymmdd10.;
run;   /* 42535 obs */

proc print data=min.bs_glp1_user_v13 (obs=30);
	var patient_id month_year_death death_date bs_date temporality;
 	where death_date < bs_date and death_date ne .;
 	title "min.bs_glp1_user_v13";
run;

proc sql;
    select count(distinct patient_id) as negative_duration
    from min.bs_glp1_user_v13
    where death_date < bs_date and temporality ne 1 and death_date ne .;
quit;     /* 679 distinct individuals */


/************************************************************************************
	STEP 2. Select covariable for stratify - bs_type & glp1_type
************************************************************************************/

/**************************************************
* new dataset: min.time_to_glp1_v05
* original dataset: min.time_to_glp1_v04
* description: bs_type & glp1_type
**************************************************/

* 2.1. bs_type_cat;
proc contents data=min.time_to_glp1_v04;
  title "min.time_to_glp1_v04";
run;

proc print data=min.time_to_glp1_v04 (obs=30);
  var patient_id Molecule bs_type bs_type_cat;
  where glp1_user =1;
  title "min.time_to_glp1_v04";
run;

* 2.2. glp1_type_cat;

data min.time_to_glp1_v05;
  set min.time_to_glp1_v04;
  format glp1_type_cat 8.;
  if Molecule = "Semaglutide" then glp1_type_cat = 1;
  else if Molecule = "Liraglutide" then glp1_type_cat = 2;
  else if Molecule = "Dulaglutide" then glp1_type_cat = 3;
  else if Molecule = "Exenatide" then glp1_type_cat = 4;
  else if Molecule = "Lixisenatide" then glp1_type_cat = 5;
  else if Molecule = "Tirzepatide" then glp1_type_cat = 6;
run;


/************************************************************************************
	STEP 3. Select covariable for further adjustment
************************************************************************************/

/**************************************************
              Covariables
* 1) 
**************************************************/
