
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 05_Covariate_ccomedication
| Date (update): July 2024
| Task Purpose : 
|      1. Create Comedication lists using the ICD_10_CT and ICD_9_CT codes
|      2. 
|      3. Remain distinct observation by one patients with comorbidity information
| Main dataset : (1) min.bs_user_all_v07, (2) tx.medication_ingredient
| Final dataset: 
************************************************************************************/


/************************************************************************************
	STEP 1. Create Comedication lists using the ICD_10_CT and ICD_9_CT codes
************************************************************************************/

* 1.1. explore procedure dataset + list up all of the value of code_system;

proc print data=tx.diagnosis (obs=40);
    title "tx.diagnosis";
run;                      
proc contents data=tx.diagnosis;
    title "tx.diagnosis";
run;        

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
%let list7 = %str(


'704'
'7531'
'5691'
'3247'
'3634'
'3638'
'2597'

/* cm_tca */

'321988'
'2556'
'32937'
'4493'
'36437'

/* cm_ssri */

'72625'
'39786'

/* cm_snri */

'30121'
'8123'

/* cm_maoi */

'10737'
'31565'
'15996'
'6646'
'6929'

/* cm_antidepressants_others */

/* cm_antipsy_typical */
/* cm_antipsy_Atypical */
/* cm_anticonv */
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









