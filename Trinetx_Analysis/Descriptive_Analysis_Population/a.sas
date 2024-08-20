

cm_metformin
cm_dpp4
cm_sglt2
cm_su
cm_thiaz
cm_insul
cm_depres
cm_psycho
cm_convul
cm_ob


ginal dataset
**************************************************/

/* the total users among TRINETX dataset */
data min.metformin_users_v00;
	set tx.medication_ingredient;
 	if code = "6809";
run;           /* 69038531 obs */

/* matching with our study population */
proc sql;
    create table min.metformin_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a 
    left join min.metformin_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 204014 obs */

/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.metformin_users_v03
* original table: min.metformin_users_v01
* description: list up metformin_users within inclusion time window
**************************************************/

data min.metformin_users_v01;
	set min.metformin_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = comedi_date;
run;

data min.metformin_users_v02;
   set min.metformin_users_v01;
   format cm_metformin 8.;
   if bs_date - comedi_date ge 0 and bs_date - comedi_date le 365;
   if not missing(comedi_date) then cm_metformin = 1;
   drop unique_id;
run;       /* 44688 obs */


/* Remain unique patients */
/**************************************************
* new table: min.metformin_users_v03
* original table: min.metformin_users_v02
* description: Remain unique patients of metformin_users within inclusion time window
**************************************************/

proc sort data=min.metformin_users_v02;
	by patient_id comedi_date;
run;

data min.metformin_users_v03;
	set min.metformin_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 8059 obs */

data min.metformin_users_v03;
	set min.metformin_users_v03;
 	rename comedi_date = cm_metformin_date;
run;


/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v00
* original table: min.metformin_users_v03
* description: Remain unique patients of metformin_users within inclusion time window
**************************************************/

proc sql;
    create table min.bs_user_comedication_v00 as 
    select a.*, /* Select all columns from table a */
           b.cm_metformin, b.cm_metformin_date 
    from min.bs_glp1_user_38384_v00 as a 
    left join min.metformin_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 obs */

data min.bs_user_comedication_v00;
	set min.bs_user_comedication_v00;
 	if missing(cm_metformin) then cm_metformin = 0;
run;

proc print data=min.bs_user_comedication_v00(obs = 30);
	var patient_id cm_metformin cm_metformin_date;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v00;
	table cm_metformin;
run;

/*
among 38384, 
cm_metformin = 1 | 8059 (21%)
cm_metformin = 0 | 30325
*/



* 1.2. dpp4 users;
/**************************************************
* new table: min.dpp4_users_v00
* original table: tx.medication_ingredient
* description: list up dpp4_users from original dataset
**************************************************/

/* the total users among TRINETX dataset */
data min.dpp4_users_v00;
	set tx.medication_ingredient;
 	if code in ('593411', '1100699', '857974', '1368001', '1992825', '729717', '1598392', '1243019', '2281864', '1727500', '1043562', '2117292', '1368402', '1368384');
run;      /* 24156249 obs */

/* matching with our study population */
proc sql;
    create table min.dpp4_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a 
    left join min.dpp4_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 84288 obs */

data min.dpp4_users_v01;
	set min.dpp4_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = cm_dpp4_date;
run;  


/* Remain co-medication within 1 yr before the surgery */
/**************************************************
* new table: min.dpp4_users_v02
* original table: min.dpp4_users_v01
* description: list up dpp4_users within inclusion time window
**************************************************/

data min.dpp4_users_v02;
   set min.dpp4_users_v01;
   format cm_dpp4 8.;
   if bs_date - cm_dpp4_date ge 0 and bs_date - cm_dpp4_date le 365;
   if not missing(cm_dpp4_date) then cm_dpp4 = 1;
   drop unique_id;
run;       /* 11746 obs */

/* Remain unique patients */
/**************************************************
* new table: min.dpp4_users_v03
* original table: min.dpp4_users_v02
* description: Remain unique patients of dpp4_users within inclusion time window
**************************************************/

proc sort data=min.dpp4_users_v02;
	by patient_id cm_dpp4_date;
run;

