
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


* 2. calculate gab between BMI measurement date and timeorigin(last BS date) ;

data mj.bmi_from_timeorigin;
    set mj.bmi_from_timeorigin (drop=text_value);
    gap_from_timeorigin = date - last_BS_date;
proc print data=mj.bmi_from_timeorigin (obs=30);
  title "mj.bmi_from_timeorigin";
run;


* 3. set outcome of BMI measurement align with the BS date;

/**************************************************
              Variable Definition
* table: mj.bmi_from_timeorigin
* bmi_before_BS : the BMI value of the closest date from time origin (incl. 0)
* bmi_after_1yr_BS : the BMI value of 
* bmi_after_3yr_BS : the BMI value of 
* description: 
**************************************************/

* 3-1. proc sort by id and BMI measurement date;

proc sort data=mj.bmi_from_timeorigin;
  by patient_id date;
proc print data=mj.bmi_from_timeorigin (obs=30);
  title "mj.bmi_from_timeorigin";
run;

* 3-2. delete rows without BMI values;

proc print data=mj.bmi_date (obs=30);
  where value is missing;
run;     /* total = 105692 missing in bmi value */

proc sql;
    select count(*) as MissingValueCount
    from mj.bmi_from_timeorigin
    where value is missing;
quit;  /* 465 missing in bmi value among 6530 obs */

data mj.bmi_from_timeorigin;
    set mj.bmi_from_timeorigin;
    if missing(value) then delete; 
run;   /* 6065 obs */

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.bmi_from_timeorigin;
    title "mj.bmi_from_timeorigin";
quit;    /* 134 obs (2 individuals have onaly missing values) */


* 3-3. mj.bmi_before_BS ;

/**************************************************
* new table: mj.bmi_before_BS
* original table: mj.bmi_from_timeorigin
* description: 114 unique individuals
*                 use mean of duplicated bmi values by patients
**************************************************/

proc sql;
    create table mj.bmi_before_BS as
    select a.*, a.num_value as bmi_before_BS_initial
    from mj.bmi_from_timeorigin a
    inner join (
        select patient_id, max(gap_from_timeorigin) as max_gap
        from mj.bmi_from_timeorigin
        where gap_from_timeorigin < 0
        group by patient_id
    ) b on a.patient_id = b.patient_id and a.gap_from_timeorigin = b.max_gap;
quit;   /* 152 obs */

proc sql;
    create table mj.bmi_before_BS as
    select *, mean(bmi_before_BS_initial) as bmi_before_BS
    from mj.bmi_before_BS
    group by patient_id;
quit;   /* 152 obs */

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.bmi_before_BS;
    title "mj.bmi_before_BS";
quit;  /* 114 unique individuals */

proc print data=mj.bmi_before_BS (obs=30);
  title "mj.bmi_before_BS";
run;


* 3-4. mj.bmi_after_6m_BS ;

/**************************************************
* new table: mj.bmi_after_6m_BS
* original table: mj.bmi_from_timeorigin
* description: 101 unique individuals
*                 use mean of duplicated bmi values by patients
**************************************************/

proc sql;
    create table mj.bmi_after_6m_BS as
    select a.*, a.num_value as bmi_after_6m_BS_initial
    from mj.bmi_from_timeorigin a
    inner join (
        select patient_id, min(gap_from_timeorigin) as min_gap
        from mj.bmi_from_timeorigin
        where gap_from_timeorigin > 182.5
        group by patient_id
    ) b on a.patient_id = b.patient_id and a.gap_from_timeorigin = b.min_gap;
quit;   /* 114 obs */

proc sql;
    create table mj.bmi_after_6m_BS as
    select *, mean(bmi_after_6m_BS_initial) as bmi_after_6m_BS
    from mj.bmi_after_6m_BS
    group by patient_id;
quit;  

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.bmi_after_6m_BS;
    title "mj.bmi_after_6m_BS";
quit;   /* 101 unique individuals */

proc print data=mj.bmi_after_6m_BS (obs=30);
  title "mj.bmi_after_6m_BS";
run;


* 3-5. mj.bmi_after_1yr_BS ;

/**************************************************
* new table: mj.bmi_after_1yr_BS
* original table: mj.bmi_from_timeorigin
* description: 86 unique individuals
*                 use mean of duplicated bmi values by patients
**************************************************/

proc sql;
    create table mj.bmi_after_1yr_BS as
    select a.*, a.num_value as bmi_after_1yr_BS_initial
    from mj.bmi_from_timeorigin a
    inner join (
        select patient_id, min(gap_from_timeorigin) as min_gap
        from mj.bmi_from_timeorigin
        where gap_from_timeorigin > 365
        group by patient_id
    ) b on a.patient_id = b.patient_id and a.gap_from_timeorigin = b.min_gap;
