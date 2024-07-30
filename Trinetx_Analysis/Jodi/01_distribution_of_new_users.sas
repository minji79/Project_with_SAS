
/************************************************************************************
| Project name : JOdi
| Program name : 01_distribution_of_new_users.sas
| Date (update): July 2024
| Task Purpose : 
|      1. 

|      5. 
| Main dataset : (1) min.bs_glp1_user_v03
************************************************************************************/

libname jd "/dcs07/trinetx/data/Users/MJ/jodi";

/************************************************************************************
	1. GLP1 new users after 2005
************************************************************************************/

* 1.1. all glp1 users + remain their initiation date;
/**************************************************
* new dataset: jd.glp1_2005_v01
* original dataset: tx.medication_ingredient
* description: all glp1 users + remain their initiation date;
**************************************************/

data jd.glp1_2005;
  set tx.medication_ingredient;
  where code in ("1991302", "1551291", "475968", "60548", "1440051", "2601723");
  if code = "1991302" then Molecule = "Semaglutide";
  else if code = "1551291" then Molecule = "Dulaglutide";
  else if code = "475968" then Molecule = "Liraglutide";
  else if code = "60548" then Molecule = "Exenatide";
  else if code = "1440051" then Molecule = "Lixisenatide";
  else if code = "2601723" then Molecule = "Tirzepatide";
run;    /* 17280539 obs with 12 var*/

proc sort data=jd.glp1_2005 out=jd.glp1_2005_v01;
  by patient_id start_date;
run;
data jd.glp1_2005_v01;
    set jd.glp1_2005_v01;
    by patient_id;  /* Sort by patient_id */
    if first.patient_id; /* Keep only the first row for each patient_id */
run;     /* 1088256 obs */

 
 /* to check the table has distinct individual */
proc print data=jd.glp1_2005_v01 (obs=30);
  title "jd.glp1_2005_v01";
run;

proc sql;
    create table jd.glp1_2005_v02 as
    select count(distinct patient_id) as distinct_users
    from jd.glp1_2005_v01;
quit;
proc print data=jd.glp1_2005_v02;
run; /* 1088256 obs */


* 1.2. format date;

data jd.glp1_2005_v03;
	set jd.glp1_2005_v01;
	start_date_num = input(start_date, yymmdd8.);
	format start_date_num yymmdd10.;
	drop encounter_id unique_id code_system source_id;
run;
proc contents data=jd.glp1_2005_v03;
run;


* 1.3. select new users after 2005;
/**************************************************
* new dataset: jd.glp1_2005_v04
* original dataset: jd.glp1_2005_v03
* description: GLP1 new users after 2005
**************************************************/

data jd.glp1_2005_v04;
  set jd.glp1_2005_v03;
  if start_date_num > '01JAN2005'd;
run;    /* 1088230 obs */


* 1.4. categorize the initiation year;
/**************************************************
* new dataset: jd.glp1_2005_v05
* original dataset: jd.glp1_2005_v04
* description: GLP1 new users after 2005
**************************************************/

data jd.glp1_2005_v05;
    set jd.glp1_2005_v04;
    format initiation_year 8.;
    initiation_year = input(substr(start_date, 1, 4), 4.);
run;
proc print data=jd.glp1_2005_v05(obs=30);
  title "jd.glp1_2005_v05";
run;

* 1.5. distribution of initiation year;
proc freq data=jd.glp1_2005_v05;
    tables Molecule*initiation_year / out=jd.glp1_2005_v06;
    title "Number of GLP1 new users by Molecule";
run;

/* cumulative bar graph */
proc sgplot data=jd.glp1_2005_v06;
    vbar initiation_year / response=Count group=Molecule;
    xaxis label="Initiation Year" values=(2005 to 2024 by 1); /* Adjust years if needed */
    yaxis label="Count";
    title "Number of GLP1 new users by Molecule";
run;
 

/************************************************************************************
	2. SGLT2 new users after 2005
************************************************************************************/

* 2.1. all glp1 users + remain their initiation date;
/**************************************************
* new dataset: jd.sglt2_2005
* original dataset: tx.medication_ingredient
* description: SGLT2 users after 2005
**************************************************/

