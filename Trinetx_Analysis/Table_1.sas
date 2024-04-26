
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

proc sql;
    select count(*) as total_rows
    from mj.glp1_user_demo;
quit;            /* 54277 obs */

proc sql;
    select count(*) as total_rows
    from mj.bs_user_demo;
quit;        /* 268 obs */

* 9. join them and identify the duplicated patients;

/**************************************************
* new table: mj.glp1_bs_user_demo
* original table: mj.glp1_user_demo + mj.bs_user_demo
* description: left join mj.bs_user_uniq_list & tx5p.patient
**************************************************/

data mj.glp1_bs_user_demo;
  set mj.glp1_user_demo mj.bs_user_demo;
run;            /* 54545 obs */ 

proc sql;
    select count(*) as total_rows
    from mj.glp1_bs_user_demo;
quit;        /* 54545 obs */

proc sort data=mj.glp1_bs_user_demo;
	by patient_id;
run;
proc sql;
    select count(*) as total_rows
    from mj.glp1_bs_user_demo;
quit;        /* 54545 obs */

proc print data=mj.glp1_bs_user_demo (obs = 40);
	title "mj.glp1_bs_user_demo";
run;

* 10. Identify Duplicates;

/**************************************************
* new table: mj.glp1_bs_duplicates
* original table: mj.glp1_bs_user_demo
* description: identify duplication
**************************************************/

proc sort data=mj.glp1_bs_user_demo;
	by patient_id;
run;

data mj.glp1_bs_duplicates;
    set mj.glp1_bs_user_demo;
    by patient_id;  /* Again, ensure this matches the sorting variables */

    /* Check if the current row is not the first or last in a group of key variables */
    if not (first.patient_id and last.patient_id) then output;
run;

proc print data=mj.glp1_bs_duplicates (obs = 40);
	title "mj.glp1_bs_duplicates";
run;

proc sql;
    select count(*) as total_rows
    from mj.glp1_bs_duplicates;
quit; 

* 10-1) make their variables all even | glp1 = 1, bs = 1, group = 2 ;

data mj.glp1_bs_duplicates;
	set mj.glp1_bs_duplicates;
 	glp1 = 1;
  	bs = 1;
   	group = 2;
proc print data=mj.glp1_bs_duplicates (obs = 30);
	title "mj.glp1_bs_duplicates";
run;

* 10-2) delete the duplicated observations;

proc sort data=mj.glp1_bs_duplicates nodupkey;
    by patient_id; 
run;            /* 84 obs */

proc print data=mj.glp1_bs_duplicates (obs = 30);
	title "mj.glp1_bs_duplicates";
run;

* 11. remove the duplicated observations;

/**************************************************
* new table: mj.glp1_bs_user_demo_wodup
* original table: mj.glp1_ps_user_demo
* description: remove the duplicated observations and replace them, compare with mj.glp1_bs_duplicates
**************************************************/

proc sort data=mj.glp1_bs_user_demo; by patient_id; run;    
proc sort data=mj.glp1_bs_duplicates; by patient_id; run;

* check the number;
proc sql;
    select count(*) as total_rows
    from mj.glp1_bs_user_demo;
quit;   /* 54545 obs */

proc sql;
    select count(*) as total_rows
    from mj.glp1_bs_duplicates;
quit;      /* 84 obs */

* remove the duplication;

data mj.glp1_bs_user_demo_wodup;
    merge mj.glp1_bs_user_demo (in=a)
          mj.glp1_bs_duplicates (in=b keep=patient_id);
    by patient_id;
    if a and not b;
run;                  /* 54377 obs (=54545 - 84*2) */

* check by using example - it cannot be found;
proc print data = mj.glp1_bs_user_demo_wodup;
	where patient_id = "CAiOG";
run;                     /* no observation was selected */

* 12. replace them by using mj.glp1_bs_duplicates;

/**************************************************
* new table: mj.glp1_bs_user_demo_54461
* original table: mj.glp1_bs_user_demo_wodup + mj.glp1_bs_duplicates
* description: left join mj.glp1_bs_user_demo_wodup & mj.glp1_bs_duplicates
**************************************************/

data mj.glp1_bs_user_demo_54461;
	set mj.glp1_bs_user_demo_wodup mj.glp1_bs_duplicates;
run;       /* 54461 obs */

proc sql;
    select count(*) as total_rows
    from mj.glp1_bs_user_demo_54461;
quit;      /* 54461 obs */








* 12. make the indicate varibale for interventions;

data mj.glp1_bs_user_demo;
	set mj.glp1_bs_user_demo;
 
    /* Create the 'group' variable based on conditions */
    if glp1 = 1 and missing(bs) then group = 1;
    else if bs = 1 and missing(glp1) then group = 0;
    else if glp1 = 1 and bs = 1 then group = 2;
    else group = .; /* Assigning missing value if none of the conditions are met */

run;

proc sql;
    select count(*) as total_rows
    from mj.glp1_bs_user_demo;
quit;        /* 54545 obs */

proc freq data=mj.glp1_bs_user_demo;
    tables group / nocum nopercent norow nocol;
    where group = 2;
run;

proc print data=mj.glp1_bs_user_demo (obs=40);
	title "mj.glp1_bs_user_demo";
run;

proc freq data=mj.glp1_bs_user_demo;
	table group;
run;
	

* 10. delete duplicated observations;

proc sort data=mj.glp1_bs_user_demo out=mj.glp1_bs_user_demo nodupkey;
    by patient_id; 
run;             /* 54461 obs -> 84 obs took both surgery and glp1 */

proc print data= mj.glp1_bs_user_demo (obs=30);
  title "mj.glp1_bs_user_demo";
run;


* 11. make table 1 using R;
















