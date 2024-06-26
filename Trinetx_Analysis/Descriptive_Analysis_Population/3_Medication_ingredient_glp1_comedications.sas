
/****************************************************************************
| Project name : Thesis - BS and GLP1
| Date (update): June 2024
| Task Purpose : listup code for key outcome measurements with 100% data set
| Main dataset : (1) Medication_ingredient, (2) Medication_drug
****************************************************************************/


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
* description:
**************************************************/

/**************************************************
* new dataset: m.medication_drug_codelist
* original dataset: tx.medication_drug
* description:
**************************************************/

* 0. check code_system to have distinct value of the code_system variable;

proc sql;
  create table m.medication_ing_codelist as
  select distinct code_system
  from tx.medication_ingredient; 
quit; 
proc print data=m.medication_ing_codelist; run;

proc sql;
  create table m.medication_drug_codelist as
  select distinct code_system
  from tx.medication_drug;
quit; 
proc print data=m.medication_drug_codelist; run;

/*
code system
: ??
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
* new table: m.glp1_user_all
* original table: tx.medication_ingredient
* description: select "all" glp1_users from tx.medication_ingredient
**************************************************/

* 2-1. make the data table;

data m.glp1_user_all;
  set tx.medication_ingredient;
  where code in ("1991302", "1551291", "475968", "60548", "1440051", "2601723");
  if code = "1991302" then Molecule = "Semaglutide";
  else if code = "1551291" then Molecule = "Dulaglutide";
  else if code = "475968" then Molecule = "Liraglutide";
  else if code = "60548" then Molecule = "Exenatide";
  else if code = "1440051" then Molecule = "Lixisenatide";
  else if code = "2601723" then Molecule = "Tirzepatide";
run;                                                          /* 856261 obs */

proc print data=m.glp1_user_all (obs=30);
  title "m.glp1_user_all";
run;

* 2-2. sort by patient_id start_date Molecule to see individual's glp1 medication history;

proc sort data = m.glp1_user_all;
  by patient_id start_date Molecule;
proc print data = m.glp1_user_all (obs=30);
run;

* 2-3. add 'indication' var + see the distribution of the indication;

data m.glp1_user_all;
  set m.glp1_user_all;
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
proc print data=m.glp1_user_all (obs=30);
  title "m.glp1_user_all with indication";
run;

proc freq data=m.glp1_user_all;
  table Indication;
run;



*****************

* 4. add variable named 'Initiation_date' to indicate 'GLP1 initiation date by type of GLP1';

/**************************************************
* new table: m.glp1_user_all_initiation_date
* original table: m.glp1_user_all
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
