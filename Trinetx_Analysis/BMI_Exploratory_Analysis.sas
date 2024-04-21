* 0.0 - Access;

ssh -X mkim@jhpce03.jhsph.edu
cd /dcs07/trinetx/data/
cd /users/mkim/

srun --pty --x11 bash
     /* srun --pty --x11 --partition sas bash */
module load sas
sas -helpbrowser SAS -xrm "SAS.webBrowser:'/usr/bin/chromium-browser'" -xrm "SAS.helpBrowser:'/usr/bin/chromium-browser'"

/****************************************************************************
| Program name : 
| Date (update): 24.03.04
| Project name : Trinetx - inital data analysis
| Purpose      : 
****************************************************************************/


*************************************************************************
* 1.0 - Set up the environment in JHPCE *
*************************************************************************

* My own directory for analysis in my own directory:     /users/mkim/trinetx/5p_test
* My own directory for sharing in team folder:           /dcs07/trinetx/data/Users/MJ

* to use original-data and 5p-data from the teamfolder;

libname tx "/dcs07/trinetx/data/SAS_datasets";
libname tx5p "/dcs07/trinetx/data/SAS_datasets_5p";
libname test "/dcs07/trinetx/data/test_data";       * this lib was from lijuan;
libname rayna "/dcs07/trinetx/data/Users/Rayna";     * this lib was from Rayna;

* to locate my own data analysis output;

libname analysis "/dcs07/trinetx/data/test_sas/5p";   * in the original location in teamfolder; 
libname share "/dcs07/trinetx/data/Users/MJ";         * under users in teamfolder - for sharing;
libname mj "/users/mkim/trinetx/5p_test";             * in my own directory;


*************************************************************************
* 2.0 - Explore the data *
*************************************************************************

/**************************************************
* new dataset: mj.vitals_signs_5p
* original dataset: tx5p.vitals_signs
* description: copy file from tx5p.vitals_signs
**************************************************/

* Step 1. copy the original dataset and convert 'result' values from character to numeric;

proc contents data=tx5p.vitals_signs;
run;

data mj.vitals_signs_5p;
  set tx5p.vitals_signs;
  num_value = input(value, 8.);
run;

proc contents data=mj.vitals_signs_5p; run;

proc print data=mj.vitals_signs_5p (obs=20); 
 title "mj.vitals_signs_5p";
run;

/**************************************************
* new dataset: mj.vitals_signs_5p_codelist
* original dataset: mj.vitals_signs_5p
* description: listup distinct value of the code_system variable
               after checking distinct value of the code_system variable from tx.vitals_signs
**************************************************/

* Step 2. distinct value of the code_system variable (어떤 코딩 시스템이 쓰이는지 확인하는 목적);

proc print data=tx.vitals_signs (obs=100);     * to check the original set;
run;

proc sql;
  create table mj.vitals_signs_5p_codelist as
  select distinct code_system
  from tx.vitals_signs; 
quit;     

proc print data=mj.vitals_signs_5p_codelist; 
 title "[vitals_signs_5p] distinct code list";
run;

************************************************************************** re-runnung **************************************************************************

* Step 3. list up the LOINC variables in vitals dataset;

proc print data=mj.vitals_signs_5p (obs=20);
  var code_system code units_of_measure;
  * where code_system = "LOINC";
run;

proc sort data=mj.vitals_signs_5p out=mj.vitals_signs_5p_codelist
    nodupkey;
    * where code_system = "LOINC";
    by descending code;               
run;                                     * there were 74 obs;

proc print data=mj.vitals_signs_5p_codelist (obs=80); 
  var code_system code units_of_measure;
 title "[vitals_signs_5p] distinct code list";
run;

proc contents data=mj.vitals_signs_5p_codelist;
run;


/**************************************************
* new dataset: mj.lab_result_5p
* original dataset: tx5p.lab_result
* description: copy file from tx5p.lab_result
**************************************************/

* Step 1. copy the original dataset and convert 'result' values from character to numeric;

proc contents data=tx5p.lab_result;
run;

