/* Echantillon auto-mpg (valeurs reelles du jeu de donnees auto-mpg,
   noms de colonnes du projet). Remplace les 3 fichiers .xlsx importes
   depuis un chemin local, pour que le script tourne de maniere autonome. */
data projet_mpg;
  length origine $8;
  input identifiant mpg cylindres deplacement puissance poids acceleration annee_du_modele origine $;
  age = 1983 - annee_du_modele;
  datalines;
1 18 8 307 130 3504 12.0 70 USA
2 15 8 350 165 3693 11.5 70 USA
3 18 8 318 150 3436 11.0 70 USA
4 16 8 304 150 3433 12.0 70 USA
5 17 8 302 140 3449 10.5 70 USA
6 24 4 113 95 2372 15.0 70 Asie
7 27 4 97 88 2130 14.5 70 Asie
8 26 4 97 46 1835 20.5 70 Europe
9 25 4 110 87 2672 17.5 70 Europe
10 24 4 107 90 2430 14.5 70 Europe
11 22 6 198 95 2833 15.5 70 USA
12 18 6 199 97 2774 15.5 70 USA
13 21 6 200 85 2587 16.0 70 USA
14 32 4 83 61 2003 19.0 74 Asie
15 28 4 90 75 2125 14.5 74 Asie
16 31 4 79 67 2000 16.0 74 Europe
17 33 4 91 53 1795 17.5 75 Asie
18 20 6 225 100 3651 17.7 76 USA
19 30 4 97 78 2189 16.9 74 Europe
20 29 4 98 83 2219 16.5 74 Europe
21 23 4 120 88 2957 17.0 75 Europe
22 35 4 72 69 1613 18.0 71 Asie
23 27 4 116 90 2123 14.0 71 Europe
24 19 6 232 100 2634 13.0 71 USA
;
run;

/* Creation de la variable indicatrice USA */
data projet_mpg_final;
  set projet_mpg;
  if origine=:'USA' then USA=1; else USA=0;
run;

/* Identification des observations qui influent negativement le modele */
proc reg data=projet_mpg_final corr;
  title 'regression de mpg en fonction de poids age USA';
  model mpg = poids age USA / r influence;
run;
quit;