data min.dpp4_users_v03;
	set min.dpp4_users_v02;
 	by patient_id;
  	if first.patient_id;
run;      /* 1133 obs */

/* merge with the total 38384 dataset */
/**************************************************
* new table: min.bs_user_comedication_v01
* original table: min.dpp4_users_v03
* description: merge into one dataset
**************************************************/

proc sql;
    create table min.bs_user_comedication_v01 as 
    select a.*, /* Select all columns from table a */
           b.cm_dpp4, b.cm_dpp4_date 
    from min.bs_user_comedication_v00 as a 
    left join min.dpp4_users_v03 as b
    on a.patient_id = b.patient_id;
quit;   /* 38384 obs */

data min.bs_user_comedication_v01;
	set min.bs_user_comedication_v01;
 	if missing(cm_dpp4) then cm_dpp4 = 0;
run;


/* calculate prevalence */
proc freq data=min.bs_user_comedication_v01;
	table cm_dpp4;
run;

/*
among 38384, 
cm_dpp4 = 1 | 1133 (2.95%)
cm_dpp4 = 0 | 37251
*/



* 1.3. sglt2 users;
/**************************************************
* new table: min.sglt2_users_v00
* original table: tx.medication_ingredient
* description: list up sglt2_users from original dataset
**************************************************/

data min.sglt2_users_v00;
	set tx.medication_ingredient;
 	if code in ('1545653', '1373458', '1488564', '1992672', '2627044', '2638675', '1664314', '1545149', '1486436', '1992684');
run;      /* 13603886 obs */

/* matching with our study population */
proc sql;
    create table min.sglt2_users_v01 as 
    select a.patient_id, a.bs_date, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a
    left join min.sglt2_users_v00 as b
    on a.patient_id = b.patient_id;
quit;       /* 61269 obs */

data min.sglt2_users_v01;
	set min.sglt2_users_v01;
 	date_num = input(start_date, yymmdd8.);
  	format date_num yymmdd10.;
  	rename date_num = cm_sglt2_date;
run;  






















* 1.4. sulfonylureas users;
/**************************************************
* new table: min.sulfonylureas_users_v00
* original table: tx.medication_ingredient
* description: list up sulfonylureas_users from original dataset
**************************************************/

data min.sulfonylureas_users_v00;
	set tx.medication_ingredient;
 	if code in ('4821','25789','4815','4816','352381','647235','606253','285129');
run;      /* 23763314 obs */



* 1.5. thiazo users;
/**************************************************
* new table: min.thiazo_users_v00
* original table: tx.medication_ingredient
* description: list up thiazo_users from original dataset
**************************************************/

data min.thiazo_users_v00;
	set tx.medication_ingredient;
 	if code in ('33738', '84108', '607999', '614348');
run;      /* 4927094 obs */


* 1.6. insulin users;
/**************************************************
* new table: min.insulin_users_v00
* original table: tx.medication_ingredient
* description: list up insulin_users from original dataset
**************************************************/

data min.insulin_users_v00;
	set tx.medication_ingredient;
 	if code in ('253182', '1008501', '1008509', '1605101');
run;      /* 140460403 obs */


* 1.7. Antidepressants users;
/**************************************************
* new table: min.antidepressant_users_v00
* original table: tx.medication_ingredient
* description: list up Antidepressants users from original dataset
**************************************************/

data min.antidepressant_users_v00;
	set tx.medication_ingredient;
 	if code in ('704', '7531', '5691', '3247', '3634', '3638', '2597', '321988', '2556', '32937', '4493', '36437', '72625', '39786', '30121', '8123', '10737', '31565', '15996', '6646', '6929');
run;      /* 91868375 obs */


* 1.8. Antipsychotics  users;
/**************************************************
* new table: min.antipsychotics_users_v00
* original table: tx.medication_ingredient
* description: list up Antipsychotics  users from original dataset
**************************************************/

data min.antipsychotics_users_v00;
	set tx.medication_ingredient;
 	if code in ('7019', '5093', '8076', '89013', '115698', '1040028', '679314', '73178', '784649', '46303', '51272', '35636', '41996', '2626', '61381');
