
/****************************************************************************
| Project name : Thesis - BS and GLP1
| Date (update): July 2024
| Task Purpose : 
|      1. listup code for key outcome measurements (BMI, weight, height, ...)
|      2. merge BMI information with our study cohort
|      3. bmi_index | the clostest value prior to the first bs_date (n = 40,605)
|      4. bmi_bf_glp1 | the clostest value prior to the first glp1 prescription date (n = 4048)
|      5. bmi_af_glp1 | the clostest value after the glp1 discontinuation date (n = )
|      6. Make variables for BMI value over time from BS date
|      additional. weight time series analysis
| Main dataset : (1) tx.vitals_signs
****************************************************************************/

/* 

issue: 
the 'standardized_terminology.csv' file is not available now
-> 100% data로 돌렸을 때, 기존 5%로는 74개 나오던 리스트가 76개 나옴. 그러나 standard term 매칭이 안된 상황
4번 해야 함

*/

/************************************************************************************
	STEP 1. listup code for key outcome measurements from tx.vitals_signs
************************************************************************************/

* 1.1. copy the original dataset and convert 'result' values from character to numeric;
/**************************************************
* new dataset: m.vitals_signs
* original dataset: tx.vitals_signs
* description: copy file "tx.vitals_signs" with adj
**************************************************/

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


* 1.2. check the type of code systems other than LOINC to have distinct value of the code_system variable;
/**************************************************
* new dataset: m.vitals_signs_codelist
* original dataset: m.vitals_signs
* description: 
        1. listup distinct value of the code_system variable
               after checking distinct value of the code_system variable from tx.vitals_signs
        2. map standardized_terminology to the codelist from vitials_signs
**************************************************/

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


/************************************************************************************
	STEP 2. merge BMI information with our study cohort
************************************************************************************/

* 2.0. patients - date of BMI measurement - BMI;

proc contents data=m.vitals_signs;
	title "m.vitals_signs";
run;

proc print data=m.vitals_signs (obs=30);
	title "m.vitals_signs";
run;


* 2.1. make a table with only BMI information sorted by patients.id;
/**************************************************
* new table: m.bmi
* original table: m.vitals_signs
* description: only bmi info sorted by patients.id
**************************************************/

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
* new table: m.bmi_startdate (deleted)
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
proc print data=m.bmi_date (obs=30);
	title "m.bmi_date";
run;


data m.bmi_date;
    set m.bmi_date;
    date_num = input(date, yymmdd8.);
    format date_num yymmdd10.;
    drop date;
    rename date_num = date;
run;

proc means data=m.bmi_date n nmiss;
	var date;
 run;


/* delete */
proc datasets library=m nolist;
    delete bmi_startdate;
quit;


* 2.4. merge the BMI information with our study cohort;
/**************************************************
* new table: min.bs_glp1_bmi_v00   /* not distinct */
* original table: min.bs_glp1_user_v03 + m.bmi_date
* description: left join min.bs_glp1_user_v03 + m.bmi_date
**************************************************/

proc SQL;
	create table min.bs_glp1_bmi_v00 as
 	select a.*, b.date, b.num_value
  	from min.bs_glp1_user_v03 as a left join m.bmi_date as b
   	on a.patient_id = b.patient_id;
quit;                         /* 865,451 obs - duplicated */

/* adjusted format and name of variables */
data min.bs_glp1_bmi_v00;
    set min.bs_glp1_bmi_v00;
    bmi_date_num = input(date, yymmdd8.);
    format bmi_date_num yymmdd10.;
    drop date code code_system derived_by_TriNetX;
    rename bmi_date_num = bmi_date glp1_date = glp1_last_date num_value = bmi;
run;

proc contents data=min.bs_glp1_bmi_v00;
	title "min.bs_glp1_bmi_v00";
run;

proc print data=min.bs_glp1_bmi_v00 (obs=30);
	var patient_id glp1_initiation_date glp1_last_date glp1_gap glp1_expose_period bmi_date bmi;
	where temporality =1;
	title "min.bs_glp1_bmi_v00";
run;

