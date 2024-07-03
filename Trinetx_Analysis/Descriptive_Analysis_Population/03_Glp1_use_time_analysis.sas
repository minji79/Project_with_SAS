
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 03_Glp1_use_time_analysis
| Date (update): June 2024
| Task Purpose : 
|      1. Analysis of glp1 initiation point compared to bs_date across types of temporality (before/after)
|      2. Analysis of glp1 duration across types of temporality (before/after)
|      3. 
|      4. [additional analysis] Specify individuals who have switching within glp1 (semaglutide)
|      5. [additional analysis] GLP1 time series analysis
| Main dataset : (1) min.bs_glp1_user_v03
************************************************************************************/


/**************************************************
              Variable Definition
* table: min.bs_glp1_user_v03
* temporality
*       0  : no glp1_user   (n = 33125)
*       1  : take glp1 before BS   (n = 4151)
*       2  : take glp1 after BS    (n = 5259)
* glp1_expose_period
**************************************************/

/*
이거 나중에 할 것!
proc sgplot data=min.bs_glp1_user_v03;
  vbox bmi정보 / group = temporality;
run;
*/


/* 
how to delete table
proc datasets library=min nolist;
    delete bs_glp1_user_v03_1;
quit;
*/

/************************************************************************************
	STEP 1. Analysis of glp1 initiation point compared to bs_date across types of temporality (before/after)
************************************************************************************/

* 1.1. exploratory analysis and categorization of gap;

proc means data=min.bs_glp1_user_v03
	n mean median min max std ;
	var glp1_before_bs;
	title "glp1_before_bs";
run;

proc means data=min.bs_glp1_user_v03
	n mean median min max std ;
	var glp1_after_bs;
	title "glp1_after_bs";
run;

/**************************************************
* new dataset: min.bs_glp1_user_v04
* original dataset: min.bs_glp1_user_v03
* description: glp1 before BS
**************************************************/

/**************************************************
              Variable Definition
* table: min.bs_glp1_user_v04
* gap_glp1_bs_cat
* 1.   'bf 5y+'    : over 5 years before the bs surgery  (n = 00)
* 2.   'bf 4-5y'   : 4-5 years before the bs surgery  (n = 00)
* 3.   '3-4y bf'   : 3-4 years before the bs surgery  (n = 00)
* 4.   '2-3y bf'   : 2-3 years before the bs surgery  (n = 00)
* 5.   '18-24m bf' : 18-24 months before the bs surgery  (n = 00)
* 6.   '12-18m bf' : 12-18 months before the bs surgery  (n = 00)
* 7.   '6-12m bf'  : 6-12 months before the bs surgery  (n = 00)
* 8.   '1-6m bf'   : 1-6 months before the bs surgery  (n = 00)
* 9.   '0-1m bf'   : 0-1 months before the bs surgery  (n = 00)
*
* 10.   '0-1m af'   : 0-1 months after the bs surgery  (n = 00)
* 11.   '1-6m af'   : 1-6 months after the bs surgery  (n = 00)
* 12.   '6-12m af'  : 6-12 months after the bs surgery  (n = 00)
* 13.   '12-18m af' : 12-18 months after the bs surgery  (n = 00)
* 14.   '18-24m af' : 18-24 months after the bs surgery  (n = 00)
* 15.   '2-3y af'   : 2-3 years after the bs surgery  (n = 00)
* 16.   '3-4y af'   : 3-4 years after the bs surgery  (n = 00)
* 17.   '4-5y af'   : 4-5 years after the bs surgery  (n = 00)
* 18.   '+5y af'    : over 5 years after the bs surgery  (n = 00)
*
* 19.   'NA'                : no glp1_user  (n = 00)
**************************************************/

