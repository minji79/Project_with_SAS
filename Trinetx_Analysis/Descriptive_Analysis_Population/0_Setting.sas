* working with 100% of dataset - for my own thesis : as of June 2024 * 


*************************************************************************
* 0.0 - Set up the environment  *
*************************************************************************

* Step 1. Access;

ssh -X mkim@jhpce03.jhsph.edu
cd /dcs07/trinetx/data/
cd /users/mkim/

srun --pty --x11 bash
     /* srun --pty --x11 --partition sas bash */
module load sas
sas -helpbrowser SAS -xrm "SAS.webBrowser:'/usr/bin/chromium-browser'" -xrm "SAS.helpBrowser:'/usr/bin/chromium-browser'"

* My own directory for analysis in my own directory:     /users/mkim/trinetx/5p_test;
* My own directory for sharing in team folder:           /dcs07/trinetx/data/Users/MJ;

* to use original-data and 5p-data from the teamfolder;

libname tx "/dcs07/trinetx/data/SAS_datasets";
libname tx5p "/dcs07/trinetx/data/SAS_datasets_5p";

* to locate my own data analysis output in the original location in team folder;
libname analysis "/dcs07/trinetx/data/test_sas/5p";

* to locate my own data analysis output under users in teamfolder;
libname share "/dcs07/trinetx/data/Users/MJ";

* to locate my own data analysis output in my own directory;
libname m "/users/mkim/trinetx/100p";
libname mj "/users/mkim/trinetx/5p_test";


/****************************************************************************
| Project name : Thesis - BS and GLP1
| Date (update): June 2024
| Task Purpose : listup code for key outcome measurements with 100% data set
|                 BMI, weight, hight, ...
****************************************************************************/

/**************************************************
* 1.1 - vitals_signs 
**************************************************/

/**************************************************
* new dataset: m.vitals_signs
* original dataset: tx.vitals_signs
* description: copy file "tx.vitals_signs" with adj
**************************************************/

* Step 1. copy the original dataset and convert 'result' values from character to numeric;

proc contents data=tx.vitals_signs;
run;

data m.vitals_signs;
  set tx.vitals_signs;
  num_value = input(value, 8.);
run;

proc contents data=m.vitals_signs; run;

proc print data=m.vitals_signs (obs=20);
 title "m.vitals_signs";
run;

/**************************************************
* new dataset: m.vitals_signs_codelist
* original dataset: m.vitals_signs
* description: listup distinct value of the code_system variable
               after checking distinct value of the code_system variable from tx.vitals_signs
**************************************************/

* Step 2. check the type of code systems other than LOINC to have distinct value of the code_system variable;

proc print data=tx.vitals_signs (obs=100);     * to check the original set;
run;

proc sql;
  create table m.vitals_signs_codelist as
  select distinct code_system
  from tx.vitals_signs; 
quit;     

proc print data=m.vitals_signs_codelist; 
 title "[vitals_signs] distinct code list";
run;


* Step 3. list up the LOINC variables in vitals dataset;

proc print data=m.vitals_signs (obs=20);
  var code_system code units_of_measure;
  * where code_system = "LOINC";
run;

proc sort data=m.vitals_signs out=m.vitals_signs_codelist
    nodupkey;
    * where code_system = "LOINC";
    by descending code;               
run;                                     * there were 74 obs;

proc print data=m.vitals_signs_codelist (obs=80); 
  var code_system code units_of_measure;
 title "[vitals_signs] distinct code list";
run;

proc contents data=m.vitals_signs_codelist;
run;

/**************************************************
* new dataset: m.vitals_signs_standterm
* original dataset: m.vitals_signs_codelist
* description: map standardized_terminology to the codelist from vitials_signs
**************************************************/

* Step 4. map standardized_terminology;

proc sql;
  create table m.vitals_signs_standterm as
  select distinct a.*, b.code, b.code_description, b.code_system 
  from m.vitals_signs_codelist a left join test.standardized_terminology b 
  on a.code_system=b.code_system and a.code=b.code;
quit;

proc print data=m.vitals_signs_standterm (obs=100); 
 var code_system code code_description units_of_measure;
 title "m.vitals_signs_standterm";
run;


/**************************************************
* 1.2 - lab_result
**************************************************/

/**************************************************
* new dataset: m.lab_result
* original dataset: tx.lab_result
* description: copy file "tx.lab_result"
**************************************************/

* Step 1. copy the original dataset and convert 'result' values from character to numeric;

proc contents data=tx.lab_result;
run;

data m.lab_result;    
  set tx.lab_result;
  lab_result_num_val = input(value, 8.);
run;                                       * there were 319431133 obs;

proc contents data=m.lab_result;
run;

/**************************************************
* new dataset: m.lab_result_codelist
* original dataset: m.lab_result
* description: distinct value of the code_system variable
**************************************************/

* Step 2. check the type of code systems other than LOINC to have distinct value of the code_system variable;

proc print data=tx.lab_result (obs=100);     * to check the original set;
     title "tx.lab_result";
run;

proc sql;
  create table m.lab_result_codelist as
  select distinct code_system
  from tx.lab_result; 
quit;     

proc print data=m.lab_result_codelist; 
 title "[lab_result] distinct code list";
run;

* Step 3. list up the LOINC variables in vitals dataset;

proc print data=m.lab_result (obs=20);
  var code_system code units_of_measure;
  * where code_system = "LOINC";
run;

proc sort data=m.lab_result out=m.lab_result_codelist
    nodupkey;
    * where code_system = "LOINC";
    by descending code;               
run;                            /* there were 13,776 obs */

proc print data=m.lab_result_codelist (obs=80); 
  var code_system code units_of_measure;
  title "m.lab_result_codelist";
run;

proc contents data=m.lab_result_codelist;
run;

/**************************************************
* new dataset: m.lab_result_standterm
* original dataset: m.lab_result_codelist
* description: map standardized_terminology to the codelist from lab_result
**************************************************/

* Step 4. map standardized_terminology;

proc sql;
  create table m.lab_result_standterm as
  select distinct a.*, b.code, b.code_description, b.code_system 
  from m.lab_result_codelist a left join test.standardized_terminology b 
  on a.code_system=b.code_system and a.code=b.code;
quit;

proc print data=m.lab_result_standterm (obs=100); 
 var code_system code code_description units_of_measure;
 title "m.lab_result_standterm";
run;

/*
results: 
1. BMI
2. weight
3. height

*/





