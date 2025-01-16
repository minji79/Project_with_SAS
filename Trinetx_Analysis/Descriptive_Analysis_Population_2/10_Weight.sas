
/************************************************************************************
	1. identify Weight dataset;
************************************************************************************/

proc contents data=m.vitals_signs; run;

proc print data=m.vitals_signs (obs=30);
  where code="29463-7";
run;
value
date

proc sort data=m.vitals_signs
		out=m.weight;
	where code="29463-7";
	by patient_id;
run;               /* 64,412,764 obs */

proc sql;
	create table min.weight_v00 as
	select a.patient_id, a.bs_date, a.glp1_user, a.glp1_initiation_date, b.value, b.date
	from min.studypopulation_v03 as a
  left join m.vitals_signs as b
  on a.patient_id=b.patient_id
  where b.code="29463-7";
quit;

data weight_v01;
  set min.weight_v00;
  if not missing(value);
run;

proc print data=weight_v01 (obs=30);
run;

