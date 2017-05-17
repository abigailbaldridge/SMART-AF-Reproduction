/*******************************************************************************************
*                                                                                          *
*   YODA PROJECT CODE                                                                      *
*   Hawkins Gay                                                                            *
*                                                                                          *
*******************************************************************************************/

/**Creating LIBRARY to work with datasets imported from repository**/
libname YODA "&_SASWS_/CTDT/JNJ-Study-SMART-AF/Files/Analysis Ready Datasets/SAS_analysis";

/**initial file with all participants was the 'screening' dataset evaluated below**/

proc contents data=yoda.screening;
run;

ods PDF file = "&_SASWS_/CTDT/Output/YODA_ENROLLMENT_PDF.pdf";

proc freq data=yoda.screening;
tables IT_SUBJECTENROLLINTOSTUDY__UVUR;

title 'Screened Patients who Enrolled in the Study';
run;

/**the code above confirms that of the 633 total subjects screened for the study, 172 were enrolled in the study**/

ods PDF close;

/**the following code is being used to create a dataset with just the enrolled subjects: i.e. 'screening2' **/

data screening1;
set yoda.screening;
IF IT_SUBJECTENROLLINTOSTUDY__UVUR = 'No' then enroll = 1;
run;

data yoda.screening2;
set screening1;
IF enroll = 1 then DELETE;
run;

proc freq data=yoda.screening2;
tables IT_SUBJECTENROLLINTOSTUDY__UVUR;
run;

/**this confirms that the 'screening2' dataset contains only those subjects that enrolled in the study - these study IDs can now be used to limit further dataset creation**/

proc freq data=yoda.screening2;
tables IT_SUBJECTMETALLEXCLUSIONCR_QPMI*IT_SUBJECTMETALLINCLUSIONCR_ZNSR;
run;

/**confirms that only 157 subjects met all inclusion and exclusion criteria, but 161 got into the safety cohort - 115 meet the criteria when run in the 'effectiveness cohort'**/

/** Sorting data by study ID in order to merge files into one for the Safety Cohort Creation - this process assumes that the ABLATION_PROCEDURE dataset contains only subjects who underwent the procedure and therefore should be included in the Safety Cohort **/

/** End result of this step will be the creation of the 'safety' dataset **/

proc contents data=yoda.ablation_procedure;
run;

proc sort data = yoda.screening2;
by DPATID;
run;

proc sort data = yoda.ablation_procedure;
by DPATID;
run;

data ablation (keep = DPATID);
set yoda.ablation_procedure;
run;

data yoda.safety;
merge yoda.screening2 ablation(IN=A);
by DPATID;
if A;
run;

proc freq data=yoda.safety;
tables IT_SUBJECTENROLLINTOSTUDY__UVUR;
run;

/**Merged dataset above, has 162 subjects in it (all enrolled), one more than the reported Safety Cohort**/

/**this step will make AGE a numeric variable in the dataset**/

data yoda.safety;
set yoda.safety;
numAGE = input (IT_AGE_NWA3, best12.);
run;

/**adding in the data from the 'baseline' dataset so that I can calculate Table 1** /

proc sort data = yoda.safety;
by DPATID;
run;

proc sort data = yoda.baseline;
by DPATID;
run;

data yoda.safety;
merge yoda.safety(IN=A) yoda.baseline;
by DPATID;
if A; **because 'baseline' dataset has 170 subjects within it, and we have narrowed to 162 for the safety cohort **
run;

/** The following variables will be combined to mirror the categories in the baseline table from Patient History in the published article **
   * Structural Heart Disease:
      * IT_ISCHEMICCARDIOMYOPATHY_KQA0 - ischemic cardiomyopathy
      * IT_NON_ISCHEMICDILATEDCARDI_L2T9 - non-ischemic cardiomyopathy
      * IT_HYPERTROPHICCARDIOMYOPAT_DW1C - hypertrophic cardiomyopathy
      * IT_SIGNIFICANTVALVEDISEASE__TOPK - significant valvular disease
      * IT_SUBJECTANYVALVULARCARDIA_GZ7T - h/o valvular surgery
      * IT_CONGENITALHEARTDISEASE_MQKK - congenital heart disease
      * IT_CONGESTIVEHEARTFAILURE_G08V - congestive heart failure
      * IF IT_LEFTVENTRICULARHYPERTROP_XEMF - left ventricular hypertrophy
   * CVA:
      * IT_CEREBROVASCULARACCIDENTS_3ECD - CVA secondary to thromboembolic event
      * IT_CEREBROVASCULARACCIDENTI_578I - CVA in the past year
      * IT_CEREBROVASCULARACCIDENTN_S8AZ - any other CVA (not due to thromboembolic event)
   * TIA: IT_TRANSIENTISCHEMICATTACKS_55SN
   * Prior Thromboembolic Events:
      * IT_PULMONARYEMOBLUS_MFXV - pulmonary embolus
      * IT_PULMONARYEMOBLUSINPAST1Y_G5W6 - PE in the last year
      * IT_DEEPVEINTHROMBUS_C595 - Deep vein thrombosus
      * IT_DEEPVEINTHROMBUSINPAST1Y_2ZLF - DVT in the past year
      * IT_OTHERTHROMBOEMBOLICEVENT_Z19S - other thromboembolic events
      * IT_THROMBOEMBOLICEVENT_S_IN_8NEG - other thromboembolic events in the past year 
      
**/      