proc means data=min.bs_glp1_bmi_v00 n nmiss;
	var bmi bmi_date;
run;

proc sql;
	select count(distinct patient_id) as distinct_patient_count
 	from min.bs_glp1_bmi_v00;
quit;           /* it should be the same as "42,535 - BS users" - yes, it is! */


/************************************************************************************
	STEP 3. bmi_index | the clostest value prior to the first bs_date (n = 18937)
************************************************************************************/

/**************************************************
              Variable Definition
* table:
* 	min.bs_glp1_bmi_v01_18937
* 	min.bs_glp1_bmi_v02_4048
* 	min.bs_glp1_bmi_v03_
* variables
*  bmi_index : the clostest value prior to the first bs_date
*  bmi_bf_glp1 : the clostest value prior to the first glp1 prescription date
*  bmi_af_glp1 : the clostest value after discontinuation of the last glp1 prescription with assuming 60 days of supply
**************************************************/

* 3.1. generate 'bmi_index' variable;
/**************************************************
* new table: min.bs_glp1_bmi_v01_18937     /* 18937 */
* original table: min.bs_glp1_bmi_v00
* description: indicate 'bmi_index; which is the closest value prior to the first bs_date
**************************************************/

data min.bs_glp1_bmi_v01_18937;
	set min.bs_glp1_bmi_v00;
 	if missing(bmi_date) then delete;
run;
proc sql;
	select count(distinct patient_id) as distinct_patient_count
 	from min.bs_glp1_bmi_v01_18937;
  	title "min.bs_glp1_bmi_v01_18937";
quit;     /* 20867 distinct patients */

data min.bs_glp1_bmi_v01_18937;
	set min.bs_glp1_bmi_v01_18937;
 	if bmi_date < bs_date then do;
  		gap1 = bs_date - bmi_date;
  	end;
 	else delete;
run;          /* 396445 obs  (= 18937 distinct patients) */

proc sort data=min.bs_glp1_bmi_v01_18937;
	by patient_id gap1;
run;  

data min.bs_glp1_bmi_v01_18937;
	set min.bs_glp1_bmi_v01_18937;
 	by patient_id;
 	if first.patient_id;
run;       /* 18937 distinct patients */

data min.bs_glp1_bmi_v01_18937;
	set min.bs_glp1_bmi_v01_18937;
 	bmi_index = bmi;
run;

data min.bs_glp1_bmi_v01_18937;
	set min.bs_glp1_bmi_v01_18937;
 	if temporality ne 1;
  run;


proc print data=min.bs_glp1_bmi_v01_18937 (obs=30);
	var patient_id bs_date bmi_date gap1 bmi bmi_index;
 	title "min.bs_glp1_bmi_v01_18937";
run;


/*
proc datasets library=min nolist;
    delete bs_glp1_bmi_v01;
quit;
*/


* 3.2. calculate the median and IQR for total population;

proc means data=min.bs_glp1_bmi_v01_18937 n nmiss median p25 p75;
    var bmi_index;
    title "bmi_index";
run;

* 3.3. calculate the median and IQR for each sub-group population;

proc sort data=min.bs_glp1_bmi_v01_18937;
	by temporality;
run;

proc means data=min.bs_glp1_bmi_v01_18937 n nmiss median p25 p75;
    var bmi_index;
    by temporality;
	title "bmi_index";
   run;


/************************************************************************************
	STEP 4. bmi_bf_glp1 | the clostest value prior to the first glp1 prescription date (n = 4048)
************************************************************************************/

* 4.1. generate 'bmi_bf_glp1' variable;
/**************************************************
* new table: min.bs_glp1_bmi_v02_4048     /* 4048 */
* original table: min.bs_glp1_bmi_v00
* description: indicate 'bmi_bf_glp1; which is the clostest value prior to the first glp1 prescription date
**************************************************/

data min.bs_glp1_bmi_v02;
	set min.bs_glp1_bmi_v00;
 	if missing(bmi_date) then delete;
run;         /* 865451 obs -> 843783 obs */

