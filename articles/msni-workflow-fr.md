# Calcul du MSNI : flux de travail Humind

Bienvenue dans le tutoriel humind. Dans le fichier RMarkdown suivant,
nous parcourons un exemple de flux de travail utilisant des données MSNA
fictives du cycle 2026. Le flux de travail est organisé par fonction et
annoté pour décrire ce que fait chaque fonction, les points clés à
garder en tête lors de l’utilisation et les variables d’entrée requises
(ainsi que leurs codes). Si vous avez des questions ou des suggestions
d’amélioration, veuillez contacter l’équipe MSNA globale.

## Configuration

Ci-dessous, nous chargeons humind et dplyr, ainsi que le jeu de données
au niveau du ménage (main) et les rosters Santé et Éducation (boucles).
Nous nous assurons également que les identifiants uniques de chaque jeu
de données sont correctement spécifiés, afin de résumer les informations
du main vers le jeu de données de boucle, comme cela est fait dans les
composites sectoriels Santé et Éducation.

``` r

library(humind)
library(dplyr)

data(humind_main)
data(humind_health_ind)
data(humind_edu_ind)

id_col_main <- "_uuid"
id_col_loop <- "_submission__uuid"
```

## Consommation alimentaire

### Indice des stratégies d’adaptation des moyens de subsistance (LCSI)

La première étape du composite de consommation alimentaire consiste à
calculer l’indice des stratégies d’adaptation des moyens de subsistance
(LCSI). La fonction
[`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md)
détermine si les ménages ont utilisé ou épuisé des stratégies
d’adaptation de stress, de crise ou d’urgence et attribue au ménage la
catégorie LCSI la plus élevée applicable : Aucune, Stress, Crise ou
Urgence.

L’exemple ci-dessous combine d’abord les variantes hôte et camp de
quatre stratégies LCSI dans les variables attendues par
[`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md).
Cela est approprié lorsque le questionnaire recueille des versions
hôte/camp mutuellement exclusives d’une même stratégie d’adaptation.

**Points clés** : Par défaut,
[`add_lcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_lcsi.md)
attend les codes de réponse yes, no_had_no_need, no_exhausted et
not_applicable. Un ménage est classé selon le niveau le plus élevé de
stratégie d’adaptation qu’il a soit utilisée, soit épuisée. La fonction
génère fsl_lcsi_cat, ainsi que des catégories distinctes fondées
uniquement sur les stratégies utilisées (fsl_lcsi_cat_yes) et les
stratégies épuisées (fsl_lcsi_cat_exhaust). Si votre questionnaire
utilise des codes de réponse différents, ceux-ci doivent être fournis
via les arguments correspondants de la fonction.

**Variables requises** :

- fsl_lcsi_stress1
- fsl_lcsi_stress2
- fsl_lcsi_stress3
- fsl_lcsi_stress4
- fsl_lcsi_crisis1
- fsl_lcsi_crisis2
- fsl_lcsi_crisis3
- fsl_lcsi_emergency1
- fsl_lcsi_emergency2
- fsl_lcsi_emergency3

``` r

main_foodsec <- humind_main |>
  # Ce formulaire répartit 4 items LCSI en variantes _host/_camp mutuellement exclusives ;
  # les fusionner (coalesce) dans les colonnes uniques attendues par add_lcsi().
  mutate(
    fsl_lcsi_stress1 = coalesce(fsl_lcsi_stress1_host, fsl_lcsi_stress1_camp),
    fsl_lcsi_stress2 = coalesce(fsl_lcsi_stress2_host, fsl_lcsi_stress2_camp),
    fsl_lcsi_emergency2 = coalesce(fsl_lcsi_emergency2_host, fsl_lcsi_emergency2_camp),
    fsl_lcsi_emergency3 = coalesce(fsl_lcsi_emergency3_host, fsl_lcsi_emergency3_camp)
  ) |>
  add_lcsi()
```

### Score de consommation alimentaire (SCA)

Ensuite, nous calculons le score de consommation alimentaire (SCA) à
l’aide de
[`add_fcs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcs.md).
La fonction applique les pondérations standard des groupes d’aliments au
nombre de jours de consommation de chaque groupe d’aliments au cours de
la période de référence et classe le score obtenu dans une catégorie
SCA.

**Points clés** : Les variables d’entrée doivent contenir le nombre de
jours de consommation, de 0 à 7. Avec `cutoffs` = “normal”, les ménages
sont classés comme ayant une consommation alimentaire pauvre lorsque le
SCA est ≤21, limite lorsqu’il est \>21 et ≤35, et acceptable lorsqu’il
est \>35. Les seuils alternatifs peuvent être sélectionnés avec
`cutoffs` = “alternative”, qui utilise les seuils 28 et 42. La fonction
génère fsl_fcs_score et fsl_fcs_cat, en plus des variables pondérées des
groupes d’aliments.

**Variables requises** :

- fsl_fcs_cereal
- fsl_fcs_legumes
- fsl_fcs_veg
- fsl_fcs_fruit
- fsl_fcs_meat
- fsl_fcs_dairy
- fsl_fcs_sugar
- fsl_fcs_oil

``` r

main_foodsec <- main_foodsec |>
  add_fcs(cutoffs = "normal")
```

### Échelle de la faim dans les ménages (HHS)

