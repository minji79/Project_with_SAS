


/************************************************************************************
	STEP 1. Analysis of glp1 initiation among 38384
************************************************************************************/


* 1.1. categorize ;
/**************************************************
* new dataset: min.bs_glp1_user_38384_v01
* original dataset: min.bs_glp1_user_38384_v00
* description: 
**************************************************/

data min.bs_glp1_user_38384_v01;
  set min.bs_glp1_user_38384_v00;
  format time_to_init $16. time_to_init_cat 8.;
    if           missing(gap_glp1_bs)                           then do;
      time_to_init = .;
      time_to_init_cat = .;
    end;
    else if  0       <= gap_glp1_bs and gap_glp1_bs < 365*0.5   then do;
      time_to_init = 'af 0-6m';
      time_to_init_cat =1;
    end;
    else if  365*0.5  <= gap_glp1_bs and gap_glp1_bs < 365*1.0  then do;
      time_to_init ='af 6-12m';
      time_to_init_cat = 2;
    end;
    else if  365*1.0  <= gap_glp1_bs and gap_glp1_bs < 365*1.5  then do;
      time_to_init = 'af 12-18m';
      time_to_init_cat = 3;
    end;
    else if  365*1.5  <= gap_glp1_bs and gap_glp1_bs < 365*2  then do;
      time_to_init = 'af 18-24m';
      time_to_init_cat = 4;
    end;
    else if  365*2    <= gap_glp1_bs and gap_glp1_bs < 365*2.5 then do;
      time_to_init = 'af 24-30m';
      time_to_init_cat = 5;
    end;
    else if  365*2.5    <= gap_glp1_bs and gap_glp1_bs < 365*3  then do;
      time_to_init = 'af 30-36m';
      time_to_init_cat = 6;
    end;
    else if  365*3    <= gap_glp1_bs and gap_glp1_bs < 365*3.5    then do;
      time_to_init = 'af 36-42m';
      time_to_init_cat = 7;
    end;
    else if  365*3.5    <= gap_glp1_bs and gap_glp1_bs < 365*4    then do;
      time_to_init = 'af 42-48m';
      time_to_init_cat = 8;
    end;
    else if  365*4    <= gap_glp1_bs and gap_glp1_bs < 365*4.5    then do;
      time_to_init = 'af 48-54m';
      time_to_init_cat = 9;
    end;
    else if  365*4.5    <= gap_glp1_bs and gap_glp1_bs < 365*5    then do;
      time_to_init = 'af 54-60m';
      time_to_init_cat = 10;
    end;
    else if  365*5    <= gap_glp1_bs and gap_glp1_bs < 365*5.5    then do;
      time_to_init = 'af 60-66m';
      time_to_init_cat = 11;
    end;
    else if  365*5.5    <= gap_glp1_bs and gap_glp1_bs < 365*6    then do;
      time_to_init = 'af 66-72m';
      time_to_init_cat = 12;
    end;
    else if  365*6    <= gap_glp1_bs and gap_glp1_bs < 365*6.5    then do;
      time_to_init = 'af 72-78m';
      time_to_init_cat = 13;
    end;
    else if  365*6.5    <= gap_glp1_bs and gap_glp1_bs < 365*7    then do;
      time_to_init = 'af 78-84m';
      time_to_init_cat = 14;
    end;
    else if  365*7    <= gap_glp1_bs and gap_glp1_bs     then do;
      time_to_init = 'af 84m + ';
      time_to_init_cat = 15;
    end;
run;

* 1.2. frequency distribution of gap_glp1_bs_cat;

/* print purpose */
proc freq data=min.bs_glp1_user_38384_v01;
    tables bs_type*time_to_init_cat;
run;

/* plotting purpose */
proc freq data=min.bs_glp1_user_38384_v01 noprint;
    tables bs_type*time_to_init_cat / out=min.bs_glp1_user_38384_v01_pct;
run;

proc sql;
    create table min.bs_glp1_user_38384_v01_linegraph as
    select bs_type,
           time_to_init_cat,
           count, 
           percent, 
           100 * count / sum(count) as col_pct  /* Calculate column percentage within time_to_init_cat */
    from min.bs_glp1_user_38384_v01_pct
    group by time_to_init_cat;
quit;


* 1.3. frequency distribution of gap_glp1_bs_cat;
/**************************************************
* new dataset: min.bs_glp1_user_v04_38384
* original dataset: min.bs_glp1_user_v04
* description: 
**************************************************/
data min.bs_glp1_user_v04_38384;
  set min.bs_glp1_user_v04;
  if temporality ne 1;
run;


* 1.3. Plot using SGPLOT;
/* histogram */
proc sgplot data=min.bs_glp1_user_v04_38384;
	  histogram gap_glp1_bs / binwidth=180 scale=count;
    xaxis label="Time to Initiation from bariatric surgery date (Days)";
    yaxis label="Individuals initiating GLP-1 after surgery, count";
 title "Time to Initiation (Days) / binwidth = 6months";
run;

