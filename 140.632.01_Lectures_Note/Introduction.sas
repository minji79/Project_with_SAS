
/* reference: https://www.biostat.jhsph.edu/~amcdermo/SAS2024/ */


****************************************************
* 3/26 | 1. Dataset and Data
****************************************************

* Every statement in SAS begins with a key word and ends with a comma - semi colon;
* # of statements = # of comma

**********************
* proc print
**********************

proc print data = sashelp.class;               /* proc - key word, run the print procedure, data -> two level names (lib + table) */
run;

/* where | if we want to see only male's data */

proc print data = sashelp.class;
  where sex = "M";
run;

/* title | add title in my output */
/* R doesn;t have 'page' concept, and it needs title  */

proc print data = sashelp.class;
  where sex = "M";
  title "SASHELP.CLASS - Males";
run;


/* var | select several variables among the given var */

proc print data = sashelp.class;
  where sex = "M";
  title "SASHELP.CLASS - Males";
  var name age weight height;
run;

proc print data = sashelp.class;
  where sex = "M" and age > 14 ;       /* we can use -> and | or */
  var name age weight height;
run;


proc print data = sashelp.class;
  where age > 12 and age <= 14 ;    
    /*   where age > 12 and <= 14; it doesn't work!! */
    /*   where 12 < age <= 14; it works!! */
  var name age weight height;
run;


**********************
* proc sort
**********************

/* by */
/* when we use more than two variables in the by statement, they have a priority in sorting the data */

proc sort data=sashelp.class;
  by sex age;                   /* lack of athourization to modify the dataset */
run;

/* out | if we don't have permission to override data set, we can make anothor table */

proc sort data=sashelp.class  
  out = work.class;
  by sex age;                   
run;

proc print data=work.class;
  by sex;                   /* it provides two seperate tables by sex - female and male */
  /* by SEX */              /* when we write the name of variable, the case doesn't matter. However, the case matters when inside of the "" */
run;


****************************************************
* 3/28 | 2. 
****************************************************

/* comment block */

/* error 1 | none will be selected */

proc print data = sashelp.class;
	where age > 14 and age < 14;
run;

/* error 2 | two where statements will not be allowed -> no error message - only second command will work */

proc print data = sashelp.class;
	where age > 14;
  where age < 15;
run;

proc print data = sashelp.class;
	where age > 14;
  var name;
  where age < 15;
run;




