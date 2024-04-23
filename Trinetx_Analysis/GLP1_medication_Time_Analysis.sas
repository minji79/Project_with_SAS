
/****************************************************************************
| Program name : glp1 time
| Date (update): 
| Project name : Trinetx - data analysis
| Purpose      : 
****************************************************************************/

* 0. explore original dataset;

proc print data=tx5p.medication_ingredient (obs=40);
    title "tx5p.medication_ingredient";
run;
proc contents data=tx5p.medication_ingredient;
    title "tx5p.medication_ingredient";
run;

proc print data=tx5p.medication_drug (obs=40);
    title "tx5p.medication_drug";
run;
proc contents data=tx5p.medication_drug;
    title "tx5p.medication_drug";
run;



* 0. distinct value of the code_system variable (어떤 코딩 시스템이 쓰이는지 확인하는 목적);

proc sql;
  create table mj.medication_ing_5p_codelist as
  select distinct code_system
  from tx.medication_ingredient; 
quit; 
proc print data=mj.medication_ing_5p_codelist; run;

proc sql;
  create table mj.medication_drug_5p_codelist as
  select distinct code_system
  from tx.medication_drug;
quit; 
proc print data=mj.medication_drug_5p_codelist; run;



* 1. explore dataset to select glp1_users;

* 1-1. Semaglutide [1991302];
proc print data=tx5p.medication_ingredient (obs=30);
    where code = "1991302";
    title "tx5p.medication_ingredient_Semaglutide";
run;

* 1-2. Dulaglutide [1551291];
proc print data=tx5p.medication_ingredient (obs=30);
    where code = "1551291";
    title "tx5p.medication_ingredient_Dulaglutide";
run;

* 1-3. Liraglutide [475968];
proc print data=tx5p.medication_ingredient (obs=30);
    where code = "475968";
    title "tx5p.medication_ingredient_Liraglutide";
run;

* 1-4. Exenatide [60548];
proc print data=tx5p.medication_ingredient (obs=30);
    where code = "60548";
    title "tx5p.medication_ingredient_Exenatide";
run;

* 1-5. Lixisenatide [1440051];
proc print data=tx5p.medication_ingredient (obs=30);
    where code = "1440051";
    title "tx5p.medication_ingredient_Lixisenatide";
run;

* 1-6. Tirzepatide [2601723];
proc print data=tx5p.medication_ingredient (obs=30);
    where code = "2601723";
    title "tx5p.medication_ingredient_Tirzepatide";
run;

* 1-7. cross check with the rayna's medication list - only for the obesity;
/*
Semaglutide [1991302]
Liraglutide [475968]
Tirzepatide [2601723]
*/

data mj.glp1_raynalist;
    set rayna.glp1_user (keep=code brand strength);
run;
proc print data=mj.glp1_raynalist (obs=30);
  title "mj.glp1_raynalist";
run;

proc sql;
    select distinct code
    from mj.glp1_raynalist;
quit;


* 2. select "all" glp1_users;

/**************************************************
* new table: mj.glp1_user_all
* original table: tx5p.medication_ingredient
* description: select "all" glp1_users from tx5p.medication_ingredient
**************************************************/

* 2-1. make the data table;

data mj.glp1_user_all;
  set tx5p.medication_ingredient;
  where code in ("1991302", "1551291", "475968", "60548", "1440051", "2601723");
  if code = "1991302" then Molecule = "Semaglutide";
  else if code = "1551291" then Molecule = "Dulaglutide";
  else if code = "475968" then Molecule = "Liraglutide";
  else if code = "60548" then Molecule = "Exenatide";
  else if code = "1440051" then Molecule = "Lixisenatide";
  else if code = "2601723" then Molecule = "Tirzepatide";
run;                                                          /* 856261 obs */
              
proc print data=mj.glp1_user_all (obs=30);
  title "mj.glp1_user_all";
run;

