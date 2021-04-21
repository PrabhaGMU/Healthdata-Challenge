/*Healthdata Challenge*/

/*creating Library*/

libname Health "/folders/myfolders/MySASProject/HealthData";
run;

/*Importing files*/
/*3000*/
proc import out=Health.demographics datafile='/folders/myfolders/demographics.csv' dbms=CSV replace; 
run;

/*13600*/
proc import out=Health.billID datafile='/folders/myfolders/MySASProject/HealthData/bill_id.csv' dbms=CSV replace; 
run;

/*13600*/
proc import out=Health.BillAmount datafile='/folders/myfolders/MySASProject/HealthData/bill_amount.csv' dbms=CSV replace; 
run;

/*3400*/
proc import out=Health.Clinicaldata datafile='/folders/myfolders/MySASProject/HealthData/clinical_data.csv' dbms=CSV replace; 
run;


proc print data=Health.demographics (obs=20);
run;

proc print data=Health.billID (obs=20);
run;

proc print data=Health.BillAmount (obs=20);
run;

proc print data=Health.Clinicaldata (obs=200);
run;


/*joining Bill_ID and Bill_Amount*/

proc sql;
create table Health.Newbill as
select x.patient_id, coalesce (x.bill_ID,y.bill_ID) as Bill_ID,x.date_of_admission,y.amount
from Health.billID as x full join Health.BillAmount as y
on x.Bill_id = y.Bill_id;
quit;

/*joining Demographics and Clinical_data*/
proc sql;
create table Health.Demo_Clinical as
select coalesce (x.patient_ID,y.ID) as Patient_ID, x.Gender,
x.race,x.resident_status,x.date_of_birth,
y.date_of_admission, y.date_of_discharge, 
y.medical_history_1, y.medical_history_2, y.medical_history_3, 
y.medical_history_4, y.medical_history_5, y.medical_history_6, 
y.medical_history_7, y.preop_medication_1, y.preop_medication_2, 
y.preop_medication_3, y.preop_medication_4, y.preop_medication_5, 
y.preop_medication_6, y.symptom_1, y.symptom_2, y.symptom_3, y.symptom_4,
 y.symptom_5, y.lab_result_1, y.lab_result_2, y.lab_result_3, y.weight,
 y.height
from Health.Demographics as x full join Health.Clinicaldata as y
on x.patient_id = y.id;
quit;

/*checked for missing values using proc freq*/

proc print data=Health.Demo_Clinical (obs=20);
run;

proc print data=Health.Newbill (obs=20);
run;

proc freq data=Health.Clinicalonly;
tables Length_of_stay/missing;
run;


proc freq data=Health.Demo_Clinical_Los;
tables Length_of_stay/missing;
tables medical_history_2/missing;
tables weight/missing;
run;

proc freq data=Health.Newbill;
tables Bill_id/missing;
tables amount/missing;
tables date_of_admission/missing;
run;

/* Joining all four tables to final table*/
proc sql;
create table Health.Final_join_health as
select x.patient_id,x.Gender,x.race,x.date_of_birth,x.date_of_admission, x.date_of_discharge, 
x.medical_history_1, x.medical_history_2, x.medical_history_3, 
x.medical_history_4, x.medical_history_5, x.medical_history_6, 
x.medical_history_7, x.preop_medication_1, x.preop_medication_2, 
x.preop_medication_3, x.preop_medication_4, x.preop_medication_5, 
x.preop_medication_6, x.symptom_1, x.symptom_2, x.symptom_3, x.symptom_4,
x.symptom_5, x.lab_result_1, x.lab_result_2, x.lab_result_3, x.weight,
 x.height,y.bill_id,y.amount
from Health.Demo_Clinical_LOS  as x full join Health.Newbill as y
on x.Patient_id=y.patient_id
and x.date_of_admission=y.date_of_admission
group by x.patient_id;
quit;

proc print data=Health.Final_join_health (obs=400);
run;


/*preprocessing the data Step 1: calculating LOS (Length of Stay)*/

data Health.Final_join_Health_LOS1;
    set Health.Final_join_health ;
    sas_admitdate=input(date_of_admission,YYMMDDD.);
    sas_releasedate=input(date_of_discharge,YYMMDDD.);
    LOS=intck('day',sas_admitdate, sas_releasedate );
    put los;
run;

/*step 2: calculating age*/
data Health.Final_join_Health_LOS_Age;
    set Health.Final_join_Health_LOS1 ;
    sas_DOB=input(date_of_birth,YYMMDDD.);
    sas_Date_of_admission=input(date_of_admission,YYMMDDD.);
    Age1=intck('day',sas_DOB,sas_Date_of_admission );
    Age=floor(age1/365);
run;

  
/*Step 3: recoding variables Medical_history_3, Race and Gender*/

data Health.recoding_Final_join_Health_LOS;
 set Health.Final_join_Health_LOS_Age;
 if medical_history_3='No' or medical_history_3=0 then  medical_history_3=0;
 if medical_history_3='Ye' or medical_history_3=1 then  medical_history_3=1;
 
 if Gender='Male' or Gender='m'
 then Gender=0;
 
 if Gender='Female' or Gender='f'
 then Gender=1;
 
 if race='Chinese' or race='chinese' then Race='Chinese';
 if race='India' or race='Indian' then Race='Indians';
run;



/*summing the amount for each admission corresponding to each patient_id*/
 