data min.bs_glp1_bmi_v02;
	set min.bs_glp1_bmi_v02;
 	if bmi_date < glp1_initiation_date then do;
  		gap2 = glp1_initiation_date  - bmi_date;
  	end;
 	else delete;
run;          /* 134298 obs  (= 4048 distinct patients) */

proc sort data=min.bs_glp1_bmi_v02;
	by patient_id gap2;
run;  

data min.bs_glp1_bmi_v02;
	set min.bs_glp1_bmi_v02;
 	by patient_id;
 	if first.patient_id;
run;       /* 4048 distinct patients */

data min.bs_glp1_bmi_v02_4048;
	set min.bs_glp1_bmi_v02;
 	bmi_bf_glp1 = bmi;
run;

proc print data=min.bs_glp1_bmi_v02_4048 (obs=30);
	var patient_id bs_date bmi_date gap2 bmi bmi_bf_glp1;
 	title "min.bs_glp1_bmi_v02_4048";
run;

/*
proc datasets library=min nolist;
    delete bs_glp1_bmi_v02;
quit;
*/


* 4.2. calculate the median and IQR for the total population;

proc means data=min.bs_glp1_bmi_v02_4048 n nmiss median p25 p75;
    var bmi_bf_glp1;
	title "min.bs_glp1_bmi_v02_4048";
run;


* 4.3. calculate the median and IQR for each sub-group population;

proc sort data=min.bs_glp1_bmi_v02_4048;
	by temporality;
run;

proc means data=min.bs_glp1_bmi_v02_4048 n nmiss median p25 p75;
    var bmi_bf_glp1;
    by temporality;
    title "min.bs_glp1_bmi_v02_4048";
run;

proc print data=iqr_results;
run;


/************************************************************************************
	STEP 5. bmi_af_glp1 | the clostest value after discontinuation of the last glp1 prescription with assuming 60 days of supply (n = )
************************************************************************************/


/************************************************************************************
	STEP 6. Make variables for BMI value over time from BS date
************************************************************************************/

/*
variables' name
bmi_1y_bf | BMI 1 year before the BS date
bmi_6m_bf | BMI 6 months before the BS date
bmi_1y_af | BMI 1 year after the BS date
bmi_2y_af | BMI 2 years after the BS date
bmi_3y_af | BMI 3 years after the BS date
*/


* 6.1. bmi_1y_bf | BMI 1 year before the BS date;
/**************************************************
* new table: min.bs_glp1_bmi_1y_bf_v00    
* original table: min.bs_glp1_bmi_v00
* description: indicate 'bmi_af_glp1' which is the clostest value after discontinuation of the last glp1 prescription with assuming 60 days of supply
**************************************************/

data min.bs_glp1_bmi_1y_bf_v00;
	set min.bs_glp1_bmi_v00;
 	if missing(bmi_date) then delete;
  if temporality = 1 then delete;
run;         /* 865451 obs -> 843783 obs */


data min.bs_glp1_bmi_1y_bf_v01;
   set min.bs_glp1_bmi_1y_bf_v00;
   if bs_date - 365 < bmi_date and bmi_date < bs_date then do;
   	gap = bmi_date - bs_date + 365;
   end;
   else delete;
run;

proc sort data = min.bs_glp1_bmi_1y_bf_v01;
	by patient_id gap;
run;     /* the smaller gap = the closer from the 1 yr prior to the surgery */

/* distinct population */
data min.bs_glp1_bmi_1y_bf_v02;
	set min.bs_glp1_bmi_1y_bf_v01;
 	by patient_id;
 	if first.patient_id;
run;       

data min.bs_glp1_bmi_1y_bf_v02;
	set min.bs_glp1_bmi_1y_bf_v02;
 	if temporality = 1 then delete;
run;     /* 16305 distinct patients */


/* distribution of the values */
proc sort data = min.bs_glp1_bmi_1y_bf_v02;
	by temporality;
run;

proc means data=min.bs_glp1_bmi_1y_bf_v02 n nmiss median p25 p75 min max;
	var bmi;
 	title "min.bs_glp1_bmi_1y_bf_v02";