data jd.sglt2_2005;
  set tx.medication_ingredient;
  where code in ("1373458", "1488564", "1545653", "1992672", "2627044", "2638675");
  if code = "1373458" then Molecule = "Canagliflozin";
  else if code = "1488564" then Molecule = "Dapagliflozin";
  else if code = "1545653" then Molecule = "Empagliflozin";
  else if code = "1992672" then Molecule = "Ertugliflozin";
  else if code = "2627044" then Molecule = "Bexagliflozin";
  else if code = "2638675" then Molecule = "Sotagliflozin";
run;   /* 13603886 obs with 12 var */

proc sort data=jd.sglt2_2005 out=jd.sglt2_2005_v01;
  by patient_id start_date;
run;
data jd.sglt2_2005_v01;
    set jd.sglt2_2005_v01;
    by patient_id;  
    if first.patient_id; 
run;     /* 830903 obs */

 
 /* to check the table has distinct individual */
proc sql;
    create table jd.sglt2_2005_v02 as
    select count(distinct patient_id) as distinct_users
    from jd.sglt2_2005_v01;
quit;
proc print data=jd.sglt2_2005_v02;
run; /* 830903 obs */


* 2.2. format date;

data jd.sglt2_2005_v03;
	set jd.sglt2_2005_v01;
	start_date_num = input(start_date, yymmdd8.);
	format start_date_num yymmdd10.;
	drop encounter_id unique_id code_system source_id;
run;
proc contents data=jd.sglt2_2005_v03;
run;


* 2.3. select new users after 2005;
/**************************************************
* new dataset: jd.sglt2_2005_v04
* original dataset: jd.sglt2_2005_v03
* description: sglt2 new users after 2005
**************************************************/

data jd.sglt2_2005_v04;
  set jd.sglt2_2005_v03;
  if start_date_num > '01JAN2005'd;
run;    /* 830897 obs */


* 2.4. categorize the initiation year;
/**************************************************
* new dataset: jd.sglt2_2005_v05
* original dataset: jd.sglt2_2005_v04
* description: GLP1 new users after 2005
**************************************************/

data jd.sglt2_2005_v05;
    set jd.sglt2_2005_v04;
    format initiation_year 8.;
    initiation_year = input(substr(start_date, 1, 4), 4.);
run;
proc print data=jd.sglt2_2005_v05 (obs=30);
  title "jd.sglt2_2005_v05";
run;

* 2.5. distribution of initiation year;
proc freq data=jd.sglt2_2005_v05;
    tables Molecule*initiation_year / out=jd.sglt2_2005_v06;
    title "Number of SGLT2 new users by Molecule";
run;

/* cumulative bar graph */
proc sgplot data=jd.sglt2_2005_v06;
    vbar initiation_year / response=Count group=Molecule;
    xaxis label="Initiation Year" values=(2005 to 2024 by 1);
    yaxis label="Count";
    title "Number of SGLT2 new users by Molecule";
run;




/************************************************************************************
	3. DPP4 users after 2005
************************************************************************************/

* 3.1. all dpp4 users + remain their initiation date;
/**************************************************
* new dataset: jd.dpp4_2005
* original dataset: tx.medication_ingredient
* description: DPP4 users after 2005
**************************************************/

data jd.dpp4_2005;
  set tx.medication_ingredient;
  where code in ("1100699", "1368001", "593411", "596554", "857974");
  if code = "1100699" then Molecule = "linagliptin";
  else if code = "1368001" then Molecule = "alogliptin";
  else if code = "593411" then Molecule = "sitagliptin";
  else if code = "596554" then Molecule = "vildagliptin";
  else if code = "857974" then Molecule = "saxagliptin";
run;  /* 24553364 obs*/

proc sort data=jd.dpp4_2005 out=jd.dpp4_2005_v01;
  by patient_id start_date;
run;
data jd.dpp4_2005_v01;
    set jd.dpp4_2005_v01;
    by patient_id;  
    if first.patient_id; 
run;     /* 919458 obs */

 
 /* to check the table has distinct individual */
proc sql;
    create table jd.dpp4_2005_v02 as
    select count(distinct patient_id) as distinct_users
    from jd.dpp4_2005_v01;
quit;
proc print data=jd.dpp4_2005_v02;
run; 


* 3.2. format date;

