
* select only GLP-1 users among study population (temporality = 2)'s for bmi long data;

/* select only GLP-1 users among study population (temporality = 2) */
proc contents data=min.bs_glp1_user_v03;
  	title "min.bs_glp1_user_v03";
   run;  /obs = 43996 = out study population */

data min.glp1_user;
    set min.bs_glp1_user_v03;
    if temporality = 2;
run;  /* 6466 */
proc print data=min.glp1_user (obs = 30);
title "min.glp1_user";
run;


proc sql;
  create table min.bmi_glp1user_long_v00 as
  select distinct a. patient_id, a.bs_date, a.bs_type, a.glp1_initiation_date, b.date, b.value 
  from min.glp1_user a left join m.bmi_date b 
  on a.patient_id=b.patient_id;
quit;
proc print data=min.bmi_glp1user_long_v00 (obs = 30);
title "min.bmi_glp1user_long_v00";
run;  /* 155155 obs */

* change the variable name;
data min.bmi_glp1user_long_v01;
  set min.bmi_glp1user_long_v00;
  rename date = bmi_date value = bmi;
run;

* time-to-glp1 & time_to_bmivariable;
data min.bmi_glp1user_long_v01;
  set min.bmi_glp1user_long_v01;
  time_to_glp1 = glp1_initiation_date - bs_date;
  time_to_bmi = bmi_date - bs_date;
run;
proc print data = min.bmi_glp1user_long_v01 (obs = 30);
  title "min.bmi_glp1user_long_v01";
run;

* remove missing bmi;
data min.bmi_glp1user_long_v02;
  set min.bmi_glp1user_long_v01;
  if missing(bmi) then delete;
run;