run;
proc means data=min.bs_glp1_bmi_1y_bf_v02 n nmiss median p25 p75 min max;
	var bmi;
 	by temporality;
 	title "min.bs_glp1_bmi_1y_bf_v02";
run;


* 6.2. bmi_6m_bf | BMI 6 months before the BS date;
/**************************************************
* new table: min.bs_glp1_bmi_6m_bf_v00    
* original table: min.bs_glp1_bmi_v00
* description: indicate 'bmi_af_glp1' which is the clostest value after discontinuation of the last glp1 prescription with assuming 60 days of supply
**************************************************/

data min.bs_glp1_bmi_6m_bf_v00;    
	set min.bs_glp1_bmi_v00;
 	if missing(bmi_date) then delete;
run;         /* 865451 obs -> 843783 obs */
data min.bs_glp1_bmi_6m_bf_v00;    
	set min.bs_glp1_bmi_6m_bf_v00;    
 	if temporality = 1 then delete;
run;         /* 717115 obs */


data min.bs_glp1_bmi_6m_bf_v01;
   set min.bs_glp1_bmi_6m_bf_v00;
   if bs_date - 365/2 < bmi_date and bmi_date < bs_date then do;
   	gap = bmi_date - bs_date + 365/2;
   end;
   else delete;
run;

proc sort data = min.bs_glp1_bmi_6m_bf_v01;
	by patient_id gap;
run;     /* the smaller gap = the closer from the 6 months prior to the surgery */

/* distinct population */
data min.bs_glp1_bmi_6m_bf_v02;
	set min.bs_glp1_bmi_6m_bf_v01;
 	by patient_id;
 	if first.patient_id;
run;       /* 15859 obs */

/* distribution of the values */
proc sort data = min.bs_glp1_bmi_6m_bf_v02;
	by temporality;
run;

proc means data=min.bs_glp1_bmi_6m_bf_v02 n nmiss median p25 p75 min max;
	var bmi;
 	title "min.bs_glp1_bmi_6m_bf_v02";
run;
proc means data=min.bs_glp1_bmi_6m_bf_v02 n nmiss median p25 p75 min max;
	var bmi;
 	by temporality;
 	title "min.bs_glp1_bmi_6m_bf_v02";
run;


* 6.3. bmi_1y_af | BMI 1 year after the BS date;
/**************************************************
* new table: min.bs_glp1_bmi_1y_af_v00    
* original table: min.bs_glp1_bmi_v00
* description: 
**************************************************/

data min.bs_glp1_bmi_1y_af_v00;    
	set min.bs_glp1_bmi_v00;
 	if missing(bmi_date) then delete;
run;         /* 865451 obs -> 843783 obs */
data min.bs_glp1_bmi_1y_af_v00;    
	set min.bs_glp1_bmi_1y_af_v00;    
 	if temporality = 1 then delete;
run;         /* obs */


data min.bs_glp1_bmi_1y_af_v01;
   set min.bs_glp1_bmi_1y_af_v00;
   if bs_date + 365 < bmi_date and bmi_date < bs_date + 365 + 90 then do;
   	gap = bmi_date - bs_date;
   end;
   else delete;
run;

proc sort data = min.bs_glp1_bmi_1y_af_v01;
	by patient_id gap;
run;    

/* distinct population */
data min.bs_glp1_bmi_1y_af_v02;
	set min.bs_glp1_bmi_1y_af_v01;
 	by patient_id;
 	if first.patient_id;
run;       /* 7381 obs */

/* distribution of the values */
proc sort data = min.bs_glp1_bmi_1y_af_v02;
	by temporality;
run;

proc means data=min.bs_glp1_bmi_1y_af_v02 n nmiss median p25 p75 min max;
	var bmi;
 	title "min.bs_glp1_bmi_1y_af_v02";
run;
proc means data=min.bs_glp1_bmi_1y_af_v02 n nmiss median p25 p75 min max;
	var bmi;
	by temporality;
 	title "min.bs_glp1_bmi_1y_af_v02";
run;