L’échelle de la faim dans les ménages (HHS) est ensuite calculée à
l’aide de
[`add_hhs()`](https://impact-initiatives-hppu.github.io/humind/reference/add_hhs.md).
La fonction combine les trois questions HHS et leurs questions de
fréquence correspondantes pour produire à la fois une catégorie HHS
générale et une catégorie HHS compatible avec l’IPC.

**Points clés** : Par défaut, la fonction attend des réponses oui/non
aux trois questions d’occurrence et des réponses rarely/sometimes/often
aux questions de fréquence. Une réponse no est notée 0, rarely ou
sometimes 1, et often 2 pour chaque item. Le fsl_hhs_score obtenu va de
0 à 6. La fonction produit à la fois fsl_hhs_cat et fsl_hhs_cat_ipc ;
cette dernière comporte les catégories None, Little, Moderate, Severe et
Very Severe. La fonction vérifie également la cohérence entre chaque
question oui/non et sa question de fréquence.

**Variables requises** :

- fsl_hhs_nofoodhh
- fsl_hhs_nofoodhh_freq
- fsl_hhs_sleephungry
- fsl_hhs_sleephungry_freq
- fsl_hhs_alldaynight
- fsl_hhs_alldaynight_freq

``` r

main_foodsec <- main_foodsec |>
  add_hhs()
```

### Indice réduit des stratégies d’adaptation (rCSI)

L’indice réduit des stratégies d’adaptation (rCSI) est calculé à l’aide
de
[`add_rcsi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_rcsi.md).
La fonction applique les pondérations standard à cinq stratégies
d’adaptation liées à l’alimentation pour produire un score rCSI global
et une catégorie ordinale.

**Points clés** : Les valeurs d’entrée doivent aller de 0 à 7 jours. Les
cinq stratégies sont pondérées respectivement 1, 2, 1, 3 et 1, et le
fsl_rcsi_score obtenu est classé No to Low lorsque ≤3, Medium lorsque
\>3 et ≤18, et High lorsque \>18. La fonction génère à la fois
fsl_rcsi_score et fsl_rcsi_cat.

**Variables requises** :

- fsl_rcsi_lessquality
- fsl_rcsi_borrow
- fsl_rcsi_mealsize
- fsl_rcsi_mealadult
- fsl_rcsi_mealnb

``` r

main_foodsec <- main_foodsec |>
  add_rcsi()
```

### Phase de consommation alimentaire

Nous calculons ensuite la phase de la matrice de consommation
alimentaire (FCM) à partir des catégories SCA, rCSI et HHS compatible
IPC calculées aux étapes précédentes.
[`add_fcm_phase()`](https://impact-initiatives-hppu.github.io/humind/reference/add_fcm_phase.md)
associe la combinaison de ces trois indicateurs à l’une des cinq phases
de consommation alimentaire, de la Phase 1 FC à la Phase 5 FC.

**Points clés** : La fonction utilise les noms de variables par défaut
ci-dessus et les libellés de catégorie par défaut : Acceptable,
Borderline et Poor pour le SCA ; No to Low, Medium et High pour le rCSI
; et None, Little, Moderate, Severe et Very Severe pour le HHS
compatible IPC. La variable obtenue est fsl_fc_phase, avec des valeurs
allant de Phase 1 FC à Phase 5 FC. La fonction crée également
fsl_fc_cell, qui identifie la cellule correspondante dans la matrice de
consommation alimentaire 5×3×3.

**Variables requises** :

- fsl_fcs_cat
- fsl_rcsi_cat
- fsl_hhs_cat_ipc

``` r

main_foodsec <- main_foodsec |>
  add_fcm_phase()
```

### Matrice consommation alimentaire – stratégies d’adaptation des moyens de subsistance (FCLCM)

La matrice consommation alimentaire – stratégies d’adaptation des moyens
de subsistance (FCLCM) est ensuite calculée en combinant la phase de
consommation alimentaire avec la catégorie LCSI. La phase obtenue va de
la Phase 1 FCLC à la Phase 5 FCLC.

**Points clés** : La fonction utilise les libellés de phase par défaut
Phase 1 FC à Phase 5 FC et les catégories LCSI None, Stress, Crisis et
Emergency. Si l’une des entrées est manquante ou contient une catégorie
inattendue, la phase fclcm_phase obtenue est NA.

**Variables requises** :

- fsl_fc_phase
- fsl_lcsi_cat

``` r

main_foodsec <- main_foodsec |>
  add_fclcm_phase(lcs_cat_var = "fsl_lcsi_cat")
```

### Composite sectoriel de consommation alimentaire

Enfin,
[`add_comp_foodsec()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_foodsec.md)
convertit directement la phase FCLCM en score du composite sectoriel de
consommation alimentaire. Les cinq phases FCLCM correspondent
directement aux scores composites de 1 à 5, les indicateurs standard de
besoin et de besoin sévère de l’MSNI étant également générés.

**Points clés** :
[`add_comp_foodsec()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_foodsec.md)
nécessite fclcm_phase, qui doit contenir l’un des cinq libellés de phase
FCLCM attendus. Les variables produites sont comp_foodsec_score,
comp_foodsec_in_need et comp_foodsec_in_severe_need. Le score composite
est directement dérivé de la phase FCLCM, la Phase 1 donnant un niveau
de sévérité 1 et la Phase 5 un niveau 5.

**Variables requises** :

- fclcm_phase

``` r

main_foodsec <- main_foodsec |>
  add_comp_foodsec()
```

## WASH

### Quantité d’eau (H-WISE)

Pour le WASH, nous commençons par le H-WISE 4 afin de calculer la
dimension Quantité d’eau. La fonction ci-dessous attribue un score de 0
à 3 à chacune des variables H-WISE et attribue directement le niveau de
sévérité en fonction de la somme par ligne. Une nouvelle variable
appelée « comp_wash_score_water_quantity » est générée.

**Points clés** : Les codes de réponse par défaut sont never, rarely,
sometimes, often, always, dnk et pnta. Si vos données utilisent des
codes de réponse différents, ceux-ci doivent être spécifiés via les
paramètres correspondants de la fonction. Le paramètre `.keep_recoded`
peut être défini sur TRUE si les scores des items H-WISE individuels
sont également requis.

**Variables requises** :

- wash_hwise_drink
- wash_hwise_hands
- wash_hwise_plans
- wash_hwise_worry

``` r

main_wash <- main_foodsec |>
  add_hwise()
```

### Qualité de l’eau potable

Nous calculons ensuite la dimension Qualité de l’eau potable. Celle-ci
repose sur le type de source d’eau potable et le temps nécessaire pour
aller chercher l’eau potable. Les fonctions suivantes recodent
progressivement ces variables dans les catégories requises pour dériver
la classification JMP de l’eau potable.

**Points clés** : La fonction recode les choix du modèle KOBO global
2026 dans les catégories standard : améliorée, non améliorée et eaux de
surface. Comme ces catégorisations peuvent différer selon les contextes,
assurez-vous que le mappage correspond à la réalité du pays. En cas de
doute, cela peut être confirmé avec le cluster WASH.

**Variables requises** :

- wash_drinking_water_source

``` r

main_wash <- main_wash |>
  add_drinking_water_source_cat()
```

**Points clés** : La fonction utilise les informations indiquant si
l’eau est disponible dans l’enceinte ainsi que le temps de collecte
déclaré. Les codes de réponse et seuils par défaut doivent être ajustés
si l’enquête utilise une codification différente.

**Variables requises** :

- wash_drinking_water_time_yn
- wash_drinking_water_time_int
- wash_drinking_water_time_sl
- wash_drinking_water_source

``` r

main_wash <- main_wash |>
  add_drinking_water_time_cat()
```

Les catégories de temps nécessaire pour aller chercher l’eau qui en
résultent sont ensuite classées selon le seuil standard de 30 minutes
utilisé dans la classification JMP.

**Points clés** : Le seuil par défaut est de 30 minutes. Cette fonction
doit être exécutée après
[`add_drinking_water_time_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_drinking_water_source_cat.md),
car elle utilise la variable catégorielle générée à cette étape.

**Variables requises** :

- wash_drinking_water_time_cat

``` r

main_wash <- main_wash |>
  add_drinking_water_time_threshold_cat()
```

La source d’eau potable et les catégories de temps de collecte sont
ensuite combinées pour générer la classification JMP de la qualité de
l’eau potable.

**Points clés** : Cette fonction utilise les catégories générées par les
deux étapes de recodage précédentes, ces fonctions doivent donc être
exécutées dans l’ordre.

**Variables requises** :

- wash_drinking_water_source_cat
- wash_drinking_water_time_30min_cat

``` r

main_wash <- main_wash |>
  add_drinking_water_quality_jmp_cat()
```

### Assainissement

Nous préparons ensuite les variables requises pour calculer la dimension
Assainissement. D’abord, le type d’installation sanitaire est recodé
dans des catégories standard.

**Points clés** : Comme pour les sources d’eau, la fonction suppose le
mappage vers des installations sanitaires améliorées et non améliorées.
Assurez-vous que ces classifications s’appliquent à votre contexte.

**Variables requises** :

- wash_sanitation_facility

``` r

main_wash <- main_wash |>
  add_sanitation_facility_cat()
```

L’installation sanitaire est ensuite classée selon qu’elle est partagée
ou non avec d’autres ménages.

**Points clés** : Les installations classées comme aucune sont
automatiquement affectées à not_applicable pour le partage. Les codes de
réponse par défaut pour la variable de partage doivent être ajustés si
les codes de réponse s’écartent du modèle KOBO global.

**Variables requises** :

- wash_sanitation_facility_sharing_yn
- wash_sanitation_facility

``` r

main_wash <- main_wash |>
 add_sharing_sanitation_facility_cat()
```

La fonction suivante estime le nombre d’individus utilisant
l’installation sanitaire. Pour les installations partagées, cela est
calculé à l’aide du nombre déclaré de ménages partageant l’installation
et de la taille moyenne pondérée des ménages. Pour les installations non
partagées, le nombre d’individus est fondé sur la taille du ménage.

**Points clés** : `hh_size` et `wash_sanitation_facility_sharing_n`
doivent être numériques. La variable `weight` est utilisée pour calculer
la taille moyenne pondérée des ménages et doit donc être présente même
lorsque l’analyse n’est pas pondérée. Pour un jeu de données non
pondéré, créez une variable appelée `weight` et définissez-la sur 1 pour
tous les ménages, comme le montre l’exemple ci-dessous.

**Variables requises** :

- wash_sharing_sanitation_facility_cat
- wash_sanitation_facility_sharing_n
- hh_size
- weight

``` r

main_wash <- main_wash |>
  mutate(weight = 1) |>
  add_sharing_sanitation_facility_n_ind()
```

À l’aide de la catégorie d’installation sanitaire et du statut de
partage, nous pouvons maintenant calculer la classification JMP de
l’assainissement utilisée dans le composite sectoriel WASH.

**Points clés** : Cette fonction utilise les catégories générées par
[`add_sanitation_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md)
et
[`add_sharing_sanitation_facility_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_sanitation_facility_cat.md),
ces étapes doivent donc être exécutées au préalable.

**Variables requises** :

- wash_sanitation_facility_cat
- wash_sharing_sanitation_facility_cat

``` r

main_wash <- main_wash |>
  add_sanitation_facility_jmp_cat()
```

### Hygiène

Pour la dernière dimension du WASH, nous calculons la classification JMP
de l’hygiène. La fonction utilise des informations observées et
auto-déclarées sur la disponibilité d’une installation pour le lavage
des mains, d’eau et de savon. La variable
wash_handwashing_facility_jmp_cat qui en résulte classe les ménages
comme disposant d’une installation pour le lavage des mains basique,
limitée ou no_facility.

**Points clés** : Si le jeu de données ne contient pas survey_modality,
celle-ci doit être ajoutée avant d’exécuter la fonction. Pour une
enquête entièrement en présentiel, elle peut être définie sur «
in_person », comme indiqué ci-dessous. La fonction distingue les
informations observées et déclarées selon la modalité de l’enquête. La
classification par défaut du savon distingue le savon admissible (savon,
détergent) du savon non admissible (ash_mud_sand). Ces paramètres
peuvent être ajustés si nécessaire.

**Variables requises** :

- survey_modality
- wash_handwashing_facility
- wash_handwashing_facility_observed_water_yn
- wash_soap_observed_yn
- wash_handwashing_facility_reported
- wash_handwashing_facility_water_reported_yn
- wash_soap_reported_yn
- wash_soap_observed_type
- wash_soap_reported_type

``` r

main_wash <- main_wash |>
  mutate(survey_modality = "in_person") |>
  add_handwashing_facility_cat()
```

### Composite sectoriel WASH

Enfin, nous calculons le composite sectoriel WASH global. La fonction
[`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md)
combine les composantes quantité d’eau, qualité de l’eau potable,
assainissement et hygiène pour générer le score composite WASH et
l’indicateur de besoin.

**Points clés** : La variable de milieu est requise car le composite
WASH applique une logique de notation différente selon les milieux camp,
urbain et rural. Par défaut, la fonction attend camp_formal et
camp_informal pour les milieux de type camp, urban pour les milieux
urbains et rural pour les milieux ruraux. Si le jeu de données utilise
des codes de milieu différents, les paramètres correspondants
`setting_camp`, `setting_urban` et/ou `setting_rural` doivent être
spécifiés.

**Variables requises** :

- setting
- comp_wash_score_water_quantity
- wash_drinking_water_quality_jmp_cat
- wash_sanitation_facility_jmp_cat
- wash_sanitation_facility_cat
- wash_sharing_sanitation_facility_n_ind
- wash_sharing_sanitation_facility_cat
- wash_handwashing_facility_jmp_cat

``` r

main_wash <- main_wash |>
  add_comp_wash()
```

## Abri et BNA (SNFI) / HLP

### Type d’abri

Nous recodons d’abord les deux variables de type d’abri en une seule
catégorie globale de type d’abri. La fonction combine les informations
sur le type d’abri général et le type d’abri individuel et classe les
ménages comme aucun, inadéquat, adéquat ou non défini. La variable
obtenue est snfi_shelter_type_cat. La fonction donne la priorité aux
réponses telles que pas d’abri ou centre collectif avant d’appliquer la
classification du type d’abri individuel.

**Points clés** : Vérifiez que le mappage des types d’abri correspond à
votre contexte. Les paramètres standard utilisés dans la fonction
peuvent différer. En cas de doute, contactez le cluster Abri pour
confirmer ces classifications.

**Variables requises** :

- snfi_shelter_type
- snfi_shelter_type_individual

``` r

main_snfi <- main_wash |>
  add_shelter_type_cat()
```

### Problèmes d’abri

Nous calculons ensuite le nombre de problèmes d’abri déclarés par chaque
ménage et le convertissons en une catégorie ordinale. La fonction compte
les problèmes déclarés parmi les 11 variables de problèmes d’abri et
génère à la fois snfi_shelter_issue_n et snfi_shelter_issue_cat. Les
catégories obtenues sont none, 1_to_3, 4_to_7 et 8_to_11, avec des
catégories distinctes pour undefined et other.

**Points clés** : La liste des 11 variables de problèmes d’abri doit
être standard dans tous les contextes. Si vous vous en écartez,
contactez l’équipe MSNA globale.

**Variables requises** :

- snfi_shelter_issue

``` r

main_snfi <- main_snfi |>
  add_shelter_issue_cat()
```

### Dommages à l’abri

Nous recodons ensuite les dommages à l’abri déclarés en une catégorie
standardisée de dommages. La fonction combine les différents types de
dommages et donne la priorité au niveau déclaré le plus sévère. La
variable snfi_shelter_damage_cat obtenue contient none, damaged, part,
total ou undefined.

**Points clés** : Les catégories de dommages doivent être standard dans
tous les contextes. Si des écarts apparaissent, assurez-vous de bien les
spécifier dans les arguments pertinents de la fonction.

**Variables requises** :

- snfi_shelter_damage

``` r

main_snfi <- main_snfi |>
  add_shelter_damage_cat()
```

### Espace domestique fonctionnel (EDF)

Nous calculons ensuite le nombre de tâches liées à l’espace domestique
fonctionnel qui ne peuvent pas être réalisées, en tenant compte de la
cuisson, du sommeil, du stockage et de l’éclairage. La fonction
standardise d’abord les trois variables de tâches domestiques et la
source d’éclairage, puis crée des indicateurs binaires et les additionne
pour produire snfi_fds_cannot_n. Celui-ci est ensuite catégorisé en
snfi_fds_cannot_cat, avec des catégories allant de aucune tâche affectée
à quatre tâches affectées.

**Points clés** : Les codes de réponse par défaut sont yes, no et
no_need pour la cuisson, et yes/no pour le sommeil et le stockage. pnta
est traité comme non défini pour les trois variables de tâches. Pour
l’éclairage, none indique l’absence de source d’éclairage.

**Variables requises** :

- snfi_fds_cooking
- snfi_fds_sleeping
- snfi_fds_storing
- energy_lighting_source

``` r

main_snfi <- main_snfi |>
  add_fds_cannot_cat()
```

### Statut d’occupation / Sécurité de la tenure

Nous classons ensuite séparément les arrangements d’occupation et le
risque d’expulsion avant de les combiner en une catégorie globale de
sécurité de la tenure. L’occupation est classée comme risque élevé,
moyen ou faible, tandis que le risque d’expulsion est classé comme
risque élevé ou faible. La variable hlp_tenure_security obtenue prend le
niveau de risque le plus élevé entre les deux composantes.

**Points clés** : Par défaut, no_agreement correspond à une occupation à
risque élevé, rented et hosted_free à un risque moyen, et ownership à un
risque faible. Pour le risque d’expulsion, yes correspond à un risque
élevé et no à un risque faible. dnk, pnta et other sont traités comme
non définis pour l’occupation, tandis que dnk et pnta sont non définis
pour le risque d’expulsion. La catégorie finale de sécurité de la tenure
prend le niveau de risque maximal entre l’occupation et le risque
d’expulsion.

**Variables requises** :

- hlp_occupancy
- hlp_risk_eviction

``` r

main_snfi <- main_snfi |>
  add_occupancy_cat()
```

### Composite sectoriel SNFI

Enfin, nous calculons le composite sectoriel SNFI global. La fonction
[`add_comp_snfi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_snfi.md)
combine le type d’abri, les problèmes d’abri, la sécurité de la tenure,
l’EDF et les catégories de dommages à l’abri standardisés et attribue
des scores à chaque composante. Elle dérive ensuite le comp_snfi_score
global, ainsi que comp_snfi_in_need et comp_snfi_in_severe_need.

**Points clés** : Les variables d’entrée sont générées par les fonctions
précédentes et doivent donc être créées avant d’exécuter
[`add_comp_snfi()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_snfi.md).

**Variables requises** :

- snfi_shelter_type_cat
- snfi_shelter_issue_cat
- hlp_occupancy_cat
- snfi_fds_cannot_cat
- snfi_shelter_damage_cat

``` r

main_snfi <- main_snfi |>
  add_comp_snfi()
```

## Protection

### Mouvement et accès aux espaces publics

Nous calculons d’abord la dimension Mouvement et accès aux espaces
publics. La fonction
[`add_prot_score_movement()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_movement.md)
utilise les préoccupations de sécurité déclarées et les changements de
mouvement ou d’activités pour calculer un score pondéré. Le score
pondéré est ensuite converti en un score de sévérité de 1 à 4 qui
représente le score de cette dimension.

**Points clés** : Toutes les options de réponse se voient attribuer une
pondération comprise entre 0 et 2. Par défaut, men_avoid_places et
men_avoid_night ont une pondération de 1, mais celles-ci peuvent être
ajustées dans les contextes où la conscription militaire est une
caractéristique de la crise. Modifiez simplement les arguments
`men_avoid_places_weight` et `men_avoid_night_weight`, respectivement.
Les variables obtenues sont comp_prot_score_prot_needs_3 et
comp_prot_score_movement.

**Variables requises** :

- prot_needs_3_movement

``` r

main_prot <- main_snfi |>
  add_prot_score_movement()
```

### Pratiques et activités sûres

Nous calculons ensuite la dimension Pratiques et activités sûres. La
fonction
[`add_prot_score_practices()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_practices.md)
calcule des scores pondérés distincts pour les restrictions affectant la
capacité des membres du ménage à mener leurs activités et à participer
aux interactions sociales. Ceux-ci sont ensuite combinés pour produire
le score de sévérité global comp_prot_score_practices, allant de 1 à 4.

**Points clés** : La fonction crée trois variables :
comp_prot_score_prot_needs_2_activities,
comp_prot_score_prot_needs_2_social et comp_prot_score_practices. Ce
n’est que si les deux scores de dimension sous-jacents sont manquants
que le score global des pratiques est également manquant.

**Variables requises** :

- prot_needs_2_activities
- prot_needs_2_social

``` r

main_prot <- main_prot |>
  add_prot_score_practices()
#> Warning: Missing input scores detected
#> ℹ `comp_prot_score_prot_needs_2_activities`: 12 NA.
#> ℹ `comp_prot_score_prot_needs_2_social`: 5 NA.
#> ✖ 3 rows have both inputs NA; `comp_prot_score_practices` will be NA for these
#>   rows.
```

### Droits et accès aux services

Ensuite, nous calculons la dernière dimension Droits et accès aux
services. Comme pour les autres dimensions de la Protection, la fonction
[`add_prot_score_rights()`](https://impact-initiatives-hppu.github.io/humind/reference/add_prot_score_rights.md)
calcule des scores pondérés distincts pour les obstacles à l’accès aux
services essentiels et les obstacles à l’accès à la justice et aux
ressources juridiques. Ceux-ci sont également combinés pour produire le
score de sévérité comp_prot_score_rights, allant de 1 à 4.

**Points clés** : Les différents obstacles sont pondérés selon leur
sévérité dans le cadre de la Protection. En particulier, les obstacles à
l’accès aux soins de santé et aux écoles reçoivent une pondération de 2,
tandis que les autres obstacles à l’accès aux services reçoivent
généralement une pondération de 1. Pour la justice et les ressources
juridiques, la difficulté d’accès aux documents d’identité et d’état
civil reçoit une pondération de 2, tandis que les autres obstacles
spécifiés reçoivent une pondération de 1. dnk et pnta sont traités comme
manquants. La fonction crée trois colonnes :
comp_prot_score_prot_needs_1_services,
comp_prot_score_prot_needs_1_justice et comp_prot_score_rights.

**Variables requises** :

- prot_needs_1_services
- prot_needs_1_justice

``` r

main_prot <- main_prot |>
  add_prot_score_rights()
#> Warning: Missing input scores detected
#> ℹ `comp_prot_score_prot_needs_1_services`: 10 NA.
#> ℹ `comp_prot_score_prot_needs_1_justice`: 35 NA.
```

### Composite sectoriel Protection

Enfin, nous calculons le composite Protection global. La fonction
[`add_comp_prot()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_prot.md)
prend le score de sévérité maximal parmi les trois dimensions de la
Protection — mouvement, pratiques, et droits et services — pour générer
le score de sévérité global de la Protection (allant de 1 à 4).

**Points clés** : Aucun.

**Variables requises** :

- comp_prot_score_movement
- comp_prot_score_practices
- comp_prot_score_rights

``` r

main_prot <- main_prot |>
  add_comp_prot()
```

## Santé

Le composite sectoriel Santé est fondé sur une seule dimension : les
besoins de santé. Il implique de résumer les données du roster vers le
jeu de données principal.

Nous calculons d’abord le besoin de soins de santé au niveau individuel
à l’aide de
[`add_loop_healthcare_needed_cat()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_healthcare_needed_cat.md).
La fonction combine le fait qu’un individu ait eu besoin de soins de
santé avec le fait qu’il les ait reçus, classant chaque individu comme
n’ayant aucun besoin, un besoin satisfait ou un besoin non satisfait.
Elle crée également des indicateurs binaires pour chaque catégorie, qui
sont utilisés dans l’agrégation ultérieure au niveau du ménage.

**Points clés** : Les individus déclarant avoir eu besoin de soins de
santé mais dont les informations sur le fait de les avoir reçus sont
dnk, pnta ou manquantes ne peuvent pas être classés comme ayant un
besoin satisfait ou non satisfait et se voient donc attribuer NA. La
fonction crée également les variables health_ind_healthcare_needed_no,
health_ind_healthcare_needed_yes_unmet et
health_ind_healthcare_needed_yes_met, qui sont utilisées pour agréger
les résultats au niveau individuel vers le niveau du ménage.

**Variables requises** :

- health_ind_healthcare_needed
- health_ind_healthcare_received

``` r

health_ind <- humind_health_ind |>
  add_loop_healthcare_needed_cat()
```

Nous utilisons ensuite
[`add_loop_healthcare_needed_cat_to_main()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_healthcare_needed_cat.md)
pour agréger les indicateurs individuels de besoin de soins de santé au
niveau du ménage. La fonction compte le nombre d’individus dans chaque
catégorie au sein de chaque ménage et rattache ces dénombrements au jeu
de données principal des ménages.

**Points clés** : `id_col_main` et `id_col_loop` doivent identifier le
ménage de manière cohérente dans les jeux de données principal et
individuel. La fonction produit health_ind_healthcare_needed_no_n,
health_ind_healthcare_needed_yes_unmet_n et
health_ind_healthcare_needed_yes_met_n, représentant le nombre
d’individus dans chaque catégorie par ménage.

**Variables requises** :

- health_ind_healthcare_needed_no
- health_ind_healthcare_needed_yes_unmet
- health_ind_healthcare_needed_yes_met
- id_col_main
- id_col_loop

``` r

main_health <- main_prot |>
  add_loop_healthcare_needed_cat_to_main(
    loop = health_ind,
    id_col_main = id_col_main, id_col_loop = id_col_loop
  )
```

Enfin,
[`add_comp_health()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_health.md)
calcule le score composite Santé au niveau du ménage en fonction de la
présence de besoins de soins de santé non satisfaits et satisfaits. Un
ménage reçoit un score de 3 si au moins un individu a un besoin de soins
de santé non satisfait, de 2 s’il y a au moins un individu avec un
besoin satisfait mais aucun besoin non satisfait, et de 1 si les
individus du ménage ne déclarent aucun besoin de soins de santé. La
fonction génère ensuite les indicateurs standard in_need et
in_severe_need.

**Points clés** : Aucun.

**Variables requises** :

- health_ind_healthcare_needed_no_n
- health_ind_healthcare_needed_yes_unmet_n
- health_ind_healthcare_needed_yes_met_n

``` r

main_health <- main_health |>
  add_comp_health()
```

## Éducation

### Boucle : préparation

Comme pour la Santé, l’Éducation implique de résumer les informations du
roster individuel (boucle) vers le jeu de données au niveau du ménage
(main). La première étape consiste à préparer le jeu de données
individuel d’éducation en identifiant les enfants d’âge scolaire. La
fonction
[`add_loop_edu_ind_age_corrected()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_ind_age_corrected.md)
corrige l’âge individuel en fonction du moment de la collecte des
données par rapport au début de l’année scolaire et crée un indicateur
binaire, edu_ind_age_schooling, identifiant les individus qui
appartiennent à la population d’âge scolaire. Par défaut, la tranche
d’âge scolaire est de 5 à 17 ans.

**Points clés** : La variable `start` du jeu de données principal doit
être une date au format ISO 8601 (AAAA-MM-JJ). Par défaut, l’année
scolaire est supposée commencer en septembre (`school_year_start_month`
= 9), et la population d’âge scolaire est définie comme les 5 à 17 ans
(`schooling_start_age` = 5, `schooling_end_age` = 17). Ces paramètres
doivent être ajustés si l’évaluation utilise un mois de début d’année
scolaire ou une tranche d’âge différente. Sinon, un mois de collecte
commun peut être spécifié à l’aide du paramètre `month`. La fonction
génère edu_ind_age_corrected et edu_ind_age_schooling. La valeur par
défaut de l’âge est edu_ind_age, en supposant que la boucle Éducation
est autonome. Dans les autres cas, ajustez ce paramètre.

**Variables requises** :

- id_col_loop (default: uuid)
- id_col_main (default: uuid)
- edu_ind_age
- start

``` r

edu_ind <- humind_edu_ind |>
  add_loop_edu_ind_age_corrected(
    main = main_health,
    id_col_loop = id_col_loop, id_col_main = id_col_main,
    ind_age = "edu_ind_age"
  )
```

### Boucle : accès à l’éducation et obstacles

Nous classons ensuite si chaque enfant d’âge scolaire a accès à
l’éducation. La fonction crée deux variables binaires :
edu_ind_access_d, indiquant l’accès à l’éducation, et
edu_ind_no_access_d, indiquant l’absence d’accès à l’éducation. Les
individus en dehors de la population d’âge scolaire se voient attribuer
NA.

**Points clés** : Par défaut, yes indique l’accès et no l’absence
d’accès. dnk et pnta sont traités comme manquants (NA) plutôt que comme
une absence d’accès. Cette étape doit être exécutée après
[`add_loop_edu_ind_age_corrected()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_ind_age_corrected.md),
car elle utilise edu_ind_age_schooling.

**Variables requises** :

- edu_access
- edu_ind_age_schooling

``` r

edu_ind <- edu_ind |>
  add_loop_edu_access_d()
```

**Points clés** : Par défaut, la fonction identifie les codes de réponse
suivants comme obstacles de protection :

- protection_at_school
- protection_travel_school
- child_work_home
- child_work_outside
- child_armed_group
- child_marriage
- child_pregnancy
- ban
- enroll_lack_documentation
- discrimination

Si l’enquête utilise des codes de réponse différents, ou si la liste des
problèmes de Protection a été contextualisée, les paramètres `barriers`
et `protection_issues` doivent être ajustés.

**Variables requises** :

- edu_barrier
- edu_ind_age_schooling

``` r

edu_ind <- edu_ind |>
  add_loop_edu_barrier_protection_d()
```

### Boucle : perturbation de l’éducation

Enfin, nous identifions les perturbations de l’éducation parmi les
enfants d’âge scolaire. La fonction crée des indicateurs binaires pour
les perturbations dues aux attaques, aux aléas, aux déplacements et à
l’absence d’enseignants.

**Points clés** : Par défaut, les quatre variables de perturbation
utilisent yes, no, dnk et pnta comme codes de réponse attendus. yes est
codé 1, no 0, tandis que dnk et pnta sont traités comme manquants. La
variable d’attaque peut être définie sur NULL si cette dimension n’est
pas collectée dans l’enquête. La fonction génère des variables binaires
se terminant par « \_d », qui sont ensuite agrégées au niveau du ménage
afin de calculer le composite sectoriel Éducation.

**Variables requises** :

- edu_disrupted_attack
- edu_disrupted_hazards
- edu_disrupted_displaced
- edu_disrupted_teacher
- edu_ind_age_schooling

``` r

edu_ind <- edu_ind |>
  add_loop_edu_disrupted_d()
```

### Principal

Avec les nouvelles colonnes ajoutées à la boucle, nous pouvons
maintenant résumer les informations vers le main.

Dans un premier temps, nous agrégeons le nombre d’enfants d’âge scolaire
dans chaque ménage. La fonction additionne edu_ind_age_schooling pour
les individus rattachés au même ménage et crée edu_schooling_age_n. Les
ménages sans enfant d’âge scolaire se voient attribuer la valeur 0.

**Points clés** : `id_col_main` et `id_col_loop` doivent contenir des
identifiants de ménage correspondants dans les jeux de données principal
et de boucle. La fonction utilise la variable individuelle
edu_ind_age_schooling générée dans la section précédente.

**Variables requises** :

- edu_ind_age_schooling
- id_col_main (default: uuid)
- id_col_loop (default: uuid)

``` r

main_edu <- main_health |>
  add_loop_edu_ind_schooling_age_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  )
```

### Principal : accès à l’éducation et obstacles

Nous agrégeons ensuite les indicateurs d’accès à l’éducation au niveau
du ménage. La fonction compte le nombre d’enfants ayant accès à
l’éducation et le nombre d’enfants n’y ayant pas accès, générant
edu_access_n et edu_no_access_n.

**Points clés** : Les deux indicateurs individuels sont générés par
[`add_loop_edu_access_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_access_d.md).
L’agrégation est effectuée par ménage à l’aide des colonnes
d’identifiant unique spécifiées, assurez-vous donc qu’elles sont
correctement spécifiées.

