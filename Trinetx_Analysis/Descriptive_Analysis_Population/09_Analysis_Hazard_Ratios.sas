
/************************************************************************************
| Project name : Thesis - BS and GLP1
| Program name : 09_Analysis_COX_Hazard_Ratios
| Date (update): July 2024
| Task Purpose : 
|      1. model 1 | unadjusted Hazard ratio for the first GLP-1 initiation | stratified by bs_type
|      2. model 2 | unadjusted Hazard ratio for the first GLP-1 initiation | stratified by Molecule (glp1_type_cat)
|      3. 
| Main dataset : (1) min.bs_user_all_v07, (2) tx.medication_ingredient, (3) tx.medication_drug (adding quantity_dispensed + days_supply)
| Final dataset : min.bs_glp1_user_v03 (with duplicated indiv)
************************************************************************************/


/************************************************************************************
	STEP 1. model 1 | unadjusted Hazard ratio for the first GLP-1 initiation 
                    stratified by bs_type
                    covariate : none
************************************************************************************/

* 1.1. Unadjusted HR stratified by bs_type_cat;

ods graphics on;

proc phreg data=min.time_to_glp1_v08;
    class bs_type_cat / param=ref ref=first; 
	  model time_to_exit*init_glp1_event(0) = bs_type_cat / eventcode=1 risklimits;
    assess var = (bs_type_cat) / resample;                             /* Check proportionality assumption */
run;        /* 697 obs with invalid time (negative value) were deleted */
 

* 1.2. KM-curve - Cumulative incidence curve;

proc lifetest data=min.time_to_glp1_v08 plots=cif(test);       
   time time_to_exit * init_glp1_event(0)/eventcode=1;
   strata bs_type / test=logrank adjust=sidak order=internal;
run;      /* 697 obs with invalid time (negative value) were deleted */


* 1.3. KM-curve - Survival curve;

proc lifetest data=min.time_to_glp1_v08 plots=survival(atrisk=0 to 2500 by 500);       
   time time_to_exit * init_glp1_event(0);
   strata bs_type / test=logrank adjust=sidak order=internal;
run;    /* 697 obs with invalid time (negative value) were deleted */


* 1.4. Cumulative Hazard curve to estimate hazard in continuous time metric;

proc phreg data=min.time_to_glp1_v08;
    class bs_type_cat / param=ref ref=first; 
	  model time_to_exit * init_glp1_event(0) = bs_type_cat / eventcode=1 risklimits;
    assess var = (bs_type_cat) / resample;
    baseline out=baseline_dataset covariates=covariate_dataset cumhaz=cum_haz_variable;
run;


proc icphreg data=min.time_to_glp1_v08 plot=cumhaz;
   class bs_type_cat / desc;
   model (time_to_exit, init_glp1_event) = bs_type_cat / basehaz=splines eventcode=1 risklimits;
   /* baseline covariates=cov; */
run;

proc sgplot data=min.time_to_glp1_v08;
    series x=time y=survival / group=bs_type_cat;
    xaxis label="Time to Exit";
    yaxis label="Cumulative Hazard";
run;


/************************************************************************************
	STEP 2. model 2 | Unadjusted Hazard ratio for the first GLP-1 initiation 
                    by BS type
		    stratified by Molecule (glp1_type_cat)
                    covariate : none
************************************************************************************/

* 2.1. make dataset for the make sub-cohort by BS types;
/**************************************************
* new dataset: min.time_to_glp1_v08_rygb
*		min.time_to_glp1_v08_sg
*		min.time_to_glp1_v08_agb
*		min.time_to_glp1_v08_sadi_s
*		min.time_to_glp1_v08_bpd
* original dataset: min.time_to_glp1_v08
* description: make sub-cohort by BS types
**************************************************/

data min.time_to_glp1_v08_rygb;
	set min.time_to_glp1_v08;
 	if bs_type = "rygb";
run;   /* 8842 obs */

data min.time_to_glp1_v08_sg;
	set min.time_to_glp1_v08;
 	if bs_type = "sg";
run;   /* 15847 obs */

data min.time_to_glp1_v08_agb;
	set min.time_to_glp1_v08;
 	if bs_type = "agb";
run;   /* 260 obs */

data min.time_to_glp1_v08_sadi_s;
	set min.time_to_glp1_v08;
 	if bs_type = "sadi_s";
run;   /* 1480 obs */

data min.time_to_glp1_v08_bpd;
	set min.time_to_glp1_v08;
 	if bs_type = "bpd";
run;   /* 11955 obs */


* 2.2. Unadjusted HR stratified by Molecule (glp1_type_cat);

ods graphics on;

proc phreg data=min.time_to_glp1_v08_rygb;
    class glp1_type_cat / param=ref ref=first; 
	  model time_to_exit*init_glp1_event(0) = glp1_type_cat / eventcode=1 risklimits;
    assess var = (glp1_type_cat) / resample;                             /* Check proportionality assumption */
run;            /* 7508 obs with invalid time (negative value) were deleted */

proc phreg data=min.time_to_glp1_v08_sg;
    class glp1_type_cat / param=ref ref=first; 
	  model time_to_exit*init_glp1_event(0) = glp1_type_cat / eventcode=1 risklimits;
    assess var = (glp1_type_cat) / resample;                             /* Check proportionality assumption */
run;            /* 12497 obs with invalid time (negative value) were deleted */


* 1.2. KM-curve - Cumulative incidence curve;

proc lifetest data=min.time_to_glp1_v08_rygb plots=cif(test);       
   time time_to_exit * init_glp1_event(0)/eventcode=1;
   strata Molecule / test=logrank adjust=sidak order=internal;
run;  

proc lifetest data=min.time_to_glp1_v08_sg plots=cif(test);       
   time time_to_exit * init_glp1_event(0)/eventcode=1;
   strata Molecule / test=logrank adjust=sidak order=internal;
run;  


* 1.3. KM-curve - Survival curve;

proc lifetest data=min.time_to_glp1_v08_rygb plots=survival(atrisk=0 to 2500 by 500);       
   time time_to_exit * init_glp1_event(0);
   strata Molecule / test=logrank adjust=sidak order=internal;
run;   /* 7508 obs with invalid time (negative value) were deleted */

proc lifetest data=min.time_to_glp1_v08_sg plots=survival(atrisk=0 to 2500 by 500);       
   time time_to_exit * init_glp1_event(0);
   strata Molecule / test=logrank adjust=sidak order=internal;
run;   /* 12497 obs with invalid time (negative value) were deleted */

proc lifetest data=min.time_to_glp1_v08_agb plots=survival(atrisk=0 to 2500 by 500);       
   time time_to_exit * init_glp1_event(0);
   strata Molecule / test=logrank adjust=sidak order=internal;
run;   /* 196 obs with invalid time (negative value) were deleted */

proc lifetest data=min.time_to_glp1_v08_sadi_s plots=survival(atrisk=0 to 2500 by 500);       
   time time_to_exit * init_glp1_event(0);
   strata Molecule / test=logrank adjust=sidak order=internal;
run;   /* 1342 obs with invalid time (negative value) were deleted */

proc lifetest data=min.time_to_glp1_v08_bpd plots=survival(atrisk=0 to 2500 by 500);       
   time time_to_exit * init_glp1_event(0);
   strata Molecule / test=logrank adjust=sidak order=internal;
run;   /* 11659 obs with invalid time (negative value) were deleted */



* 1.4. Cumulative Hazard curve to estimate hazard in continuous time metric;



