
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 02_Cohort_dertivation
| Date (update): June 2024
| Task Purpose : 
|      1. All glp1 users (regardless of BS history) (N = 1,088,256)
|      2. Among BS users, identify glp1 users     (among N = 42,535, glp1 users = 9,410)
|      3. Indicate the timing of glp1 use compared with the bs_date
|      4. [additional analysis] Specify individuals who have switching within glp1 (semaglutide)
|      5. [additional analysis] GLP1 time series analysis
| Main dataset : (1) min.bs_user_all_v07, (2) tx.medication_ingredient, (3) tx.medication_drug (adding quantity_dispensed + days_supply)
************************************************************************************/


/**************************************************
              Variable Definition
* table: min.bs_glp1_user_v03
* temporality
*       0  : no glp1_user   (n = 33125)
*       1  : take glp1 before BS   (n = 4151)
*       2  : take glp1 after BS    (n = 5259)
**************************************************/


/************************************************************************************
	STEP 1. All Glp1 users (regardless of BS history, age, index date)      N = 1,088,256
************************************************************************************/

* 0.0. explore original dataset;

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
*              m.medication_drug_codelist
* original dataset: tx.medication_ingredient
* description: listup distinct value of the code_system variable
**************************************************/


* 1.0. check code_system to have distinct value of the code_system variable;

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
quit;                           /* 2 obs - NCD and RxNorm */
proc print data=m.medication_drug_codelist; run;

/*
	medication_ingredient | code system | RxNorm
	medication_drug | code system | RxNorm & NCD
*/


* 1.1. explore dataset to select glp1_users;

/*
glp1 only for obesity:
	Semaglutide [1991302]
	Liraglutide [475968]
	Tirzepatide [2601723]
*/

* 1) Semaglutide [1991302];
proc print data=tx.medication_ingredient (obs=30);
    where code = "1991302";
    title "tx.medication_ingredient_Semaglutide";
run;

* 2) Dulaglutide [1551291];
proc print data=tx.medication_ingredient (obs=30);
    where code = "1551291";
    title "tx.medication_ingredient_Dulaglutide";
run;

* 3) Liraglutide [475968];
proc print data=tx.medication_ingredient (obs=30);
    where code = "475968";
    title "tx.medication_ingredient_Liraglutide";
run;

* 4) Exenatide [60548];
proc print data=tx.medication_ingredient (obs=30);
    where code = "60548";
    title "tx.medication_ingredient_Exenatide";
run;

* 5) Lixisenatide [1440051];
proc print data=tx.medication_ingredient (obs=30);
    where code = "1440051";
    title "tx.medication_ingredient_Lixisenatide";
run;

* 6) Tirzepatide [2601723];
proc print data=tx.medication_ingredient (obs=30);
    where code = "2601723";
    title "tx.medication_ingredient_Tirzepatide";
run;


* 1.2. select "all" glp1_users;
*      sort by patient_id start_date Molecule to see individual's glp1 medication history;

/**************************************************
* new table: min.glp1_user_all
* original table: tx.medication_ingredient
* description: select "all" glp1_users from tx.medication_ingredient
**************************************************/

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

proc sort data = min.glp1_user_all;
  by patient_id start_date Molecule;
run;
proc print data = min.glp1_user_all (obs=30);
run;


* 1.3. add 'indication' var + see the distribution of the indication;

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


* 1.4. add variable named 'Initiation_date' to indicate 'GLP1 initiation date by type of GLP1';

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


* 1.5. do mapping Initiation_date with 'min.glp1_user_all' table by patient.id;

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


* 1.6. format date;

data min.glp1_user_all_date_v01;
	set min.glp1_user_all_date;
	start_date_num = input(start_date, yymmdd8.);
	Initiation_date_num = input(Initiation_date, yymmdd8.);
	format start_date_num Initiation_date_num yymmdd10.;
	drop start_date Initiation_date;
    rename start_date_num = glp1_date Initiation_date_num = glp1_initiation_date;
run;


* 1.7. calculate the gap between Initiation_date and date;

data min.glp1_user_all_date_v01;
	set min.glp1_user_all_date_v01;
	glp1_gap = glp1_date - glp1_initiation_date;
run;

proc print data = min.glp1_user_all_date_v01 (obs = 30) label;
	title "min.glp1_user_all_date_v01";
run;

* 1.8. calculate the total number of glp1 users;