* 2-2. sort by patient_id start_date Molecule to see individual's glp1 medication history;

proc sort data = mj.glp1_user_all;
  by patient_id start_date Molecule;
proc print data = mj.glp1_user_all (obs=30);
run;

* 2-3. add 'indication' var + see the distribution of the indication;

data mj.glp1_user_all;
  set mj.glp1_user_all;
  if brand = "Wegovy" then Indication = "Obesity";
  else if brand = "Saxenda" then Indication = "Obesity";
  else if brand = "Zepbound" then Indication = "Obesity";
  else if brand = "Ozempic" then Indication = "T2DB";
  else if brand = "Rybelsus" then Indication = "T2DB";
  else if brand = "Trulicity" then Indication = "T2DB";
  else if brand = "Victoza" then Indication = "T2DB";
  else if brand = "Xultophy" then Indication = "T2DB";
  else if brand = "Bydureon" then Indication = "T2DB";
  else if brand = "Byetta" then Indication = "T2DB";
  else if brand = "Adlyxin" then Indication = "T2DB";
  else if brand = "Sqliqua" then Indication = "T2DB";
  else if brand = "Mounjaro" then Indication = "T2DB";
  else if brand = "Unknown" then Indication = "Unknown";
run;   
proc print data=mj.glp1_user_all (obs=30);
  title "mj.glp1_user_all with indication";
run;

proc freq data=mj.glp1_user_all;
  table Indication;
run;


* 4. add variable named 'Initiation_date' to indicate 'GLP1 initiation date by type of GLP1';

/**************************************************
* new table: mj.glp1_user_all_initiation_date
* original table: mj.glp1_user_all
* description: add variable named 'Initiation_date' to indicate 'GLP1 initiation date by type of GLP1'
**************************************************/

proc sql;
	create table mj.glp1_user_all_initiation_date as
	select patient_id, min(start_date) as Initiation_date
	from mj.glp1_user_all
	group by patient_id;
quit;
proc print data=mj.glp1_user_all_initiation_date (obs=30);
	title "mj.glp1_user_all_initiation_date";
run;


* 5. do mapping Initiation_date with 'mj.glp1_user_all' table by patient.id;

/**************************************************
* new table: mj.glp1_user_all_date
* original table: mj.glp1_user_all + mj.glp1_user_all_initiation_date
* description: left join mj.glp1_user_all & mj.glp1_user_all_initiation_date
**************************************************/

proc sql;
  create table mj.glp1_user_all_date as
  select distinct a.*, b.Initiation_date
  from mj.glp1_user_all a left join mj.glp1_user_all_initiation_date b 
  on a.patient_id=b.patient_id;
quit;

proc sort data=mj.glp1_user_all_date;
	by patient_id start_date;
run;

proc print data=mj.glp1_user_all_date (obs=30) label;
	var patient_id Initiation_date start_date Molecule brand strength Indication;
	label start_date = "Date";
	title "mj.glp1_user_all_date";
run;

* 6. format date;

data mj.glp1_user_all_date;
	set mj.glp1_user_all_date;
	start_date_num = input(start_date, yymmdd8.);
	Initiation_date_num = input(Initiation_date, yymmdd8.);
	format start_date_num Initiation_date_num yymmdd10.;
	drop start_date Initiation_date;
    rename start_date_num=start_date Initiation_date_num=Initiation_date;
run;

proc contents data = mj.glp1_user_all_date;
	title "mj.glp1_user_all_date";
run;

proc print data = mj.glp1_user_all_date (obs = 30) label;
  label start_date = "Date";
	title "mj.glp1_user_all_date";
run;


* 7. calculate the gap between Initiation_date and date;

data mj.glp1_user_all_date;
	set mj.glp1_user_all_date;
	gap = start_date - Initiation_date;
run;

proc print data = mj.glp1_user_all_date (obs = 30) label;
  var patient_id Initiation_date start_date Molecule strength gap;
  label start_date = "Date"
  gap = "Date gap";
	title "mj.glp1_user_all_date";