data min.bs_glp1_user_v04;
  set min.bs_glp1_user_v03;
  format gap_glp1_bs_cat $16.;
    if           missing(gap_glp1_bs)                           then gap_glp1_bs_cat = 'NA';
    else if              gap_glp1_bs < -365*5                   then gap_glp1_bs_cat = 'bf 5y+';
    else if  -365*5   <= gap_glp1_bs and gap_glp1_bs < -365*4   then gap_glp1_bs_cat = 'bf 4-5y';
    else if  -365*4   <= gap_glp1_bs and gap_glp1_bs < -365*3   then gap_glp1_bs_cat = 'bf 3-4y';
    else if  -365*3   <= gap_glp1_bs and gap_glp1_bs < -365*2   then gap_glp1_bs_cat = 'bf 2-3y';
    else if  -365*2   <= gap_glp1_bs and gap_glp1_bs < -365*1.5 then gap_glp1_bs_cat = 'bf 18-24m';
    else if  -365*1.5 <= gap_glp1_bs and gap_glp1_bs < -365*1.0 then gap_glp1_bs_cat = 'bf 12-18m';
    else if  -365*1.0 <= gap_glp1_bs and gap_glp1_bs < -365*0.5 then gap_glp1_bs_cat = 'bf 6-12m';
    else if  -365*0.5 <= gap_glp1_bs and gap_glp1_bs < -30      then gap_glp1_bs_cat = 'bf 1-6m';
    else if  -30      <= gap_glp1_bs and gap_glp1_bs < 0        then gap_glp1_bs_cat = 'bf 0-1m';
    else if  0        <= gap_glp1_bs and gap_glp1_bs < 30       then gap_glp1_bs_cat = 'af 0-1m';
    else if  30       <= gap_glp1_bs and gap_glp1_bs < 365*0.5  then gap_glp1_bs_cat = 'af 1-6m';
    else if  365*0.5  <= gap_glp1_bs and gap_glp1_bs < 365*1.0  then gap_glp1_bs_cat = 'af 6-12m';
    else if  365*1.0  <= gap_glp1_bs and gap_glp1_bs < 365*1.5  then gap_glp1_bs_cat = 'af 12-18m';
    else if  365*1.5  <= gap_glp1_bs and gap_glp1_bs < 365*2    then gap_glp1_bs_cat = 'af 18-24m';
    else if  365*2    <= gap_glp1_bs and gap_glp1_bs < 365*3    then gap_glp1_bs_cat = 'af 2-3y';
    else if  365*3    <= gap_glp1_bs and gap_glp1_bs < 365*4    then gap_glp1_bs_cat = 'af 3-4y';
    else if  365*4    <= gap_glp1_bs and gap_glp1_bs < 365*5    then gap_glp1_bs_cat = 'af 4-5y';
    else if  365*5    <= gap_glp1_bs                            then gap_glp1_bs_cat = 'af 5y+';
run;

data min.bs_glp1_user_v04;
  set min.bs_glp1_user_v03;
  format gap_glp1_bs_cat $16. gap_glp1_bs_cat_n 8.;
    if           missing(gap_glp1_bs)                           then do;
      gap_glp1_bs_cat = 'NA';
      gap_glp1_bs_cat_n = 19;
    end;
    else if              gap_glp1_bs < -365*5                   then do;
      gap_glp1_bs_cat = 'bf 5y+';
      gap_glp1_bs_cat_n = 1; 
      end;
    else if  -365*5   <= gap_glp1_bs and gap_glp1_bs < -365*4   then do;
      gap_glp1_bs_cat = 'bf 4-5y';
      gap_glp1_bs_cat_n = 2;
    end;
    else if  -365*4   <= gap_glp1_bs and gap_glp1_bs < -365*3   then do;
      gap_glp1_bs_cat = 'bf 3-4y';
      gap_glp1_bs_cat_n = 3;
    end;
    else if  -365*3   <= gap_glp1_bs and gap_glp1_bs < -365*2   then do;
      gap_glp1_bs_cat = 'bf 2-3y';
      gap_glp1_bs_cat_n = 4;
    end;
    else if  -365*2   <= gap_glp1_bs and gap_glp1_bs < -365*1.5 then do;
      gap_glp1_bs_cat = 'bf 18-24m';
      gap_glp1_bs_cat_n = 5;
    end;
    else if  -365*1.5 <= gap_glp1_bs and gap_glp1_bs < -365*1.0 then do;
      gap_glp1_bs_cat = 'bf 12-18m';
      gap_glp1_bs_cat_n = 6;
    end;
    else if  -365*1.0 <= gap_glp1_bs and gap_glp1_bs < -365*0.5 then do;
      gap_glp1_bs_cat = 'bf 6-12m';
      gap_glp1_bs_cat_n = 7;
    end;
    else if  -365*0.5 <= gap_glp1_bs and gap_glp1_bs < -30      then do;
      gap_glp1_bs_cat = 'bf 1-6m';
      gap_glp1_bs_cat_n = 8;
    end;
    else if  -30      <= gap_glp1_bs and gap_glp1_bs < 0        then do;
      gap_glp1_bs_cat = 'bf 0-1m';
      gap_glp1_bs_cat_n = 9;
    end;
    else if  0        <= gap_glp1_bs and gap_glp1_bs < 30       then do;
      gap_glp1_bs_cat = 'af 0-1m';
      gap_glp1_bs_cat_n = 10;
    end;
    else if  30       <= gap_glp1_bs and gap_glp1_bs < 365*0.5  then do;
      gap_glp1_bs_cat = 'af 1-6m';
      gap_glp1_bs_cat_n = 11;
    end;
    else if  365*0.5  <= gap_glp1_bs and gap_glp1_bs < 365*1.0  then do;
      gap_glp1_bs_cat = 'af 6-12m';
      gap_glp1_bs_cat_n = 12;
    end;
    else if  365*1.0  <= gap_glp1_bs and gap_glp1_bs < 365*1.5  then do;
      gap_glp1_bs_cat = 'af 12-18m';
      gap_glp1_bs_cat_n = 13;
    end;
    else if  365*1.5  <= gap_glp1_bs and gap_glp1_bs < 365*2    then do;
      gap_glp1_bs_cat = 'af 18-24m';
      gap_glp1_bs_cat_n = 14;
    end;
    else if  365*2    <= gap_glp1_bs and gap_glp1_bs < 365*3    then do;
      gap_glp1_bs_cat = 'af 2-3y';
      gap_glp1_bs_cat_n = 15;
    end;
    else if  365*3    <= gap_glp1_bs and gap_glp1_bs < 365*4    then do;
      gap_glp1_bs_cat = 'af 3-4y';
      gap_glp1_bs_cat_n = 16;
    end;
    else if  365*4    <= gap_glp1_bs and gap_glp1_bs < 365*5    then do;
      gap_glp1_bs_cat = 'af 4-5y';
      gap_glp1_bs_cat_n = 17;
    end;
    else if  365*5    <= gap_glp1_bs                            then do;
      gap_glp1_bs_cat = 'af 5y+';
      gap_glp1_bs_cat_n = 18;
    end;