proc sql;
	select count(distinct patient_id) as distinct_patient_count
 	from min.glp1_user_all_date_v01;
quit;          /* 1,088,256 distinct glp1 users */



/************************************************************************************
	STEP 2. Among BS users, identify glp1 users       N = 9,410
************************************************************************************/

* 2.0. before merging, make indicator variables for glp1 users;

data min.glp1_user_all_date_v01;
	set min.glp1_user_all_date_v01;
	glp1_user = 1;
run;             /* 17,280,539 obs */

proc print data = min.glp1_user_all_date_v01 (obs = 30);
	title "min.glp1_user_all_date_v01";
run;


* 2.1. merge 'bs_users table' and 'glp1_users table'; 

/**************************************************
* new table: min.bs_glp1_user_v00
* original table: min.bs_user_all_v07 + min.glp1_user_all_date
* description: Among glp1 users, identify glp1 users - join two tables
**************************************************/

proc SQL;
	create table min.bs_glp1_user_v00 as
 	select distinct a.*, b.*
	from min.bs_user_all_v07 as a left join min.glp1_user_all_date_v01 as b 
	on a.patient_id=b.patient_id;
quit;       /* 177,022 obs */

* 2.2. fill '0' in glp1_user cells with null values for further analysis;

data min.bs_glp1_user_v00;
    set min.bs_glp1_user_v00;
        if missing(glp1_user) then glp1_user = '0';
run;

* 2.3. count the population number;

proc sql;
	select count(distinct patient_id) as distinct_patient_count
 	from min.bs_glp1_user_v00;
quit;           /* it should be the same as "42,535 - BS users" - yes, it is! */

proc sql;
    select count(distinct patient_id) as distinct_patient_count
    from min.bs_glp1_user_v00
    where glp1_user = 1;
quit;           /* 9,410 obs = glp1 users among BS users */

proc print data=min.bs_glp1_user_v00 (obs=30);
	title "min.bs_glp1_user_v00";
	where glp1_user = 1;
run;

proc contents data=min.bs_glp1_user_v00;
	title "min.bs_glp1_user_v00";
run;


/************************************************************************************
	STEP 3. Indicate the timing order of glp1 use compared with the bs_date  
************************************************************************************/

* 3.1. calculate gap between glp1_initiation_date and the bs_date;

/**************************************************
* new table: min.bs_glp1_user_v02
*            min.bs_glp1_user_v01
* original table: min.bs_glp1_user_v00
* description: calculate gap between glp1_initiation_date and the bs_date;
**************************************************/

/**************************************************
              Variable Definition
* table: min.bs_glp1_user_v01
* temporality
*       0  : no glp1_user
*       1  : take glp1 before BS
*       2  : take glp1 after BS 
**************************************************/

data min.bs_glp1_user_v01;
	set min.bs_glp1_user_v00;
	gap_glp1_bs = glp1_initiation_date - bs_date;
run;      /* 177022 obs */

proc print data=min.bs_glp1_user_v01 (obs = 30);
	var patient_id glp1_user bs_date glp1_initiation_date glp1_date gap_glp1_bs;
 	where glp1_user = 0;
  	title "min.bs_glp1_user_v01";
run;

data min.bs_glp1_user_v02;
	set min.bs_glp1_user_v01;
 
    if glp1_user = 0 then do;
      temporality = 0;
    end;
    else if gap_glp1_bs < 0 then do;
      temporality = 1;
      glp1_before_BS = gap_glp1_bs;
    end;
    else if gap_glp1_bs >= 0 then do;
      temporality = 2;
      glp1_after_BS = gap_glp1_bs;
    end;
run;       


