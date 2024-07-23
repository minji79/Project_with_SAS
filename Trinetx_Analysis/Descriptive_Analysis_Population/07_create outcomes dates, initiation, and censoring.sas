
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 07_create outcomes dates, initiation, and censoring
| Date (update): July 2024
| Task Purpose : 
|      1. Exclude people who did not undergo BS (no time origin) & had GLP-1 exposure before BS date  (N = 38384)
|      2. Generate study entry variable to account for the late entry - we don't have late entry based on study design
|      3. Generate study exit variable - (1) event | glp1_initation, (2) censor_date | censoring scenario
|         Generate variable for the event status : event = 1, censoring = 0 
|      4. Generate duration of follow-up variable | time_to_event = exit_date – entry_date(bs_date)


|      5. Select covariable for further adjustment
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
* 	0) censor_date
* 	0) censor_type
*   	1) lost to FU = the last encounter date
*   	2) death_date | competing risk 1 - death 
*   	3) comedi_antiob_start_date | competing risk 2 - switching to other type of anti-obesity medication
* 	4) encounter_end_date | lost to follow-up
*   	5) study_end_date | administrative censoring (2023.12.31)
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
	var patient_id month_year_death death_year death_month death_date;
	title "min.time_to_glp1_v02";
run;


* 3.3 switching to other types of anti-obesity medications;

/* select anti-obesity medication users among the total population */
/**************************************************
* new dataset: min.anti_ob_users_v00
* original dataset: tx.medication_ingredient
* description: select anti-obesity medication users among total population
*		comedi_antiob 8. comedi_antiob_type $32. comedi_antiob_start_date yymmdd10.;
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
run;        /* 3913651 obs (with duplication) */

proc print data=min.anti_ob_users_v00 (obs=30);
	var patient_id comedi_antiob comedi_antiob_type comedi_antiob_start_date;
	title "min.anti_ob_users_v00";
run;


/* match the anti-obesity medication users with our study population */

/**************************************************
* new dataset: min.time_to_glp1_v03   /* 38384 obs (with 2153 distinct patients who switched to AOM 'after BS-date' among bs users) */
*		min.anti_ob_users_v01
*		min.anti_ob_users_v02
* original dataset: min.time_to_glp1_v02 & min.anti_ob_users_v00
* description: select anto-obesity medication users among total population
**************************************************/

/* merge two dataset */
proc sql;
	create table min.anti_ob_users_v01 as
 	select a.*, b.comedi_antiob, b.comedi_antiob_start_date, b.comedi_antiob_type
  	from min.time_to_glp1_v02 as a, min.anti_ob_users_v00 as b
   	where a.patient_id = b.patient_id ;
quit;         /* 64000 obs with 53 var */


/* select switching to AOM after bs date */
data min.anti_ob_users_v01;
	set min.anti_ob_users_v01;
 	if comedi_antiob_start_date < bs_date then do;
  		comedi_antiob_start_date = .;
    		comedi_antiob = .;
      		comedi_antiob_type = .;
 	end;
run;     /* 64000 obs with 53 var */


/* select only patients who switched to AOM 'after BS-date'*/
proc sort data=min.anti_ob_users_v01;
	by patient_id comedi_antiob_start_date;
run;
                           
proc print data=min.anti_ob_users_v01 (obs=30);
	var patient_id comedi_antiob comedi_antiob_type bs_date comedi_antiob_start_date;
 	title "min.anti_ob_users_v01";
run;


data min.anti_ob_users_v02;
	set min.anti_ob_users_v01;
 	by patient_id;
 	if first.patient_id;
run;           /* 4867 distinct patients who switched to AOM among bs users */

proc means data= min.anti_ob_users_v02 n nmiss;
  var comedi_antiob;
  title "comedi_antiob";
run;    /* 2153 distinct patients who switched to AOM 'after BS-date' among bs users */


proc print data=min.anti_ob_users_v02 (obs=30);
	var patient_id comedi_antiob comedi_antiob_type bs_date comedi_antiob_start_date;
 	title "min.anti_ob_users_v02";
run;


/**************************************************
* new dataset: min.time_to_glp1_v03
* original dataset: min.time_to_glp1_v02 & min.anti_ob_users_v02
* description: merge with my study population
**************************************************/
proc sql;
	create table min.time_to_glp1_v03 as
 	select a.*, b.comedi_antiob, b.comedi_antiob_start_date, b.comedi_antiob_type
  	from min.time_to_glp1_v02 as a left join min.anti_ob_users_v02 as b
   	on a.patient_id = b.patient_id ;
quit;    /* 38384 obs (with 2153 distinct patients who switched to AOM 'after BS-date' among bs users) */



* 3.4. lost to follow-up;
/**************************************************
* new dataset: min.time_to_glp1_v04
* original dataset: min.time_to_glp1_v03
* Description: encounter_end_date
**************************************************/

/* see the original data */
proc print data=tx.encounter (obs=30);
    title "tx.encounter";
