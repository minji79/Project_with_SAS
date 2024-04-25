
/****************************************************************************
| Program name : make the table 1
| Date (update): 
| Project name : Trinetx - data analysis
| Purpose      : 
****************************************************************************/

* 1. see the demograph data;

proc print data=tx5p.patient (obs=40);
    title "tx5p.patient";
run;
proc contents data=tx5p.patient;
    title "tx5p.patient";
run;


proc print data=tx5p.patient_cohort (obs=40);
    title "tx5p.patient_cohort";
run;
proc contents data=tx5p.patient_cohort;
    title "tx5p.patient_cohort";
run;


proc print data=tx5p.genomic (obs=40);
    title "tx5p.genomic";
run;
proc contents data=tx5p.genomic;
    title "tx5p.genomic";
run;

************ glp1 users ************

* 2. distinct value of glp1 users;

/**************************************************
* new table: mj.glp1_user_uniq_list
* original table: mj.glp1_user_all
* description: distinct value of glp1 users
**************************************************/

proc sql;
  create table mj.glp1_user_uniq_list as
  select distinct patient_id
  from mj.glp1_user_all;
run;          /* 54277 obs */

proc print data=mj.glp1_user_uniq_list (obs=30);
  title "mj.glp1_user_uniq_list";
run;

* 3. do mapping mj.glp1_user_demo with tx5p.patient by patient.id;

/**************************************************
* new table: mj.glp1_user_demo
* original table: mj.glp1_user_uniq_list + tx5p.patient
* description: left join mj.glp1_user_uniq_list & tx5p.patient
**************************************************/

proc sql;
  create table mj.glp1_user_demo as
  select distinct a.patient_id, b.*
  from mj.glp1_user_uniq_list a join tx5p.patient b 
  on a.patient_id=b.patient_id;
quit;                    /* 54277 obs */

proc print data=mj.glp1_user_demo (obs = 30);
	title "mj.glp1_user_demo";
run;

* 4. to convert 'year_of_birth' to 'age', change the format of the 'year_of_birth';

data mj.glp1_user_demo;
  set mj.glp1_user_demo;
  year_of_birth_num = input(year_of_birth, 4.);
  age = 2024 - year_of_birth_num;
run;
proc print data=mj.glp1_user_demo (obs = 30);
	title "mj.glp1_user_demo";
run;



************ BS users ************

* 5. distinct value of BS users;

/**************************************************
* new table: mj.bs_user_uniq_list
* original table: mj.bs_user_all
* description: distinct value of bs users;
**************************************************/

proc sql;
  create table mj.bs_user_uniq_list as
  select distinct patient_id
  from mj.bs_user_all;
run;          /* 268 obs */

proc print data=mj.bs_user_uniq_list (obs=30);
  title "mj.bs_user_uniq_list";
run;

* 6. do mapping mj.bs_user_demo with tx5p.patient by patient.id;

/**************************************************
* new table: mj.bs_user_demo
* original table: mj.bs_user_uniq_list + tx5p.patient
* description: left join mj.bs_user_uniq_list & tx5p.patient
**************************************************/

proc sql;
  create table mj.bs_user_demo as
  select distinct a.patient_id, b.*
  from mj.bs_user_uniq_list a join tx5p.patient b 
  on a.patient_id=b.patient_id;
quit;                    /* 268 obs */

proc print data=mj.bs_user_demo (obs = 30);
	title "mj.bs_user_demo";
run;

* 7. to convert 'year_of_birth' to 'age', change the format of the 'year_of_birth';

data mj.bs_user_demo;
  set mj.bs_user_demo;
  year_of_birth_num = input(year_of_birth, 4.);
  age = 2024 - year_of_birth_num;
run;
proc print data=mj.bs_user_demo (obs = 30);
	title "mj.bs_user_demo";
run;


************ make into one file ************

* 8. make indicator variables for each users;

data mj.glp1_user_demo;
  set mj.glp1_user_demo;
  glp1 = 1;
run;

data mj.bs_user_demo;
  set mj.bs_user_demo;
  bs = 1;
run;

* 9. join;

data mj.glp1_bs_user_demo;
  set mj.glp1_user_demo mj.bs_user_demo;
run;            /* 54545 obs */ 

proc sort data=mj.glp1_bs_user_demo;
  by patient_id;
run;

* 10. delete duplicated observations;

proc sort data=mj.glp1_bs_user_demo out=mj.glp1_bs_user_demo nodupkey;
    by patient_id; 
run;             /* 54461 obs -> 84 obs took both surgery and glp1 */

proc print data= mj.glp1_bs_user_demo (obs=30);
  title "mj.glp1_bs_user_demo";
run;



















