

/************************************************************************************
	 1. GLP1 use - long dataset  | min.bs_glp1_user_long
************************************************************************************/

* Remove People with death_date < GLP1_initiation_date;
data min.bs_glp1_user_long;
    set min.bs_glp1_user_v01;
    if not missing(death_date) and death_date < glp1_initiation_date then delete;
run;   

* remove RYGB & SG patients;
data min.bs_glp1_user_long;
  set min.bs_glp1_user_long;
  if bs_type in ('sg', 'rygb');
run;   /* 213283 obs */


* how many people used GLP-1s before surgery;
/**************************************************
* new table: min.before_glp1users_long
* description: people used GLP-1s before surgery;
**************************************************/

proc sql;
  create table min.before_glp1users_long as
  select distinct b.*
  from min.before_glp1users a left join min.bs_glp1_user_long b
  on a.patient_id = b.patient_id;
quit;    /* 116701 obs */

proc sql;
	select count(distinct patient_id) as distinct_patient_count
 	from min.before_glp1users_long;
quit;    /* 5609 obs */

* how many pre-surgery GLP-1 users initiated GLP-1s after surgery;
data reinitiator;
  set min.before_glp1users_long;
  by patient_id;
  if bs_date < glp1_date then reinitiator = 1;
  else reinitiator = 0;
run;

data min.reinitiator;
  set reinitiator;
  if reinitiator = 1;
run;    /* 33200 obs -> 2140 individuals */

proc sql;
	select count(distinct patient_id) as distinct_patient_count
 	from min.reinitiator;
quit;  /* 2140 obs */


/************************************************************************************
	 2. GLP1 use - only 1st use | min.before_glp1users
************************************************************************************/

* Remove People with death_date < GLP1_initiation_date ;
data min.bs_glp1_user_v02;
    set min.bs_glp1_user_v02;
    if not missing(death_date) and death_date < glp1_initiation_date then delete;
run;   

* remove RYGB & SG patients;
data min.bs_glp1_user_v02;
  set min.bs_glp1_user_v02;
  if bs_type in ('sg', 'rygb');
run;   /* 40924 obs */

* how many people used GLP-1s before surgery;
/**************************************************
* new table: min.before_glp1users
* description: people used GLP-1s before surgery;
**************************************************/

data min.before_glp1users;
  set min.bs_glp1_user_v02;
  if temporality = 1;
run;  /* 5609 obs */


* indicate reinitiator ;
proc sql;
   create table min.before_glp1users as
   select distinct a.*, b.reinitiator 
   from min.before_glp1users a left join min.reinitiator b
  on a.patient_id = b.patient_id;
quit; /* 5609 obs */

data min.before_glp1users; set min.before_glp1users; if missing(reinitiator) then reinitiator = 0; run;

proc freq data=min.before_glp1users; table reinitiator; run;



proc print data=min.bs_glp1_user_long (obs=30); where temporality = 1; run;




