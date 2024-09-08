***Création de la librairie***;

libname Projet "C:\Users\ADMIN\Desktop\Cours Uiv-lille\Projet SAS\Projet\Projet sous sas" ;

/*Importation des fichiers*/
/*Auto-mpg1 */

FILENAME REFFILE 'C:\Users\ADMIN\Desktop\Cours Uiv-lille\Projet SAS\Projet\Projet sous sas\auto-mpg-1.xlsx';
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=Projet.autompg1;
	GETNAMES=YES;
RUN;

/* auto-mpg-2*/
FILENAME REFFILE 'C:\Users\ADMIN\Desktop\Cours Uiv-lille\Projet SAS\Projet\Projet sous sas\auto-mpg-2.xlsx';
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=Projet.autompg2;
	GETNAMES=YES;
RUN;

/*auto-mpg-3*/
FILENAME REFFILE 'C:\Users\ADMIN\Desktop\Cours Uiv-lille\Projet SAS\Projet\Projet sous sas\auto-mpg-3.xlsx';
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=Projet.autompg3;
	GETNAMES=YES;
RUN;

/*Concatenation autompg1 et autompg2 */
Proc sort data=projet.autompg1; 
by Identifiant;
run;

Proc sort data=projet.autompg2; 
by Identifiant;
run;

data projet.autompg12;
merge projet.autompg1 projet.autompg2; 
by Identifiant;
run;

/*concatenation de autompg12 et mpg3 */

data projet.mpg;
set projet.autompg12 projet.autompg3; 
run;
proc print data=projet.mpg;run;

/** Format des variables**/

proc contents data=projet.mpg;
run;

/*Creation de la variable age */
data projet.mpg;
set PROJET.mpg;
age=1983-annee_du_modele;
drop annee_du_modele;
run;
proc print data=projet.mpg;run;

*** creation d'une copie de base de données***;
data Projet.mpg_initial; set projet.mpg;run;

**Graphique de la répartition des voitures selon l'origine*;
PROC GCHART DATA=Projet.mpg_initial;
title 'hitogrmme des voitures selon origine';
VBAR3D origine / SUBGROUP=origine FREQ ;
RUN ; 
QUIT ;

/*Statistiques descriptives selon l'origine avant néttoyage des données*/
proc means data=Projet.mpg_initial  NMISS MIN MAX MEAN MEDIAN STD;
title 'analyse descriptive du fichier mpg_initial';
var  mpg cylindres deplacement puissance poids acceleration;
class origine;
run;

*Statistiques descrptives de l'echantillon avant nettoyage*;
proc means data=Projet.mpg_initial  NMISS MIN MAX MEAN MEDIAN STD;
title 'analyse descriptive du fichier mpg_initial';
var  cylindres deplacement puissance poids acceleration ;
run;

/*Nettoyage des données*/

/* remplacement des données manquantes par la médiane*/
proc means data=Projet.mpg_initial N NMISS MIN MAX RANGE MEAN MEDIAN STD;
title 'analyse descriptif du fichier mpg_initial';
var mpg cylindres deplacement puissance poids acceleration;
class origine;
run;

DATA Projet.mpg_complet; set Projet.mpg_initial;
IF deplacement="." and origine=:"Europe" Then deplacement=105 ;
IF deplacement="." and origine=:"Asie" Then deplacement=97 ;
IF deplacement="." and origine=:"USA" Then deplacement=250 ;
IF puissance="." and origine=:"Europe" Then puissance=76.5 ;
IF puissance="." and origine=:"Asie" Then puissance=75 ;
IF puissance="." and origine=:"USA" Then puissance=105 ;
IF acceleration="." and origine=:"Europe" Then acceleration=15.5 ;
IF acceleration="." and origine=:"Asie" Then acceleration=16.4 ;
IF acceleration="." and origine=:"USA" Then acceleration=15 ;
IF poids="." and origine=:"Europe" Then poids=2250.0 ;
IF poids="." and origine=:"Asie" Then poids=2160 ;
IF poids="." and origine=:"USA" Then poids=3372.5 ;
run;
proc print data=Projet.mpg_complet; run;