proc sql;
create table Health.Final_table_Descriptive_stat as
select distinct patient_id, SUM(amount) as tot_amount, gender, race, date_of_admission,date_of_discharge,medical_history_1,medical_history_2,
medical_history_3,medical_history_4,medical_history_5,medical_history_6,medical_history_7,
preop_medication_1,preop_medication_2,preop_medication_3,preop_medication_4,
preop_medication_5,preop_medication_6,symptom_1,symptom_2,symptom_3,symptom_4,symptom_5,
lab_result_1,lab_result_2,lab_result_3,Age,weight,height,LOS from 
Health.recoding_Final_join_Health_LOS
group by patient_id,date_of_admission;
quit;



proc print data=Health.Final_table_Descriptive_stat(obs=100);
run;

/*exporting the data file as CSV for later analysis*/


proc export data=Health.Final_table_Descriptive_stat
    outfile="/folders/myfolders/MySASProject/HealthData/Final.csv"
    dbms=csv;
run;


proc sql;
create table test3 as
SELECT *,
CASE
    WHEN weight <84.5  THEN 0
    ELSE 1
END AS Weight1,
case 
when Height<168.5 then 0
Else 1
End as Height1,
case
when tot_amount<30000 then 1
when tot_amount between 30001 and 70000 then 2
Else 3
End as Final_cost,
case 
when LOS<10 then 0
Else 1
End as LOS_1,
case 
when Age<25 then 1
when Age between 26 and 34 then 2
Else 3
End as Age1
FROM Health.Final_table_Descriptive_stat;
quit;



/*Continuing with preprocessing to use the data only for descriptive analysis*/

/*finding min and max for few variables to group them as categorical and continous*/

proc sql;
create table test1 as
select min(Age) as min, max(Age) as max
from Health.Final_table_Descriptive_stat
group by Age;
quit;

/*preprocessing step: 4 recoding variable weight , height, LOS, tot_amount and AGe*/

proc sql;
create table test2 as
SELECT *,
CASE
    WHEN weight <84.5  THEN 0
    ELSE 1
END AS Weight1,
case 
when Height<168.5 then 0
Else 1
End as Height1,
case
when tot_amount<30000 then'Bill amount below 30,000'
when tot_amount between 30001 and 70000 then 'Btw 30,000-70,000'
Else 'Amount paid more than 70,000'
End as Final_cost,
case 
when LOS<10 then 0
Else 1
End as LOS_1,
case 
when Age<25 then '21-25'
when Age between 26 and 34 then '26-34'
Else'35 and older'
End as Age1
FROM Health.Final_table_Descriptive_stat;
quit;

proc sql;
create table Health.Healthdata_regression_only as
select gender,race, Weight1,Height1,tot_amount,LOS_1,Age1,medical_history_1, medical_history_2, 
medical_history_3, medical_history_4, medical_history_5, medical_history_6, 
medical_history_7, preop_medication_1, preop_medication_2, preop_medication_3,
preop_medication_4,preop_medication_5,preop_medication_6,symptom_1,symptom_2,
symptom_3,symptom_4,symptom_5
from test3;
quit;

data Health.Healthdata_regression_only_Final;
set Health.Healthdata_regression_only;
 if race='Chinese' or race='chinese' then Race=1;
 if race='India' or race='Indians' then Race=2;
 if race='Malay' then race=3;
 if race='Others' then race=4;
run;

data regression_only_Final;
set Health.Healthdata_regression_only_Final;
race1= input(race, 7.);
medical_history_3N=input(medical_history_3, 2.);
run;



proc print data=Health.Healthdata_regression_only_Final (obs=50);
run;

/*preparing the final table and keeping only needed variables for descriptive analysis*/
proc sql;
create table Health.Healthdata_descriptive_only as
select gender,race, Weight1,Height1,Final_cost,LOS,Age1,medical_history_1, medical_history_2, 
medical_history_3, medical_history_4, medical_history_5, medical_history_6, 
medical_history_7, preop_medication_1, preop_medication_2, preop_medication_3,
preop_medication_4,preop_medication_5,preop_medication_6,symptom_1,symptom_2,
symptom_3,symptom_4,symptom_5
from test2;
quit;

proc print data=Health.Healthdata_descriptive_only (obs=10);
run;

proc export data=Health.Healthdata_descriptive_only
    outfile="/folders/myfolders/MySASProject/HealthData/DESRIP_Only.csv"
    dbms=csv;
run;

/* Descriptive Analysis- inserted different variables to form a table with all variables*/

proc freq data=Health.Healthdata_descriptive_only;
tables medical_history_3*Race/ norow nocol;
run;

/*visualization*/

proc SGPLOT data=
vbar Final_cost/discrete type=percent subgroup=LOS_1;
quit;

PROC SGPLOT DATA =Health.Healthdata_descriptive_only;
VBAR Final_cost / GROUP = LOS_1;
 TITLE 'Total bill cost by Length of Stay';
 Run;
 
 proc glm data= regression_only_Final;
 model tot_amount=LOS_1 race1 Age1 height1 weight1 medical_history_1 medical_history_2	medical_history_3N	medical_history_4	medical_history_5 medical_history_6	medical_history_7 preop_medication_1 preop_medication_2	preop_medication_3	preop_medication_4	
 preop_medication_5	preop_medication_6 symptom_1 symptom_2 symptom_3 symptom_4 symptom_5;
 run;
 