proc means data=min.bs_glp1_bmi_1y_af_v02 n nmiss median p25 p75 min max;
	var bmi;
 	title "min.bs_glp1_bmi_1y_af_v02";
run;
proc means data=min.bs_glp1_bmi_1y_af_v02 n nmiss median p25 p75 min max;
	var bmi;
	by temporality;
 	title "min.bs_glp1_bmi_1y_af_v02";
run;


* 6.4. bmi_2y_af | BMI 2 years after the BS date;
/**************************************************
* new table: min.bs_glp1_bmi_2y_af_v00    
* original table: min.bs_glp1_bmi_v00
* description: 
**************************************************/

data min.bs_glp1_bmi_2y_af_v00;    
	set min.bs_glp1_bmi_v00;
 	if missing(bmi_date) then delete;
run;         /* 865451 obs -> 843783 obs */
data min.bs_glp1_bmi_2y_af_v00;    
	set min.bs_glp1_bmi_2y_af_v00;    
 	if temporality = 1 then delete;
run;         /* 717115 obs */


data min.bs_glp1_bmi_2y_af_v01;
   set min.bs_glp1_bmi_2y_af_v00;
   if bs_date + 365*2 < bmi_date and bmi_date < bs_date + 365*2 + 90 then do;
   	gap = bmi_date - bs_date;
   end;
   else delete;
run;

proc sort data = min.bs_glp1_bmi_2y_af_v01;
	by patient_id gap;
run;    

/* distinct population */
data min.bs_glp1_bmi_2y_af_v02;
	set min.bs_glp1_bmi_2y_af_v01;
 	by patient_id;
 	if first.patient_id;
run;       /* 5752 obs */

/* distribution of the values */
proc sort data = min.bs_glp1_bmi_2y_af_v02;
	by temporality;
run;

proc means data=min.bs_glp1_bmi_2y_af_v02 n nmiss median p25 p75 min max;
	var bmi;
 	title "min.bs_glp1_bmi_2y_af_v02";
run;
proc means data=min.bs_glp1_bmi_2y_af_v02 n nmiss median p25 p75 min max;
	var bmi;
	by temporality;
 	title "min.bs_glp1_bmi_2y_af_v02";
run;


* 6.5. bmi_3y_af | BMI 3 years after the BS date;
/**************************************************
* new table: min.bs_glp1_bmi_3y_af_v00    
* original table: min.bs_glp1_bmi_v00
* description: 
**************************************************/

data min.bs_glp1_bmi_3y_af_v00;    
	set min.bs_glp1_bmi_v00;
 	if missing(bmi_date) then delete;
run;         /* 865451 obs -> 843783 obs */
data min.bs_glp1_bmi_3y_af_v00;    
	set min.bs_glp1_bmi_3y_af_v00;    
 	if temporality = 1 then delete;
run;         /* 717115 obs */


data min.bs_glp1_bmi_3y_af_v01;
   set min.bs_glp1_bmi_3y_af_v00;
   if bs_date + 365*3 < bmi_date and bmi_date < bs_date + 365*3 + 90 then do;
   	gap = bmi_date - bs_date;
   end;
   else delete;
run;

proc sort data = min.bs_glp1_bmi_3y_af_v01;
	by patient_id gap;
run;    

/* distinct population */
data min.bs_glp1_bmi_3y_af_v02;
	set min.bs_glp1_bmi_3y_af_v01;
 	by patient_id;
 	if first.patient_id;
run;       /* 4681 obs */

/* distribution of the values */
proc sort data = min.bs_glp1_bmi_3y_af_v02;
	by temporality;
run;

proc means data=min.bs_glp1_bmi_3y_af_v02 n nmiss median p25 p75 min max;
	var bmi;
 	title "min.bs_glp1_bmi_3y_af_v02";
run;
proc means data=min.bs_glp1_bmi_3y_af_v02 n nmiss median p25 p75 min max;
	var bmi;
	by temporality;
 	title "min.bs_glp1_bmi_3y_af_v02";
run;





/****************************************************************************
* additional analysis. weight time series analysis
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




