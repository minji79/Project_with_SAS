
/****************************************************************************
| Program name : Identify study_population
| Date (update): 
| Project name :
| Purpose      : 
****************************************************************************/


* 1. indicate the date of BS;

/**************************************************
* new table: mj.bs_user_all
* original table: mj.bs_user_all
* description: convert the date from characther to numeric
**************************************************/

* 1-1. convert the date from characther to numeric;

data mj.bs_user_all;
	set mj.bs_user_all;
  date_num = input(date,yymmdd8.);
  format date_num yymmdd10.;
  drop date;
  rename data_num = bs_date;
run;                  /* 484 obs */

proc print data=mj.bs_user_all (obs=30);
  title "mj.bs_user_all";
run;

* 2. merge the glp1 initial date with the BS date among individuals with BS;

/**************************************************
* new table: mj.glp1_bs_date_compare
* original table: mj.bs_user_all & mj.glp1_user_all_date
* description: 
**************************************************/

* 2-1. ;

proc sql;
  create table mj.glp1_bs_date_compare as
  select distinct a.*, b.Initiation_date
  from mj.bs_user_all a left join mj.glp1_user_all_date b
  on a.patient_id = b.patient_id;
quit;        /* 371 obs */
proc print data=mj.glp1_bs_date_compare (obs=30);
  title "mj.glp1_bs_date_compare";
run;

* 2-2. check the number of rows & UniqueIDs ;

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.bs_user_all;
    title "mj.bs_user_all";
quit;     /* 268 obs */
proc sql;
    select count(*) as RowCount
    from mj.bs_user_all ;
    title "mj.bs_user_all";
quit;    /* 484 obs */


proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.glp1_user_all_date;
    title "mj.glp1_user_all_date";
quit;   /* 54277 obs */
proc sql;
    select count(*) as RowCount
    from mj.glp1_user_all_date ;
    title "mj.glp1_user_all_date";
quit;    /* 856261 obs */


proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.glp1_bs_date_compare;
    title "mj.glp1_bs_date_compare";
quit;     /* 268 obs */
proc sql;
    select count(*) as RowCount
    from mj.glp1_bs_date_compare ;
    title "mj.glp1_bs_date_compare";
quit;    /* 371 obs */


* 3. deal with the duplicated rows - take BS several times & diff CPT code ;

* 3-1. see the BS duplication;

/**************************************************
* new table: mj.glp1_bs_date_duplication
* original table: mj.glp1_bs_date_compare
* description: see the BS duplication
**************************************************/

proc sql;
    create table mj.glp1_bs_date_duplication as
    select distinct patient_id, encounter_id, code_system, code, principal_procedure_indicator, derived_by_TriNetX, source_id, date_num, Initiation_date, count(*) as count
    from mj.glp1_bs_date_compare
    group by patient_id
    having count > 1;
quit;    /* 168 obs */
proc print data=mj.glp1_bs_date_duplication (obs=40);
  title "mj.glp1_bs_date_duplication";
run;

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.glp1_bs_date_duplication;
    title "mj.glp1_bs_date_duplication";
quit;     /* 65 obs */


* 3-2. remain only the last row among the duplicated rows;

/**************************************************
* new table: work.last_occurrences
* original table: mj.glp1_bs_date_duplication
* description: test
**************************************************/

proc sort data=mj.glp1_bs_date_duplication;
    by patient_id descending date_num; /* Assuming 'date' determines the latest occurrence */
run;
proc print data=mj.glp1_bs_date_duplication (obs=40);
  title "mj.glp1_bs_date_duplication";
run;

data last_occurrences;
    set mj.glp1_bs_date_duplication;
    by patient_id;
    if first.patient_id;
run;    /* 65 obs */

/**************************************************
* new table: mj.glp1_bs_date_compare_uniq
* original table: mj.glp1_bs_date_compare
* description: 
**************************************************/

proc sort data=mj.glp1_bs_date_compare out=mj.glp1_bs_date_compare_sorted;
    by patient_id descending date_num;
run;

data mj.glp1_bs_date_compare_uniq;
    set mj.glp1_bs_date_compare_sorted;
    by patient_id;
    if first.patient_id;
run;    /* 268 obs */

proc print data=mj.glp1_bs_date_compare_uniq (obs=40);
  title "mj.glp1_bs_date_compare_uniq";
run;


* 4. adjust the table;

* 4-1. change the name of the date variable;

data mj.glp1_bs_date_compare_uniq;
    set mj.glp1_bs_date_compare_uniq;
    rename date_num = last_BS_date Initiation_date = glp1_initiation_date;
run;
proc print data=mj.glp1_bs_date_compare_uniq (obs=40);
  title "mj.glp1_bs_date_compare_uniq";
run;


* 4-2. indicate 'BS only' and 'BS + glp1' patients;

data mj.glp1_bs_date_compare_uniq;  
    set mj.glp1_bs_date_compare_uniq;
    if missing(glp1_initiation_date) then
        BS_glp1_combi = 0;
    else
        BS_glp1_combi = 1;