data yoda.safety;
set yoda.safety;
IF IT_ISCHEMICCARDIOMYOPATHY_KQA0 = 'Yes' then structure = 'Yes';
IF IT_NON_ISCHEMICDILATEDCARDI_L2T9 = 'Yes' then structure = 'Yes';
IF IT_HYPERTROPHICCARDIOMYOPAT_DW1C = 'Yes' then structure = 'Yes';
IF IT_SIGNIFICANTVALVEDISEASE__TOPK = 'Yes' then structure = 'Yes';
IF IT_SUBJECTANYVALVULARCARDIA_GZ7T = 'Yes' then structure = 'Yes';
IF IT_CONGENITALHEARTDISEASE_MQKK = 'Yes' then structure = 'Yes';
IF IT_CONGESTIVEHEARTFAILURE_G08V = 'Yes' then structure = 'Yes';
IF IT_LEFTVENTRICULARHYPERTROP_XEMF = 'Yes' then structure = 'Yes';
IF IT_CEREBROVASCULARACCIDENTS_3ECD = 'Yes' then CVA = 'Yes';
IF IT_CEREBROVASCULARACCIDENTI_578I = 'Yes' then CVA = 'Yes';
IF IT_CEREBROVASCULARACCIDENTN_S8AZ = 'Yes' then CVA = 'Yes';
IF IT_PULMONARYEMOBLUS_MFXV = 'Yes' then thrombo = 'Yes';
IF IT_PULMONARYEMOBLUSINPAST1Y_G5W6 = 'Yes' then thrombo = 'Yes';
IF IT_DEEPVEINTHROMBUS_C595 = 'Yes' then thrombo = 'Yes';
IF IT_DEEPVEINTHROMBUSINPAST1Y_2ZLF = 'Yes' then thrombo = 'Yes';
IF IT_OTHERTHROMBOEMBOLICEVENT_Z19S = 'Yes' then thrombo = 'Yes';
IF IT_THROMBOEMBOLICEVENT_S_IN_8NEG = 'Yes' then thrombo = 'Yes';
run;

proc freq data=yoda.safety;
tables IT_PULMONARYEMOBLUS_MFXV*IT_PULMONARYEMOBLUSINPAST1Y_G5W6*IT_DEEPVEINTHROMBUS_C595*IT_DEEPVEINTHROMBUSINPAST1Y_2ZLF*IT_OTHERTHROMBOEMBOLICEVENT_Z19S*IT_THROMBOEMBOLICEVENT_S_IN_8NEG*thrombo
 / LIST MISSING;
run;

/** checking NYHA Functional Class **/
proc freq data=yoda.safety;
table IT_PLEASEINDICATECURRENTNYH_41ZB / LIST MISSING;
run;

/**Calculate LVEF**/
proc means data=yoda.safety;
var IT_LVEF_LEFTVENTRICLEEJECTI_HFZH;
run;

/**Calculate LA dimension, from the parasternal long view**/
proc means data=yoda.safety;
var IT_PARASTERNALLONGAXISVIEW__ZDQ2;
run;

/**Putting it all together for the Safety Cohort in Table 1**/

ods PDF file = "&_SASWS_/CTDT/Output/YODA_BASELINE_PDF.pdf";

proc means data = yoda.safety
   MEAN STD MEDIAN CLM MAX MIN Q1 Q3 MAXDEC=1;
VAR numAGE IT_HOWLONGSUBJECTSYMPTOMATI_8JU1 IT_LVEF_LEFTVENTRICLEEJECTI_HFZH IT_PARASTERNALLONGAXISVIEW__ZDQ2;
title 'Summary Statistics for Safety Cohort';
run;

