
/****************************************************************************
| Project name : Thesis - BS and GLP1
| Date (update): June 2024
| Task Purpose : listup code for key outcome measurements with 100% data set
| Main dataset : (1) Medication_ingredient, (2) Medication_drug
****************************************************************************/

/****************************************************************************
| Project name : Thesis - BS and GLP1
| Date (update): June 2024
| Task Purpose : 
|      1. listup code for key outcome measurements with 100% data set
|                 GLP1, ...
|      2. GLP1 time series analysis
|      3. specify individuals who have switching within glp1 (semaglutide)
| Main dataset : (1) Medication_ingredient, (2) Medication_drug (= (1) + quantity_dispensed + days_supply
****************************************************************************/

/* 

issue: 
1. encounter # 가 뭐지?
2. cannot check the missing value to check that the two variables were added properly

*/

* 0. explore original dataset;

proc print data=tx.medication_ingredient (obs=40);
    title "tx.medication_ingredient";
run;
proc contents data=tx.medication_ingredient;
    title "tx.medication_ingredient";
run;

proc print data=tx.medication_drug (obs=40);
    title "tx.medication_drug";
run;
proc contents data=tx.medication_drug;
    title "tx.medication_drug";
run;

/**************************************************
* new dataset: m.medication_ing_codelist
* original dataset: tx.medication_ingredient
* description: listup distinct value of the code_system variable
**************************************************/

/**************************************************
* new dataset: m.medication_drug_codelist
* original dataset: tx.medication_drug
* description: listup distinct value of the code_system variable
**************************************************/

* 0. check code_system to have distinct value of the code_system variable;

proc sql;
  create table m.medication_ing_codelist as
  select distinct code_system
  from tx.medication_ingredient; 
quit; 
proc print data=m.medication_ing_codelist; run;    /* 1 obs - only RxNorm */

proc sql;
  create table m.medication_drug_codelist as
  select distinct code_system
  from tx.medication_drug;
quit;                           /* 2 obs - only RxNorm */
proc print data=m.medication_drug_codelist; run;

/*

code system: 
RxNorm
NCD

*/


* 1. explore dataset to select glp1_users;

/*
only for obesity:
Semaglutide [1991302]
Liraglutide [475968]
Tirzepatide [2601723]
*/

* 1-1. Semaglutide [1991302];
proc print data=tx.medication_ingredient (obs=30);
    where code = "1991302";
    title "tx.medication_ingredient_Semaglutide";
run;

* 1-2. Dulaglutide [1551291];
proc print data=tx.medication_ingredient (obs=30);
    where code = "1551291";
    title "tx.medication_ingredient_Dulaglutide";
run;

* 1-3. Liraglutide [475968];
proc print data=tx.medication_ingredient (obs=30);
    where code = "475968";
    title "tx.medication_ingredient_Liraglutide";
run;

* 1-4. Exenatide [60548];
proc print data=tx.medication_ingredient (obs=30);
    where code = "60548";
    title "tx.medication_ingredient_Exenatide";
run;

* 1-5. Lixisenatide [1440051];
proc print data=tx.medication_ingredient (obs=30);
    where code = "1440051";
    title "tx.medication_ingredient_Lixisenatide";
run;

* 1-6. Tirzepatide [2601723];
proc print data=tx.medication_ingredient (obs=30);
    where code = "2601723";
    title "tx.medication_ingredient_Tirzepatide";
run;


* 2. select "all" glp1_users;

/**************************************************
* new table: min.glp1_user_all
* original table: tx.medication_ingredient
* description: select "all" glp1_users from tx.medication_ingredient
**************************************************/

* 2-1. make the data table;

data min.glp1_user_all;
  set tx.medication_ingredient;
  where code in ("1991302", "1551291", "475968", "60548", "1440051", "2601723");
  if code = "1991302" then Molecule = "Semaglutide";
  else if code = "1551291" then Molecule = "Dulaglutide";
  else if code = "475968" then Molecule = "Liraglutide";
  else if code = "60548" then Molecule = "Exenatide";
  else if code = "1440051" then Molecule = "Lixisenatide";
  else if code = "2601723" then Molecule = "Tirzepatide";
run;                                                          /* 17,280,539 obs */

proc print data=min.glp1_user_all (obs=30);
  title "min.glp1_user_all";
run;

* 2-2. sort by patient_id start_date Molecule to see individual's glp1 medication history;

proc sort data = min.glp1_user_all;
  by patient_id start_date Molecule;
run;
proc print data = min.glp1_user_all (obs=30);
run;

* 2-3. add 'indication' var + see the distribution of the indication;

data min.glp1_user_all;
  set min.glp1_user_all;
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
proc print data=min.glp1_user_all (obs=30);
  title "min.glp1_user_all with indication";
run;

proc freq data=min.glp1_user_all;
  table Indication;
run;


* 3. add variable named 'Initiation_date' to indicate 'GLP1 initiation date by type of GLP1';

/**************************************************
* new table: min.glp1_user_all_initiation_date
* original table: min.glp1_user_all
* description: add variable named 'Initiation_date' to indicate 'GLP1 initiation date by type of GLP1'
**************************************************/

proc sql;
	create table min.glp1_user_all_initiation_date as
	select patient_id, min(start_date) as Initiation_date
	from min.glp1_user_all
	group by patient_id;
quit;
proc print data=min.glp1_user_all_initiation_date (obs=30);
	title "min.glp1_user_all_initiation_date";
run;


* 4. do mapping Initiation_date with 'm.glp1_user_all' table by patient.id;