**Variables requises** :

- edu_ind_access_d
- edu_ind_no_access_d
- id_col_main (default: uuid)
- id_col_loop (default: uuid)

``` r

main_edu <- main_edu |>
  add_loop_edu_access_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  )
```

Ensuite, nous agrégeons le nombre d’enfants d’âge scolaire confrontés à
des obstacles de protection de l’enfance au niveau du ménage. La
fonction génère edu_barrier_protection_n, représentant le nombre
d’enfants d’âge scolaire dans le ménage qui sont confrontés à un
obstacle de protection à l’éducation.

**Points clés** : L’indicateur individuel de protection doit d’abord
être généré à l’aide de
[`add_loop_edu_barrier_protection_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_barrier_protection_d.md).

**Variables requises** :

- edu_ind_barrier_protection_d
- id_col_main (default: uuid)
- id_col_loop (default: uuid)

``` r

main_edu <- main_edu |>
  add_loop_edu_barrier_protection_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  )
```

### Principal : perturbation de l’éducation

Enfin, nous agrégeons les différents indicateurs de perturbation de
l’éducation au niveau du ménage. La fonction compte le nombre d’enfants
d’âge scolaire connaissant chaque type de perturbation et génère de
nouvelles colonnes : edu_disrupted_attack_n, edu_disrupted_hazards_n,
edu_disrupted_displaced_n et edu_disrupted_teacher_n.

**Points clés** : Les quatre indicateurs de perturbation utilisés ici
sont générés par
[`add_loop_edu_disrupted_d()`](https://impact-initiatives-hppu.github.io/humind/reference/add_loop_edu_disrupted_d.md).
La dimension attaque peut être omise en définissant `attack_d` = NULL
lorsque cet indicateur a été omis.

**Variables requises** :

- edu_ind_age_schooling
- edu_disrupted_attack_d
- edu_disrupted_hazards_d
- edu_disrupted_displaced_d
- edu_disrupted_teacher_d
- id_col_main (default: uuid)
- id_col_loop (default: uuid)

``` r

