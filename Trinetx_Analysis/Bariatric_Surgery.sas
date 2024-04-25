/****************************************************************************
| Program name : identify bariatric surgery patients
| Date (update): 
| Project name : Trinetx - data analysis
| Purpose      : 
****************************************************************************/

* 0. explore original dataset;

proc print data=tx5p.procedure (obs=40);
    title "tx5p.procedure";
run;
proc contents data=tx5p.procedure;
    title "tx5p.procedure";
run;

* 01. list up all of the value of code_system;

/**************************************************
* new table: mj.procedure_5p_codelist
* original table: tx5p.procedure
* description: select "all" glp1_users from tx5p.procedure
**************************************************/

proc sql;
  create table mj.procedure_5p_codelist as
  select distinct code_system
  from tx.procedure; 
quit; 
proc print data=mj.procedure_5p_codelist; 
  title "mj.procedure_5p_codelist";
run;

* 2. select "all" bariatric_surgery(bs)_users;

/**************************************************
* new table: mj.bs_user_all
* original table: tx5p.procedure
* description: select "all" bariatric_surgery(bs)_users from tx5p.procedure
**************************************************/

* 2-1. make the "mj.bs_user_all" table;

data mj.bs_user_all;
  set tx5p.procedure;
  where code in ("43772", "43865", "43850", "43855", "43771", "43773", "43860", "43848", "43774", "43887", "43886", "44.97", "44.96", "44.5");
run;                                                          /* 484 obs */
              
proc print data=mj.bs_user_all (obs=30);
  title "mj.bs_user_all";
run;

* 2-2. sort by patient_id to see individual's glp1 medication history;

proc sort data = mj.bs_user_all;
  by patient_id;
proc print data = mj.bs_user_all (obs=30);
run;