run;


proc print data=min.bs_glp1_user_v04 (obs=30);
  var patient_id glp1_user gap_glp1_bs gap_glp1_bs_cat gap_glp1_bs_cat_n;
  where glp1_user = 1;
  title "min.bs_glp1_user_v04";
run;


* 1.2. frequency distribution of gap_glp1_bs_cat;

proc freq data=min.bs_glp1_user_v04;
  table gap_glp1_bs_cat;
  title "distribution of gap_glp1_bs_cat";
run;

proc sgplot data=min.bs_glp1_user_v04;
	  histogram gap_glp1_bs / binwidth=180 scale=count;
   density gap_glp1_bs / type=Normal;
 title "gap_glp1_bs_cat";
run;



/************************************************************************************
	STEP 2. Analysis of glp1 duration across types of temporality (before/after)
************************************************************************************/

* 2.1. Analysis of glp1 duration across types of temporality (before/after);

proc means data=min.bs_glp1_user_v04
	n mean median min max std nmiss ;
	var glp1_expose_period;
  where temporality = 1 ;
	title "glp1 duration - used before the surgery";
run;

proc means data=min.bs_glp1_user_v04
	n mean median min max std nmiss ;
	var glp1_expose_period;
  where temporality = 2 ;
	title "glp1 duration - used after the surgery";
run;






/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/
/*******************************************************************************************************************************************************************/


/************************************************************************************
	STEP 4. [additional analysis] Among glp1 user, specify individuals who have switching within glp1 (semaglutide) 
************************************************************************************/

/**************************************************
* new dataset: min.glp1_user_swt
* original dataset: min.glp1_user_all
* description: select the individuals switching medication within glp1
**************************************************/

* 9.1. make the copy of glp1_users_all with only two variables;

proc sql;
    create table min.glp1_user_swt as
    select patient_id, code, start_date /* Include the date variable */
    from min.glp1_user_all
    order by patient_id, start_date; /* Sort by patient_id and date */
quit;        /* 17,280,539 obs */

proc sql;
    create table min.glp1_user_swt as
    select patient_id, code
    from min.glp1_user_all
quit;

proc sql;
    create table min.glp1_user_swt as
    select patient_id, code
    from min.glp1_user_all
    group by patient_id;
quit;                          /* 17,280,539 obs */
proc print data=min.glp1_user_swt (obs=30); 
	title "min.glp1_user_swt";
run;

* 9.2. need to check with example of individuals ("#A#4", "#A#BC", "#A#GB");
* check the order of the rows reflected real prescription date;

proc print data=min.glp1_user_all (obs = 30); 
    where patient_id in ('#A#4', '#A#BC', '#A#GB');
    title "example of '#A#4', '#A#BC', '#A#GB'";
run;


