
/************************************************************************************
	1. check the diabetes codes;
************************************************************************************/

/**************************************************
* new dataset: min.comorbidity_v01
* original dataset: min.comorbidity
* description: add
**************************************************/
proc print data=tx.diagnosis (obs=30);
   where code like 'E11%' or code like '250.%';
run;   

data diabetes;
  set min.bs_user_comorbidity_v00;
  where code like 'E11%' or code like '250.%';
run;

proc sql;
  create table diabetes as
  select distinct a.*, b.bs_date 
  from diabetes as a
  left join min.studypopulation_v03 as b
  on a.patient_id = b.patient_id;
quit;

data diabetes;
	set diabetes;
 	date_num = input(date, yymmdd8.);
  	format date_num yymmdd10.;
run;
data diabetes;
   set diabetes;
   if bs_date - date_num ge 0 and bs_date - date_num le 365;
run;
proc sort data=diabetes; by patient_id date_num; run;

data diabetes;
	set diabetes;
  	by patient_id;
  	if first.patient_id;
run;   /* 18411 obs */

data diabetes; set diabetes; cc_diabetes =1; run;

proc sql;
    create table min.comorbidity_v01 as 
    select a.*, b.cc_diabetes
    from min.comorbidity as a 
    left join diabetes as b
    on a.patient_id = b.patient_id;
quit;

data min.comorbidity_v01;
  set min.comorbidity_v01;
  if missing(cc_diabetes) then cc_diabetes = 0;
run;

* compared the proportion of diabetes based on differenct definition;
proc freq data=min.comorbidity_v01;
  table cc_t2db;
run;

proc freq data=min.comorbidity_v01;
  table cc_diabetes;
run;

/************************************************************************************
	2. merge with the total study population;
************************************************************************************/
/**************************************************
* new dataset: min.studypopulation_v04
* original dataset: min.studypopulation_v03
* description: add
**************************************************/

proc sql;
    create table min.studypopulation_v03 as 
    select a.*, b.cc_diabetes
    from min.studypopulation_v03 as a 
    left join min.comorbidity_v01 as b
    on a.patient_id = b.patient_id;
quit;