main_edu <- main_edu |>
  add_loop_edu_disrupted_d_to_main(
    loop = edu_ind, id_col_main = id_col_main, id_col_loop = id_col_loop
  )
```

### Composite sectoriel Éducation

Enfin, nous pouvons calculer le composite sectoriel Éducation à l’aide
des dénombrements au niveau du ménage générés ci-dessus.
[`add_comp_edu()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_edu.md)
calcule deux scores de composante fondés sur les deux dimensions du
cadre : un score d’éducation perturbée et un score d’assiduité et
d’obstacles. Le composite Éducation global est le maximum de ces deux
scores de composante.

Le score d’éducation perturbée va de 1 à 4. Un ménage sans enfant d’âge
scolaire reçoit un score de 1 ; une perturbation due à une attaque donne
un score de 4 ; une perturbation due à des aléas ou à un déplacement
donne 3 ; et l’absence d’enseignant donne 2.

Le score d’assiduité et d’obstacles est de 1 lorsque tous les enfants
d’âge scolaire ont accès, de 3 lorsqu’au moins un enfant d’âge scolaire
n’a pas accès, et de 4 lorsqu’au moins un enfant n’a pas accès et est
confronté à un obstacle de protection.

**Points clés** : Les sept variables requises doivent être numériques.
Le comp_edu_score global est calculé comme le maximum des scores
d’éducation perturbée et d’assiduité/obstacles. La fonction génère
ensuite comp_edu_in_need et comp_edu_in_severe_need à l’aide des seuils
de besoin standard de l’MSNI. Ces variables individuelles, puis au
niveau du ménage, doivent donc toutes être générées avant d’exécuter
[`add_comp_edu()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_edu.md).

**Variables requises** :

- edu_schooling_age_n
- edu_no_access_n
- edu_barrier_protection_n
- edu_disrupted_attack_n
- edu_disrupted_hazards_n
- edu_disrupted_displaced_n
- edu_disrupted_teacher_n

``` r

main_edu <- main_edu |>
  add_comp_edu()
```

## MSNI

Une fois tous les composites sectoriels calculés, nous pouvons générer
l’indice multisectoriel des besoins (MSNI) global à l’aide de
[`add_msni()`](https://impact-initiatives-hppu.github.io/humind/reference/add_msni.md).
La fonction combine les scores des composites sectoriels et calcule le
score de sévérité MSNI global ainsi que les indicateurs de besoin
associés. Le jeu de données msni_output obtenu peut ensuite être utilisé
pour les analyses et rapports ultérieurs.

**Points clés** : Les six scores de composite sectoriel sont utilisés
pour calculer le msni_score global, qui est le score composite sectoriel
maximal. Les scores de composite sectoriel sont censés aller de 1 à 5.
Les variables correspondantes « \_in_need » et « \_in_severe_need » sont
utilisées pour calculer le nombre et le profil des besoins sectoriels.

Le secteur Santé est inclus dans le score MSNI global et dans le calcul
du nombre et du profil des besoins sectoriels, mais
comp_health_in_severe_need n’est pas une entrée de la fonction
[`add_msni()`](https://impact-initiatives-hppu.github.io/humind/reference/add_msni.md)
actuelle, car la sévérité maximale pour la Santé est de 3. Par
conséquent, la Santé n’est pas incluse dans sector_in_severe_need_n ni
dans sector_severe_needs_profile dans l’implémentation actuelle.

La fonction peut prendre en charge des variables de composite sectoriel
manquantes : si certains scores ou indicateurs sectoriels sont absents,
elle émet un avertissement et calcule les sorties pertinentes à l’aide
des secteurs disponibles. Veillez à le signaler dans toute sortie, car
les dimensions et secteurs manquants entraîneront une sous-estimation
des besoins, en raison de l’approche du maximum utilisée dans le calcul
du MSNI global.

La fonction génère les sept principales colonnes de sortie suivantes qui
caractérisent le profil de besoins de chaque ménage :

- msni_score.
- msni_in_need.
- msni_in_severe_need.
- sector_in_need_n.
- sector_in_severe_need_n.
- sector_needs_profile.
- sector_severe_needs_profile.

**Variables requises** :

- comp_edu_score
- comp_foodsec_score
- comp_health_score
- comp_prot_score
- comp_snfi_score
- comp_wash_score
- comp_foodsec_in_need
- comp_snfi_in_need
- comp_wash_in_need
- comp_prot_in_need
- comp_health_in_need
- comp_edu_in_need
- comp_foodsec_in_severe_need
- comp_snfi_in_severe_need
- comp_wash_in_severe_need
- comp_prot_in_severe_need
- comp_edu_in_severe_need

``` r

msni_output <- add_msni(main_edu)
msni_output |> head()
#>      _uuid      start fsl_fcs_cereal fsl_fcs_legumes fsl_fcs_veg fsl_fcs_fruit
#> 1 hh_00001 2026-06-01             NA              NA          NA            NA
#> 2 hh_00002 2026-06-01              5               3           2             6
#> 3 hh_00003 2026-06-01              3               3           3             3
#> 4 hh_00004 2026-06-01              5               3           0             5
#> 5 hh_00005 2026-06-01              5               7           5             4
#> 6 hh_00006 2026-06-01              5               3           0             0
#>   fsl_fcs_meat fsl_fcs_dairy fsl_fcs_sugar fsl_fcs_oil fsl_hhs_nofoodhh
#> 1           NA            NA            NA          NA             <NA>
#> 2            5             4             3           3              yes
#> 3            3             3             3           3               no
#> 4            5             7             7           5              yes
#> 5            7             7             7           7               no
#> 6            5             7             7           5              yes
#>   fsl_hhs_nofoodhh_freq fsl_hhs_sleephungry fsl_hhs_sleephungry_freq
#> 1                  <NA>                <NA>                     <NA>
#> 2             sometimes                 yes                sometimes
#> 3                  <NA>                  no                     <NA>
#> 4                rarely                 yes                sometimes
#> 5                  <NA>                  no                     <NA>
#> 6                rarely                 yes                sometimes
#>   fsl_hhs_alldaynight fsl_hhs_alldaynight_freq fsl_rcsi_lessquality
#> 1                <NA>                     <NA>                   NA
#> 2                 yes                   rarely                    2
#> 3                  no                     <NA>                    3
#> 4                  no                     <NA>                    3
#> 5                  no                     <NA>                    0
#> 6                  no                     <NA>                    3
#>   fsl_rcsi_borrow fsl_rcsi_mealsize fsl_rcsi_mealadult fsl_rcsi_mealnb
#> 1              NA                NA                 NA              NA
#> 2               5                 2                  1               1
#> 3               3                 3                  3               3
#> 4               2                 1                  0               0
#> 5               0                 0                  0               0
#> 6               2                 1                  0               0
#>   fsl_lcsi_stress1_host fsl_lcsi_stress1_camp fsl_lcsi_stress2_host
#> 1                  <NA>                  <NA>                  <NA>
#> 2                  <NA>          no_exhausted                  <NA>
#> 3                   yes                  <NA>                   yes
#> 4          no_exhausted                  <NA>          no_exhausted
#> 5          no_exhausted                  <NA>          no_exhausted
#> 6          no_exhausted                  <NA>          no_exhausted
#>   fsl_lcsi_stress2_camp fsl_lcsi_stress3 fsl_lcsi_stress4 fsl_lcsi_crisis1
#> 1                  <NA>             <NA>             <NA>             <NA>
#> 2                   yes   no_had_no_need   no_had_no_need   no_had_no_need
#> 3                  <NA>   no_had_no_need     no_exhausted     no_exhausted
#> 4                  <NA>              yes     no_exhausted     no_exhausted
#> 5                  <NA>     no_exhausted   no_had_no_need     no_exhausted
#> 6                  <NA>              yes     no_exhausted   no_had_no_need
#>   fsl_lcsi_crisis2 fsl_lcsi_crisis3 fsl_lcsi_emergency1
#> 1             <NA>             <NA>                <NA>
#> 2   no_had_no_need   no_had_no_need                 yes
#> 3     no_exhausted     no_exhausted        no_exhausted
#> 4     no_exhausted              yes      not_applicable
#> 5   no_had_no_need   no_had_no_need      no_had_no_need
#> 6     no_exhausted              yes                 yes
#>   fsl_lcsi_emergency2_host fsl_lcsi_emergency2_camp fsl_lcsi_emergency3_host
#> 1                     <NA>                     <NA>                     <NA>
#> 2                     <NA>           no_had_no_need                     <NA>
#> 3             no_exhausted                     <NA>             no_exhausted
#> 4             no_exhausted                     <NA>           no_had_no_need
#> 5           no_had_no_need                     <NA>           no_had_no_need
#> 6           not_applicable                     <NA>           no_had_no_need
#>   fsl_lcsi_emergency3_camp wash_hwise_drink wash_hwise_hands wash_hwise_plans
#> 1                     <NA>             <NA>             <NA>             <NA>
#> 2           no_had_no_need        sometimes        sometimes           rarely
#> 3                     <NA>        sometimes        sometimes        sometimes
#> 4                     <NA>           rarely        sometimes        sometimes
#> 5                     <NA>            never            never            never
#> 6                     <NA>            often        sometimes        sometimes
#>   wash_hwise_worry hwise4_score comp_wash_score_water_quantity
#> 1             <NA>           NA                             NA
#> 2            often            8                              3
#> 3        sometimes            8                              3
#> 4        sometimes            7                              3
#> 5            never            0                              1
#> 6        sometimes            9                              4
#>   wash_drinking_water_source wash_drinking_water_time_yn
#> 1                       <NA>                        <NA>
#> 2             piped_compound                        <NA>
#> 3                        tap              number_minutes
#> 4             piped_dwelling                        <NA>
#> 5             piped_compound                        <NA>
#> 6             piped_dwelling                        <NA>
#>   wash_drinking_water_time_int wash_drinking_water_time_sl
#> 1                           NA                        <NA>
#> 2                           NA                        <NA>
#> 3                            3                        <NA>
#> 4                           NA                        <NA>
#> 5                           NA                        <NA>
#> 6                           NA                        <NA>
#>   wash_sanitation_facility wash_sanitation_facility_sharing_yn
#> 1                     <NA>                                <NA>
#> 2        flush_pit_latrine                                 yes
#> 3        flush_pit_latrine                                 dnk
#> 4                   bucket                                  no
#> 5        flush_septic_tank                                  no
#> 6         flush_open_drain                                 yes
#>   wash_sanitation_facility_sharing_n hh_size     setting
#> 1                                 NA      NA        <NA>
#> 2                                 12       6 camp_formal
#> 3                                 NA       3       rural
#> 4                                 NA       4       rural
#> 5                                 NA       7       rural
#> 6                                  2       4       rural
#>   wash_handwashing_facility wash_handwashing_facility_observed_water_yn
#> 1                      <NA>                                        <NA>
#> 2          available_mobile                         water_not_available
#> 3          available_mobile                         water_not_available
#> 4                      none                                        <NA>
#> 5   available_fixed_in_plot                             water_available
#> 6             no_permission                                        <NA>
#>   wash_handwashing_facility_reported
#> 1                               <NA>
#> 2                               <NA>
#> 3                               <NA>
#> 4                               <NA>
#> 5                               <NA>
#> 6                         fixed_yard
#>   wash_handwashing_facility_water_reported_yn wash_soap_observed_yn
#> 1                                        <NA>                  <NA>
#> 2                                        <NA>        soap_available
#> 3                                        <NA>    soap_not_available
#> 4                                        <NA>                  <NA>
#> 5                                        <NA>        soap_available
#> 6                                          no                  <NA>
#>   wash_soap_observed_type wash_soap_reported_yn wash_soap_reported_type
#> 1                    <NA>                  <NA>                    <NA>
#> 2               detergent                  <NA>                    <NA>
#> 3                    <NA>                  <NA>                    <NA>
#> 4                    <NA>                  <NA>                    <NA>
#> 5               detergent                  <NA>                    <NA>
#> 6                    <NA>                    no                    <NA>
#>    snfi_shelter_type snfi_shelter_type_individual      snfi_shelter_issue
#> 1               <NA>                         <NA>                    <NA>
#> 2 individual_shelter                    apartment lack_privacy lack_space
#> 3 individual_shelter          unfinished_building            lack_privacy
#> 4 individual_shelter                        house              lack_space
#> 5 individual_shelter                    apartment                    none
#> 6 individual_shelter                    makeshift  lack_space temperature
#>   snfi_shelter_issue/none snfi_shelter_issue/lack_privacy
#> 1                      NA                              NA
#> 2                       0                               1
#> 3                       0                               1
#> 4                       0                               0
#> 5                       1                               0
#> 6                       0                               0
#>   snfi_shelter_issue/lack_space snfi_shelter_issue/temperature
#> 1                            NA                             NA
#> 2                             1                              0
#> 3                             0                              0
#> 4                             1                              0
#> 5                             0                              0
#> 6                             1                              1
#>   snfi_shelter_issue/ventilation snfi_shelter_issue/vectors
#> 1                             NA                         NA
#> 2                              0                          0
#> 3                              0                          0
#> 4                              0                          0
#> 5                              0                          0
#> 6                              0                          0
#>   snfi_shelter_issue/no_natural_light snfi_shelter_issue/leak
#> 1                                  NA                      NA
#> 2                                   0                       0
#> 3                                   0                       0
#> 4                                   0                       0
#> 5                                   0                       0
#> 6                                   0                       0
#>   snfi_shelter_issue/lock snfi_shelter_issue/lack_lighting
#> 1                      NA                               NA
#> 2                       0                                0
#> 3                       0                                0
#> 4                       0                                0
#> 5                       0                                0
#> 6                       0                                0
#>   snfi_shelter_issue/difficulty_move snfi_shelter_issue/lack_space_laundry
#> 1                                 NA                                    NA
#> 2                                  0                                     0
#> 3                                  0                                     0
#> 4                                  0                                     0
#> 5                                  0                                     0
#> 6                                  0                                     0
#>   snfi_shelter_issue/other snfi_shelter_issue/dnk snfi_shelter_issue/pnta
#> 1                       NA                     NA                      NA
#> 2                        0                      0                       0
#> 3                        0                      0                       0
#> 4                        0                      0                       0
#> 5                        0                      0                       0
#> 6                        0                      0                       0
#>   snfi_shelter_damage/none snfi_shelter_damage/minor_roof
#> 1                       NA                             NA
#> 2                        0                              1
#> 3                        0                              0
#> 4                        1                              0
#> 5                        1                              0
#> 6                        0                              1
#>   snfi_shelter_damage/major_roof snfi_shelter_damage/windows_doors
#> 1                             NA                                NA
#> 2                              1                                 0
#> 3                              1                                 0
#> 4                              0                                 0
#> 5                              0                                 0
#> 6                              1                                 0
#>   snfi_shelter_damage/floors snfi_shelter_damage/walls
#> 1                         NA                        NA
#> 2                          0                         0
#> 3                          0                         0
#> 4                          0                         0
#> 5                          0                         0
#> 6                          1                         0
#>   snfi_shelter_damage/total_collapse snfi_shelter_damage/other
#> 1                                 NA                        NA
#> 2                                  0                         0
#> 3                                  0                         0
#> 4                                  0                         0
#> 5                                  0                         0
#> 6                                  0                         0
#>   snfi_shelter_damage/dnk snfi_shelter_damage/pnta snfi_fds_cooking
#> 1                      NA                       NA             <NA>
#> 2                       0                        0              yes
#> 3                       0                        0       no_no_need
#> 4                       0                        0               no
#> 5                       0                        0               no
#> 6                       0                        0               no
#>   snfi_fds_sleeping snfi_fds_storing  energy_lighting_source hlp_occupancy
#> 1              <NA>             <NA>                    <NA>          <NA>
#> 2               yes              yes rechargeable_flashlight   hosted_free
#> 3         undefined               no rechargeable_flashlight        rented
#> 4                no               no             electricity     ownership
#> 5               yes              yes             electricity     ownership
#> 6                no               no                    none     ownership
#>   hlp_risk_eviction prot_needs_3_movement/no_changes_feel_unsafe
#> 1              <NA>                                           NA
#> 2                no                                            0
#> 3                no                                            0
#> 4                no                                            1
#> 5                no                                            0
#> 6               yes                                            0
#>   prot_needs_3_movement/no_safety_concerns
#> 1                                       NA
#> 2                                        0
#> 3                                        0
#> 4                                        0
#> 5                                        1
#> 6                                        1
#>   prot_needs_3_movement/women_girls_avoid_places
#> 1                                             NA
#> 2                                              1
#> 3                                              1
#> 4                                              0
#> 5                                              0
#> 6                                              0
#>   prot_needs_3_movement/men_avoid_places
#> 1                                     NA
#> 2                                      0
#> 3                                      0
#> 4                                      0
#> 5                                      0
#> 6                                      0
#>   prot_needs_3_movement/boys_avoid_places
#> 1                                      NA
#> 2                                       1
#> 3                                       0
#> 4                                       0
#> 5                                       0
#> 6                                       0
#>   prot_needs_3_movement/women_girls_avoid_night
#> 1                                            NA
#> 2                                             1
#> 3                                             0
#> 4                                             0
#> 5                                             0
#> 6                                             0
#>   prot_needs_3_movement/men_avoid_night prot_needs_3_movement/boys_avoid_night
#> 1                                    NA                                     NA
#> 2                                     0                                      1
#> 3                                     0                                      0
#> 4                                     0                                      0
#> 5                                     0                                      0
#> 6                                     0                                      0
#>   prot_needs_3_movement/girls_boys_avoid_school
#> 1                                            NA
#> 2                                             0
#> 3                                             0
#> 4                                             0
#> 5                                             0
#> 6                                             0
#>   prot_needs_3_movement/different_routes prot_needs_3_movement/avoid_markets
#> 1                                     NA                                  NA
#> 2                                      1                                   1
#> 3                                      0                                   0
#> 4                                      0                                   0
#> 5                                      0                                   0
#> 6                                      0                                   0
#>   prot_needs_3_movement/avoid_public_offices prot_needs_3_movement/avoid_fields
#> 1                                         NA                                 NA
#> 2                                          1                                  0
#> 3                                          0                                  0
#> 4                                          0                                  0
#> 5                                          0                                  0
#> 6                                          0                                  0
#>   prot_needs_3_movement/women_girls_boys_avoid_firewood
#> 1                                                    NA
#> 2                                                     1
#> 3                                                     0
#> 4                                                     0
#> 5                                                     0
#> 6                                                     0
#>   prot_needs_3_movement/women_girls_boys_avoid_places
#> 1                                                  NA
#> 2                                                   0
#> 3                                                   0
#> 4                                                   0
#> 5                                                   0
#> 6                                                   0
#>   prot_needs_3_movement/other_safety_measures prot_needs_3_movement/dnk
#> 1                                          NA                        NA
#> 2                                           0                         0
#> 3                                           0                         0
#> 4                                           0                         0
#> 5                                           0                         0
#> 6                                           0                         0
#>   prot_needs_3_movement/pnta comp_prot_score_prot_needs_3
#> 1                         NA                            0
#> 2                          0                           15
#> 3                          0                            2
#> 4                          0                            1
#> 5                          0                            0
#> 6                          0                            0
#>   comp_prot_score_movement prot_needs_2_activities/yes_work
#> 1                        1                               NA
#> 2                        4                                1
#> 3                        3                                0
#> 4                        2                                1
#> 5                        1                                0
#> 6                        1                                0
#>   prot_needs_2_activities/yes_livelihood prot_needs_2_activities/yes_safety
#> 1                                     NA                                 NA
#> 2                                      1                                  0
#> 3                                      1                                  0
#> 4                                      1                                  1
#> 5                                      0                                  0
#> 6                                      0                                  0
#>   prot_needs_2_activities/yes_farm prot_needs_2_activities/yes_water
#> 1                               NA                                NA
#> 2                                1                                 0
#> 3                                0                                 0
#> 4                                0                                 0
#> 5                                0                                 0
#> 6                                1                                 0
#>   prot_needs_2_activities/yes_other_activities
#> 1                                           NA
#> 2                                            0
#> 3                                            0
#> 4                                            0
#> 5                                            0
#> 6                                            0
#>   prot_needs_2_activities/yes_free_choices prot_needs_2_activities/no
#> 1                                       NA                         NA
#> 2                                        0                          0
#> 3                                        0                          0
#> 4                                        0                          0
#> 5                                        0                          1
#> 6                                        0                          0
#>   prot_needs_2_activities/dnk prot_needs_2_activities/pnta
#> 1                          NA                           NA
#> 2                           0                            0
#> 3                           0                            0
#> 4                           0                            0
#> 5                           0                            0
#> 6                           0                            0
#>   prot_needs_2_social/yes_visiting_family
#> 1                                      NA
#> 2                                       1
#> 3                                       0
#> 4                                       1
#> 5                                       0
#> 6                                       0
#>   prot_needs_2_social/yes_visiting_friends
#> 1                                       NA
#> 2                                        0
#> 3                                        0
#> 4                                        0
#> 5                                        0
#> 6                                        0
#>   prot_needs_2_social/yes_community_events
#> 1                                       NA
#> 2                                        1
#> 3                                        1
#> 4                                        1
#> 5                                        0
#> 6                                        0
#>   prot_needs_2_social/yes_joining_groups prot_needs_2_social/yes_other_social
#> 1                                     NA                                   NA
#> 2                                      0                                    0
#> 3                                      0                                    0
#> 4                                      0                                    0
#> 5                                      0                                    0
#> 6                                      0                                    0
#>   prot_needs_2_social/yes_child_recreation
#> 1                                       NA
#> 2                                        0
#> 3                                        0
#> 4                                        0
#> 5                                        0
#> 6                                        0
#>   prot_needs_2_social/yes_decision_making prot_needs_2_social/no
#> 1                                      NA                     NA
#> 2                                       0                      0
#> 3                                       0                      0
#> 4                                       0                      0
#> 5                                       0                      1
#> 6                                       0                      1
#>   prot_needs_2_social/dnk prot_needs_2_social/pnta
#> 1                      NA                       NA
#> 2                       0                        0
#> 3                       0                        0
#> 4                       0                        0
#> 5                       0                        0
#> 6                       0                        0
#>   comp_prot_score_prot_needs_2_activities comp_prot_score_prot_needs_2_social
#> 1                                       0                                   0
#> 2                                       3                                   2
#> 3                                       1                                   1
#> 4                                       3                                   2
#> 5                                       0                                   0
#> 6                                       1                                   0
#>   comp_prot_score_practices prot_needs_1_services/yes_healthcare
#> 1                         1                                   NA
#> 2                         4                                    1
#> 3                         3                                    0
#> 4                         4                                    1
#> 5                         1                                    0
#> 6                         2                                    0
#>   prot_needs_1_services/yes_schools
#> 1                                NA
#> 2                                 1
#> 3                                 1
#> 4                                 0
#> 5                                 0
#> 6                                 0
#>   prot_needs_1_services/yes_therapeutic_services
#> 1                                             NA
#> 2                                              1
#> 3                                              0
#> 4                                              0
#> 5                                              0
#> 6                                              0
#>   prot_needs_1_services/yes_edu_facilities
#> 1                                       NA
#> 2                                        1
#> 3                                        0
#> 4                                        0
#> 5                                        0
#> 6                                        0
#>   prot_needs_1_services/yes_social_services
#> 1                                        NA
#> 2                                         1
#> 3                                         0
#> 4                                         0
#> 5                                         0
#> 6                                         0
#>   prot_needs_1_services/yes_gov_services
#> 1                                     NA
#> 2                                      1
#> 3                                      0
#> 4                                      0
#> 5                                      0
#> 6                                      1
#>   prot_needs_1_services/yes_other_services prot_needs_1_services/none
#> 1                                       NA                         NA
#> 2                                        1                          0
#> 3                                        0                          0
#> 4                                        0                          0
#> 5                                        0                          1
#> 6                                        0                          0
#>   prot_needs_1_services/dnk prot_needs_1_services/pnta
#> 1                        NA                         NA
#> 2                         0                          0
#> 3                         0                          0
#> 4                         0                          0
#> 5                         0                          0
#> 6                         0                          0
#>   prot_needs_1_justice/yes_identity_documents
#> 1                                          NA
#> 2                                           1
#> 3                                           0
#> 4                                           1
#> 5                                           0
#> 6                                           0
#>   prot_needs_1_justice/yes_counselling_legal
#> 1                                         NA
#> 2                                          0
#> 3                                          1
#> 4                                          0
#> 5                                          0
#> 6                                          0
#>   prot_needs_1_justice/yes_property_docs prot_needs_1_justice/yes_gov_services
#> 1                                     NA                                    NA
#> 2                                      1                                     0
#> 3                                      0                                     0
#> 4                                      0                                     1
#> 5                                      0                                     0
#> 6                                      0                                     0
#>   prot_needs_1_justice/yes_birth_certificates
#> 1                                          NA
#> 2                                           1
#> 3                                           0
#> 4                                           0
#> 5                                           0
#> 6                                           0
#>   prot_needs_1_justice/yes_other_services prot_needs_1_justice/no
#> 1                                      NA                      NA
#> 2                                       1                       0
#> 3                                       0                       0
#> 4                                       0                       0
#> 5                                       0                       1
#> 6                                       0                       0
#>   prot_needs_1_justice/dnk prot_needs_1_justice/pnta
#> 1                       NA                        NA
#> 2                        0                         0
#> 3                        0                         0
#> 4                        0                         0
#> 5                        0                         0
#> 6                        0                         0
#>   comp_prot_score_prot_needs_1_services comp_prot_score_prot_needs_1_justice
#> 1                                     0                                    0
#> 2                                     9                                    4
#> 3                                     2                                    1
#> 4                                     2                                    3
#> 5                                     0                                    0
#> 6                                     1                                    0
#>   comp_prot_score_rights  admin1 fsl_lcsi_stress1 fsl_lcsi_stress2
#> 1                      1 zone_02             <NA>             <NA>
#> 2                      4 zone_05     no_exhausted              yes
#> 3                      3 zone_01              yes              yes
#> 4                      4 zone_02     no_exhausted     no_exhausted
#> 5                      1 zone_02     no_exhausted     no_exhausted
#> 6                      2 zone_02     no_exhausted     no_exhausted
#>   fsl_lcsi_emergency2 fsl_lcsi_emergency3 fsl_lcsi_stress_yes
#> 1                <NA>                <NA>                <NA>
#> 2      no_had_no_need      no_had_no_need                   1
#> 3        no_exhausted        no_exhausted                   1
#> 4        no_exhausted      no_had_no_need                   1
#> 5      no_had_no_need      no_had_no_need                   0
#> 6      not_applicable      no_had_no_need                   1
#>   fsl_lcsi_stress_exhaust fsl_lcsi_stress fsl_lcsi_crisis_yes
#> 1                    <NA>            <NA>                <NA>
#> 2                       1               1                   0
#> 3                       1               1                   0
#> 4                       1               1                   1
#> 5                       1               1                   0
#> 6                       1               1                   1
#>   fsl_lcsi_crisis_exhaust fsl_lcsi_crisis fsl_lcsi_emergency_yes
#> 1                    <NA>            <NA>                   <NA>
#> 2                       0               0                      1
#> 3                       1               1                      0
#> 4                       1               1                      0
#> 5                       1               1                      0
#> 6                       1               1                      1
#>   fsl_lcsi_emergency_exhaust fsl_lcsi_emergency fsl_lcsi_cat_yes
#> 1                       <NA>               <NA>             <NA>
#> 2                          0                  1        Emergency
#> 3                          1                  1           Stress
#> 4                          1                  1           Crisis
#> 5                          0                  0             None
#> 6                          0                  1        Emergency
#>   fsl_lcsi_cat_exhaust fsl_lcsi_cat fcs_weight_cereal1 fcs_weight_legume2
#> 1                 <NA>         <NA>                 NA                 NA
#> 2               Stress    Emergency                 10                  9
#> 3            Emergency    Emergency                  6                  9
#> 4            Emergency    Emergency                 10                  9
#> 5               Crisis       Crisis                 10                 21
#> 6               Crisis    Emergency                 10                  9
#>   fcs_weight_dairy3 fcs_weight_meat4 fcs_weight_veg5 fcs_weight_fruit6
#> 1                NA               NA              NA                NA
#> 2                16               20               2                 6
#> 3                12               12               3                 3
#> 4                28               20               0                 5
#> 5                28               28               5                 4
#> 6                28               20               0                 0
#>   fcs_weight_oil7 fcs_weight_sugar8 fsl_fcs_score fsl_fcs_cat
#> 1              NA                NA            NA        <NA>
#> 2             1.5               1.5            66  Acceptable
#> 3             1.5               1.5            48  Acceptable
#> 4             2.5               3.5            78  Acceptable
#> 5             3.5               3.5           103  Acceptable
#> 6             2.5               3.5            73  Acceptable
#>   fsl_hhs_nofoodhh_recoded fsl_hhs_nofoodhh_freq_recoded
#> 1                       NA                            NA
#> 2                        1                             1
#> 3                        0                             0
#> 4                        1                             1
#> 5                        0                             0
#> 6                        1                             1
#>   fsl_hhs_sleephungry_recoded fsl_hhs_sleephungry_freq_recoded
#> 1                          NA                               NA
#> 2                           1                                1
#> 3                           0                                0
#> 4                           1                                1
#> 5                           0                                0
#> 6                           1                                1
#>   fsl_hhs_alldaynight_recoded fsl_hhs_alldaynight_freq_recoded fsl_hhs_comp1
#> 1                          NA                               NA            NA
#> 2                           1                                1             1
#> 3                           0                                0             0
#> 4                           0                                0             1
#> 5                           0                                0             0
#> 6                           0                                0             1
#>   fsl_hhs_comp2 fsl_hhs_comp3 fsl_hhs_score fsl_hhs_cat_ipc  fsl_hhs_cat
#> 1            NA            NA            NA            <NA>         <NA>
#> 2             1             1             3        Moderate     Moderate
#> 3             0             0             0            None Little to No
#> 4             1             0             2        Moderate     Moderate
#> 5             0             0             0            None Little to No
#> 6             1             0             2        Moderate     Moderate
#>   rcsi_lessquality_weighted rcsi_borrow_weighted rcsi_mealsize_weighted
#> 1                        NA                   NA                     NA
#> 2                         2                   10                      2
#> 3                         3                    6                      3
#> 4                         3                    4                      1
#> 5                         0                    0                      0
#> 6                         3                    4                      1
#>   rcsi_mealadult_weighted rcsi_mealnb_weighted fsl_rcsi_score fsl_rcsi_cat
#> 1                      NA                   NA             NA         <NA>
#> 2                       3                    1             18       Medium
#> 3                       9                    3             24         High
#> 4                       0                    0              8       Medium
#> 5                       0                    0              0    No to Low
#> 6                       0                    0              8       Medium
#>   fsl_fc_cell fsl_fc_phase  fclcm_phase comp_foodsec_score comp_foodsec_in_need
#> 1          NA         <NA>         <NA>                 NA                   NA
#> 2          18   Phase 2 FC Phase 3 FCLC                  3                    1
#> 3          31   Phase 2 FC Phase 3 FCLC                  3                    1
#> 4          18   Phase 2 FC Phase 3 FCLC                  3                    1
#> 5           1   Phase 1 FC Phase 2 FCLC                  2                    0
#> 6          18   Phase 2 FC Phase 3 FCLC                  3                    1
#>   comp_foodsec_in_severe_need wash_drinking_water_source_cat
#> 1                          NA                           <NA>
#> 2                           0                       improved
#> 3                           0                       improved
#> 4                           0                       improved
#> 5                           0                       improved
#> 6                           0                       improved
#>   wash_drinking_water_time_cat wash_drinking_water_time_30min_cat
#> 1                         <NA>                               <NA>
#> 2                         <NA>                               <NA>
#> 3                 under_30_min                        under_30min
#> 4                     premises                           premises
#> 5                         <NA>                               <NA>
#> 6                     premises                           premises
#>   wash_drinking_water_quality_jmp_cat wash_sanitation_facility_cat
#> 1                                <NA>                         <NA>
#> 2                                <NA>                     improved
#> 3                               basic                     improved
#> 4                               basic                   unimproved
#> 5                                <NA>                     improved
#> 6                               basic                   unimproved
#>   wash_sharing_sanitation_facility_cat weight
#> 1                                 <NA>      1
#> 2                               shared      1
#> 3                            undefined      1
#> 4                           not_shared      1
#> 5                           not_shared      1
#> 6                               shared      1
#>   wash_sanitation_facility_sharing_n_calc
#> 1                                      NA
#> 2                               67.798964
#> 3                                      NA
#> 4                                      NA
#> 5                                      NA
#> 6                                9.618088
#>   wash_sharing_sanitation_facility_n_ind wash_sanitation_facility_jmp_cat
#> 1                                   <NA>                             <NA>
#> 2                           50_and_above                          limited
#> 3                                   <NA>                        undefined
#> 4                                   <NA>                       unimproved
#> 5                                   <NA>                            basic
#> 6                           19_and_below                       unimproved
#>   survey_modality wash_handwashing_facility_jmp_cat
#> 1       in_person                              <NA>
#> 2       in_person                           limited
#> 3       in_person                           limited
#> 4       in_person                       no_facility
#> 5       in_person                             basic
#> 6       in_person                           limited
#>   comp_wash_score_water_quality comp_wash_score_sanitation
#> 1                            NA                         NA
#> 2                            NA                          4
#> 3                             1                         NA
#> 4                             1                          2
#> 5                            NA                          1
#> 6                             1                          2
#>   comp_wash_score_hygiene comp_wash_score comp_wash_in_need
#> 1                      NA              NA                NA
#> 2                       2               4                 1
#> 3                       2               3                 1
#> 4                       2               3                 1
#> 5                       1               1                 0
#> 6                       2               4                 1
#>   comp_wash_in_severe_need snfi_shelter_type_cat snfi_shelter_issue_n
#> 1                       NA                  <NA>                    0
#> 2                        1              adequate                    2
#> 3                        0            inadequate                    1
#> 4                        0              adequate                    1
#> 5                        0              adequate                    0
#> 6                        1            inadequate                    2
#>   snfi_shelter_issue_cat snfi_shelter_damage_cat snfi_fds_cooking_d
#> 1                   none                    <NA>                 NA
#> 2                 1_to_3                    part                  0
#> 3                 1_to_3                    part                  0
#> 4                 1_to_3                    none                  1
#> 5                   none                    none                  1
#> 6                 1_to_3                    part                  1
#>   snfi_fds_sleeping_d snfi_fds_storing_d energy_lighting_source_d
#> 1                  NA                 NA                       NA
#> 2                   0                  0                        0
#> 3                  NA                  1                        0
#> 4                   1                  1                        0
#> 5                   0                  0                        0
#> 6                   1                  1                        1
#>   snfi_fds_cannot_n snfi_fds_cannot_cat hlp_occupancy_cat hlp_eviction_cat
#> 1                NA                <NA>              <NA>             <NA>
#> 2                 0                none       medium_risk         low_risk
#> 3                NA                <NA>       medium_risk         low_risk
#> 4                 3        2_to_3_tasks          low_risk         low_risk
#> 5                 1              1_task          low_risk         low_risk
#> 6                 4             4_tasks          low_risk        high_risk
#>   hlp_tenure_security comp_snfi_score_shelter_type_cat
#> 1                <NA>                               NA
#> 2         medium_risk                                1
#> 3         medium_risk                                3
#> 4            low_risk                                1
#> 5            low_risk                                1
#> 6           high_risk                                3
#>   comp_snfi_score_shelter_issue_cat comp_snfi_score_tenure_security_cat
#> 1                                 1                                  NA
#> 2                                 2                                   2
#> 3                                 2                                   2
#> 4                                 2                                   1
#> 5                                 1                                   1
#> 6                                 2                                   1
#>   comp_snfi_score_fds_cannot_cat comp_snfi_score_shelter_damage_cat
#> 1                             NA                                 NA
#> 2                              1                                  4
#> 3                             NA                                  4
#> 4                              3                                  1
#> 5                              2                                  1
#> 6                              4                                  4
#>   comp_snfi_score comp_snfi_in_need comp_snfi_in_severe_need comp_prot_score
#> 1               1                 0                        0               1
#> 2               4                 1                        1               4
#> 3               4                 1                        1               3
#> 4               3                 1                        0               4
#> 5               2                 0                        0               1
#> 6               4                 1                        1               2
#>   comp_prot_in_need comp_prot_in_severe_need health_ind_healthcare_needed_no_n
#> 1                 0                        0                                NA
#> 2                 1                        1                                 1
#> 3                 1                        0                                 2
#> 4                 1                        1                                 0
#> 5                 0                        0                                 5
#> 6                 0                        0                                 2
#>   health_ind_healthcare_needed_yes_unmet_n
#> 1                                       NA
#> 2                                        0
#> 3                                        0
#> 4                                        1
#> 5                                        0
#> 6                                        2
#>   health_ind_healthcare_needed_yes_met_n comp_health_score comp_health_in_need
#> 1                                     NA                NA                  NA
#> 2                                      4                 2                   0
#> 3                                      0                 1                   0
#> 4                                      3                 3                   1
#> 5                                      1                 2                   0
#> 6                                      0                 3                   1
#>   comp_health_in_severe_need edu_schooling_age_n edu_access_n edu_no_access_n
#> 1                         NA                   0           NA              NA
#> 2                          0                   2            2               0
#> 3                          0                   0           NA              NA
#> 4                          0                   0           NA              NA
#> 5                          0                   2            2               0
#> 6                          0                   1            1               0
#>   edu_barrier_protection_n edu_disrupted_hazards_n edu_disrupted_displaced_n
#> 1                       NA                      NA                        NA
#> 2                        0                       2                         1
#> 3                       NA                      NA                        NA
#> 4                       NA                      NA                        NA
#> 5                        0                       0                         0
#> 6                        0                       1                         1
#>   edu_disrupted_teacher_n edu_disrupted_attack_n comp_edu_score_disrupted
#> 1                      NA                     NA                        1
#> 2                       2                      0                        3
#> 3                      NA                     NA                        1
#> 4                      NA                     NA                        1
#> 5                       0                      0                        1
#> 6                       1                      0                        3
#>   comp_edu_score_attendance comp_edu_score comp_edu_in_need
#> 1                         1              1                0
#> 2                         1              3                1
#> 3                         1              1                0
#> 4                         1              1                0
#> 5                         1              1                0
#> 6                         1              3                1
#>   comp_edu_in_severe_need msni_score msni_in_need msni_in_severe_need
#> 1                       0          1            0                   0
#> 2                       0          4            1                   1
#> 3                       0          4            1                   1
#> 4                       0          4            1                   1
#> 5                       0          2            0                   0
#> 6                       0          4            1                   1
#>   sector_in_need_n sector_in_severe_need_n
#> 1               NA                      NA
#> 2                5                       3
#> 3                4                       1
#> 4                5                       1
#> 5               NA                      NA
#> 6                5                       2
#>                                   sector_needs_profile
#> 1                                                 <NA>
#> 2 Food security - SNFI - WASH - Protection - Education
#> 3             Food security - SNFI - WASH - Protection
#> 4    Food security - SNFI - WASH - Protection - Health
#> 5                                                 <NA>
#> 6     Food security - SNFI - WASH - Health - Education
#>   sector_severe_needs_profile
#> 1                        <NA>
#> 2    SNFI - WASH - Protection
#> 3                        SNFI
#> 4                  Protection
#> 5                        <NA>
#> 6                 SNFI - WASH
```
