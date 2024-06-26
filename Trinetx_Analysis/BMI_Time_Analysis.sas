/****************************************************************************
| Program name : BMI time 
| Date (update):
| Project name :
| Purpose      : Create new BMI files from vitals and lap
****************************************************************************/

* 0. patients - date of BMI measurement - BMI;

proc contents data=mj.vitals_signs_5p;
	title "mj.vitals_signs_5p";
run;

proc print data=mj.vitals_signs_5p (obs=30);
	title "mj.vitals_signs_5p";
run;

/**************************************************
* new table: mj.bmi
* original table: mj.vitals_signs_5p
* description: only bmi info sorted by patients.id
**************************************************/

* 1. make a table with only BMI information sorted by patients.id;

proc sort data=mj.vitals_signs_5p 
		out=mj.bmi;
	where code="39156-5";
	by patient_id;
run;

proc print data=mj.bmi (obs=30);      * this is basic form of the "mj.bmi" table;
	title "mj.bmi";
run;

* 2. print "patients - date of BMI measurement - BMI';

proc print data=mj.bmi (obs=30) label;
	label date = "Date"
		num_value = "BMI";
	var patient_id date num_value;
	title "[mj.bmi] BMI measurement date";
run;

* 3. add variable named 'startdate' to indicate 'minimum date of BMI measurement';

/**************************************************
* new table: mj.bmi_startdate
* original table: mj.bmi
* description: indicate the min(date) as startdate
**************************************************/

proc sql;
	create table mj.bmi_startdate as
	select patient_id, min(date) as startdate
	from mj.bmi
	group by patient_id;
quit;
proc print data=mj.bmi_startdate (obs=30);
	title "mj.bmi_startdate";
run;

* 4. do mapping startdate with 'mj.bmi' table by patient.id;

/**************************************************
* new table: mj.bmi_date
* original table: mj.bmi + mj.bmi_startdate
* description: left join mj.bmi & mj.bmi_startdate
**************************************************/

proc sql;
  create table mj.bmi_date as
  select distinct a.*, b.startdate
  from mj.bmi a left join mj.bmi_startdate b 
  on a.patient_id=b.patient_id;
quit;

proc sort data=mj.bmi_date;
	by patient_id date;
run;

proc print data=mj.bmi_date (obs=30) label;
	var patient_id startdate date num_value;
	label num_value = "BMI";
	title "mj.bmi_date";
run;

* 5. format date;

data mj.bmi_date;
	set mj.bmi_date;
	date_num = input(date, yymmdd8.);
	startdate_num = input(startdate, yymmdd8.);
	format date_num startdate_num yymmdd10.;
	drop date startdate;
    rename date_num=date startdate_num=startdate;
run;

proc contents data = mj.bmi_date;
	title "mj.bmi_date";
run;

proc print data = mj.bmi_date (obs = 30);
	title "mj.bmi_date";
run;


* 6. calculate the gap between startdate and date;

data mj.bmi_date;
	set mj.bmi_date;
	gap = date - startdate;
run;

proc print data = mj.bmi_date (obs = 30);
	title "mj.bmi_date";
run;

proc print data=mj.bmi_date (obs=30) label;
	var patient_id startdate date num_value gap;
	label num_value = "BMI"
	gap = "Date gap";
	title "mj.bmi_date";
run;


* 7. make time series table;

/**************************************************
* new table: mj.bmi_time_series
* original table: mj.bmi_date
* description: time series table
**************************************************/

data mj.bmi_time_series;
	set mj.bmi_date;
	array months[37] m0-m36;    /* Define an array for the m0 to m36 variables */
	do i = 1 to 37;             /* Initialize all elements of the months array to missing */
        	months[i] = .;
   	end;
	if gap >= 0 then do;        /* Determine which month variable to assign num_value to based on gap */
		/* Calculate the index for the months array */	
	idx = floor(gap / 30); /* Floor function ensures integer division */
		/* Assign num_value to the appropriate variable, if within range */
        if idx <= 36 then months[idx+1] = num_value; /* Arrays are 1-based in SAS */
   	end;
	drop i idx; /* Clean up the temporary variables */
run;

proc print data=mj.bmi_time_series (obs=30) label;
  var patient_id startdate date num_value gap m0-m36;
  label num_value = "BMI [kg/m2]"
	gap = "Date gap";
	title "mj.bmi_time_series";
run;




/****************************************************************************
| Program name : BMI - compare with the calculation from weight and height 
| Date (update): 
| Project name : 
| Purpose      : 
|                 LOINC: 29463-7 : Body weight [lb_av] 
|                 LOINC: 8302-2 : Height [in_us] 
****************************************************************************/

* Step 1. compare BMI info with the calculation from weight and height;
* using Vitals files; 

proc means data = 






* Step 3. all people form vitals with 39156-5 and  all people from lab with 89270-3 and make them in one table;

proc sort data = comp_eff.pdesaf out = comp_eff.pdesaf nodup; by patient_id; run; *177158183;
data comp_eff.Pdesaf_rx;			
	merge comp_eff.pdesaf comp_eff.covariate_12(keep = patient_id in=in2);
	by patient_id;
	if in2;
run;
proc sort data = comp_eff.Pdesaf_rx out = comp_eff.Pdesaf_rx nodup; by patient_id; run;



```sas
@GetMapping("/videos")
public ResponseEntity<List<VideoListResponse>> getVideoRandomList() {
    return new ResponseEntity<>(videoService.getRandomVideos(RANDOM_VIDEO_ACCESS_SIZE), HttpStatus.OK);
}
```
