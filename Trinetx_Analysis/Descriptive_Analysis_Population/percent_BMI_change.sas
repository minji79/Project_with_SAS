
* calculate percent BMI change;

proc means data=min.bs_glp1_bmi_v01_18937 n nmiss median p25 p75;
    var bmi_index;
    title "bmi_index";
run;

proc sql;
  create table min.bmi_change_1y_af as 
  select a.patient_id, a.bmi_index, b.bmi
  from min.bs_glp1_bmi_v01_18937 a left join min.bs_glp1_bmi_1y_af_v02 b
  on a.patient_id = b.patient_id;
quit; /* 8104 */

* delete any null value in bmi or bmi_index;


proc print data=min.bmi_change_1y_af (obs=30);
run;

data bmi_change_1y_af;
    set min.bs_glp1_bmi_index_16844_v01;
    
    /* Calculate Percent BMI Change */
    percent_bmi_change = ((bmi - bmi_index) / bmi_index) * 100;
run;

/* Step 2: Calculate Medians and Perform Wilcoxon Test */
proc npar1way data=bmi_change wilcoxon;
    class group; /* Group variable differentiates between the two groups */
    var percent_bmi_change;
    exact wilcoxon; /* Use for small sample sizes */
run;

proc ttest data=min.bs_glp1_bmi_index_16844_v01;
   class temporality;
   var bmi_index;
run;

proc ttest data=min.bs_glp1_bmi_1y_af_v02;
   class temporality;
   var bmi;
run;