/**************************************************
* new table: min.glp1_user_all_date
* original table: min.glp1_user_all + min.glp1_user_all_initiation_date
* description: left join min.glp1_user_all & min.glp1_user_all_initiation_date
**************************************************/

proc sql;
  create table min.glp1_user_all_date as
  select distinct a.*, b.Initiation_date
  from min.glp1_user_all a left join min.glp1_user_all_initiation_date b 
  on a.patient_id=b.patient_id;
quit;

proc sort data=min.glp1_user_all_date;
	by patient_id start_date;
run;                    /* 17,280,539 obs */

proc print data=min.glp1_user_all_date (obs=30) label;
	var patient_id Initiation_date start_date Molecule brand strength Indication;
	label start_date = "Date";
	title "min.glp1_user_all_date";
run;


* 5. format date;

data min.glp1_user_all_date;
	set min.glp1_user_all_date;
	start_date_num = input(start_date, yymmdd8.);
	Initiation_date_num = input(Initiation_date, yymmdd8.);
	format start_date_num Initiation_date_num yymmdd10.;
	drop start_date Initiation_date;
    rename start_date_num=start_date Initiation_date_num=Initiation_date;
run;

proc contents data = min.glp1_user_all_date;
	title "min.glp1_user_all_date";
run;

proc print data = min.glp1_user_all_date (obs = 30) label;
  label start_date = "Date";
	title "min.glp1_user_all_date";
run;


* 6. calculate the gap between Initiation_date and date;

data min.glp1_user_all_date;
	set min.glp1_user_all_date;
	gap = start_date - Initiation_date;
run;

proc print data = min.glp1_user_all_date (obs = 30) label;
  var patient_id Initiation_date start_date Molecule strength gap;
  label start_date = "Date"
  gap = "Date gap";
	title "min.glp1_user_all_date";
run;


* 7. make time series table;

/**************************************************
* new dataset: min.glp1_user_all_time_series
* original dataset: min.glp1_user_all_date
* description: time series table
**************************************************/

data min.glp1_user_all_time_series;
	set min.glp1_user_all_date;
	array months[37] m0-m36;    
	do i = 1 to 37;            
        	months[i] = .;
   	end;
	if gap >= 0 then do;      
	idx = floor(gap / 30); 
        if idx <= 36 then months[idx+1] = 1; 
   	end;
	drop i idx;
run;                   /* 17,280,539 obs */

proc print data = min.glp1_user_all_time_series (obs = 30) label;
  var patient_id Initiation_date start_date unique_id Molecule strength gap m0-m36;
  label start_date = "Date"
  gap = "Date gap";
  title "min.glp1_user_all_time_series";
run;


* 8. link the medication_drug file to the 

/**************************************************
* new dataset: min.glp1_user_all_merge
* original dataset: min.glp1_user_all + tx.medication_drug
* description: by merging min.glp1_user_all & tx.medication_drug, add 'quantity_dispensed' and 'days_supply' variables to the glp1 user data set
**************************************************/

proc sql;
  create table min.glp1_user_all_merge as
  select distinct a.*, b.quantity_dispensed, b.days_supply
  from min.glp1_user_all a left join tx.medication_drug b 
  on a.unique_id=b.unique_id;
quit;  

proc print data=min.glp1_user_all_merge (obs = 40);
	title "min.glp1_user_all_merge";
run;


* check the missing value to check that the two variables were added properly ;  /* it doesn;t work */

data min.glp1_user_all_merge;
  set min.glp1_user_all_merge;
  num_value = input(value, 8.);
run; 

data min.glp1_user_all_merge;
	set min.glp1_user_all_merge;
	quantity_dispensed_num = input(quantity_dispensed, $12.);
	days_supply_num = input(days_supply, $5.);
	format quantity_dispensed_num days_supply_num 8.;
	drop quantity_dispensed days_supply;
    rename quantity_dispensed_num=quantity_dispensed days_supply_num=days_supply;
run;
proc contents data = min.glp1_user_all_merge;
	title "min.glp1_user_all_merge";
run;

proc means data=min.glp1_user_all_merge N NMISS;
    var quantity_dispensed days_supply;
run;


* 9. select switching case;

/**************************************************
* new dataset: min.glp1_user_swt
* original dataset: min.glp1_user_all
* description: select the individuals who swicting
**************************************************/

* 8.1. make the copy of glp1_users_all with only two variables;

proc sql;
    create table min.glp1_user_swt as
    select patient_id, code, start_date /* Include the date variable */
    from min.glp1_user_all
    order by patient_id, start_date; /* Sort by patient_id and date */
quit;        /* 17,280,539 obs */

proc sql;
    create table min.glp1_user_swt as
    select patient_id, code
    from min.glp1_user_all
quit;

proc sql;
    create table min.glp1_user_swt as
    select patient_id, code
    from min.glp1_user_all
    group by patient_id;
quit;                          /* 17,280,539 obs */
proc print data=min.glp1_user_swt (obs=30); 
	title "min.glp1_user_swt";
run;

* 8.2. need to check with example of individuals ("#A#4", "#A#BC", "#A#GB");
* check the order of the rows reflected real prescription date;

proc print data=min.glp1_user_all (obs = 30); 
    where patient_id in ('#A#4', '#A#BC', '#A#GB');
    title "example of '#A#4', '#A#BC', '#A#GB'";
run;

* 8.3. Remove the duplication - the total number of distinct glp1 users;

proc sort data=min.glp1_user_swt nodupkey out=min.glp1_user_swt;
    by _all_;
run;

proc sql;
    create table min.glp1_user_swt as
    select patient_id code;
    from min.glp1_user_swt
    group by patient_id
    having count(distinct code) > 1;
quit;


/*
the total of ** individuals 


*/