data mj.lab_result_5p;    
  set tx5p.lab_result;
  lab_result_num_val = input(value, 8.);
run;                                       * there were 319431133 obs;

proc contents data=mj.lab_result_5p;
run;


/**************************************************
* new dataset: mj.lab_result_5p_codelist
* original dataset: mj.lab_result_5p
* description: distinct value of the code_system variable
**************************************************/

* Step 2. distinct value of the code_system variable (어떤 코딩 시스템이 쓰이는지 확인하는 목적);

proc print data=tx.lab_result (obs=100);     * to check the original set;
     title "tx.lab_result";
run;

proc sql;
  create table mj.lab_result_5p_codelist as
  select distinct code_system
  from tx.lab_result; 
quit;     
************************************************************************** in processing **************************************************************************

proc print data=mj.lab_result_5p_codelist; 
 title "[lab_result_5p] distinct code list";
run;

* Step 3. list up the LOINC variables in vitals dataset;

proc print data=mj.lab_result_5p (obs=20);
  var code_system code units_of_measure;
  * where code_system = "LOINC";
run;

proc sort data=mj.lab_result_5p out=mj.lab_result_5p_codelist
    nodupkey;
    * where code_system = "LOINC";
    by descending code;               
run;                                     /* there were 13,776 obs */

proc print data=analysis.list_lab (obs=80); 
  var code_system code units_of_measure;
run;

proc contents data=analysis.list_lab;
run;

/* distinct value of the coding system variable */
proc print data=tx.lab_result (obs=100);
run;

proc sql;
  create table analysis.test_vitals_code_list as
  select distinct code_system
  from tx.vitals_signs; 
quit;     
proc print data=analysis.test_vitals_code_list; run;



*************************************************************************
* 2.1 - Map standardized_terminology *
*************************************************************************  

*************
 * vitals *
*************

/* Map VITAL SIGNS LOINC terms */
proc sql;
  create table analysis.map_vit as
  select distinct a.*, b.code, b.code_description, b.code_system 
  from analysis.list_vt a left join test.standardized_terminology b 
  on a.code_system=b.code_system and a.code=b.code;
quit;

proc print data=analysis.map_vit (obs=100); 
 var code_system code code_description units_of_measure;
run;

%LET code_vital = analysis.map_vit.code;

proc freq data=analysis.map_vit;
   table code_system code code_description units_of_measure;
   where code = "&code_vital";
run;
proc print data=analysis.map_vit (obs=50); run;
  
/* table freq */

proc sql;
  create table analysis.map_vit_all as
  select a.*, b.code, b.code_description, b.code_system 
  from analysis.list_vt a left join test.standardized_terminology b 
  on a.code_system=b.code_system and a.code=b.code;
quit;

proc print data=analysis.map_vit_all (obs=100); 
 var _all_;
run;

****************** no ****
%LET code_vital = analysis.map_vit.code;

proc freq data=analysis.map_vit;
   table code_system code code_description units_of_measure;
   where code = "&code_vital";
run;

proc print data=analysis.map_vit_all (obs=50); run;

******************
  * lab_result *
******************

/* Map LAB result LOINC terms */
proc sql;
  create table analysis.map_lab as
  select distinct a.*, b.code, b.code_description, b.code_system 
  from analysis.list_lab a left join test.standardized_terminology b 
  on a.code_system=b.code_system and a.code=b.code;
quit;                                                         /* there are 13776 obs */

proc print data=analysis.map_lab (obs=100); 
 var code_system code code_description units_of_measure;
 where units_of_measure like "kg/m2";
 title "List of LONIC variable in LAB result file";
run;

*************************************************************************
* 2.2 - Explore the data for BMI *
*************************************************************************

*************
 * vitals *
*************

/* alignment by id for 'by group processing' */

proc sort data=analysis.test_vitals out=analysis.test_vt_id;
by patient_id date;
run;
proc print data=analysis.test_vt_id (obs=50); run;

proc contents data=analysis.test_vt_id;
run;