* 9.3. Remove the duplication rows - but still have all of drug's code that indiv have;

proc sort data=min.glp1_user_swt nodupkey out=min.glp1_user_swt;
    by _all_;
proc print data=min.glp1_user_swt (obs=30); 
	title "min.glp1_user_swt";
run;                            /* remove the duplicated rows - but still have all of drug that indiv have */

* 9.4. select the individuals switching medication within glp1 - with codes;

/**************************************************
* new dataset: min.glp1_user_swt_v01
* original dataset: min.glp1_user_swt
* description: select the individuals switching medication within glp1
*		var: patient_id, code, drug_count
**************************************************/

proc sql;
    create table min.glp1_user_swt_v01 as
    select patient_id, code, count(distinct code) as drug_count
    from min.glp1_user_swt
    group by patient_id
    having drug_count > 1;
quit;              /* 533,896 obs : including duplications - not distinct  */

proc print data=min.glp1_user_swt_v01 (obs=30); 
	title "min.glp1_user_swt_v01";
run;   


* 9.5. select the "distinct" individuals switching medication within glp1 - without codes;

/**************************************************
* new dataset: min.glp1_user_swt_v02
* original dataset: min.glp1_user_swt_v01
* description: select the individuals switching medication within glp1
*		count "distinct" number of switching individuals
*		discriptive analysis of the number of switching
*		var: patient_id, drug_count
**************************************************/

data min.glp1_user_swt_v02 (drop = code);
	set min.glp1_user_swt_v01;
proc print data=min.glp1_user_swt_v02 (obs = 30);
	title "min.glp1_user_swt_v02";
run;

proc sort data=min.glp1_user_swt_v02 nodupkey out=min.glp1_user_swt_v02;
    by _all_;
proc print data=min.glp1_user_swt_v02 (obs=30); 
	title "min.glp1_user_swt_v02";
run;                                   /* 239,328 distinct individuals */ 

proc contents data=min.glp1_user_swt_v02;
	title "min.glp1_user_swt_v02";
run; 


/*
the total of 239,328 individuals switched their glp1 to another type of glp1

*/



/************************************************************************************
	STEP 5. [additional analysis] GLP1 time series analysis
************************************************************************************/

* 7. make time series table;

/**************************************************
* new dataset: min.glp1_user_all_time_series
* original dataset: min.glp1_user_all_date
* description: time series table
**************************************************/

data min.glp1_user_all_time_series;
	set min.glp1_user_all_date;
	array months[37] m0-m36;    
	do i = 1 to 37;            
        	months[i] = .;
   	end;
	if gap >= 0 then do;      
	idx = floor(gap / 30); 
        if idx <= 36 then months[idx+1] = 1; 
   	end;
	drop i idx;
run;                   /* 17,280,539 obs */

proc print data = min.glp1_user_all_time_series (obs = 30) label;
  var patient_id Initiation_date start_date unique_id Molecule strength gap m0-m36;
  label start_date = "Date"
  gap = "Date gap";
  title "min.glp1_user_all_time_series";
run;


* 8. link the medication_drug file to the min.glp1_user_all (which is from medication_ingredient);

/**************************************************
* new dataset: min.glp1_user_all_merge
* original dataset: min.glp1_user_all + tx.medication_drug
* description: by merging min.glp1_user_all & tx.medication_drug, add 'quantity_dispensed' and 'days_supply' variables to the glp1 user data set
**************************************************/

proc sql;
  create table min.glp1_user_all_merge as
  select distinct a.*, b.quantity_dispensed, b.days_supply
  from min.glp1_user_all a left join tx.medication_drug b 
  on a.unique_id=b.unique_id;
quit;  

proc print data=min.glp1_user_all_merge (obs = 40);
	title "min.glp1_user_all_merge";
run;


* check the missing value to check that the two variables were added properly ;  /* it doesn;t work */

data min.glp1_user_all_merge;
  set min.glp1_user_all_merge;
  num_value = input(value, 8.);
run; 

data min.glp1_user_all_merge;
	set min.glp1_user_all_merge;
	quantity_dispensed_num = input(quantity_dispensed, $12.);
	days_supply_num = input(days_supply, $5.);
	format quantity_dispensed_num days_supply_num 8.;
	drop quantity_dispensed days_supply;
    rename quantity_dispensed_num=quantity_dispensed days_supply_num=days_supply;
run;
proc contents data = min.glp1_user_all_merge;
	title "min.glp1_user_all_merge";
run;

proc means data=min.glp1_user_all_merge N NMISS;
    var quantity_dispensed days_supply;
run;