/* line graph */
proc sgplot data=min.bs_glp1_user_38384_v01_linegraph;
    scatter x=time_to_init_cat y=col_pct / group=bs_type 
                                           markerattrs=(symbol=circlefilled size=7)  /* Customize marker appearance */
                                           datalabel=col_pct datalabelattrs=(size=8); /* Add data labels */
    series x=time_to_init_cat y=col_pct / group=bs_type lineattrs=(thickness=2);

    xaxis label="Time to Initiation from bariatric surgery date (Months)" values=(1 to 15 by 1)
           valueattrs=(weight=bold size=10) /* Adjust label style */
           valuesdisplay=(
               '6' 
               '12'
               '18'
               '24'
               '30'
               '36'
               '42'
               '48'
               '54'
               '60'
               '66'
               '72'
               '78'
               '84'
               '84+'
           );

    yaxis label="Individuals initiating GLP-1 after surgery, percentage (%)" values=(0 to 80 by 10);
    title "Time to GLP-1 Initiation by Surgery Type";
run;


/************************************************************************************
	STEP 2. Analysis of glp1 initiation only for GLP-1 initiaters (n=5259)
************************************************************************************/

/**************************************************
* new dataset: min.bs_glp1_user_v04_5259
* original dataset: min.bs_glp1_user_v04
* description: 
**************************************************/

data min.bs_glp1_user_v04_5259;
  set min.bs_glp1_user_v04;
  if temporality = 2;
run;

proc means data=min.bs_glp1_user_v04_5259 
  n nmiss mean std min max median p25 p75;
  var gap_glp1_bs;
  title "distribution of time to post-surgery GLP-1 use";
run;

proc contents data=min.bs_glp1_user_38384_v01;
run;


/************************************************************************************
	STEP 3. Analysis of glp1 initiation by bs type
************************************************************************************/

proc freq data=min.bs_glp1_user_38384_v01;
    tables bs_type*time_to_init_cat / out=min.bs_glp1_user_38384_v01_hist;
    title "Number of GLP-1 initiators by BS types";
run;

/* cumulative bar graph */
proc sgplot data=min.bs_glp1_user_38384_v01_hist;
    vbar time_to_init_cat / response=Count group=bs_type;
    xaxis label="Time to Initiation from bariatric surgery date (Months)" values=(1 to 15 by 1)
           valueattrs=(weight=bold size=10) /* Adjust label style */
           valuesdisplay=(
               '6' 
               '12'
               '18'
               '24'
               '30'
               '36'
               '42'
               '48'
               '54'
               '60'
               '66'
               '72'
               '78'
               '84'
               '84+'
           );
    yaxis label="Individuals initiating GLP-1 after surgery, count";
    title "Number of GLP-1 initiators overtime by surgery types";
run;


/************************************************************************************
	STEP 4. Analysis of glp1 initiation by glp1 types
************************************************************************************/

* 4.1. frequency distribution of gap_glp1_bs_cat by glp1 types;

/* print purpose */
proc freq data=min.bs_glp1_user_38384_v01;
    tables glp1_type_cat*time_to_init_cat;
run;

/* plotting purpose */
proc freq data=min.bs_glp1_user_38384_v01 noprint;
    tables Molecule*time_to_init_cat / out=min.bs_glp1_user_38384_v01_pct2;
run;

proc sql;
    create table min.bs_glp1_user_38384_linegraph2 as
    select Molecule,
           time_to_init_cat,
           count, 
           percent, 
           100 * count / sum(count) as col_pct  /* Calculate column percentage within time_to_init_cat */
    from min.bs_glp1_user_38384_v01_pct2
    group by time_to_init_cat;
quit;

/* line graph */
proc sgplot data=min.bs_glp1_user_38384_linegraph2;
    scatter x=time_to_init_cat y=col_pct / group=Molecule
                                           markerattrs=(symbol=circlefilled size=7)  /* Customize marker appearance */
                                           datalabel=col_pct datalabelattrs=(size=8); /* Add data labels */
    series x=time_to_init_cat y=col_pct / group=Molecule lineattrs=(thickness=2);

    xaxis label="Time to Initiation from bariatric surgery date (Months)" values=(1 to 15 by 1)
           valueattrs=(weight=bold size=10) /* Adjust label style */
           valuesdisplay=(
               '6' 
               '12'
               '18'
               '24'
               '30'
               '36'
               '42'
               '48'
               '54'
               '60'
               '66'
               '72'
               '78'
               '84'
               '84+'
           );

    yaxis label="Individuals initiating GLP-1 after surgery, percentage (%)" values=(0 to 80 by 10);
    title "Time to GLP-1 Initiation by GLP-1 Type";
run;


/* cumulative bar graph */
proc sgplot data=min.bs_glp1_user_38384_linegraph2;
    vbar time_to_init_cat / response=Count group=Molecule;
    xaxis label="Time to Initiation from bariatric surgery date (Months)" values=(1 to 15 by 1)
           valueattrs=(weight=bold size=10) /* Adjust label style */
           valuesdisplay=(
               '6' 
               '12'
               '18'
               '24'
               '30'
               '36'
               '42'
               '48'
               '54'
               '60'
               '66'
               '72'
               '78'
               '84'
               '84+'
           );
    yaxis label="Individuals initiating GLP-1 after surgery, count";
    title "Number of GLP-1 initiators overtime by GLP-1 types";
run;
