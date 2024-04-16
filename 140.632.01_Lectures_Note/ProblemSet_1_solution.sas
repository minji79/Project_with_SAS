/***** Problem Set 1 *****/

/***** Part 1. The SASHELP.HEART dataset *****/

/* 1. How many variables are there in the dataset? : 17 */
/* 2. What is the length of the smoking_status variable? : 17 */
proc contents data=sashelp.heart;
run;
proc print data=sashelp.heart (obs=10);
run;


/* 3. What is the percentage of females in the dataset? (answer to 2 decimal places) : 55.15% */
proc freq data=sashelp.heart;
	table sex;
run;


/* 4. What is the percentage of females who died? (answer to 2 decimal places) : 45.00% */
proc freq data=sashelp.heart;
	table sex * status;
	where sex="Female";
	title1 "the percentage of females who died";
run;
title;


/* 5. For how many individuals is the deathCause variable missing? : 3218 */
/* method 1 */
proc sql;
    select count(*) as MissingCount
    from sashelp.heart
    where deathCause is missing;
quit;

/* method 2 */
proc freq data=sashelp.heart;
	table deathCause;
run;


/* 6. For how many individuals is the deathCause variable "Unknown"? : 112 */
proc freq data=sashelp.heart;
	table deathCause / missing;
run;

proc sql;
    select count(*) as UnknownCount
    from sashelp.heart
    where deathCause = 'Unknown';
quit;


/* 7. What percentage of females were smokers? (answer to 2 decimal places) : 41.45% */
proc freq data=sashelp.heart;
	table sex smoking sex*smoking / nopercent nocol;
run;

/* making binary var: missing value will be included in smk */
data missing_delete;
	set sashelp.heart;
	if missing(smoking)=1 then delete;
run;

data work.heart;
	set missing_delete;
	if smoking =0 then smk=0;
	else smk =1;
run;
proc freq data=work.heart;
	table sex*smk;
run;


*original;
data work.heart;
	set sashelp.heart;
	* if Smoking_Status is missing then delete;
	if Smoking_Status = "Non-smoker" then smk = 0;
	else smk = 1;
run;
proc print data=work.heart (obs=20); run;

proc freq data=work.heart;
	table sex * smk;
run;


/* 8. What percentage of males were smokers? (answer to 2 decimal places) : 64.94% */
data work.heart2;
	set sashelp.heart;
	where sex ="Male";
	if Smoking_Status = "Non-smoker" then smk = 0;
	else smk = 1;
run;
proc print data=work.heart2 (obs=20); run;
proc freq data = work.heart2; 
	table smk;
run;


/* 9. What is the mean weight for females in the dataset? (answer to 2 decimal places) : 141.388 */
proc means data=sashelp.heart maxdec=2; 
	var Weight;
	where sex = "Female";
run;	


/* 10. What is median weight for males in the dataset? (answer to 2 decimal places) : 167.00 */
proc means data=sashelp.heart 
		n median mean std;
	var Weight;
	where sex = "Male";
run;


/* 11. What is the mean systolic blood pressure for male smokers? (answer to 2 decimal places) : 136.938 */
proc means data=sashelp.heart mean maxdec=2;
	var Systolic;
	where sex = "Male" and smoking > 0;
run;


/* 12. What is the mean systolic blood pressure for male non-smokers? (answer to 2 decimal places)*/
proc means data=sashelp.heart mean maxdec=2;
	var Systolic;
	where sex = "Male" and smoking = 0;
run;


/* 13. What is the mean systolic blood pressure for males between the ages 40 and 50 inclusively at the start of the study? (answer to 2 decimal places) */
proc contents data=sashelp.heart;
run;

proc means data=sashelp.heart mean maxdec=2;
	var Systolic;
	where sex = "Male" and ageAtStart >= 40 and ageAtStart <=50;
run;

proc means data=sashelp.heart mean maxdec=2;
	var Systolic;
	where sex = "Male" and 40 < ageAtStart < 50;
run;

* others solution;
proc sort data=sashelp.heart out=work.heart_sex;
	by sex;
proc means data=work.heart_sex n nmiss mean std maxdec=2;
	where ageAtStart >= 40 and ageAtStart <=50;





/***** Part 2. Catching errors *****/
   proc print mylib.fisher;
   run;
   proc sort data = mylib.fisher out=work.fisher;
     by trial;
   proc means data = mylib.fisher n mean var max;
     by trial;
     var temp sbp sbp;
   proc means data = work.fisher n mean var max;
     var temp sbp dbp.
run;

/* 14. How many errors are there in the code? */
/*
 proc print mylib.fisher; -> they don't assign the lib properly
 var temp sbp dbp. -> no ;
 */
proc print mylib.fisher;
   run;
proc sort data = mylib.fisher out=work.fisher;
     by trial;
proc means data = mylib.fisher n mean var max;
     by trial;
     var temp sbp sbp;
   proc means data = work.fisher n mean var max;
     var temp sbp dbp.
run;



/***** Part 3. Proc means *****/
/* 15-16. What is the mean and standard deviation of the air variable? */
proc contents data=sashelp.air;
run;

proc means data=sashelp.air mean std maxdec=2;
	var air;
run;


/* 17-18. What is the mean and standard deviation of the salary variable for those in the "NE" division (i.e. where div = "NE")? */
proc contents data=sashelp.baseball;
run;

proc means data=sashelp.baseball mean std maxdec=2;
	var salary;
	where div = "NE";
run;


/* 19-20. What is the mean and standard deviation of the T variable for those where group is "AML-High Risk"? */
proc contents data=sashelp.bmt;
run;

proc means data=sashelp.bmt mean std maxdec=2;
	var T;
	where group = "AML-High Risk";
run;


/* 21-22. What is the mean and standard deviation of the weight vari- able for mothers who were non-smokers? That is, subset to MomSmoke=0 */
proc contents data=sashelp.bweight;
run;

proc means data=sashelp.bweight mean std maxdec=2;
	var weight;
	where MomSmoke = 0;
run;


/* 23-24. What is the mean and standard deviation of the weight variable for mothers who were smokers? That is, subset to MomSmoke=1 */
proc contents data=sashelp.bweight;
run;

proc means data=sashelp.bweight mean std maxdec=2;
	var weight;
	where MomSmoke = 1;
run;


/* 25-26. What is the mean and standard deviation of the PetalLength vari- able for Setosa species? That is, subset to species="Setosa" */
proc contents data=sashelp.iris;
run;

proc means data=sashelp.iris mean std maxdec=2;
	var PetalLength;
	where species="Setosa";
run;