proc freq data = yoda.safety;
tables IT_GENDER2_O1RP IT_ATRIALFLUTTER_AFL__WRON IT_HYPERTENSION_AZRU IT_DIABETES_OPG_4HVD structure CVA IT_TRANSIENTISCHEMICATTACKS_55SN thrombo IT_PLEASEINDICATECURRENTNYH_41ZB;
title 'Summary Statistics for Safety Cohort';
run;

ods PDF close;

/**Will now use IT_ISTHISSUBJECTACALIBRATIO_HA6M to identify the Roll-In subjects and create an Effectiveness Cohort group i.e. rollin = 0**/
proc freq data=yoda.safety;
tables IT_ISTHISSUBJECTACALIBRATIO_HA6M;
run;

data safety1;
set yoda.safety;
IF IT_ISTHISSUBJECTACALIBRATIO_HA6M = 'Yes' then rollin = 1;
IF IT_ISTHISSUBJECTACALIBRATIO_HA6M = 'No' then rollin = 0;
run;

proc freq data = safety1;
tables rollin;
run;

data yoda.effectiveness;
set safety1;
IF rollin = 1 then DELETE;
run; ** after deleting all of the rollin subjects I am left with 124 subjects in the 'effectivesness cohort', two more then the published paper lists**;

proc freq data=yoda.effectiveness;
tables IT_ISTHISSUBJECTACALIBRATIO_HA6M*rollin / LIST MISSING;
run;

/**This confirms that the code above created a dataset where rollin = 0 means the subject is part of the effectiveness cohort**/

/**Putting it all together for the Effectiveness Cohort in Table 1**/

ods PDF file = "&_SASWS_/CTDT/Output/YODA_BASELINE2_PDF.pdf";

proc means data = yoda.effectiveness
   MEAN STD MEDIAN CLM MAX MIN Q1 Q3 MAXDEC=1;
VAR numAGE IT_HOWLONGSUBJECTSYMPTOMATI_8JU1 IT_LVEF_LEFTVENTRICLEEJECTI_HFZH IT_PARASTERNALLONGAXISVIEW__ZDQ2;
title 'Summary Statistics for Effectiveness Cohort';
run;

proc freq data = yoda.effectiveness;
tables IT_GENDER2_O1RP IT_ATRIALFLUTTER_AFL__WRON IT_HYPERTENSION_AZRU IT_DIABETES_OPG_4HVD structure CVA IT_TRANSIENTISCHEMICATTACKS_55SN thrombo IT_PLEASEINDICATECURRENTNYH_41ZB;
title 'Summary Statistics for Effectiveness Cohort';
run;

ods PDF close;

/**Creating datafiles for Figure 2, KM curve of symptom free survival**/

/**In order to do this, need to take multiple steps, including coding for DAY variable that measures day of documented symptomatic recurrence episode:
   
   *These episodes take place in the 3, 6, 9 and 12 months Follow-Up databases, because the first 3 months = blanking period

   *the databases contain data on # of days to recurrent episodes which need to be quantified and rolled into a single analysis dataset for KM creation

**/

/*3 month f/u data manipulation*/
data thfu;
set yoda.fup_3_month;
if 1 <= FDSG62ZDY <= 90 then days3 = .;
else if FDSG62ZDY > 90 then days3 = FDSG62ZDY+0;
else if FDSG62ZDY = . then days3 = .;
run;

/*6 month f/u data manipulation*/
data sxfu;
set yoda.fup_6_month;
if 1 <= FDSJKFKDY <= 90 then days6 = .;
else if FDSJKFKDY > 90 then days6 = FDSJKFKDY+0;
else if FDSJKFKDY = . then days6 = .;
run;

/*9 month f/u data manipulation*/
data nifu;
set yoda.fup_9_month;
if 1 <= FDSYOCYDY <= 90 then days9 = .;
else if FDSYOCYDY > 90 then days9 = FDSYOCYDY+0;
else if FDSYOCYDY = . then days9 = .;
run;

/*12 month f/u data manipulation*/
data twfu;
set yoda.fup_12_month;
if 1 <= FDSX4VKDY <= 90 then days12 = .;
else if FDSX4VKDY > 90 then days12 = FDSX4VKDY+0;
else if FDSX4VKDY = . then days12 = .;
run;

/*will sort datasets created above in order to merge into one dataset with all DAPTIDs*/

proc sort data = thfu;
by DPATID;
run;

proc sort data = sxfu;
by DPATID;
run;

proc sort data = nifu;
by DPATID;
run;

proc sort data = twfu;
by DPATID;
run;