* 3.2. make a variable to indicate glp1_expose time (regardless of the discontinuation) ;
*      + Remove duplications (only remain 'the last glp1_date' & removing other glp1_date information;

/**************************************************
* new table: min.bs_glp1_user_v03
* original table: min.bs_glp1_user_v02
* description: make a variable to indicate glp1_expose time (regardless of the discontinuation)
* 			 + Remove duplications (only remain 'the last glp1_date' & removing other glp1_date information
**************************************************/

/* to see the duplication case : patient_id = 5A#p */
proc print data=min.bs_glp1_user_v02 (obs=30);
  	title "min.bs_glp1_user_v02_5A#p";
   	where patient_id = '5A#p';
run;

proc sort data = min.bs_glp1_user_v02;
	by patient_id glp1_date;
run;

data min.bs_glp1_user_v03;
	set min.bs_glp1_user_v02;
 	by patient_id;
  	glp1_expose_period = first(glp1_date) - last(glp1_date);
run;

data min.bs_glp1_user_v03;
    set min.bs_glp1_user_v02;
    by patient_id;

    retain first_glp1_date last_glp1_date;
    
    if first.patient_id then do;
        first_glp1_date = glp1_date;
        last_glp1_date = glp1_date;
    end;
    else last_glp1_date = glp1_date;

    if last.patient_id then do;
        glp1_expose_period = last_glp1_date - first_glp1_date;
        output;
    end;
    drop first_glp1_date last_glp1_date;
run;       /* 42535 obs */


proc print data=min.bs_glp1_user_v03 (obs=20);
  	title "min.bs_glp1_user_v03";
   	where glp1_user = 1 & patient_id = '5A#p';
run;

proc sql;
	select count(distinct patient_id) as distinct_patient_count
 	from min.bs_glp1_user_v03;
quit;      /* 42535 obs */


* 3.3. frequency distribution of glp1_user;

proc freq data=min.bs_glp1_user_v03;
	table temporality;
run;

/**************************************************
              Variable Definition
* table: min.bs_glp1_user_v03
* temporality
*       0  : no glp1_user   (n = 33125)
*       1  : take glp1 before BS   (n = 4151)
*       2  : take glp1 after BS    (n = 5259)
**************************************************/



/************************************************************************************
	STEP 4. [additional analysis] Among glp1 user, specify individuals who have switching within glp1 (semaglutide) 
************************************************************************************/

/**************************************************
* new dataset: min.glp1_user_swt
* original dataset: min.glp1_user_all
* description: select the individuals switching medication within glp1
**************************************************/

* 9.1. make the copy of glp1_users_all with only two variables;

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

* 9.2. need to check with example of individuals ("#A#4", "#A#BC", "#A#GB");
* check the order of the rows reflected real prescription date;

proc print data=min.glp1_user_all (obs = 30); 
    where patient_id in ('#A#4', '#A#BC', '#A#GB');
    title "example of '#A#4', '#A#BC', '#A#GB'";
run;


* 9.3. Remove the duplication rows - but still have all of drug's code that indiv have;

proc sort data=min.glp1_user_swt nodupkey out=min.glp1_user_swt;
    by _all_;
proc print data=min.glp1_user_swt (obs=30); 
	title "min.glp1_user_swt";
run;                            /* remove the duplicated rows - but still have all of drug that indiv have */

* 9.4. select the individuals switching medication within glp1 - with codes;

/**************************************************
* new dataset: min.glp1_user_swt_v01
* original dataset: min.glp1_user_swt
* description: select the individuals switching medication within glp1
*		var: patient_id, code, drug_count
**************************************************/

proc sql;
    create table min.glp1_user_swt_v01 as
    select patient_id, code, count(distinct code) as drug_count
    from min.glp1_user_swt
    group by patient_id
    having drug_count > 1;
quit;              /* 533,896 obs : including duplications - not distinct  */

proc print data=min.glp1_user_swt_v01 (obs=30); 
	title "min.glp1_user_swt_v01";
run;   


* 9.5. select the "distinct" individuals switching medication within glp1 - without codes;

/**************************************************
* new dataset: min.glp1_user_swt_v02
* original dataset: min.glp1_user_swt_v01
* description: select the individuals switching medication within glp1
*		count "distinct" number of switching individuals
*		discriptive analysis of the number of switching
*		var: patient_id, drug_count
**************************************************/

data min.glp1_user_swt_v02 (drop = code);
	set min.glp1_user_swt_v01;
proc print data=min.glp1_user_swt_v02 (obs = 30);
	title "min.glp1_user_swt_v02";
run;

proc sort data=min.glp1_user_swt_v02 nodupkey out=min.glp1_user_swt_v02;
    by _all_;
proc print data=min.glp1_user_swt_v02 (obs=30); 
	title "min.glp1_user_swt_v02";
run;                                   /* 239,328 distinct individuals */ 

proc contents data=min.glp1_user_swt_v02;
	title "min.glp1_user_swt_v02";
run; 


/*
the total of 239,328 individuals switched their glp1 to another type of glp1

*/



/************************************************************************************
	STEP 5. [additional analysis] GLP1 time series analysis
************************************************************************************/

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


* 8. link the medication_drug file to the min.glp1_user_all (which is from medication_ingredient);

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














