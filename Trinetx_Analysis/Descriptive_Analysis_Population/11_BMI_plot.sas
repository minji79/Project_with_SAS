
/************************************************************************************
	STEP 1. make dataset of study population (temporality = 0 and 2) with BMI - long format
************************************************************************************/

/* 1.1. select only GLP-1 users among study population (temporality = 2) */
proc contents data=min.bs_glp1_user_v03;
  	title "min.bs_glp1_user_v03";
   run;  /obs = 43996 = out study population */

data min.studypopulation;
    set min.bs_glp1_user_v03;
    if temporality in (0, 2);
run;  /* 6466 + 31667 = 38133 */

/* 1.2. merge bmi long data with the glp1 users population */
proc sql;
  create table min.bmi_glp1user_long_v00 as
  select distinct a.patient_id, a.bs_date, a.bs_type, a.temporality, a.glp1_initiation_date, b.date, b.value 
  from min.studypopulation a left join m.bmi_date b 
  on a.patient_id=b.patient_id;
quit;
proc print data=min.bmi_glp1user_long_v00 (obs = 30);
title "min.bmi_glp1user_long_v00";
run;  /* 722178 obs */

* 1.3. change the variable name;
data min.bmi_glp1user_long_v00;
  set min.bmi_glp1user_long_v00;
  rename date = bmi_date value = bmi temporality = glp1_use;
run;

* 1.4. convert char -> numeric in bmi;
data min.bmi_glp1user_long_v00;
  set min.bmi_glp1user_long_v00;
  bmi_num = input(bmi, ??best.);
run;

data min.bmi_glp1user_long_v00;
  set min.bmi_glp1user_long_v00;
  drop bmi;
  rename bmi_num = bmi;
run;