run;

proc contents data=tx.encounter;
    title "tx.encounter";
run;

/* identify the last date of encounter by patients */
/**************************************************
* new dataset: min.lost_to_fu_v00
* original dataset: min.time_to_glp1_v03 & tx.encounter
* description: select anto-obesity medication users among total population
**************************************************/

proc SQL;
  create table min.lost_to_fu_v00 as
  select a.*, b.encounter_id, b.start_date, b.end_date
  from min.time_to_glp1_v03 as a, tx.encounter as b
  where a.patient_id = b.patient_id;
quit;   /* 11276518 obs */

proc sort data=min.lost_to_fu_v00;
  by patient_id descending end_date; 
run;
proc print data=min.lost_to_fu_v00 (obs=30);
	var patient_id encounter_id start_date end_date;
	title "min.lost_to_fu_v00";
run;

data min.lost_to_fu_v00;
	set min.lost_to_fu_v00;
 	encounter_start_date = input(start_date, yymmdd8.); 
  	encounter_end_date = input(end_date, yymmdd8.);
   	format encounter_start_date encounter_end_date yymmdd10.;
run;       /* 11276518 obs */

data min.time_to_glp1_v04;
	set min.lost_to_fu_v00;
 	by patient_id descending encounter_end_date;
 	if first.patient_id;       /* to remain the last encounter date by patients */
run;
proc print data=min.time_to_glp1_v04 (obs=30);
	var patient_id encounter_start_date encounter_end_date;
	title "min.time_to_glp1_v04";
run;              /* 38384 obs */


* 3.5. identify 'censor_date' and 'censor_type' among the several censoring endpoints;
/**************************************************
* new dataset: min.time_to_glp1_v05
* original dataset: min.time_to_glp1_v04
* description: identify 'censor_date' and 'censor_type' among the several censoring endpoints
**************************************************/

data min.time_to_glp1_v05;
  set min.time_to_glp1_v04;
  format censor_type $32.;
  
  	censor_date = 999999;
 	array date{4} $ death_date comedi_antiob_start_date encounter_end_date study_end_date;
	do i=1 to 4;
		if date{i} lt censor_date and date{i} ne "." then censor_date=date{i};
	end;
	
 	if censor_date=999999 then censor_date = ".";
  
	format censor_date yymmdd10. censor_type_cat 8.;

  	/* define censoring type */
 	if censor_date = "." then do;
  		censor_type = "none";
    		censor_type_cat = 0;
      	end;
	else if censor_date = death_date then do;
 		censor_type = "death";
 		censor_type_cat = 1;
   	end;
	else if censor_date = comedi_antiob_start_date then do;
 		censor_type = "switching to	AOM";  /* AMO = anti-obesity medication */
   		censor_type_cat = 2;
   	end;
	else if censor_date = encounter_end_date then do;
 		censor_type = "lost to follow-up";
   		censor_type_cat = 3;
   	end;
	else if censor_date = study_end_date then do;
 		censor_type = "administrative censored";
   		censor_type_cat = 4;
	end;
 
run;

proc print data=min.time_to_glp1_v05 (obs=30);
	var patient_id entry_date init_glp1_event init_glp1_date censor_date censor_type death_date comedi_antiob_start_date encounter_end_date study_end_date;
	title "min.time_to_glp1_v05";
run;

* 3.6. see distribution of 'censor_date' and 'censor_type';

proc freq data=min.time_to_glp1_v05;
	table init_glp1_event;
run;

proc sort data=min.time_to_glp1_v05;
	by censor_type_cat;
run;
proc means data=min.time_to_glp1_v05 n nmiss;
	var censor_type_cat;
 	by censor_type_cat;
  	title "Summary Statistics by Censoring Type";
run;

/************************************************************************************
	STEP 4. Generate "exit_date"
************************************************************************************/

* 4.1. Generate "exit_date" variable ;
/**************************************************
* new dataset: min.time_to_glp1_v06
* original dataset: min.time_to_glp1_v05
* description: exit_date 
**************************************************/

data min.time_to_glp1_v06;
  set min.time_to_glp1_v05;
  if init_glp1_date = . then exit_date = censor_date;
  else if censor_date = . then exit_date = init_glp1_date;
  else exit_date = min(init_glp1_date, censor_date);

  if exit_date = init_glp1_date then do;
  	censor_type = "event";
   	censor_type_cat = 5;
  end;
run;

* 4.2. distribution of censor_type_cat;

proc sort data=min.time_to_glp1_v06;
	by censor_type_cat;
run;
proc means data=min.time_to_glp1_v06 n nmiss;
	var censor_type_cat;
 	by censor_type_cat;
  	title "Summary Statistics by Censoring Type";
run;

/*
1. death = 3041
2. switching = 1745
3. lost to FU = 29273
4. administrative censored = 0
5. glp1 initiation = 4325   (5259)
total = 38384
*/
