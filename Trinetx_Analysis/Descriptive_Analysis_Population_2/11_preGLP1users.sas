

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

/*
among pre-surgery GLP-1 users (n=5609),
reinitiator = 2140 (38.2%)
*/


/************************************************************************************
	 3. pre-surgery glp1users -> comorbidities
************************************************************************************/

proc sql;
    create table min.before_glp1users_comorbidity as 
    select a.patient_id, 
           b.*  /* Select all columns from table b */
    from min.before_glp1users as a 
    left join tx.diagnosis as b
    on a.patient_id = b.patient_id;
quit;  /* 5491832 obs */

data min.before_glp1users_v01;
    set min.before_glp1users_comorbidity;
    format cc_t2db cc_obs cc_htn cc_dyslip cc_osa cc_cad cc_hf cc_af cc_asthma 
           cc_liver cc_ckd cc_pos cc_infertility cc_gerd 8.;

    /* Initialize variables for each patient (first record) */
    by patient_id; 
    if first.patient_id then do;
        cc_t2db = 0;
        cc_obs = 0;
        cc_htn = 0;
        cc_dyslip = 0;
        cc_osa = 0;
        cc_cad = 0;
        cc_hf = 0;
        cc_af = 0;
        cc_asthma = 0;
        cc_liver = 0;
        cc_ckd = 0;
        cc_pos = 0;
        cc_infertility = 0;
        cc_gerd = 0;
    end;

    /* Check for conditions and set flags */
    if code in ('E11', 'E11.0', 'E11.1', 'E11.2', 'E11.3', 'E11.4', 'E11.5', 'E11.6', 'E11.7', 'E11.8', 'E11.9', '250.00', '250.02') then do;
        cc_t2db = 1;
    end;
    else if code in ('E66', 'E66.0', 'E66.1', 'E66.2', 'E66.3', 'E66.8', 'E66.9', '278.0', "Z68.35", "Z68.36", "Z68.37", "Z68.38", "Z68.39", "Z68.41") then do;
        cc_obs = 1;
        
    end;
    else if code in ('I10', '401.1', '401.9') then do;
        cc_htn = 1;
        
    end;
    else if code in ('E78.4', 'E78.5', 'E78.81', 'E11.618', '272') then do;
        cc_dyslip = 1;
        
    end;
    else if code in ('G47.33', '327.23') then do;
        cc_osa = 1;
       
    end;
    else if code in ('I25', '414') then do;
        cc_cad = 1;
       
    end;
    else if code in ('I50', 'I50.1', 'I50.9', '428') then do;
        cc_hf = 1;
        
    end;
    else if code in ('I48', '427.3') then do;
        cc_af = 1;
       
    end;
    else if code in ('J45', '493') then do;
        cc_asthma = 1;
       
    end;
    else if code in ('K76.0', 'K75.81', '571.8') then do;
        cc_liver = 1;
        
    end;
    else if code in ('N18', '585') then do;
        cc_ckd = 1;
       
    end;
    else if code in ('E28.2', '256.4') then do;
        cc_pos = 1;
        
    end;
    else if code in ('N97', 'N46.0', 'N46.1', 'N46.8', '628', '606') then do;
        cc_infertility = 1;
        
    end;
    else if code in ('K21', '530.81') then do;
        cc_gerd = 1;
        
    end;
run;  /* 5491832 obs */

* convert date format ;
data min.before_glp1users_v01;
	set min.before_glp1users_v01;
 	date_num = input(date, yymmdd8.);
  	format date_num yymmdd10.;
 	drop date;
  	rename date_num = como_date;
run;

* Remain comorbidity diagnosed within 1 yr before the surgery;
proc sql;
    create table min.before_glp1users_v02 as 
    select a.*, 
           b.bs_date  
    from min.before_glp1users_v01 as a 
    left join min.before_glp1users as b
    on a.patient_id = b.patient_id;
quit; 

data min.before_glp1users_v02;
   set min.before_glp1users_v02;
   if bs_date - como_date ge 0 and bs_date - como_date le 365;
run;      /* 1210252 obs */

data t2dm;
    set min.before_glp1users_v02(keep=patient_id cc_t2db);
    if cc_t2db = 1;
run;  /* 59788 obs */ 

proc sort data=t2dm nodupkey out=t2dm;
    by patient_id;
run; /* 4145 obs */