run;      /* 30609157 obs */


* 1.9. Anticonvulsants  users;
/**************************************************
* new table: min.anticonvulsants_users_v00
* original table: tx.medication_ingredient
* description: list up Antipsychotics  users from original dataset
**************************************************/

data min.anticonvulsants_users_v00;
	set tx.medication_ingredient;
 	if code in ('38404', '39998', '28439', '114477', '31914', '32624', '25480', '187832', '40254', '2002');
run;      /* 89574604 obs */


/**************************************************
* new table: min.bs_user_comedi_v00
* original table: tx.medication_ingredient;
* description: list up comedications
**************************************************/

%let list1 = %str('6809');  /* cm_metformin */
%let list2 = %str('593411', '1100699', '857974', '1368001', '1992825', '729717', '1598392', '1243019', '2281864', '1727500', '1043562', '2117292', '1368402', '1368384'); /* cm_dpp4 */
%let list3 = %str('1545653', '1373458', '1488564', '1992672', '2627044', '2638675', '1664314', '1545149', '1486436', '1992684');  /* cm_sglt2 */
%let list4 = %str('4821','25789','4815','4816','352381','647235','606253','285129');    /* cm_sulfonylureas */
%let list5 = %str('33738', '84108', '607999', '614348');     /* cm_thiazo */
%let list6 = %str('253182', '1008501', '1008509', '1605101');       /* cm_insulin */

* 1.7. Antidepressants users;
%let list7 = %str('704', '7531', '5691', '3247', '3634', '3638', '2597') /* cm_tca */
%let list8 = %str('321988', '2556', '32937', '4493', '36437') /* cm_ssri */
%let list9 = %str('72625', '39786')  /* cm_snri */
%let list10 = %str('30121', '8123') /* cm_maoi */
%let list8 = %str('10737', '31565', '15996', '6646', '6929') /* cm_antidepressants_others */

* 1.8. Antipsychotics users;
%let list8 = %str('7019', '5093', '8076')  /* cm_antipsy_typical */
%let list8 = %str('89013', '115698', '1040028', '679314', '73178', '784649', '46303', '51272', '35636', '41996', '2626', '61381') /* cm_antipsy_Atypical */
 

%let list8 = %str('38404', '39998', '28439', '114477', '31914', '32624', '25480', '187832', '40254', '2002')  /* cm_anticonv */



/* cm_lithium */














proc sql;
    create table min.bs_user_comedi_v00 as 
    select a.patient_id, 
           b.*  /* Select all columns from table b */
    from min.bs_glp1_user_38384_v00 as a 
    left join tx.medication_ingredient as b
    on a.patient_id = b.patient_id;
quit;


data min.bs_user_comedi_v01;
  set min.bs_user_comedi_v00;
  format cm_metformin cm_dpp4 cm_sglt2 cm_su cm_thia cm_insul 8.;

    cm_metformin =0;
    cm_dpp4 =0;
    cm_sglt2 =0;
    cm_su =0;
    cm_thia =0;
    cm_insul=0;
    
    if code in (&list1) then cm_metformin = 1;
    else if code in (&list2) then cm_dpp4 = 1;
    else if code in (&list3) then cm_sglt2 = 1;



    
    else delete;

run;





data min.anti_ob_users_v00;
  set tx.medication_ingredient;
  format comedi_antiob 8. comedi_antiob_type $32. comedi_antiob_start_date yymmdd10.;
  where code in ("7243", "1551467", "37925", "8152", "1302826", "2469247");
  if code = "7243" then comedi_antiob_type = "naltrexone";
  else if code = "1551467" then comedi_antiob_type = "naltrexone/bupropion";
  else if code = "37925" then comedi_antiob_type = "orlistat";
  else if code = "8152" then comedi_antiob_type = "phentermine";
  else if code = "1302826" then comedi_antiob_type = "phentermine/topiramate";
  else if code = "2469247" then comedi_antiob_type = "setmelanotide";
  comedi_antiob = 1;
  comedi_antiob_start_date = input(start_date, yymmdd8.);
  drop start_date;
run;  