* 1.5. remove missing bmi & extreme values (less than 10, more than 70;
proc sql; 
create table min.bmi_glp1user_long_v01 as
select distinct a.*
from min.bmi_glp1user_long_v00 a
where not missing(bmi) and bmi >= 10 and bmi <= 70;
quit;      /* 604675 obs */

* 1.6. avg BMI if multiple BMI within a day;
proc sql; 
create table bmi_glp1user_deduplicate as
select distinct patient_id, bmi_date, avg(bmi) as bmi
from min.bmi_glp1user_long_v01
group by patient_id, bmi_date;
quit;    /* 539950 */

proc sql;
create table min.bmi_glp1user_long_v02 as
select distinct a.patient_id, a.bs_date, a.glp1_use, a.glp1_initiation_date, b.bmi_date, b.bmi
from min.bmi_glp1user_long_v01 a left join bmi_glp1user_deduplicate b
on a.patient_id = b.patient_id;
quit;   /* 539950 */


/************************************************************************************
	STEP 2. add index_bmi_date and index_bmi
************************************************************************************/

* find pts with bmi 6 months prior the BS date;
/**************************************************
* new table: min.bmi_6monPrior 
* original table: min.bmi_glp1user_long_v01
* description: find pts with bmi 6 months prior the BS date
**************************************************/

proc sql;
create table min.bmi_6monPrior as
select distinct a.*
from min.bmi_glp1user_long_v02 a
where bmi_date <= bs_date and (bs_date - 180) <= bmi_date ;
quit;    /* 74477 obs */

/*latest bmi 6mon prior index, only have date in the output*/
proc sql;
create table bmi_6monPrior_latest as
select distinct patient_id, bs_date, max(bmi_date) as index_bmi_date format=yymmdd10.
from min.bmi_6monPrior
group by patient_id, bs_date;
quit;    /* 13734 obs */

/* left join index_bmi_date with bmi value */
proc sql;
create table bmi_baseline as
select distinct a.*, b.bmi
from bmi_6monPrior_latest a left join min.bmi_6monPrior b
on (a.patient_id = b.patient_id and a.bs_date = b.bs_date and a.index_bmi_date = b.bmi_date);
quit;  /* 13734 obs */

/* left join bmi_index and index_bmi_date with the long dataset */
proc sql; 
create table min.bmi_glp1user_long_v03 as
select distinct a.*, b.index_bmi_date, b.bmi as bmi_index
from min.bmi_glp1user_long_v02 a left join bmi_baseline b
on a.patient_id = b.patient_id;
quit;    /* 539950 obs */

/* remove bmi value before index_bmi */
proc sql; 
create table min.bmi_glp1user_long_v04 as
select distinct a.*
from min.bmi_glp1user_long_v03 a
where index_bmi_date <= bmi_date;
quit;   /* 332538 */

/************************************************************************************
	STEP 3. seperate glp-1 non-user vs glp1 users -> remove bmi value after glp1 initiation -> reunion
************************************************************************************/

* 3.1. glp1 users;

proc sql; 
create table bmi_glp1user as
select distinct a.*
from min.bmi_glp1user_long_v04 a
where glp1_use = 2;
quit;   /* 74693 */

* 3.2. remove bmi value after glp1 initiation;

proc sql; 
create table bmi_glp1user_cleaned as
select distinct a.*
from bmi_glp1user a
where bmi_date <= glp1_initiation_date;
quit;    /* 55375 */

* 3.3. non-users;
proc sql; 
create table bmi_nonuser as
select distinct a.*
from min.bmi_glp1user_long_v04 a
where glp1_use = 0;
quit;  /* 257845 */

* 3.4. merge cleaned dataset;
data min.bmi_glp1user_long_v05;
set bmi_glp1user_cleaned bmi_nonuser;
run;  /* 313220 = 55375 + 257845 */


proc print data=min.bmi_glp1user_long_v05 (obs = 30);
title "min.bmi_glp1user_long_v05";
run;

/************************************************************************************
	STEP 4. make discrete time interval
************************************************************************************/

/* creat table for monthly BMI seperatly */
/* Month 1 needs to be done separately due to the equal sign */
proc sql;
create table Bmi_after_m1 as
select a.*
from min.bmi_glp1user_long_v05 a
where bs_date <= bmi_date and bmi_date <= bs_date+30;
quit;

/* Month 2 ~ further months with macro */

%macro monthly (data= , time= );

proc sql;
create table &data as
select a.*
from min.bmi_glp1user_long_v05 a
where bs_date <= bmi_date and bmi_date <= bs_date+30;
quit;

%mend monthly;

/* Generate datasets for each interval */
%monthly (data=Bmi_after_m2, time=bs_date+30);
%monthly (data=Bmi_after_m3, time=bs_date+60);
%monthly (data=Bmi_after_m4, time=bs_date+90);
%monthly (data=Bmi_after_m5, time=bs_date+120);
%monthly (data=Bmi_after_m6, time=bs_date+150);
%monthly (data=Bmi_after_m7, time=bs_date+180);
%monthly (data=Bmi_after_m8, time=bs_date+210);
%monthly (data=Bmi_after_m9, time=bs_date+240);
%monthly (data=Bmi_after_m10, time=bs_date+270);
%monthly (data=Bmi_after_m11, time=bs_date+300);
%monthly (data=Bmi_after_m12, time=bs_date+330);
%monthly (data=Bmi_after_m13, time=bs_date+360);
%monthly (data=Bmi_after_m14, time=bs_date+390);
%monthly (data=Bmi_after_m15, time=bs_date+420);
%monthly (data=Bmi_after_m16, time=bs_date+450);
%monthly (data=Bmi_after_m17, time=bs_date+480);
%monthly (data=Bmi_after_m18, time=bs_date+510);
%monthly (data=Bmi_after_m19, time=bs_date+540);
%monthly (data=Bmi_after_m20, time=bs_date+570);
%monthly (data=Bmi_after_m21, time=bs_date+600);
%monthly (data=Bmi_after_m22, time=bs_date+630);
%monthly (data=Bmi_after_m23, time=bs_date+660);
%monthly (data=Bmi_after_m24, time=bs_date+690);
%monthly (data=Bmi_after_m24, time=bs_date+690);
%monthly (data=Bmi_after_m25, time=bs_date+720);
%monthly (data=Bmi_after_m26, time=bs_date+750);
%monthly (data=Bmi_after_m27, time=bs_date+780);
%monthly (data=Bmi_after_m28, time=bs_date+810);
%monthly (data=Bmi_after_m29, time=bs_date+840);
%monthly (data=Bmi_after_m30, time=bs_date+870);
%monthly (data=Bmi_after_m31, time=bs_date+900);
%monthly (data=Bmi_after_m32, time=bs_date+930);
%monthly (data=Bmi_after_m33, time=bs_date+960);
%monthly (data=Bmi_after_m34, time=bs_date+990);
%monthly (data=Bmi_after_m35, time=bs_date+1020);
%monthly (data=Bmi_after_m36, time=bs_date+1050);

/* creat table for averaging monthly BMI */
%macro average (data1= , data2= );

proc sql;
create table &data1 as
Select a.*, avg (bmi) as bmi_avg
From &data2 a
Group by patient_id;
quit;

%mend average;

%average (data1=Bmi_after_m1_avg, data2=Bmi_after_m1);
%average (data1=Bmi_after_m2_avg, data2=Bmi_after_m2);
%average (data1=Bmi_after_m3_avg, data2=Bmi_after_m3);
%average (data1=Bmi_after_m4_avg, data2=Bmi_after_m4);
%average (data1=Bmi_after_m5_avg, data2=Bmi_after_m5);
%average (data1=Bmi_after_m6_avg, data2=Bmi_after_m6);
%average (data1=Bmi_after_m7_avg, data2=Bmi_after_m7);
%average (data1=Bmi_after_m8_avg, data2=Bmi_after_m8);
%average (data1=Bmi_after_m9_avg, data2=Bmi_after_m9);
%average (data1=Bmi_after_m10_avg, data2=Bmi_after_m10);
%average (data1=Bmi_after_m11_avg, data2=Bmi_after_m11);
%average (data1=Bmi_after_m12_avg, data2=Bmi_after_m12);
%average (data1=Bmi_after_m13_avg, data2=Bmi_after_m13);
%average (data1=Bmi_after_m14_avg, data2=Bmi_after_m14);
%average (data1=Bmi_after_m15_avg, data2=Bmi_after_m15);
%average (data1=Bmi_after_m16_avg, data2=Bmi_after_m16);
%average (data1=Bmi_after_m17_avg, data2=Bmi_after_m17);
%average (data1=Bmi_after_m18_avg, data2=Bmi_after_m18);
%average (data1=Bmi_after_m19_avg, data2=Bmi_after_m19);
%average (data1=Bmi_after_m20_avg, data2=Bmi_after_m20);
%average (data1=Bmi_after_m21_avg, data2=Bmi_after_m21);
%average (data1=Bmi_after_m22_avg, data2=Bmi_after_m22);
%average (data1=Bmi_after_m23_avg, data2=Bmi_after_m23);
%average (data1=Bmi_after_m24_avg, data2=Bmi_after_m24);
%average (data1=Bmi_after_m25_avg, data2=Bmi_after_m25);
%average (data1=Bmi_after_m26_avg, data2=Bmi_after_m26);
%average (data1=Bmi_after_m27_avg, data2=Bmi_after_m27);
%average (data1=Bmi_after_m28_avg, data2=Bmi_after_m28);
%average (data1=Bmi_after_m29_avg, data2=Bmi_after_m29);
%average (data1=Bmi_after_m30_avg, data2=Bmi_after_m30);
%average (data1=Bmi_after_m31_avg, data2=Bmi_after_m31);
%average (data1=Bmi_after_m32_avg, data2=Bmi_after_m32);
%average (data1=Bmi_after_m33_avg, data2=Bmi_after_m33);
%average (data1=Bmi_after_m34_avg, data2=Bmi_after_m34);
%average (data1=Bmi_after_m35_avg, data2=Bmi_after_m35);
%average (data1=Bmi_after_m36_avg, data2=Bmi_after_m36);


/* join monthly BMI together */
Proc sql;
Create table min.bmi_discrete_wide as
Select distinct b.patient_id, b.bs_date, b.glp1_use, b.glp1_initiation_date, b.index_bmi_date, b.bmi_index,
(b1.BMI) as BMI_m1,
(b2.BMI) as BMI_m2,
(b3.BMI) as BMI_m3,
(b4.BMI) as BMI_m4,
(b5.BMI) as BMI_m5, 
(b6.BMI) as BMI_m6,
(b7.BMI) as BMI_m7,
(b8.BMI) as BMI_m8,
(b9.BMI) as BMI_m9,
(b10.BMI) as BMI_m10,
(b11.BMI) as BMI_m11,
(b12.BMI) as BMI_m12,
(b13.BMI) as BMI_m13,
(b14.BMI) as BMI_m14,
(b15.BMI) as BMI_m15,
(b16.BMI) as BMI_m16,
(b17.BMI) as BMI_m17,
(b18.BMI) as BMI_m18,
(b19.BMI) as BMI_m19,
(b20.BMI) as BMI_m20,
(b21.BMI) as BMI_m21,
(b22.BMI) as BMI_m22,
(b23.BMI) as BMI_m23,
(b24.BMI) as BMI_m24,
(b25.BMI) as BMI_m25,
(b26.BMI) as BMI_m26,
(b27.BMI) as BMI_m27,
(b28.BMI) as BMI_m28,
(b29.BMI) as BMI_m29,
(b30.BMI) as BMI_m30,
(b31.BMI) as BMI_m31,
(b32.BMI) as BMI_m32,
(b33.BMI) as BMI_m33,
(b34.BMI) as BMI_m34,
(b35.BMI) as BMI_m35,
(b36.BMI) as BMI_m36
From min.bmi_glp1user_long_v05 b 
Left join Bmi_after_m1_avg b1 on b.patient_id =b1.patient_id and b.bs_date =b1.bs_date
Left join Bmi_after_m2_avg b2 on b.patient_id =b2.patient_id and b.bs_date =b2.bs_date
Left join Bmi_after_m3_avg b3 on b.patient_id =b3.patient_id and b.bs_date =b3.bs_date
Left join Bmi_after_m4_avg b4 on b.patient_id =b4.patient_id and b.bs_date =b4.bs_date
Left join Bmi_after_m5_avg b5 on b.patient_id =b5.patient_id and b.bs_date =b5.bs_date
Left join Bmi_after_m6_avg b6 on b.patient_id =b6.patient_id and b.bs_date =b6.bs_date
Left join Bmi_after_m7_avg b7 on b.patient_id =b7.patient_id and b.bs_date =b7.bs_date
Left join Bmi_after_m8_avg b8 on b.patient_id =b8.patient_id and b.bs_date =b8.bs_date
Left join Bmi_after_m9_avg b9 on b.patient_id =b9.patient_id and b.bs_date =b9.bs_date
Left join Bmi_after_m10_avg b10 on b.patient_id =b10.patient_id and b.bs_date =b10.bs_date
Left join Bmi_after_m11_avg b11 on b.patient_id =b11.patient_id and b.bs_date =b11.bs_date
Left join Bmi_after_m12_avg b12 on b.patient_id =b12.patient_id and b.bs_date =b12.bs_date
Left join Bmi_after_m13_avg b13 on b.patient_id =b13.patient_id and b.bs_date =b13.bs_date
Left join Bmi_after_m14_avg b14 on b.patient_id =b14.patient_id and b.bs_date =b14.bs_date
Left join Bmi_after_m15_avg b15 on b.patient_id =b15.patient_id and b.bs_date =b15.bs_date
Left join Bmi_after_m16_avg b16 on b.patient_id =b16.patient_id and b.bs_date =b16.bs_date
Left join Bmi_after_m17_avg b17 on b.patient_id =b17.patient_id and b.bs_date =b17.bs_date
Left join Bmi_after_m18_avg b18 on b.patient_id =b18.patient_id and b.bs_date =b18.bs_date
Left join Bmi_after_m19_avg b19 on b.patient_id =b19.patient_id and b.bs_date =b19.bs_date
Left join Bmi_after_m20_avg b20 on b.patient_id =b20.patient_id and b.bs_date =b20.bs_date
Left join Bmi_after_m21_avg b21 on b.patient_id =b21.patient_id and b.bs_date =b21.bs_date
Left join Bmi_after_m22_avg b22 on b.patient_id =b22.patient_id and b.bs_date =b22.bs_date
Left join Bmi_after_m23_avg b23 on b.patient_id =b23.patient_id and b.bs_date =b23.bs_date
Left join Bmi_after_m24_avg b24 on b.patient_id =b24.patient_id and b.bs_date =b24.bs_date 
Left join Bmi_after_m25_avg b25 on b.patient_id =b25.patient_id and b.bs_date =b25.bs_date 
Left join Bmi_after_m26_avg b26 on b.patient_id =b26.patient_id and b.bs_date =b26.bs_date 
Left join Bmi_after_m27_avg b27 on b.patient_id =b27.patient_id and b.bs_date =b27.bs_date 
Left join Bmi_after_m28_avg b28 on b.patient_id =b28.patient_id and b.bs_date =b28.bs_date 
Left join Bmi_after_m29_avg b29 on b.patient_id =b29.patient_id and b.bs_date =b29.bs_date 
Left join Bmi_after_m30_avg b30 on b.patient_id =b30.patient_id and b.bs_date =b30.bs_date 
Left join Bmi_after_m31_avg b31 on b.patient_id =b31.patient_id and b.bs_date =b31.bs_date 
Left join Bmi_after_m32_avg b32 on b.patient_id =b32.patient_id and b.bs_date =b32.bs_date 
Left join Bmi_after_m33_avg b33 on b.patient_id =b33.patient_id and b.bs_date =b33.bs_date 
Left join Bmi_after_m34_avg b34 on b.patient_id =b34.patient_id and b.bs_date =b34.bs_date 
Left join Bmi_after_m35_avg b35 on b.patient_id =b35.patient_id and b.bs_date =b35.bs_date 
Left join Bmi_after_m36_avg b36 on b.patient_id =b36.patient_id and b.bs_date =b36.bs_date ;
quit;

proc print data = min.bmi_discrete_wide (obs = 30);
title "min.bmi_discrete_wide";
run;

/* transpose bmi wide to long*/
Proc transpose data=Rayna.Bmi_bl_fp  Out =Bmi_bl_fp_long;
By patient_id;
VAR BMI_m0 BMI_m1 BMI_m2 BMI_m3 BMI_m4 BMI_m5 BMI_m6 BMI_m7 BMI_m8 BMI_m9 
BMI_m10 BMI_m11 BMI_m12 BMI_m13 BMI_m14 BMI_m15 BMI_m16 BMI_m17 BMI_m18 BMI_m19 
BMI_m20 BMI_m21 BMI_m22 BMI_m23 BMI_m24 ;
RUN;