/* suppression des données abérantes*/

*supression des valeurs aberrantes;
PROC MEANS DATA=Projet.mpg_complet  N Q1 Q3;
  VAR poids acceleration cylindres puissance deplacement;
  RUN;
  Data stat_summary;
  P25_poids=2234;
  P75_poids=3574;
  P25_acceleration=13.7;
  P75_acceleration=17;
  P25_puissance=76;
  P75_puissance=125;
  P25_cylindres=4;
  P75_cylindres=8;
  P25_deplacement=105;
  P75_deplacement=267;
  RUN;
  *Définition des seuils pour les valeurs aberrantes pour chaque variable;
DATA seuils;
  SET stat_summary;
  seuil_inf_poids = P25_poids - 1.5 * (P75_poids - P25_poids);
  seuil_sup_poids = P75_poids + 1.5 * (P75_poids - P25_poids);
  
  seuil_inf_acceleration = P25_acceleration - 1.5 * (P75_acceleration - P25_acceleration);
  seuil_sup_acceleration = P75_acceleration + 1.5 * (P75_acceleration - P25_acceleration);
  
  seuil_inf_cylindres = P25_cylindres - 1.5 * (P75_cylindres - P25_cylindres);
  seuil_sup_cylindres = P75_cylindres + 1.5 * (P75_cylindres - P25_cylindres);
  
  seuil_inf_puissance = P25_puissance - 1.5 * (P75_puissance - P25_puissance);
  seuil_sup_puissance = P75_puissance + 1.5 * (P75_puissance - P25_puissance);
  
  seuil_inf_deplacement = P25_deplacement - 1.5 * (P75_deplacement - P25_deplacement);
  seuil_sup_deplacement = P75_deplacement + 1.5 * (P75_deplacement - P25_deplacement);
RUN;
PROC PRINT DATA=seuils;
RUN;
DATA Projet.mpg_clean;
  SET Projet.mpg_complet;
  if acceleration<21.95 and acceleration>8.75;
  if poids<5584 and poids>224;
  if cylindres<14 and cylindres> -2;
  if puissance<198.5 and puissance>2.5;
  if deplacement<510 and deplacement> -138;
RUN;
PROC PRINT DATA=Projet.mpg_clean;
RUN;


/*statistiques descriptive après nettoyage de la base de données selon l'origine*/
proc means data=Projet.mpg_clean NMISS MIN MAX MEAN MEDIAN STD;
title 'analyse descriptive du fichier mpg_clean';
var mpg cylindres deplacement puissance poids acceleration age ;
class origine;
run;

***statistiques descriptives sur le fichier clean**;
proc means data=Projet.mpg_clean N NMISS MIN MAX MEAN MEDIAN STD;
title 'analyse descriptive du fichier mpg_clean';
var mpg cylindres deplacement puissance poids acceleration age ;
run;

*** histogrammes de quelques variables continue***;
***mpg***;
PROC GCHART DATA=Projet.mpg_clean;
title 'hitogrmme de mpg par rapport a origine';
VBAR3D mpg / SUBGROUP=origine FREQ;
RUN ; 
QUIT ;

**poids***;
PROC GCHART DATA=Projet.mpg_clean ;
title 'hitogrmme du poids par rapport a origine';
VBAR3D poids / SUBGROUP=origine FREQ;
RUN ; 
QUIT;


/*création des USA, Europe,Asie*/
DATA Projet.mpg_final ;
set Projet.mpg_clean ;
IF origine=:'USA' Then USA=1;
ELSE USA=0;
IF origine=:'Europe' Then Europe=1;
ELSE Europe=0;
IF origine=:'Asie' Then Asie=1;
ELSE Asie=0;
RUN;

proc contents data=Projet.mpg_final; run;

*****correlation entre les variables*****;

