The aim of this preliminary study is to provide information on habitats favourable to O. mayottensis. Passive acoustic monitoring was carried out in Mayotte in three types of habitat (forest, mangrove and agroforest) in order to quantify the vocal activity of the species and to assess the impact of several environmental variables on this activity. New findings concerning the species' vocalisations were also reported. The R scripts used to create the maps of the study site and the statistical analysis of the data can be found in the "scripts" folder.

Concernant les analyses statistiques des données, nous avons défini l'activité vocale d'O. mayottensis comme le pourcentage de temps de chant (PST) enregistré par 
enregistrement. Le PST étant une proportion, il suit une distribution Bêta. Nous avons également testé la multicollinéarité entre les variables explicatives 
(type d'habitat, pourcentage utilisable de l'enregistrement, présence/absence de pluie, pourcentage de lune visible et distance à la zone urbaine la plus proche) 
après les avoir centrées et mises à l'échelle. Pour évaluer si la durée d'échantillonnage affectait l'activité d'O. mayottensis, nous avons mené une étude répétée 
sur le même site forestier et testé la signification de cet effet à l'aide d'une analyse de variance ANOVA avec un test du chi-carré. 

Pour vérifier si les deux appareils AudioMoth de chaque paire placés sur chaque site ont enregistré les mêmes données, nous avons effectué une analyse de covariance 
ANCOVA sur un modèle linéaire comparant le PST sur les 3 jours en fonction de l'appareil AudioMoth (premier ou second composant de la paire) pour les 5 premiers sites 
où les enregistrements ont été annotés. Pour déterminer l'importance de nos variables explicatives sur le PST, nous avons ajusté un modèle linéaire mixte généralisé 
(à l'aide du logiciel glmmTMB) en supposant une distribution Bêta, avec le site d'échantillonnage comme facteur aléatoire puisque nous avons enregistré pendant trois 
jours consécutifs sur chaque site. Le modèle a été testé à l'aide d'une analyse de variance de type III ANOVA avec un test chi-carré de Wald. Les représentations 
graphiques des prédictions PST ont été produites à partir du modèle linéaire mixte généralisé à l'aide de la fonction plot_model() du package sjPlot. 
La validation du modèle a été effectuée à l'aide de la fonction simulateResiduals() du progiciel DHARMa.