data jd.dpp4_2005_v03;
	set jd.dpp4_2005_v01;
	start_date_num = input(start_date, yymmdd8.);
	format start_date_num yymmdd10.;
	drop encounter_id unique_id code_system source_id;
run;

* 3.3. select new users after 2005;
/**************************************************
* new dataset: jd.dpp4_2005_v04
* original dataset: jd.dpp4_2005_v03
* description: dpp4 new users after 2005
**************************************************/

data jd.dpp4_2005_v04;
  set jd.dpp4_2005_v03;
  if start_date_num > '01JAN2005'd;
run;    /* 919242 obs */


* 3.4. categorize the initiation year;
/**************************************************
* new dataset: jd.dpp4_2005_v05
* original dataset: jd.dpp4_2005_v04
* description: GLP1 new users after 2005
**************************************************/

data jd.dpp4_2005_v05;
    set jd.dpp4_2005_v04;
    format initiation_year 8.;
    initiation_year = input(substr(start_date, 1, 4), 4.);
run;
proc print data=jd.dpp4_2005_v05 (obs=30);
  title "jd.dpp4_2005_v05";
run;

* 3.5. distribution of initiation year;
proc freq data=jd.dpp4_2005_v05;
    tables Molecule*initiation_year / out=jd.dpp4_2005_v06;
    title "Number of DPP4 new users by Molecule";
run;

/* cumulative bar graph */
proc sgplot data=jd.dpp4_2005_v06;
    vbar initiation_year / response=Count group=Molecule;
    xaxis label="Initiation Year" values=(2005 to 2024 by 1);
    yaxis label="Count";
    title "Number of DPP4 new users by Molecule";
run;



/************************************************************************************
	4. Metfotmin users after 2005
************************************************************************************/

/**************************************************
* new dataset: jd.met_2005
* original dataset: tx.medication_ingredient
* description: Metfotmin users after 2005
**************************************************/

data jd.met_2005;
  set tx.medication_ingredient;
  where code in ("6809");
  if code = "6809" then Molecule = "metformin";
run;     /* 29785825 obs with 12 var*/

proc sort data=jd.met_2005 out=jd.met_2005_v01;
  by patient_id start_date;
run;
data jd.met_2005_v01;
    set jd.met_2005_v01;
    by patient_id;  
    if first.patient_id; 
run;     /* 2831079 obs */ 

 
 /* to check the table has distinct individual */
proc sql;
    create table jd.met_2005_v02 as
    select count(distinct patient_id) as distinct_users
    from jd.met_2005_v01;
quit;
proc print data=jd.met_2005_v02;
run; /*  obs */


* 4.2. format date;

data jd.met_2005_v03;
	set jd.met_2005_v01;
	start_date_num = input(start_date, yymmdd8.);
	format start_date_num yymmdd10.;
	drop encounter_id unique_id code_system source_id;
run;
proc contents data=jd.met_2005_v03;
run;


* 4.3. select new users after 2005;
/**************************************************
* new dataset: jd.met_2005_v04
* original dataset: jd.met_2005_v03
* description: sglt2 new users after 2005
**************************************************/

data jd.met_2005_v04;
  set jd.met_2005_v03;
  if start_date_num > '01JAN2005'd;
run;    /* 2791089 obs */


* 4.4. categorize the initiation year;
/**************************************************
* new dataset: jd.met_2005_v05
* original dataset: jd.met_2005_v04
* description: metformin new users after 2005
**************************************************/

data jd.met_2005_v05;
    set jd.met_2005_v04;
    format initiation_year 8.;
    initiation_year = input(substr(start_date, 1, 4), 4.);
run;
proc print data=jd.met_2005_v05 (obs=30);
  title "jd.met_2005_v05";
run;

* 2.5. distribution of initiation year;
proc freq data=jd.met_2005_v05;
    tables Molecule*initiation_year / out=jd.met_2005_v06;
    title "Number of Metformin new users by Molecule";
run;

/* cumulative bar graph */
proc sgplot data=jd.met_2005_v06;
    vbar initiation_year / response=Count group=Molecule;
    xaxis label="Initiation Year" values=(2005 to 2024 by 1);
    yaxis label="Count";
    title "Number of Metformin new users by Molecule";
run;


