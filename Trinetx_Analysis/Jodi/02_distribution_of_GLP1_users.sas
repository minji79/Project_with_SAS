
/************************************************************************************
| Project name : JOdi
| Program name : 02_distribution_of_GLP1_users.sas
| Date (update): August 2024
| Task Purpose : 
|      1. 

|      5. 
| Main dataset : (1) min.bs_glp1_user_v03
************************************************************************************/

libname jd "/dcs07/trinetx/data/Users/MJ/jodi";

/************************************************************************************
	1. GLP1 new users after 2011
************************************************************************************/

* 1.1. select GLP1 users after 2011 | use jd.glp1_2005_v05;
/**************************************************
* new dataset: jd.glp1_2011_v00
* original dataset: jd.glp1_2005_v05
* description: GLP1 new users after 2005
**************************************************/

data jd.glp1_2011_v00;
  set jd.glp1_2005_v05;
  if start_date_num > '01JAN2011'd;
run;    /* 1,088,230 obs -> 1,075,129 obs */


* 1.2. distribution of initiation year;
proc freq data=jd.glp1_2011_v00;
    tables Molecule*initiation_year / out=jd.glp1_2011_v01;
    title "Number of GLP1 new users by Molecule";
run;

/* cumulative bar graph */
proc sgplot data=jd.glp1_2011_v01;
    vbar initiation_year / response=Count group=Molecule;
    xaxis label="Initiation Year" values=(2011 to 2024 by 1); /* Adjust years if needed */
    yaxis label="Count";
    title "Number of GLP1 new users by Molecule";
run;