run;


* 8. make time series table;

/**************************************************
* new dataset: mj.glp1_user_all_time_series
* original dataset: mj.glp1_user_all_date
* description: time series table
**************************************************/

data mj.glp1_user_all_time_series;
	set mj.glp1_user_all_date;
	array months[37] m0-m36;    
	do i = 1 to 37;            
        	months[i] = .;
   	end;
	if gap >= 0 then do;      
	idx = floor(gap / 30); 
        if idx <= 36 then months[idx+1] = 1; 
   	end;
	drop i idx;
run;

proc print data = mj.glp1_user_all_time_series (obs = 30) label;
  var patient_id Initiation_date start_date unique_id Molecule strength gap m0-m36;
  label start_date = "Date"
  gap = "Date gap";
  title "mj.glp1_user_all_time_series";
run;

/*****************************************************************************************************************************************************/
* how to defind the discontinuation;

/**** Method 1 | indicator variable ****/
* 1. make indicator variable of the discontinuation;

data mj.glp1_user_all_time_series;
	set mj.glp1_user_all_time_series;
 	if gap > 90 then disc = 1;
  	else disc = 0;
proc print data=mj.glp1_user_all_time_series(obs=40);
	var patient_id Initiation_date start_date gap m0 disc;
 	title "discontinuation of glp1";
run;

* 2. To fo exploratory analysis of date-gap -> excluded the observation with gap=0 ;

/**************************************************
* new dataset: mj.glp1_user_all_time_series_disc
* original dataset: mj.glp1_user_all_time_series
* description: exclude the observation with gap=0 to analyze discontinuation 
**************************************************/

proc freq data=mj.glp1_user_all_time_series;
	where gap <> 0;
 	table disc;
	title "discontinuation distribution";
run;

proc means data=mj.glp1_user_all_time_series n nmiss mean std maxdec=1;
	var gap;
	title "mj.glp1_users_gap_stats";
run;


/**** Method 2 | calculate the "total exposure period" from the initial dose to the last dose ****/

* 1. make the "final_date" variable to indicate the date of the last dose of glp1;

/**************************************************
* new table: mj.glp1_user_all_final_date
* original table: mj.glp1_user_all
* description: add variable named 'total_exposure_period' to indicate the total exposure period from the initial dose to the last dose
**************************************************/

proc sql;
	create table mj.glp1_user_all_final_date as
 	select patient_id, max(start_date) as final_date
  	from mj.glp1_user_all
   	group by patient_id;
quit;
proc print data=mj.glp1_user_all_final_date (obs=30);
	title "mj.glp1_user_all_final_date";
run;

* 2. format date of the "final_date" variable;

data mj.glp1_user_all_final_date;
	set mj.glp1_user_all_final_date;
	final_date_num = input(final_date, yymmdd8.);
	format final_date_num yymmdd10.;
	drop final_date;
    rename final_date_num=final_date;
run;

proc print data=mj.glp1_user_all_final_date (obs=30);
	title "mj.glp1_user_all_final_date";
run;

proc contents data = mj.glp1_user_all_final_date;
	title "mj.glp1_user_all_final_date";
run;

* 3. (update the "mj.glp1_user_all_date" data set) do mapping final_date with 'mj.glp1_user_all_date' table by patient.id;

/**************************************************
* new table: mj.glp1_user_all_date
* original table: mj.glp1_user_all_date + mj.glp1_user_all_final_date
* description: left join mj.glp1_user_all_date & mj.glp1_user_all_final_date
**************************************************/

data mj.glp1_user_all_date;
    set mj.glp1_user_all_date (drop = final_date total_exposure_period);
run;

proc sql;
  create table mj.glp1_user_all_date as
  select distinct a.*, b.final_date
  from mj.glp1_user_all_date a left join mj.glp1_user_all_final_date b 
  on a.patient_id=b.patient_id;
