
/****************************************************************************
| Program name : measure outcome (BMI) from time origin
| Date (update): 
| Project name :
| Purpose      : 
****************************************************************************/

* 1. import BS date to the ;

/**************************************************
* new table: mj.bmi_from_timeorigin
* original table: mj.bmi_date
* description: 
*          left join mj.bmi_date & mj.glp1_bs_date_compare_uniq
**************************************************/

proc print data=mj.bmi_date (obs=30);
  title "mj.bmi_date";
run;

proc print data=mj.bmi (obs=30);
  title "mj.bmi";
run;

* 1-1. left join join mj.bmi_date & mj.glp1_bs_date_compare_uniq ;

proc sql;
  create table mj.bmi_from_timeorigin as
  select distinct a.*, b.last_BS_date, b.BS_glp1_combi, b.temporality
  from mj.bmi_date a left join mj.glp1_bs_date_compare_uniq b
  on a.patient_id = b.patient_id;
quit;        /* 3014953 obs */
proc print data=mj.bmi_from_timeorigin (obs=30);
  title "mj.bmi_from_timeorigin";
run;

* 1-2. remain with only study population - who took BS ;

data mj.bmi_from_timeorigin;
    set mj.bmi_from_timeorigin;
    if missing(last_BS_date) then delete; 
run;    /* 6530 obs */

* 1-3. check the number of people;

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.bmi_from_timeorigin;
    title "mj.bmi_from_timeorigin";
quit;    /* 136 obs */

proc print data=mj.bmi_from_timeorigin (obs=30);
  title "mj.bmi_from_timeorigin";
run;

* 1-4. re-check to comfirm that only 136 patients among patient undertaking the BS have BMI values;

proc print data=mj.glp1_bs_date_compare_uniq;
  where last_BS_date is missing;
  title "mj.glp1_bs_date_compare_uniq";
run;  /* 0 obs */


proc sql;
  create table mj.bmi_from_timeorigin_136 as
  select distinct a.*, b.patient_id, b.last_BS_date
  from mj.bmi_date a left join mj.glp1_bs_date_compare_uniq b
  on a.patient_id = b.patient_id;
quit;    /* 3014953 obs */
proc print data=mj.bmi_from_timeorigin_136 (obs=30);
  title "mj.bmi_from_timeorigin_136";
run;


proc sql;
    create table mj.bmi_from_timeorigin_136 as
    select count(distinct text_value) as UniqueIDs
    from mj.bmi_from_timeorigin;
    title "mj.bmi_from_timeorigin";
quit;   