quit;   /* 99 obs */

proc sql;
    create table mj.bmi_after_1yr_BS as
    select *, mean(bmi_after_1yr_BS_initial) as bmi_after_1yr_BS
    from mj.bmi_after_1yr_BS
    group by patient_id;
quit;  

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.bmi_after_1yr_BS;
    title "mj.bmi_after_1yr_BS";
quit;   /* 86 unique individuals */

proc print data=mj.bmi_after_1yr_BS (obs=30);
  title "mj.bmi_after_1yr_BS";
run;


* 3-6. mj.bmi_after_2yr_BS ;

/**************************************************
* new table: mj.bmi_after_2yr_BS
* original table: mj.bmi_from_timeorigin
* description: 79 unique individuals
*                 use mean of duplicated bmi values by patients
**************************************************/

proc sql;
    create table mj.bmi_after_2yr_BS as
    select a.*, a.num_value as bmi_after_2yr_BS_initial
    from mj.bmi_from_timeorigin a
    inner join (
        select patient_id, min(gap_from_timeorigin) as min_gap
        from mj.bmi_from_timeorigin
        where gap_from_timeorigin > 730
        group by patient_id
    ) b on a.patient_id = b.patient_id and a.gap_from_timeorigin = b.min_gap;
quit;   /* 91 obs */

proc sql;
    create table mj.bmi_after_2yr_BS as
    select *, mean(bmi_after_2yr_BS_initial) as bmi_after_2yr_BS
    from mj.bmi_after_2yr_BS
    group by patient_id;
quit;  

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.bmi_after_2yr_BS;
    title "mj.bmi_after_2yr_BS";
quit;   /* 79 unique individuals */

proc print data=mj.bmi_after_2yr_BS (obs=30);
  title "mj.bmi_after_2yr_BS";
run;


* 3-7. mj.bmi_after_3yr_BS ;

/**************************************************
* new table: mj.bmi_after_3yr_BS
* original table: mj.bmi_from_timeorigin
* description: 70 unique individuals
*                 use mean of duplicated bmi values by patients
**************************************************/

proc sql;
    create table mj.bmi_after_3yr_BS as
    select a.*, a.num_value as bmi_after_3yr_BS_initial
    from mj.bmi_from_timeorigin a
    inner join (
        select patient_id, min(gap_from_timeorigin) as min_gap
        from mj.bmi_from_timeorigin
        where gap_from_timeorigin > 1095
        group by patient_id
    ) b on a.patient_id = b.patient_id and a.gap_from_timeorigin = b.min_gap;
quit;   /* 80 obs */

proc sql;
    create table mj.bmi_after_3yr_BS as
    select *, mean(bmi_after_3yr_BS_initial) as bmi_after_3yr_BS
    from mj.bmi_after_3yr_BS
    group by patient_id;
quit;  

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.bmi_after_3yr_BS;
    title "mj.bmi_after_3yr_BS";
quit;   /* 70 unique individuals */

proc print data=mj.bmi_after_3yr_BS (obs=30);
  title "mj.bmi_after_3yr_BS";
run;


* 3-8. mj.bmi_after_4yr_BS ;

/**************************************************
* new table: mj.bmi_after_4yr_BS
* original table: mj.bmi_from_timeorigin
* description: 61 unique individuals
*                 use mean of duplicated bmi values by patients
**************************************************/

proc sql;
    create table mj.bmi_after_4yr_BS as
    select a.*, a.num_value as bmi_after_4yr_BS_initial
    from mj.bmi_from_timeorigin a
    inner join (
        select patient_id, min(gap_from_timeorigin) as min_gap
        from mj.bmi_from_timeorigin
        where gap_from_timeorigin > 1460
        group by patient_id
    ) b on a.patient_id = b.patient_id and a.gap_from_timeorigin = b.min_gap;
quit;   /* 71 obs */

proc sql;
    create table mj.bmi_after_4yr_BS as
    select *, mean(bmi_after_4yr_BS_initial) as bmi_after_4yr_BS
    from mj.bmi_after_4yr_BS
    group by patient_id;
quit;  

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.bmi_after_4yr_BS;
    title "mj.bmi_after_4yr_BS";
quit;   /* 61 unique individuals */

proc print data=mj.bmi_after_4yr_BS (obs=30);
  title "mj.bmi_after_4yr_BS";
run;

* 3-9. mj.bmi_after_5yr_BS ;

/**************************************************
* new table: mj.bmi_after_5yr_BS
* original table: mj.bmi_from_timeorigin
* description: 48 unique individuals
*                 use mean of duplicated bmi values by patients
**************************************************/

