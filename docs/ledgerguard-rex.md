# LEDGERGUARD — Journal de bord & retour d'expérience

> Construire un pipeline de qualité de données et de reporting réglementaire
> risque de crédit, sur 2,26 millions de prêts réels. Ce texte ne raconte pas
> le résultat — il raconte les décisions, les erreurs, et les corrections.
> C'est là que se trouve le vrai travail.

## Pourquoi ce projet

Le marché du Business Analyst en Île-de-France est écrasé par la banque, la
finance et l'assurance : monétique, réglementaire, risque de crédit, cash
management. Les annonces réclament toutes la même chose — savoir prendre un
besoin métier, modéliser des flux de données, contrôler leur qualité, et
produire un reporting fiable et traçable.

J'ai donc construit exactement ça, sur de la donnée réelle : le dataset ouvert
Lending Club (prêts 2007–2018, licence CC0). Le principe directeur, tenu de bout
en bout : **le déterminisme d'abord**. Le code contrôle, vérifie et calcule ;
rien n'est laissé au hasard, et une donnée non conforme est isolée plutôt que
corrigée en douce ou supprimée.

## Les décisions qui ont façonné le projet

**J'ai tué ma propre hypothèse de départ.** Le cadrage initial annonçait un
score de qualité passant de 72 % à 98,5 %. En profilant réellement la donnée,
j'ai découvert qu'elle était complète à ~99,99 % : le 72 % était une fiction.
Je l'ai supprimé. Le vrai récit est plus intéressant et plus senior : la
complétude naïve frôle les 100 %, mais des contrôles rigoureux de **validité,
de plausibilité et de conformité au référentiel** révèlent des enregistrements
toxiques qui corrompraient le reporting. Publier un chiffre gonflé aurait été
la première chose démontée en entretien.

**Une absence de clé est devenue un constat de gouvernance.** La colonne
identifiant du dataset est vide. Plutôt que de l'ignorer, j'ai généré une clé de
substitution et documenté le trou : l'identifiabilité est un principe explicite
de BCBS 239. Un défaut de donnée, correctement nommé, devient un livrable.

**Le typage sert de détecteur.** En convertissant le texte brut avec `try_cast`,
une conversion qui échoue produit un `NULL` au lieu de faire planter le pipeline.
L'échec de typage devient lui-même un signal d'anomalie — élégant et gratuit.

**Une seule source de vérité pour les règles.** Les règles de contrôle sont
définies une unique fois, dans des macros appelées à la fois par le modèle de
production et par le modèle d'évaluation. Impossible que ce qui tourne diverge de
ce qui est évalué. C'est la garantie que le test ne ment pas.

## Les erreurs et frictions — le journal honnête

Rien de ce qui suit n'était propre du premier coup.

- **Environnement Windows.** Les commandes bash `{a,b,c}` et `mkdir -p` ne passent
  pas sous PowerShell. Les opérateurs `<` `>` `|` cassent tout `python -c` en une
  ligne — j'ai fini par sortir chaque requête contenant des comparaisons dans des
  fichiers `.py` jetables. Détail idiot, une heure perdue si on ne le connaît pas.
- **Mots réservés.** `rows` comme alias de colonne fait planter le parseur DuckDB.
- **Dépréciation dbt 1.12.** Les arguments des tests génériques doivent désormais
  être imbriqués sous `arguments:` — un warning à traiter pour garder un repo sans bruit.
- **Le faux triomphe évité.** Un modèle d'évaluation s'est créé en 0,08 s. Trop
  rapide : j'ai vérifié qu'il n'était pas vide avant de calculer quoi que ce soit.
  Un F1 calculé sur une table vide est le pire des pièges.
- **Ma fausse piste du BOM.** Face à un seed CSV refusé par DuckDB, j'ai d'abord
  suspecté un BOM UTF-8 ajouté par Windows. J'ai réécrit le fichier proprement —
  et l'erreur a persisté. La vraie cause était ailleurs : le *partial parsing* de
  dbt gardait en cache l'ancien schéma du seed (4 colonnes) alors que le fichier
  en avait désormais 5. La correction : `--full-refresh --no-partial-parse`.
  Leçon retenue : dès qu'on change la structure d'un seed, forcer la relecture.