quit;

proc sort data = mj.glp1_user_all_date;
  by patient_id start_date;
proc print data = mj.glp1_user_all_date (obs=40);
run;

proc print data=mj.glp1_user_all_date (obs=40) label;
	var patient_id Initiation_date start_date final_date;
	label start_date = "Date";
	title "mj.glp1_user_all_date (updated with the final date)";
run;


* 4. add variable named 'exposure_time' to indicate 'the total exposure time to glp1 by patient';

data mj.glp1_user_all_date;
	set mj.glp1_user_all_date;
	exposure_time = final_date - Initiation_date;
run;

proc print data=mj.glp1_user_all_date (obs=40);
	title "mj.glp1_user_all_date (updated with the total_exposure_period";
run;

* 5. keep only distint oberservation by patient;

/**************************************************
* new table: mj.glp1_user_all_exposure_time
* original table: mj.glp1_user_all_date
* description: keep only distinct exposure time by patient
**************************************************/

proc sql;
  create table mj.glp1_user_all_exposure_time as
  select distinct patient_id, exposure_time, final_date, Initiation_date
  from mj.glp1_user_all_date;
quit;                                       /* total 54277 observations */

proc print data=mj.glp1_user_all_exposure_time (obs=40); 
 title "mj.glp1_user_all_exposure_time";
run;

* 6. to explore the distribution of exposure time by patient, keep only distint oberservation by patient;

* basic statistics;
proc means data=mj.glp1_user_all_exposure_time n q1 median mean q3 std min max;
	var exposure_time;
	title "exposure_time";
 	output out=quantile_exposure median=Q50 Q1=Q25 Q3=Q75;
run;

* the number of value of 0;
proc means data=mj.glp1_user_all_exposure_time n;
	var exposure_time;
 	where exposure_time = 0;
	title "exposure_time = 0";
run;

proc print data=mj.glp1_user_all_exposure_time (obs=30);
	var patient_id Initiation_date final_date exposure_time;
 	where exposure_time = 0;
	title "exposure_time = 0";
run;

*think about inclusion criteria;
* 1) exposure_time > 365 (1 yr) ;
proc means data=mj.glp1_user_all_exposure_time n;
	var exposure_time;
 	where exposure_time > 365;
	title "exposure_time > 365 - over 1yr";
run;

proc means data=mj.glp1_user_all_exposure_time n q1 median mean q3 std min max;
	var exposure_time;
	 where exposure_time > 365;
	title "exposure_time";
 	output out=quantile_exposure median=Q50 Q1=Q25 Q3=Q75;
run;


* 2) exposure_time > 548 (1.5y) ;




* 6-1. histogram;
* 1) plot histogram;

ods graphics on;
proc sgplot data=mj.glp1_user_all_exposure_time;
	histogram exposure_time / binstart=50 binwidth=100;
	density exposure_time / type=Normal;
 	density exposure_time / type=Kernel;
	xaxis label="Exposure Time";
    	yaxis label="Frequency";
    	title "Histogram of Exposure Time with Density Plots";
run;

/**************************************************/**************************************************
* 6-2. boxplot;
* 1) Create Binned Variable - quantiles - for Precise Matching;

/**************************************************
* new table: mj.glp1_user_all_exposure_time_ranked
* original table: mj.glp1_user_all_exposure_time
* description: keep only distinct exposure time by patient
**************************************************/

proc rank data=mj.glp1_user_all_exposure_time out=mj.glp1_user_all_exposure_time_r groups=5;
    var exposure_time;  /* Variable to be binned */
    ranks quantile;     /* New variable to hold quantile information */
run;

proc freq data=mj.glp1_user_all_exposure_time_r;
    tables quantile;
run;

proc means data=mj.glp1_user_all_exposure_time_ranked;
    class quantile;
    var exposure_time;
run;






