proc print data=analysis.test_vt_id (obs=50);
   where code="39156-5";
   title "[Vitals] BMI trend over time by Patient";
run;


/* calculate summary statistics by individual */

proc means data=analysis.test_vt_id;
      var num_value;
      where code like "39156-5";
      class patient_id;
   output out=analysis.mean_bmi_by_patient 
       mean=mean_bmi
       std=std_bmi
       min=min_bmi
       max=max_bmi;
run;

proc print data=analysis.mean_bmi_by_patient (obs=50); 
   title "Summary Statistics of BMI by Patient";
run;

/* examine extreme values */
proc univariate data=analysis.test_vt_id;
      var num_value;
      where code like "39156-5";
run;


******************
  * lab_result *
******************

/* alignment by id for 'by group processing' */

proc sort data=analysis.test_lab out=analysis.test_lab_id;
by patient_id date;
run;
proc print data=analysis.test_lab_id (obs=50); 
run;                                         /* there are 319431133 obs */

proc contents data=analysis.test_lab_id;
run;

proc print data=analysis.test_lab_id (obs=50);
   where code="89270-3";
   title "[Lab] BMI trend over time by Patient";
run;

/* calculate summary statistics by individual */

proc means data=analysis.test_lab_id;
      var lab_result_num_val;
      where code like "89270-3";
      class patient_id;
   output out=analysis.mean_estbmi_by_patient 
       mean=mean_bmi
       std=std_bmi
       min=min_bmi
       max=max_bmi;
run;

proc print data=analysis.mean_estbmi_by_patient (obs=50); 
   title "Summary Statistics of estimated BMI by Patient";
run;

/* examine extreme values */
proc univariate data=analysis.test_vt_id;
      var num_value;
      where code like "89270-3";
run;

*************************************************************************
* 1.0 - Save the output  *
*************************************************************************

ods rtf file="users/mkim/trinetx/output/01_exploredata_5p.rtf";
footnote "Outputs generated from &progname..sas";


*************************************************************************
* read rayna file
*************************************************************************

/* analytic */
* 1. index_date_all;
* 2. analytic;

/* bmi */
* 1. bmi_6monprior;
* 2. bmi_after;
* 3. bmi_baseline;
* 4. bmi_byquarter;
* 5. bmi_deduplicate;
* 6. bmi_fp_long;
* 7. bmi_fp;
* 8. bmi_nomissing;
* 9. bmi_prior_1stmeds_ingredient;
* 10. bmi;

/* ingredient */
* 1. glp1_ingredient57_byquarter;
* 2. glp1_ingredient_after_index57;
* 3. glp1_user_adult_nomissingsex;
* 4. glp1_user_all_formated;
* 5. glp1_user_all;
* 6. glp1_user;
* 7. glp_after_index;
* 8. glp_bl_fp_long;
* 9. glp_bl_fp;
* 10. glp_on_after_index;
* 11. metformin_all;
* 00. glp_fp_long;    * no observation in this dataset;

/* demogragph */
* 1. sociodemo_all;
* 2. sociodemo_cohort;

%LET raynafile=sociodemo_cohort;

proc print data=rayna.&raynafile (obs=30);
  title "rayna_&raynafile";
run;
proc contents data=rayna.&raynafile; run;




******************************************************************************************************************************************************
******************************************************************************************************************************************************

/*import the data file(take over 10mins)*/

data trinetx.test;
infile "/dcs07/trinetx/data/SAS_datasets_5p/lab_result.sas7bdat";
input 
  patient_id  $
  encounter_id  $
  code_system  $
  code  $
  date  $
  lab_result_num_val
  lab_result_text_val  $
  units_of_measure  $
  derived_by_TriNetX  $
  source_id  $
;
if _ERROR_ then call symputx('_EFIERR_',1);
run;


/*import-other ways*/
proc import out = trinetx.test
  datafile="/users/mkim/sas/lab_result.sas7bdat";
  dbms=
  getnames=yes;
run;


/*look at the data set contents*/
proc contents data=trinetx.test;
  run;
