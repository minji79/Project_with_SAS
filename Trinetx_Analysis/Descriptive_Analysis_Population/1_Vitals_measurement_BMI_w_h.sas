
/****************************************************************************
| Project name : Thesis - BS and GLP1
| Date (update): June 2024
| Task Purpose : 
|      1. listup code for key outcome measurements with 100% data set
|                 BMI, weight, hight, ...
|      2. BMI time series analysis
|      3. weight time series analysis
|      4. BMI calculation with weight and hight -> compare to the BMI
| Main dataset : vitals_signs
****************************************************************************/

/* 

issue: 

the 'standardized_terminology.csv' file is not available now
-> 100% data로 돌렸을 때, 기존 5%로는 74개 나오던 리스트가 76개 나옴. 그러나 standard term 매칭이 안된 상황
4번 해야 함

*/

/****************************************************************************
* 1. listup code for key outcome measurements with 100% data set
****************************************************************************/

/**************************************************
* new dataset: m.vitals_signs
* original dataset: tx.vitals_signs
* description: copy file "tx.vitals_signs" with adj
**************************************************/

* 1.1. copy the original dataset and convert 'result' values from character to numeric;

proc print data=tx.vitals_signs (obs=30);     * to check the original set;
run;

proc contents data=tx.vitals_signs;
run;

data m.vitals_signs;
  set tx.vitals_signs;
  num_value = input(value, 8.);
run;                        /* 2,620,534,452 obs */

proc contents data=m.vitals_signs; run;

proc print data=m.vitals_signs (obs=20);
 title "m.vitals_signs";
run;

/**************************************************
* new dataset: m.vitals_signs_codelist
* original dataset: m.vitals_signs
* description: 
        1. listup distinct value of the code_system variable
               after checking distinct value of the code_system variable from tx.vitals_signs
        2. map standardized_terminology to the codelist from vitials_signs
**************************************************/

* 1.2. check the type of code systems other than LOINC to have distinct value of the code_system variable;

proc sql;
  create table m.vitals_signs_codelist as
  select distinct code_system
  from tx.vitals_signs; 
quit;     

proc print data=m.vitals_signs_codelist; 
 title "[vitals_signs] distinct code list";
run;                      /* LOINC is the only codesystem in vitals table */


* 1.3. list up the LOINC variables in vitals dataset;

proc print data=m.vitals_signs (obs=20);
  var code_system code units_of_measure;
  * where code_system = "LOINC";
run;

proc sort data=m.vitals_signs out=m.vitals_signs_codelist
    nodupkey;
    * where code_system = "LOINC";
    by descending code;               
run;                                     /* 76 obs */

proc print data=m.vitals_signs_codelist (obs=100); 
  var code_system code units_of_measure;
 title "[vitals_signs] distinct code list";
run;

proc contents data=m.vitals_signs_codelist;
run;


* 1.4. map standardized_terminology;    /* the 'standardized_terminology.csv' file is not available now */

proc sql;
  create table m.vitals_signs_codelist as
  select distinct a.*, b.code, b.code_description, b.code_system 
  from m.vitals_signs_codelist a left join test.standardized_terminology b 
  on a.code_system=b.code_system and a.code=b.code;
quit;

proc print data=m.vitals_signs_codelist (obs=100); 
 var code_system code code_description units_of_measure;
 title "m.vitals_signs_codelist";
run;

/*
LOINC
39156-5 Body Mass Index
29463-7: Body weight
8302-2 Height
*/


/****************************************************************************
* 2. BMI time series analysis
****************************************************************************/

* 2.0. patients - date of BMI measurement - BMI;

proc contents data=m.vitals_signs;
	title "m.vitals_signs";
run;

proc print data=m.vitals_signs (obs=30);
	title "m.vitals_signs";
run;

/**************************************************
* new table: m.bmi
* original table: m.vitals_signs
* description: only bmi info sorted by patients.id
**************************************************/

* 2.1. make a table with only BMI information sorted by patients.id;

proc sort data=m.vitals_signs
		out=m.bmi;
	where code="39156-5";
	by patient_id;
run;               /* 64,412,764 obs */

proc print data=m.bmi (obs=30) label;
	label date = "Date"
		num_value = "BMI";
	var patient_id date num_value;
	title "[m.bmi] BMI measurement date";
run;


* 2.2. add variable named 'startdate' to indicate 'minimum date of BMI measurement';

/**************************************************
* new table: m.bmi_startdate
* original table: m.bmi
* description: indicate the min(date) as startdate
**************************************************/

proc sql;
	create table m.bmi_startdate as
	select patient_id, min(date) as startdate
	from m.bmi
	group by patient_id;
quit;
proc print data=m.bmi_startdate (obs=30);
	title "m.bmi_startdate";
run;

* 2.3. do mapping startdate with 'm.bmi' table by patient.id;

/**************************************************
* new table: m.bmi_date
* original table: m.bmi + m.bmi_startdate
* description: left join m.bmi & m.bmi_startdate
**************************************************/

proc sql;
  create table m.bmi_date as
  select distinct a.*, b.startdate
  from m.bmi a left join m.bmi_startdate b 
  on a.patient_id=b.patient_id;
quit;                  /* 60513355 obs */  

proc sort data=m.bmi_date;
	by patient_id date;
run;

proc print data=m.bmi_date (obs=30) label;
	var patient_id startdate date num_value;
	label num_value = "BMI";
	title "m.bmi_date";
run;


/****************************************************************************
* 3. weight time series analysis
****************************************************************************/

* 3.1. make a table with only Weight information sorted by patients.id;

/**************************************************
* new table: m.weight
* original table: m.vitals_signs
* description: only bmi info sorted by patients.id
**************************************************/

proc sort data=m.vitals_signs
		out=m.weight;
	where code="29463-7";
	by patient_id;
run;                  /*76,331,021 obs*/

proc print data=m.weight (obs=30);      * this is basic form of the "m.weight" table;
	title "m.weight";
run;

* 3.2. add variable named 'startdate' to indicate 'minimum date of BMI measurement';

/**************************************************
* new table: m.weight_startdate
* original table: m.weight
* description: indicate the min(date) as startdate
**************************************************/

proc sql;
	create table m.weight_startdate as
	select patient_id, min(date) as startdate
	from m.weight
	group by patient_id;
quit;
proc print data=m.weight_startdate (obs=30);
	title "m.weight_startdate";
run;


* 3.3. do mapping startdate with 'm.bmi' table by patient.id;

/**************************************************
* new table: m.weight_date
* original table: m.weight + m.weight_startdate
* description: left join m.weight & m.weight_startdate
**************************************************/

proc sql;
  create table m.weight_date as
  select distinct a.*, b.startdate
  from m.weight a left join m.weight_startdate b 
  on a.patient_id=b.patient_id;
quit;                  /* 60,513,355 obs */  

proc sort data=m.weight_date;
	by patient_id date;
run;                        /* 62,231,802 obs*/

proc print data=m.weight_date (obs=30) label;
	var patient_id startdate date num_value;
	label num_value = "Weight";
	title "m.weight_date";
run;




