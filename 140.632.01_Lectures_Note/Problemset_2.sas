/***** Problem Set 2 *****/

* 1. How many men are in the dataset?;
proc contents data=data.diabetes;
run;

proc means data=data.diabetes n;
	var sex;
	where sex = 2;
run;

* 2. How many people have diabetes?;
proc means data=data.diabetes n;
	var diabetes;
	where diabetes = 1;
run;

* 3. How many individuals have missing diabetes?;
proc freq data=data.diabetes;
	table diabetes / nopercent nocol;
run;

* 4. What percentage of men have diabetes?;
proc freq data=data.diabetes;
	table diabetes*sex / nopercent nocol;
run;

* 5. What percentage of women have diabetes?;
proc freq data=data.diabetes;
	table diabetes*sex / nopercent nocol;
	where sex = 1;
run;

* 6. What is the likelihood ratio chi-square statistic?;
* 7. What is the associated p-value?;
proc freq data = data.diabetes;
	tables diabetes*sex / nopercent nocol chisq;
run;

* 8. What is the minimum age of individuals in the dataset?;
proc means data=data.diabetes min;
	var age;
run;

* 9. What is the maximum age of individuals in the dataset?;
proc means data=data.diabetes max;
	var age;
run;

* 10. What is the mean age for men in the dataset?;
proc means data=data.diabetes mean;
	var age;
	where sex = 2;
run;

* 11. What is the mean age for women in the dataset?;
proc means data=data.diabetes mean;
	var age;
	where sex = 1;
run;

* 12. What is the mean DBP for men in the dataset?;
proc means data=data.diabetes mean;
	var DBP;
	where sex = 2;
run;

* 13. What is the mean DBP for women in the dataset?;
proc means data=data.diabetes mean;
	var DBP;
	where sex = 1;
run;

* Create a format called agef to break age into the four categories given here;
* 14. How many individuals are between the ages 35 and 44 years inclusively?;
proc format;
	value agef
		0  -< 35 = "under 35"
		35 - 44 = "35 - 44"
		45 - 64 = "45 - 64"
		65 - high = "over 65";
proc means data=data.diabetes N;
	var age;
	format age agef.;
	where 35 ge age <= 44;
run;

* 15. What percentage of individuals are between the ages 35 and 44 years inclusively?;
proc freq data=data.diabetes;
	table age;
	format age agef.;
run;

* 16. What is the likelihood ratio chi-square statistic?;
* 17. What is the associated p-value?;
proc freq data=data.diabetes;
	table age*sex / chisq;
	format age agef.;
run;

* 18. What is the likelihood ratio chi-square statistic?;
* 19. What is the associated p-value?;
proc freq data=data.diabetes;
	table age*diabetes / chisq;
	format age agef.;
run;

* 20. What is the mean diastolic blood pressure for African Americans aged 41 to 60 years?;
proc format;
	value sexf
		1 = "Female"
		2 = "Male";
	value ethf
		1 = "White"
		2 = "African American"
		3 = "Mexican American"
		4 = "Other";
	value agef
		low - 40 = "<=40"
		40 <- 60 = "41 to 60"
		60 <- 75 = "61 to 75"
		75 <- high = "over 75";
	value diabf
		0 = "non-diabetic"
		1 = "diabetic";
run;

proc means data=data.diabetes mean maxdec=2;
	var DBP;
	format sex sef. age agef. ethnicity ethf. diabetes diabf.;
	class ethnicity age;
	title "the diabetes dataset using formats";
run;

* 21. How many people in the Other group who were over 75 had a non-missing diastolic blood pressure?;
proc means data=data.diabetes N;
	format sex sef. age agef. ethnicity ethf. diabetes diabf.;
	where 75 <- age and DBP is not missing;
	class ethnicity age;
run;
	









