
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 01_Cohort_dertication
| Date (update): June 2024
| Task Purpose : 
|      1. 00
|      2. 00
|      3. 00
| Main dataset : (1) procedure (2) Medication_ingredient, (3) Medication_drug
************************************************************************************/


/************************************************************************************
	STEP 1. All Bariatric Surgery(BS) patients	     N = 1,436,930
************************************************************************************/

* 1.0. explore procedure dataset;

proc print data=tx.procedure (obs=40);
    title "tx.procedure";
run;
proc contents data=tx.procedure;
    title "tx.procedure";
run;


* 1.1. list up all of the value of code_system;

/**************************************************
* new table: min.procedure_codelist
* original table: tx.procedure
* description: select "all" BS_users from tx.procedure
**************************************************/

proc sql;
  create table min.procedure_codelist as
  select distinct code_system
  from tx.procedure; 
quit; 
proc print data=min.procedure_codelist; 
  title "min.procedure_codelist";
run;


* 1.2. select "all" bariatric_surgery(bs)_users;

/**************************************************
* new table: min.bs_user_all
* original table: tx.procedure
* description: select "all" BS_users from tx.procedure
**************************************************/


