proc sort data = yoda.effectiveness;
by DPATID;
run;

data life_curve;
merge yoda.effectiveness(IN=A) thfu sxfu nifu twfu;
by DPATID;
if A;  
run;

data life;
set life_curve;
if days12 >= 0 and days9 >= 0 and days6 >= 0 and days3 >= 0 then day = days3+0;
else if days12 >= 0 and days9 >= 0 and days6 >= 0 then day = days6+0;
else if days12 >= 0 and days9 >= 0 then day = days9+0;
else if days12 >= 0 and days6 >= 0 then day = days6+0;
else if days12 >= 0 and days3 >= 0 then day = days3+0;
else if days9 >= 0 and days6 >= 0 then day = days6+0;
else if days9 >= 0 and days3 >= 0 then day = days3+0;
else if days6 >= 0 and days3 >= 0 then day = days3+0;
else if days3 >= 0 then day = days3+0;
else if days6 >= 0 then day = days6+0;
else if days9 >= 0 then day = days9+0;
else if days12 >= 0 then day = days12+0;
else if days12 = . and days9 = . and days6 = . and days3 = . then day = .;
run;

proc freq data = life_curve;
tables DPATID*days12*days9*days6*days3 / LIST MISSING;
run;

/**Need to find the ID of the study participants that were lost to follow-up and what day they were lost so that they can be censored from the KM analysis at the correct time**/

proc sort data = yoda.end_of_study;
by DPATID;
run;
 
data eos;
merge yoda.safety yoda.end_of_study;
run;

proc print data = eos;
var DPATID IT_PLEASESPECIFY_45_SUU5 IT_PLEASESPECIFY_45_SUU5 FIS066TDY;
run;

/** from this step I am able to find the following:
   *'S-3344-22738' lost to follow-up day = 212
   *'S-2632-13925' lost to follow-up day = 248
   *'S-2632-11454' lost to follow-up day = 211
   *'S-0154-16502' lost to follow-up day = 200
   *'S-0154-00026' lost to follow-up day = 127
**/

data life_curve2; 
set life;
if DPATID = 'S-3344-22738' then censor = 1;
if DPATID = 'S-2632-13925' then censor = 1;
if DPATID = 'S-2632-11454' then censor = 1;
if DPATID = 'S-0154-16502' then censor = 1;
if DPATID = 'S-0154-00026' then censor = 1;
if DPATID = 'S-0154-13508' then censor = 0;
if DPATID = 'S-0154-19229' then censor = 0;
if DPATID = 'S-2842-13939' then censor = 0;
if DPATID = 'S-3344-22738' then day = 212;
if DPATID = 'S-2632-13925' then day = 248;
if DPATID = 'S-2632-11454' then day = 211;
if DPATID = 'S-0154-16502' then day = 200;
if DPATID = 'S-0154-00026' then day = 127;
if DPATID = 'S-0154-13508' then day = 90;
if DPATID = 'S-0154-19229' then day = 90;
if DPATID = 'S-2842-13939' then day = 90;
run;

data yoda.life_curve;
set life_curve2;
if censor = 1 then censor = 1;
else if censor < 1 then censor = 0;
if day = . then day = 1000; 
run;

proc freq data = yoda.life_curve;
tables censor*day / LIST MISSING;
run;

ods graphics on;
ods PDF file = "&_SASWS_/CTDT/Output/YODA_PDF.pdf";

/**This step will produce the KM curve w/ max time 360 days, and censoring those listed as censor = 1**/
proc lifetest data=yoda.life_curve maxtime = 360 plots=survival(cl nocensor test atrisk(maxlen=13 outside(0.15)));
time day*censor(1);
run;

ods PDF close;

/**Creating the Histogram Safety and Effectiveness datasets needed to re-create Figure 3**/

proc sort data=yoda.effectiveness;
by DPATID;
run;

proc sort data=yoda.safety;
by DPATID;
run;

proc sort data=yoda.ablationtarget_ablationprocedure;
by DPATID;
run;

data ablation_target;
merge yoda.effectiveness(IN=A) yoda.ablationtarget_ablationprocedure;
by DPATID;
if A;
run;

data ablation_target_safe;
merge yoda.safety(IN=A) yoda.ablationtarget_ablationprocedure;
by DPATID;
if A;
run;

/**checking the overall contact force means, before getting mean per participant**/
proc means data = ablation_target;
var IT_MAXCONTACTFORCE_FLOAT_PPXJ;
run;

proc means data = ablation_target_safe;
var IT_MAXCONTACTFORCE_FLOAT_PPXJ;
run;