proc sql;
    create table mj.bmi_after_5yr_BS as
    select a.*, a.num_value as bmi_after_5yr_BS_initial
    from mj.bmi_from_timeorigin a
    inner join (
        select patient_id, min(gap_from_timeorigin) as min_gap
        from mj.bmi_from_timeorigin
        where gap_from_timeorigin > 1825
        group by patient_id
    ) b on a.patient_id = b.patient_id and a.gap_from_timeorigin = b.min_gap;
quit;   /* 51 obs */

proc sql;
    create table mj.bmi_after_5yr_BS as
    select *, mean(bmi_after_5yr_BS_initial) as bmi_after_5yr_BS
    from mj.bmi_after_5yr_BS
    group by patient_id;
quit;  

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.bmi_after_5yr_BS;
    title "mj.bmi_after_5yr_BS";
quit;   /* 48 unique individuals */

proc print data=mj.bmi_after_5yr_BS (obs=30);
  title "mj.bmi_after_5yr_BS";
run;


* 4. merge bmi value with study population (268 indiv);

/**************************************************
* new table: mj.study_pop_bmi_outcome
* original table: mj.glp1_bs_date_compare_uniq + 
*          mj.bmi_before_BS
*          mj.bmi_after_6m_BS
*          mj.bmi_after_1yr_BS
*          mj.bmi_after_2yr_BS
*          mj.bmi_after_3yr_BS
*          mj.bmi_after_4yr_BS
*          mj.bmi_after_5yr_BS
* description: 
**************************************************/

* 1-1. left join mj.glp1_bs_date_compare_uniq with bmi value over time from time origin ;

proc sql;
  create table mj.study_pop_bmi_outcome as
  select distinct a.*, b.bmi_before_BS
  from mj.glp1_bs_date_compare_uniq a left join mj.bmi_before_BS b
  on a.patient_id = b.patient_id;
quit;    /* 268 obs */    

proc sql;
  create table mj.study_pop_bmi_outcome as
  select distinct a.*, b.bmi_after_6m_BS
  from mj.study_pop_bmi_outcome a left join mj.bmi_after_6m_BS b
  on a.patient_id = b.patient_id;
quit;  

proc sql;
  create table mj.study_pop_bmi_outcome as
  select distinct a.*, b.bmi_after_1yr_BS
  from mj.study_pop_bmi_outcome a left join mj.bmi_after_1yr_BS b
  on a.patient_id = b.patient_id;
quit;  

proc sql;
  create table mj.study_pop_bmi_outcome as
  select distinct a.*, b.bmi_after_2yr_BS
  from mj.study_pop_bmi_outcome a left join mj.bmi_after_2yr_BS b
  on a.patient_id = b.patient_id;
quit;  

proc sql;
  create table mj.study_pop_bmi_outcome as
  select distinct a.*, b.bmi_after_3yr_BS
  from mj.study_pop_bmi_outcome a left join mj.bmi_after_3yr_BS b
  on a.patient_id = b.patient_id;
quit;  

proc sql;
  create table mj.study_pop_bmi_outcome as
  select distinct a.*, b.bmi_after_4yr_BS
  from mj.study_pop_bmi_outcome a left join mj.bmi_after_4yr_BS b
  on a.patient_id = b.patient_id;
quit;  

proc sql;
  create table mj.study_pop_bmi_outcome as
  select distinct a.*, b.bmi_after_5yr_BS
  from mj.study_pop_bmi_outcome a left join mj.bmi_after_5yr_BS b
  on a.patient_id = b.patient_id;
quit;  

proc print data=mj.study_pop_bmi_outcome (obs=30);
  title "mj.study_pop_bmi_outcome";
run;


* 5. delete the patients without any bmi information ;

/**************************************************
* new table: mj.study_pop_bmi_outcome_cleaned
* original table: mj.study_pop_bmi_outcome
* description: delete the patients without any bmi information
*                 114 unique individuals
**************************************************/

data mj.study_pop_bmi_outcome_cleaned;
  set mj.study_pop_bmi_outcome;
  if missing(bmi_before_BS) then delete;
run;

proc print data=mj.study_pop_bmi_outcome_cleaned (obs =40);
  title "mj.study_pop_bmi_outcome_cleaned";
run;

proc sql;
    select count(distinct patient_id) as UniqueIDs
    from mj.study_pop_bmi_outcome_cleaned;
    title "mj.study_pop_bmi_outcome_cleaned";
quit;   /* 114 unique individuals */

proc sql;
    select count(*) as RowCount
    from mj.study_pop_bmi_outcome_cleaned;
    title "mj.study_pop_bmi_outcome_cleaned";
quit;   /* 114 unique individuals */

* 6. calculate outcome ;