## Le moment clé : quand le dispositif s'est corrigé lui-même

C'est le passage dont je suis le plus fier, et il n'a rien à voir avec un chiffre parfait.

Mon harness d'évaluation — qui injecte des anomalies connues dans le pipeline réel
et mesure sa capacité de détection — a d'abord sorti un **F1 de 0,972** : 49
anomalies passées à travers. Mais le tableau détaillé affichait un rappel de 1,0
sur *chacune* des neuf règles. Mathématiquement impossible : si chaque règle
attrape ses 100 anomalies, le total ne peut pas en rater 49.

L'un des deux chiffres mentait. J'ai creusé. Les 49 ratés avaient tous une
étiquette nulle : c'étaient des lignes marquées « anomalie » qui n'avaient en
réalité jamais été corrompues, à cause d'un défaut dans mon découpage en groupes.
Le moteur de détection était sain — c'était la *comptabilité* qui était fausse.

J'ai corrigé l'injection, puis j'ai ajouté un garde-fou qui fait **échouer le
harness** si une anomalie n'a pas d'étiquette. Un dispositif d'évaluation capable
de produire un faux triomphe silencieux est dangereux ; désormais, il casse au
lieu de mentir. Résultat final : **F1 = 1,00, 900 anomalies détectées sur 900,
zéro faux positif sur 5 000 lignes réelles conformes** — et cette fois, les deux
tableaux concordent.

L'argument que je retiens : ce n'est pas « mes contrôles marchent », c'est
« j'ai un dispositif qui prouve quand ils ne marchent pas — et il l'a déjà fait ».

## Les limites que j'assume

Un projet honnête nomme ses simplifications avant qu'on les lui reproche.

- **Le biais de maturité.** Le millésime 2018 affiche un taux de défaut plus bas
  que 2016 — mais seulement 11 % de ses prêts sont arrivés à terme. Le chiffre est
  mécaniquement sous-estimé, pas rassurant. J'expose un taux de maturation à côté
  de chaque millésime pour rendre la lecture honnête.
- **Exposition à l'origine, pas encours résiduel.** Je somme le montant octroyé,
  pas le capital restant dû. C'est une exposition à l'origination assumée ; le vrai
  encours vivant nécessiterait une colonne supplémentaire du dataset brut.
- **Anomalies conçues, pas exhaustives.** Un F1 de 1,00 prouve que chaque règle
  attrape la corruption qu'elle vise — pas que mon jeu de règles couvre tous les
  cas du monde réel. Je parle de *couverture de détection*, jamais de qualité parfaite.

## Ce que ce projet démontre

Au-delà du code, il matérialise un mode de travail : profiler avant d'affirmer,
mesurer plutôt qu'estimer, isoler la donnée douteuse au lieu de la maquiller,
et construire des dispositifs qui se contrôlent eux-mêmes. C'est précisément ce
qu'un environnement bancaire régulé — BCBS 239, DAMA, reporting réglementaire —
attend d'un profil qui touche à la donnée.

Douze ans en environnement ferroviaire à forte exigence de sécurité m'ont appris
une chose que ce projet réapplique : dans un système critique, on ne fait pas
confiance à une mesure qu'on ne peut pas tracer, ni à un contrôle qu'on n'a pas
éprouvé.

## Chiffres clés

| Indicateur | Valeur |
|---|---|
| Prêts traités | 2 260 701 |
| Couverture de détection (F1) | 1,00 — precision 1,0, recall 1,0 |
| Faux positifs sur donnée propre | 0 / 5 000 |
| Enregistrements mis en quarantaine | 4 314 (0,19 %), dont 4 274 DTI aberrants |
| Taux de défaut par grade | 6,0 % (A) → 49,7 % (G), strictement croissant |

*Stack : SQL · DuckDB · dbt · Python · Power BI. Données : Lending Club (CC0).*