*** Corrélation des variables explicatives avec la variable à explique***;
Proc corr data=Projet.mpg_final;
title 'Corrélation des variables explicatives avec la variable à expliquer';
var mpg cylindres deplacement puissance poids acceleration age;
run ; 

*Ajout des variables USA,Europe et Asie*;
Proc corr data=Projet.mpg_final;
title 'Corrélation des variables explicatives avec la variable à expliquer';
var mpg cylindres deplacement puissance poids acceleration age USA Europe Asie;
run ;

*** Corrélation entre les variables explicatives***;
Proc corr data=Projet.mpg_final; 
title 'Corrélation entre les variables explicatives'; 
var cylindres deplacement puissance poids acceleration age;
run ; 

Proc corr data=Projet.mpg_final; 
title 'Corrélation entre les variables explicatives'; 
var poids acceleration age USA Europe Asie ;
run ;

***estimation des version du modèle****;
***version1***;
Proc REG data=Projet.mpg_initial; 
title 'regression de mpg en fonction cylindres deplacement puissance poids acceleration age'; 
model mpg=cylindres deplacement puissance poids acceleration age ; 
run;
quit;

***version2***;
Proc REG data=Projet.mpg_complet; 
title 'regression de mpg en fonction cylindres deplacement puissance poids acceleration age'; 
model mpg=cylindres deplacement puissance poids acceleration age ; 
run;
quit;

***version3***;
Proc REG data=Projet.mpg_clean; 
title 'regression de mpg en fonction cylindres deplacement puissance poids acceleration age'; 
model mpg=cylindres deplacement puissance poids acceleration age ; 
run;
quit;

***version4***;
Proc REG data=Projet.mpg_final; 
title 'regression de mpg en fonction cylindres deplacement puissance poids acceleration age USA Europe Asie'; 
model mpg=cylindres deplacement puissance poids acceleration age USA Europe Asie ; 
run;
quit;

***Premier modèle avec les variables significatives***;

Proc REG data=Projet.mpg_final;
title 'regression de mpg en fonction de poids age USA'; 
model mpg=poids age USA  ; 
run;
quit;

***Identification des observations qui influent négativement le modèle***;
Proc REG data=Projet.mpg_final corr;
title 'regression de mpg en fonction de poids age USA'; 
model mpg=poids age USA / r influence; 
run;
quit;

*** Supression des observations qui influent négativement le modèle***;

data Projet.mpg_end; 
set Projet.mpg_final;
if identifiant=104 then delete;
if identifiant=159 then delete;
if identifiant=218 then delete;
if identifiant=225 then delete;
if identifiant=275 then delete;
if identifiant=277 then delete;
run;
***Modèle final***;

Proc REG data=Projet.mpg_end corr;
title 'regression de mpg en fonction de poids age USA'; 
model mpg=poids age USA ; 
run;
quit;



*Prediction mpg du fichier auto-mpg-a-predire*;

FILENAME REFFILE 'C:\Users\ADMIN\Desktop\Cours Uiv-lille\Projet SAS\Projet\Projet sous sas\auto-mpg-a-predire.xlsx';
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=Projet.mpg_predire;
	GETNAMES=YES;
RUN;

**Création de la variable age dans le fichier mpg à prédire*;
data Projet.prediction;
set PROJET.mpg_predire;
age=83-annee_du_modele;
drop annee_du_modele;
run;

** creation de la variable USA dans le fichier mpg à prédiire*;
DATA Projet.predictionfin ;
set Projet.prediction ;
IF origine=:'USA' Then USA=1;
ELSE USA=0 ;
RUN;

**prediction**;
data Projet.predictionfinal;
set Projet.predictionfin;
mpg_predire=48.17772-0.00610*poids-0.79078*age-1.84420*USA;
drop mpg;
run;

/*Pour renommer la variable mpg_predire en mpg*/
data Projet.mpg_prediction;
  set Projet.predictionfinal;
  mpg=mpg_predire;
  drop mpg_predire; 
run;
Proc print data=Projet.mpg_prediction;run;

