/**************************************************
* new table: mj.study_pop_bmi_outcome_cleaned
* original table: mj.study_pop_bmi_outcome
* description: calculate outcome
*                 ciriteria = 6m
*                 bmi_change_6m = criteria for assessment
**************************************************/

data mj.study_pop_bmi_outcome_cleaned;
  set mj.study_pop_bmi_outcome_cleaned;
  bmi_change_6m = bmi_after_6m_BS - bmi_before_BS;
  bmi_change_1yr = bmi_after_1yr_BS - bmi_before_BS;
  bmi_change_2yr = bmi_after_2yr_BS - bmi_before_BS;
  bmi_change_3yr = bmi_after_3yr_BS - bmi_before_BS;
  bmi_change_4yr = bmi_after_4yr_BS - bmi_before_BS;
  bmi_change_5yr = bmi_after_5yr_BS - bmi_before_BS;
proc print data=mj.study_pop_bmi_outcome_cleaned (obs =40);
  title "mj.study_pop_bmi_outcome_cleaned";
run;


* 7. Define the event as regaining the original BMI ;

/**************************************************
* new table: mj.study_pop_bmi_outcome_cleaned
* original table: mj.study_pop_bmi_outcome_cleaned
* description: calculate outcome
*                 ciriteria = 6m
*                 bmi_change_6m = criteria for assessment
**************************************************/

data mj.study_pop_bmi_outcome_cleaned;
    set mj.study_pop_bmi_outcome_cleaned;
    if bmi_change_6m >= 0 then event_6m = 1;
    else event_6m = 0;
    if bmi_change_1yr >= 0 then event_1yr = 1;
    else event_1yr = 0;
    if bmi_change_2yr >= 0 then event_2yr = 1;
    else event_2yr = 0;
    if bmi_change_3yr >= 0 then event_3yr = 1;
    else event_3yr = 0;
    if bmi_change_4yr >= 0 then event_4yr = 1;
    else event_4yr = 0;
    if bmi_change_5yr >= 0 then event_5yr = 1;
    else event_5yr = 0;
run;    /* 114 obs */

proc print data=mj.study_pop_bmi_outcome_cleaned (obs =40);
  title "mj.study_pop_bmi_outcome_cleaned";
run;


* 8. link the demographic info to the 'mj.study_pop_bmi_outcome_cleaned';

/**************************************************
* new table: mj.study_pop_bmi_outcome_cleaned
* original table: mj.study_pop_bmi_outcome_cleaned + tx5p.patient
* description: link the demographic info to the 'mj.study_pop_bmi_outcome_cleaned'
**************************************************/

proc sql;
  create table mj.study_pop_bmi_outcome_cleaned as
  select distinct a.*, b.*
  from mj.study_pop_bmi_outcome_cleaned a left join tx5p.patient b
  on a.patient_id = b.patient_id;
quit;  

proc print data=mj.study_pop_bmi_outcome_cleaned (obs =20);
  title "mj.study_pop_bmi_outcome_cleaned";
run;

* 9. indicate group and age;

/**************************************************
* new table: mj.study_pop_bmi_outcome_cleaned
* original table: mj.study_pop_bmi_outcome_cleaned
* description: 
*           group = 0 -> BS only
*           group = 1 -> glp1 users after BS
*           group = 2 -> glp1 users 'before' BS
**************************************************/

* 9-1. make group;

data mj.study_pop_bmi_outcome_cleaned;
    set mj.study_pop_bmi_outcome_cleaned (drop=glp1_users_after_BS);
    if BS_glp1_combi = 0 and temporality = 0 then group = 0;
    else if BS_glp1_combi = 1 and temporality = 1 then group = 1;
    else if BS_glp1_combi = 1 and temporality = 0 then group = 2;
run;

data mj.study_pop_bmi_outcome_cleaned;
    set mj.study_pop_bmi_outcome_cleaned (drop=glp1_users_after_BS);
    /* Initialize group to a default value to handle cases not covered by the conditions below */
    group = .;
    if BS_glp1_combi = 0 and temporality = 0 then group = 0;
    else if BS_glp1_combi = 1 and temporality = 1 then group = 1;
    else if BS_glp1_combi = 1 and temporality = 0 then group = 2;
run;    /* 114 obs */

proc print data=mj.study_pop_bmi_outcome_cleaned (obs =20);
  title "mj.study_pop_bmi_outcome_cleaned";
run;

* 9-2. make age variable ; 

data  mj.study_pop_bmi_outcome_cleaned;
  set  mj.study_pop_bmi_outcome_cleaned;
  year_of_birth_num = input(year_of_birth, 4.);
  age = 2024 - year_of_birth_num;
run;

    