/**will now sum the means per participant, move to a new dataset, combine them and reproduce the histograms**/
proc means data = ablation_target;
by DPATID;
var IT_MAXCONTACTFORCE_FLOAT_PPXJ;
ODS OUTPUT summary = id_mean_CF;
run;

proc means data = ablation_target_safe;
by DPATID;
var IT_MAXCONTACTFORCE_FLOAT_PPXJ;
ODS OUTPUT summary = id_mean_CF_safe;
run;

proc contents data = id_mean_CF;
run;

proc contents data = id_mean_CF_safe;
run;

proc means data = id_mean_CF;
var IT_MAXCONTACTFORCE_FLOAT__Mean;
run;

proc means data = id_mean_CF_safe;
var IT_MAXCONTACTFORCE_FLOAT__Mean;
run;

/**the steps above allow mean contact force for the study to be calculated and reported for the Effectiveness cohort and the Safety cohort**/

data id_mean_CF_1;
set id_mean_CF;
histo = 1;
run;

data id_mean_CF_safe_1;
set id_mean_CF_safe;
histo = 2;
run;

data histo;
merge id_mean_CF_1 id_mean_CF_safe_1;
by histo;
run;

data yoda.histo;
set histo;
run;

/**printing the histogram to try and replicate Figure 3**/

ods graphics on;
ods PDF file = "&_SASWS_/CTDT/Output/YODA_HISTO_PDF.pdf";

proc univariate data=yoda.histo;
histogram IT_MAXCONTACTFORCE_FLOAT__Mean / vscale = count;
class histo;
run;

ods PDF close;

/**Checking for patients that were failures due to repeat ablation procedures**/
proc freq data=yoda.new_ablation_ablation_procedure;
tables DPATID*ABPRY476DY / LIST MISSING;
run;

proc sort data = yoda.effectiveness;
by DPATID;
run;

proc sort data = yoda.new_ablation_ablation_procedure;
by DPATID;
run;

data new;
merge yoda.effectiveness(IN=A) yoda.new_ablation_ablation_procedure;
by DPATID;
if A;
run;

proc freq data=new;
tables DPATID*ABPRY476DY / LIST MISSING;
run;  **this code lists the STUDY ID and the number of repeat ablations needed**

/** from the code above I can tell there were 6 subjects that had >2 repeat ablations post procedure**/;

data yoda.repeat_ablation_mult;
set new;
run;
**this step creates a permanent dataset to look at this data later**

/**looking for subjects who failed because they did not have exit block verified post procedure**/;
proc sort data=yoda.ablation_procedure;
by DPATID;
run;

data block;
set yoda.effectiveness(IN=A) yoda.ablation_procedure;
by DPATID;
if A;
run;

proc freq data = block;
tables IT_ACUTESUCCESSACHIEVED_ENT_9CJW;
run;
/**of note, this data is missing for all subjects**/

/**checking to see how many people finished the study, as well as those who were lost to follow-up**/
proc print data = yoda.end_of_study;
run;

proc freq data = yoda.end_of_study;
tables IT_SUBJECTCOMPLETED12MONTHV_VECH*FIS066TDY*DPATID / LIST MISSING;
run;

/**6 were lost to follow-up, but one had the event before being lost, another large group didnt complete the study for other reasons, but it is unclear how were they treated in the survival analysis**/


/**Multivariable Logistic Regression Model Creation**/

data model;
set yoda.life_curve;
If day = 1000 then recurrence = 0;
if day < 1000 then recurrence = 1;
run;

proc freq data = model;
tables recurrence;
run;

proc sort model;
by DPATID;
run;

proc sort yoda.effectiveness;
by DPATID;
run;

data model_1;
merge model(IN=A) yoda.effectiveness;
by DPATID;
if A;
run;

proc logistic data = model_1 descending;
      class *need to list categorical variables here, need to transform them to 1 or 0 first* 
      model recurrence = numAGE IT_HOWLONGSUBJECTSYMPTOMATI_8JU1 IT_LVEF_LEFTVENTRICLEEJECTI_HFZH IT_PARASTERNALLONGAXISVIEW__ZDQ2;
run;

/**NOTE: could never complete the above log reg model, as all variables needed to be included could not be identified in the datasets, including %of time CF within investigator selected ranges of >/= 80%, %of time of shaft proximity index severity >/= 2, and % of time of lateral CF > 30g**/

/******************************************************
PDF CODE

ods PDF file = "&_SASWS_/CTDT/Output/YODA_PDF.pdf";

proc contents data=yoda.screening;
run;

ods PDF close;
******************************************************/