run;
proc print data=mj.glp1_bs_date_compare_uniq (obs=40);
  title "mj.glp1_bs_date_compare_uniq";
run;

proc freq data=mj.glp1_bs_date_compare_uniq;
	table BS_glp1_combi;
	title "mj.glp1_bs_date_compare_uniq";
run;

/* 
BS_glp1_combi = 1 : 84
BS_glp1_combi = 0 : 184
*/

* 4-3. calculate gap between glp1 initial date and the BS date;

/**************************************************
              Variable Definition
* table: mj.glp1_bs_date_compare_uniq
* temporality 
*       0  : take glp1 before BS
*       1  : take glp1 after BS
*       2  : take glp1 during BS   /* 0 obs */
* description: test
**************************************************/


data mj.glp1_bs_date_compare_uniq;
	set mj.glp1_bs_date_compare_uniq;
	gap = glp1_initiation_date - last_BS_date;
run;
proc print data=mj.glp1_bs_date_compare_uniq (obs=40);
  title "mj.glp1_bs_date_compare_uniq";
run;

proc print data=mj.glp1_bs_date_compare_uniq ;
  where gap = 0;
run;

data mj.glp1_bs_date_compare_uniq;
	set mj.glp1_bs_date_compare_uniq;
  if gap > 0 then do;
      temporality = 1;
      glp1_after_BS = gap;
    end;
  else if gap < 0 then do;
      temporality = 0;
      glp1_before_BS = gap;
    end;
run;
proc print data=mj.glp1_bs_date_compare_uniq (obs=40);
  title "mj.glp1_bs_date_compare_uniq";
run;

proc freq data=mj.glp1_bs_date_compare_uniq;
	table temporality;
 	where temporality = 1;
 	title "mj.glp1_bs_date_compare_uniq";
run;

/*
temporality = 0 : 211 (incl. glp1 not users)
temporality = 1 : 57
temporality = 2 : 0

gap >0 : 57
gap <0 : 27

*/

proc means data=mj.glp1_bs_date_compare_uniq n nmiss mean max min ;
	var temporality;
 	where gap >0;
run;

* 5. distribution of the temporality;

* 5-1. glp1 after BS;
proc means data=mj.glp1_bs_date_compare_uniq
	n mean median min max std ;
	var glp1_after_BS;
	title "glp1_after_BS";
run;

proc sgplot data=mj.glp1_bs_date_compare_uniq;
	histogram glp1_after_BS / binstart=1 binwidth=10 scale=count;
	density glp1_after_BS / type=Normal;
	title "glp1_after_BS";
run;


proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 30;
	title "number of glp1 initications within 30 days after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 91.25;
	title "number of glp1 initications within 3 months after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 182.5;
	title "number of glp1 initications within 6 months after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 365;
	title "number of glp1 initications within 1 year after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 365*2;
	title "number of glp1 initications within 2 years after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 365*3;
	title "number of glp1 initications within 3 years after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 365*4;
	title "number of glp1 initications within 4 years after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 365*5;
	title "number of glp1 initications within 5 years after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 365*6;
	title "number of glp1 initications within 6 years after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 365*7;
	title "number of glp1 initications within 7 years after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 365*8;
	title "number of glp1 initications within 8 years after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 365*9;
	title "number of glp1 initications within 9 years after BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_after_BS;
 	where glp1_after_BS < 365*10;
	title "number of glp1 initications within 10 years after BS";
run;


* 5-2. glp1 before BS;

proc means data=mj.glp1_bs_date_compare_uniq
	n mean median min max std ;
	var glp1_before_BS;
	title "glp1_before_BS";
run;

proc sgplot data=mj.glp1_bs_date_compare_uniq;
	histogram glp1_before_BS / binwidth=10 scale=count;
	density glp1_before_BS / type=Normal;
	title "glp1_before_BS";
run;


proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > -30;
	title "number of glp1 initications within 30 days before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 91.25;
	title "number of glp1 initications within 3 months before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 182.5;
	title "number of glp1 initications within 6 months before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365;
	title "number of glp1 initications within 1 year before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*2;
	title "number of glp1 initications within 2 years before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*3;
	title "number of glp1 initications within 3 years before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*4;
	title "number of glp1 initications within 4 years before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*5;
	title "number of glp1 initications within 5 years before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*6;
	title "number of glp1 initications within 6 years before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*7;
	title "number of glp1 initications within 7 years before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*8;
	title "number of glp1 initications within 8 years before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*9;
	title "number of glp1 initications within 9 years before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*10;
	title "number of glp1 initications within 10 years before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*15;
	title "number of glp1 initications within 15 years before BS";
run;

proc means data=mj.glp1_bs_date_compare_uniq
	n ;
	var glp1_before_BS;
 	where glp1_before_BS > - 365*20;
	title "number of glp1 initications within 20 years before BS";
run;



/*****************************/

proc sql;
    create table last_occurrences as
    select *
    from your_dataset
    where id in (
        select id from your_dataset
        group by id
        having count(id) > 1
    )
    and date = (select max(date) from your_dataset as b where b.id = your_dataset.id);
quit;






