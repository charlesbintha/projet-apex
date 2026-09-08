# Guide d'équipe APEXlang, Git et déploiement DEV–TEST–PROD

## 1. Objet du guide

Ce guide définit la méthode commune pour créer, modifier, valider, versionner, livrer et restaurer une application Oracle APEX 26.1 avec :

- APEXlang pour les sources de l'application ;
- SQLcl pour la validation et les scripts de base de données ;
- Git et GitHub pour l'historique et la collaboration ;
- trois environnements distincts : DEV, TEST et PROD ;
- des migrations SQL immuables pour le schéma Oracle.

La règle fondamentale est la suivante : **le même commit Git doit être promu de DEV vers TEST puis PROD**. On ne recopie pas manuellement des pages entre environnements et on ne maintient pas trois versions différentes du code.

Ce guide prévoit également un mode de repli lorsque certaines commandes SQLcl ne sont pas prises en charge par une connexion OREST.

> Tous les noms d'organisation, dépôt, application, workspace, schéma, table, URL et identifiants utilisés ci-dessous sont fictifs. Ils servent uniquement d'exemples et doivent être remplacés dans une mise en œuvre réelle.

## 2. Sources de vérité

| Élément | Source de vérité |
| --- | --- |
| Pages et composants APEX | Fichiers APEXlang dans `apex/` |
| Tables, vues, index, packages et triggers | Migrations versionnées dans `database/` |
| Version applicative | Commit Git et tag de livraison |
| Données métier | Base de données de chaque environnement |
| Configuration d'environnement | Profil de déploiement dédié, sans secret |
| Mot de passe, wallet et clé | Gestionnaire de secrets local ou plateforme, jamais Git |

Les demandes, commentaires et instances de workflow ne sont pas enregistrés dans Git. Git conserve les définitions de l'application et du schéma, pas les données d'exécution.

## 3. Environnements

Chaque environnement doit avoir son propre schéma, sa propre application APEX et ses propres secrets.

| Environnement | Usage | Application | Schéma | Déploiement autorisé depuis |
| --- | --- | ---: | --- | --- |
| DEV | Développement et intégration | `12010` (exemple) | `ATLAS_DEV` | Branche de fonctionnalité ou `main` |
| TEST | Recette fonctionnelle et technique | `12020` (exemple) | `ATLAS_TEST` | Tag candidat `vX.Y.Z-rc.N` |
| PROD | Utilisation réelle | `12030` (exemple) | `ATLAS_PROD` | Tag final `vX.Y.Z` uniquement |

Ces noms et IDs sont fictifs. Chaque équipe les remplace dans sa matrice d'environnement sans y placer de mot de passe.

## 4. Stratégie Git retenue

### 4.1 Une seule branche principale

La branche `main` contient toujours une version validée et potentiellement livrable.

Les environnements ne sont pas représentés par trois branches permanentes `dev`, `test` et `prod`. Cette approche provoquerait des différences difficiles à expliquer entre les branches. La promotion est réalisée avec des commits et des tags immuables.

### 4.2 Branches de travail

Les développeurs créent une branche courte depuis `main` :

```text
feature/numero-demande-description
fix/numero-demande-description
hotfix/numero-demande-description
backend/numero-demande-description
docs/description
```

Exemples :

```text
feature/atlas-142-filtre-priorite
fix/atlas-157-affectation-agent
hotfix/atlas-201-erreur-validation
backend/atlas-166-ajout-date-echeance
```

### 4.3 Destination des push

Un développeur pousse uniquement sa branche de travail :

```bash
git push -u origin feature/atlas-142-filtre-priorite
```

Il ne pousse pas directement sur `main`. La branche est intégrée par une Pull Request après validation et revue.

### 4.4 Tags de promotion

| Tag | Destination |
| --- | --- |
| `v1.2.0-dev.1` | Version identifiée en DEV, facultatif |
| `v1.2.0-rc.1` | Candidat déployé en TEST |
| `v1.2.0` | Version approuvée pour PROD |

Un tag désigne un commit exact. Le code ne doit pas être modifié entre TEST et PROD : seul le profil de déploiement change.

### 4.5 Organisation de l'équipe

L'équipe utilise une responsabilité exclusive pour le backend et des plages de pages pour le développement APEX.

| Rôle | Périmètre principal | Éléments réservés |
| --- | --- | --- |
| Développeur backend | Schéma, migrations, vues, packages, triggers, API et ORDS | `database/`, `ords/` et PL/SQL métier partagé |
| Développeur APEX A | Pages 1 à 100 | Fichiers `p00001` à `p00100` |
| Développeur APEX B | Pages 101 à 200 | Fichiers `p00101` à `p00200` |
| Développeur APEX C | Pages 201 à 300 | Fichiers `p00201` à `p00300` |
| Développeur APEX D | Pages 301 à 400 | Fichiers `p00301` à `p00400` |
| Intégrateur APEX | Revue et fusion, rôle pouvant tourner dans l'équipe | Page globale 0, connexion 9999, `application.apx`, composants partagés et profils |

L'équipe peut ajouter d'autres plages de cent pages selon le même principe. Une page existante conserve toujours le même propriétaire de plage.

Le développeur backend est le seul à modifier directement les objets sous `database/` et `ords/`. Les développeurs de pages expriment leurs besoins de colonne, vue, package ou API dans leur ticket et attendent la migration du backend avant de terminer leur page.

### 4.6 Règles pour les pages

Chaque développeur APEX :

1. crée les nouvelles pages uniquement dans sa plage ;
2. ne modifie pas une page appartenant à une autre plage sans accord explicite ;
3. ajoute dans la Pull Request la liste exacte des pages modifiées ;
4. copie dans sa branche uniquement les fichiers de ses pages depuis un export App Builder ;
5. ne remplace jamais tout le dossier `apex/pages/` avec son export personnel.

La page globale 0 et la page de connexion 9999 sont hors plage. Elles sont traitées comme des composants partagés et fusionnées par l'intégrateur.

### 4.7 Composants partagés

Les plages de pages réduisent fortement les conflits, mais elles ne protègent pas automatiquement :

- `application.apx` ;
- les listes et LOV partagées ;
- les autorisations et authentifications ;
- le CSS global ;
- les tâches et workflows ;
- les profils de déploiement.

Toute modification d'un composant partagé doit être annoncée dans le ticket et isolée dans une Pull Request dédiée lorsque possible. Une seule Pull Request modifiant le même composant partagé est fusionnée à la fois.

### 4.8 Copie APEX par développeur

La solution préférable est une Working Copy APEX ou une copie d'application par développeur. Le développeur travaille dans sa copie, exporte l'application, puis reporte uniquement les fichiers appartenant à sa plage dans sa branche Git.

Si toute l'équipe partage une seule application DEV, les développeurs doivent réserver leurs pages avant modification et ne jamais réimporter un export complet personnel sans intégration Git préalable.

### 4.9 Méthode de fusion proposée

Les Pull Requests sont fusionnées une par une avec **Squash and merge** : une fonctionnalité devient un seul commit facilement annulable.

Avant la fusion, le développeur synchronise sa branche sans réécrire l'historique partagé :

```bash
git fetch origin
git switch feature/atlas-142-filtre-priorite
git merge origin/main
scripts/validate.sh
git push
```

Ordre de fusion recommandé :

1. migration backend compatible avec l'ancienne application ;
2. composants partagés nécessaires ;
3. pages consommatrices, une Pull Request après l'autre ;
4. documentation et nettoyage non destructif.

Après chaque fusion, la Pull Request suivante récupère le nouveau `main`, résout les éventuels conflits et relance la validation complète. Une merge queue GitHub peut automatiser cette sérialisation ; sinon l'intégrateur APEX applique manuellement cet ordre.

Si deux fonctionnalités doivent modifier la même page ou le même composant partagé, elles ne sont pas développées en parallèle sans coordination. L'intégrateur désigne une branche principale ; la seconde branche attend la fusion de la première puis se resynchronise.

## 5. Protection du dépôt GitHub

La branche `main` doit être protégée avec les règles suivantes :

- interdiction des push directs ;
- interdiction des suppressions et des force push ;
- Pull Request obligatoire ;
- au moins une approbation ;
- validation APEXlang obligatoire ;
- résolution des conversations de revue obligatoire ;
- historique linéaire recommandé ;
- suppression automatique de la branche après fusion, si l'équipe le souhaite.

Les commandes suivantes ne doivent jamais être utilisées sur une branche partagée :

```bash
git reset --hard
git push --force
```

Pour annuler un changement partagé, utiliser `git revert`.

## 6. Préparer un poste de développement

### 6.1 Prérequis

Installer :

- Git ;
- Java 17 ou 21 ;
- SQLcl compatible avec APEX 26.1 ;
- un éditeur de texte ou VS Code ;
- les outils `zip`, `unzip` et `rsync` sur macOS/Linux.

### 6.2 Cloner le projet

Si le dépôt n'existe pas encore, créer d'abord un dépôt Git distant vide, puis initialiser le projet :

```bash
mkdir atlas-apex-demo
cd atlas-apex-demo
git init -b main
git remote add origin https://github.com/acme-example/atlas-apex-demo.git
mkdir -p apex database/migrations database/tests docs scripts
```

Ajouter ensuite la baseline du schéma, l'export APEXlang initial, le `.gitignore` et les scripts de validation avant de créer le premier commit.

Si le dépôt existe déjà, chaque développeur le clone :

```bash
cd "/chemin/vers/projets"
git clone https://github.com/acme-example/atlas-apex-demo.git
cd atlas-apex-demo
```

### 6.3 Configurer l'identité Git

```bash
git config --local user.name "Prénom Nom"
git config --local user.email "adresse@entreprise.com"
```

Vérifier :

```bash
git config user.name
git config user.email
git remote -v
git status --short --branch
```

### 6.4 Installer SQLcl localement

SQLcl peut être placé dans le dossier local `sqlcl/`. Ce dossier est exclu de Git.

Vérifier :

```bash
./sqlcl/bin/sql -version
```

## 7. Créer une branche de travail

Toujours commencer depuis un dépôt propre et à jour :

```bash
cd "/chemin/vers/atlas-apex-demo"
git switch main
git pull --ff-only origin main
git status --short --branch
git switch -c feature/atlas-142-filtre-priorite
```

Si `git pull --ff-only` refuse l'opération, ne pas forcer. Examiner d'abord :

```bash
git status
git log --oneline --decorate --graph --all -20
```

Conserver les modifications locales dans un commit de travail ou demander une revue avant de synchroniser.

## 8. Fonctionnement APEXlang

APEXlang représente l'application sous forme de fichiers texte lisibles et adaptés à Git :

```text
apex/
├── .apex/apexlang.json
├── application.apx
├── page-groups.apx
├── pages/
├── shared-components/
├── supporting-objects/
└── deployments/
```

Le fichier `.apex/apexlang.json` contient la version de métadonnées utilisée par le compilateur. Il ne doit jamais être modifié manuellement.

Une importation APEXlang porte sur l'application complète. L'import d'une seule page APEXlang n'est pas disponible dans APEX 26.1. Pour une page seule, utiliser un export SQL de page ou réimporter l'application complète validée.

Documentation Oracle :

- <https://docs.oracle.com/en/database/oracle/apex/26.1/apxdc/using-sqlcl-apexlang.html>
- <https://docs.oracle.com/en/database/oracle/apex/26.1/apxdc/using-app-builder-and-external-tools-together.html>

## 9. Modifier l'application APEX

### 9.1 Méthode A — modification dans App Builder

1. Ouvrir l'application DEV.
2. Réaliser la modification.
3. Tester immédiatement la page ou le workflow.
4. Exporter l'application complète au format APEXlang.
5. Conserver le ZIP brut dans `apex/apex-exports/raw/`.
6. Extraire et valider le ZIP avant de remplacer la baseline Git.

Préparer un répertoire temporaire :

```bash
cd "/chemin/vers/atlas-apex-demo"
repertoire_temporaire="$(mktemp -d)"
unzip "/chemin/vers/export-apexlang.zip" -d "$repertoire_temporaire"
scripts/validate.sh "$repertoire_temporaire"
```

Le résultat attendu est :

```text
Validation successful.
```

Un développeur de pages recopie uniquement les fichiers qu'il possède. Par exemple, le développeur de la plage 101–200 ayant modifié les pages 101 et 115 exécute :

```bash
cp "$repertoire_temporaire/pages/p00101-liste-clients.apx" apex/pages/
cp "$repertoire_temporaire/pages/p00115-detail-client.apx" apex/pages/
```

Les noms sont des exemples ; utiliser les noms exacts présents dans l'export.

Il vérifie ensuite que son diff ne contient aucune autre page :

```bash
git status --short apex/pages
git diff -- apex/pages
```

Seul l'intégrateur peut effectuer une resynchronisation complète avec `rsync --delete`, après avoir vérifié que toutes les branches utiles ont été fusionnées. Les composants partagés sont recopiés séparément et uniquement lorsqu'ils font partie de la Pull Request approuvée.

Ne pas recopier automatiquement :

- les credentials du workspace ;
- les clés OCI ;
- les paramètres GenAI propres à un environnement ;
- les mots de passe ;
- les profils `deployments/` non contrôlés.

### 9.2 Méthode B — modification directe des fichiers

Codex ou un développeur peut modifier directement :

```text
apex/pages/p00010-demandes.apx
apex/pages/p00020-detail-demande.apx
apex/shared-components/workflows/ATLAS-REQUEST-LIFECYCLE.apx
apex/shared-components/static-files/app.css
```

Après chaque groupe cohérent de modifications :

```bash
scripts/validate.sh
```

Une source APEXlang invalide ne doit jamais être poussée ni importée.

### 9.3 Éviter les modifications concurrentes

Avant d'exporter App Builder, vérifier que personne n'a modifié les mêmes composants dans Git. Si les versions divergent :

1. exporter la version App Builder dans un dossier temporaire ;
2. comparer avec la branche Git ;
3. fusionner les différences dans les fichiers APEXlang ;
4. valider ;
5. réimporter l'application unifiée.

Ne jamais écraser silencieusement le dossier `apex/` avec un export ancien.

## 10. Valider avant commit

### 10.1 Validation APEXlang hors connexion

La validation ne nécessite pas de connexion à la base :

```bash
./sqlcl/bin/sql /nolog -execute 'apex validate -input apex'
```

Le projet fournit la commande simplifiée :

```bash
scripts/validate.sh
```

### 10.2 Contrôles Git

```bash
git status
git diff --stat
git diff -- apex database scripts docs
git diff --check
```

Les espaces issus d'un export APEX peuvent produire des avertissements. Ils doivent être examinés, mais ne justifient pas de reformater massivement des fichiers générés.

### 10.3 Contrôle des secrets

Vérifier qu'aucun élément suivant n'est ajouté :

- mot de passe ;
- wallet ;
- clé privée ;
- token ;
- fichier `.env` ;
- credential APEX exporté ;
- archive contenant des données d'exécution.

## 11. Commit, push et Pull Request

Ajouter uniquement les fichiers concernés :

```bash
git add apex/pages/p00010-demandes.apx
git add apex/shared-components/lovs.apx
```

Pour une évolution plus large :

```bash
git add apex database docs
```

Éviter `git add .` si le répertoire contient des documents ou exports temporaires.

Examiner l'index :

```bash
git diff --cached --stat
git diff --cached
```

Créer un commit petit et explicite :

```bash
git commit -m "Ajouter le filtre de priorité à la page 10"
git push -u origin feature/atlas-142-filtre-priorite
```

Créer ensuite une Pull Request vers `main`. La Pull Request doit indiquer :

- le besoin fonctionnel ;
- les pages et objets modifiés ;
- la migration éventuelle ;
- les tests réalisés ;
- les impacts de sécurité ;
- le plan de retour arrière.

## 12. Versionner les changements de schéma

### 12.1 Installation initiale

Le script suivant est réservé à un schéma DEV vide :

```sql
@"/chemin/vers/atlas-apex-demo/database/install-first-time.sql"
```

Il ne doit pas être relancé sur un schéma déjà installé. Le script initial peut supprimer et recréer des objets ; ce comportement n'est pas une migration.

### 12.2 Migrations incrémentales

Après l'installation initiale, chaque évolution reçoit un nouveau fichier :

```text
database/migrations/
├── V001__baseline_atlas.sql
├── V002__ajout_date_echeance_demande.sql
├── V003__index_statut_priorite.sql
└── V004__evolution_package_workflow.sql
```

Une migration déjà exécutée dans un environnement ne doit jamais être modifiée. Une correction devient une nouvelle migration.

Mauvaise pratique : modifier `V002` après son passage en TEST.

Bonne pratique : ajouter `V005__correction_date_echeance.sql`.

### 12.3 Exemple d'évolution `ALTER TABLE`

```sql
whenever sqlerror exit failure rollback

alter table at_requests
    add due_at timestamp with time zone;

comment on column at_requests.due_at
    is 'Date et heure cible de résolution';

create index at_requests_due_at_ix
    on at_requests(due_at);

commit;
```

Ajouter une vérification séparée :

```sql
select column_name, data_type
from user_tab_columns
where table_name = 'AT_REQUESTS'
  and column_name = 'DUE_AT';
```

Attention : de nombreuses instructions DDL Oracle effectuent des commits implicites. Un simple `rollback` ne restaure pas toujours un `ALTER TABLE` ou un `DROP`.

### 12.4 Ordre de compatibilité

Utiliser une stratégie d'expansion puis contraction :

1. ajouter les nouveaux objets ou colonnes sans casser l'ancienne application ;
2. déployer la nouvelle application ;
3. vérifier son fonctionnement ;
4. supprimer les anciens objets dans une livraison ultérieure.

Éviter de renommer ou supprimer immédiatement une colonne encore utilisée par la version APEX précédente.

## 13. Déployer une migration SQL

### 13.1 Connexion OREST

Depuis le terminal macOS :

```bash
./sqlcl/bin/sql /nolog
```

Puis, dans l'invite `SQL>` :

```sql
connect -orest -verbose -user ATLAS_DEV -url "https://db.example.com/ords/atlas_dev"
show user
```

L'URL doit être une URL simple. Ne pas coller une syntaxe Markdown comme `[URL](URL)`.

### 13.2 Contrôler impérativement la cible

Avant toute migration :

```sql
show user
select sys_context('USERENV', 'CURRENT_SCHEMA') as current_schema from dual;
```

Si l'utilisateur ou le schéma ne correspond pas à l'environnement prévu, arrêter immédiatement.

### 13.3 Exécuter la migration

```sql
@"/chemin/vers/atlas-apex-demo/database/migrations/V002__ajout_date_echeance_demande.sql"
```

Puis exécuter les tests :

```sql
@"/chemin/vers/atlas-apex-demo/database/tests/00_verify_install.sql"
```

La même migration, avec le même hash Git, est exécutée successivement en DEV, TEST puis PROD.

## 14. Utiliser Liquibase lorsque la connexion le permet

SQLcl fournit les commandes Liquibase suivantes :

```sql
lb validate -changelog-file database/changelog/controller.xml
lb status -verbose -changelog-file database/changelog/controller.xml
lb update-sql -changelog-file database/changelog/controller.xml
lb update -changelog-file database/changelog/controller.xml
lb history -changelog-file database/changelog/controller.xml
```

Toujours exécuter `update-sql` et relire le SQL avant `update` en TEST et PROD.

Pour préparer un retour arrière :

```sql
lb rollback-sql -tag v1.2.0 -changelog-file database/changelog/controller.xml
```

Puis seulement après revue et autorisation :

```sql
lb rollback -tag v1.2.0 -changelog-file database/changelog/controller.xml
```

Documentation Oracle SQLcl Liquibase :

<https://docs.oracle.com/en/database/oracle/sql-developer-command-line/26.1/sqcug/liquibase.html>

### 14.1 Limitation OREST

Le fonctionnement complet de Liquibase doit être validé sur chaque plateforme utilisant une connexion OREST.

Si une commande `lb` échoue à cause d'une opération JDBC non prise en charge :

1. ne pas marquer manuellement le changeset comme exécuté ;
2. conserver la sortie d'erreur ;
3. exécuter le SQL versionné avec `@fichier.sql` si la migration a été approuvée ;
4. enregistrer la preuve d'exécution ;
5. prévoir wallet/Oracle Net pour l'automatisation future.

Ne jamais utiliser `lb drop-all` sur DEV partagé, TEST ou PROD.

## 15. Profils de déploiement APEX

Les sources APEXlang sont communes aux environnements. Les paramètres variables sont conservés dans des profils séparés :

```text
apex/deployments/
├── default.json            # DEV, application fictive 12010
├── new-application.json    # création d'une copie, sans ID
├── test.json               # TEST, application fictive 12020
└── prod.json               # PROD, application fictive 12030
```

Exemple fictif DEV :

```json
{
  "app": {
    "id": 12010,
    "name": "Portail Atlas DEV",
    "alias": "ATLAS-DEV",
    "databaseSession": {
      "parsingSchema": "ATLAS_DEV"
    }
  }
}
```

Chaque équipe remplace ces valeurs fictives par ses IDs, alias et schémas. Les profils ne contiennent jamais de mot de passe.

Pour créer une nouvelle application, le profil ne fixe pas d'ID. Pour redéployer sur une application existante, le profil contient son ID exact.

## 16. Construire un paquet depuis Git

### 16.1 Version courante

```bash
git switch main
git pull --ff-only origin main
scripts/package-apex.sh
```

Le paquet DEV d'exemple est généré ici :

```text
dist/atlas-apex-dev.zip
```

Le ZIP global téléchargé depuis GitHub n'est pas directement importable dans APEX. Il faut utiliser le ZIP produit par le script de packaging.

### 16.2 Commit ou tag précis sans changer la branche courante

```bash
cd "/chemin/vers/atlas-apex-demo"
version_release="v1.2.0-rc.1"
repertoire_release="$(mktemp -d)"
git archive "$version_release" | tar -x -C "$repertoire_release"
SQLCL_BIN="$PWD/sqlcl/bin/sql" "$repertoire_release/scripts/package-apex.sh"
```

Le paquet est créé dans :

```text
$repertoire_release/dist/
```

Cette méthode garantit que le ZIP provient uniquement du commit ou tag choisi, sans fichiers locaux non enregistrés.

### 16.3 Profil propre à TEST ou PROD

Dans le répertoire temporaire de release, remplacer uniquement le profil `default.json` par le profil de la cible avant de lancer le packaging :

```bash
cp "$repertoire_release/apex/deployments/test.json" \
   "$repertoire_release/apex/deployments/default.json"
```

Pour PROD :

```bash
cp "$repertoire_release/apex/deployments/prod.json" \
   "$repertoire_release/apex/deployments/default.json"
```

Cette opération est effectuée dans un répertoire temporaire. Elle ne modifie pas le commit Git. Après le packaging, renommer le fichier pour identifier la cible et la version :

```bash
mv "$repertoire_release/dist/atlas-apex-dev.zip" \
   "$repertoire_release/dist/atlas-apex-prod-v1.2.0.zip"
```

Pour construire une nouvelle copie avec un ID attribué par APEX, appliquer de la même manière le profil sans ID avant le packaging :

```bash
cp "$repertoire_release/apex/deployments/new-application.json" \
   "$repertoire_release/apex/deployments/default.json"
SQLCL_BIN="$PWD/sqlcl/bin/sql" "$repertoire_release/scripts/package-apex.sh"
```

## 17. Importer APEXlang

### 17.1 Connexion Oracle Net ou wallet

Avec une connexion Oracle classique compatible, SQLcl peut importer :

```sql
apex import -input "/chemin/vers/application.zip"
```

L'import valide d'abord l'APEXlang, puis compile et exécute le PL/SQL produit.

### 17.2 Connexion OREST avec fonctions JDBC limitées

Sur certaines plateformes OREST, les résultats suivants peuvent être observés :

| Commande | Résultat OREST |
| --- | --- |
| SQL et PL/SQL ordinaires | Fonctionnent |
| Scripts `@fichier.sql` | Fonctionnent |
| `apex validate` avec `/nolog` | Fonctionne |
| `apex export` | Échec `PreparedStatement.setNull ... not supported` |
| `apex import` | Échec `CallableStatement.getBigDecimal` / `NullPointerException` |

Dans cet environnement, utiliser App Builder pour exporter et importer APEXlang.

### 17.3 Import dans App Builder

1. sauvegarder l'application cible par un export ;
2. ouvrir App Builder dans le workspace cible ;
3. choisir **Importer** ;
4. téléverser le ZIP APEXlang construit depuis le tag ;
5. vérifier l'ID, le schéma d'analyse, le nom et l'alias ;
6. réutiliser l'ID importé pour redéployer sur l'application existante, si cette option est proposée ;
7. ne jamais supprimer manuellement l'application avant l'import ;
8. lancer les smoke tests.

L'import par-dessus une application existante est particulièrement important pour préserver les instances de workflow et de tâches. Une suppression manuelle de l'application supprime ces instances.

Documentation Oracle :

<https://docs.oracle.com/en/database/oracle/apex/26.1/apxdc/importing-vs-deleting-application.html>

## 18. Promotion DEV → TEST → PROD

### 18.1 DEV

1. déployer la branche ou le commit de la Pull Request dans DEV ;
2. exécuter les migrations DEV ;
3. importer l'APEXlang dans l'application DEV ;
4. exécuter les tests ;
5. fusionner la Pull Request dans `main`.

### 18.2 TEST

Créer un tag candidat depuis `main` :

```bash
git switch main
git pull --ff-only origin main
git tag -a v1.2.0-rc.1 -m "Candidat recette 1.2.0"
git push origin v1.2.0-rc.1
```

Construire l'artefact depuis ce tag, appliquer les migrations TEST, importer l'application TEST puis réaliser la recette.

Si la recette échoue, créer une nouvelle branche corrective et un nouveau tag `v1.2.0-rc.2`. Ne pas déplacer ni réécrire `rc.1`.

### 18.3 PROD

Après validation de TEST, créer le tag final sur le même commit :

```bash
git tag -a v1.2.0 v1.2.0-rc.2 -m "Version production 1.2.0"
git push origin v1.2.0
```

Déployer en PROD le paquet construit depuis `v1.2.0`, avec le profil PROD. Ne jamais déployer directement un répertoire de travail non commité.

## 19. Tests après chaque déploiement

Tester au minimum :

1. connexion et autorisations ;
2. navigation et menu ;
3. tableau de bord ;
4. liste des tickets ;
5. création et modification d'un ticket ;
6. redirection vers le détail ;
7. commentaire et historique ;
8. affectation ;
9. pages de tâches et workflows ;
10. validation et rejet de résolution ;
11. absence d'objets Oracle invalides ;
12. journaux APEX et erreurs JavaScript.

Conserver avec la livraison :

- le tag ;
- le hash complet du commit ;
- le hash SHA-256 du ZIP ;
- le résultat des migrations ;
- le résultat des smoke tests ;
- l'identité de l'approbateur.

## 20. Revenir à une ancienne version d'un fichier

Afficher l'historique :

```bash
git log --oneline -- apex/pages/p00020-detail-demande.apx
```

Examiner une ancienne version :

```bash
git show COMMIT:apex/pages/p00020-detail-demande.apx
```

Restaurer sans effacer l'historique :

```bash
git switch -c fix/restauration-page-20
git restore --source COMMIT -- apex/pages/p00020-detail-demande.apx
scripts/validate.sh
git add apex/pages/p00020-detail-demande.apx
git commit -m "Restaurer la page 20 depuis COMMIT"
git push -u origin fix/restauration-page-20
```

Créer ensuite une Pull Request. La restauration devient un nouveau commit traçable.

## 21. Annuler un commit

Pour annuler un commit déjà partagé :

```bash
git switch -c revert/sd-142
git revert IDENTIFIANT_COMMIT
scripts/validate.sh
git push -u origin revert/sd-142
```

Créer une Pull Request vers `main`.

`git revert` conserve le commit initial et ajoute son annulation. Il ne provoque pas de perte chez les autres développeurs.

## 22. Revenir à une ancienne version complète de l'application

1. identifier le dernier tag stable ;
2. construire le ZIP depuis ce tag avec `git archive` ;
3. sélectionner le profil de l'environnement ;
4. sauvegarder l'application APEX actuelle ;
5. importer l'ancienne version par-dessus l'application existante ;
6. exécuter les smoke tests ;
7. créer ensuite un `git revert` ou un correctif sur `main` pour que Git reflète à nouveau l'état voulu.

Ne pas ramener la branche `main` en arrière avec `reset`. L'environnement peut temporairement exécuter une ancienne release, mais l'historique Git doit rester linéaire et explicite.

## 23. Retour arrière du schéma

Le retour arrière applicatif et le retour arrière du schéma sont deux opérations différentes.

Pour la base :

- préférer une migration corrective en avant ;
- préparer un script de rollback avant la livraison lorsqu'il est réellement possible ;
- générer et relire le SQL Liquibase de rollback avant exécution ;
- effectuer une sauvegarde pour toute migration destructive ;
- ne jamais supposer qu'un `rollback` Oracle annule un DDL déjà validé implicitement.

Exemple de migration corrective :

```text
V006__ajout_contrainte.sql
V007__correction_contrainte.sql
```

On ne modifie pas `V006` après son déploiement.

## 24. Incidents de commande connus et solutions

### `zsh: command not found: connect`

Cause : `connect` a été lancé dans le terminal macOS.

Solution :

```bash
./sqlcl/bin/sql /nolog
```

Puis exécuter `connect` dans l'invite `SQL>`.

### `Unexpected token` avec `\`

Cause : utilisation du caractère de continuation shell dans l'invite SQLcl.

Solution : saisir la commande SQLcl sur une seule ligne.

### URL Oracle invalide

Cause possible : URL du workspace au lieu de l'URL du schéma, faute dans l'hôte ou syntaxe Markdown copiée.

Solution : utiliser uniquement :

```text
https://hote/ords/schema
```

### `apex export` échoue avec OREST

Solution : exporter depuis App Builder, conserver le ZIP brut localement puis valider avec SQLcl `/nolog`.

### `apex import` échoue avec OREST

Solution : construire le ZIP depuis Git et l'importer depuis App Builder. Utiliser wallet/Oracle Net pour automatiser ultérieurement.

### Validation APEXlang en erreur

Ne pas importer. Corriger chaque fichier et relancer :

```bash
scripts/validate.sh
```

### Conflit Git

Ne pas choisir automatiquement une version complète. Comparer les blocs APEXlang, fusionner consciemment, puis relancer la validation complète.

### Migration déjà exécutée

Ne pas modifier ni rejouer la migration. Créer une nouvelle migration corrective.

## 25. Checklist d'une Pull Request

- [ ] Branche créée depuis un `main` à jour.
- [ ] Modification limitée au besoin demandé.
- [ ] Aucun secret ni export brut ajouté.
- [ ] APEXlang validé avec succès.
- [ ] Migration nouvelle et immuable si le schéma change.
- [ ] SQL de migration relu.
- [ ] Tests DEV réussis.
- [ ] Plan de rollback décrit.
- [ ] Diff Git relu.
- [ ] Documentation mise à jour.

## 26. Checklist TEST

- [ ] Tag `rc` créé depuis un commit de `main`.
- [ ] Artefact construit depuis le tag, pas depuis le poste du développeur.
- [ ] Profil TEST contrôlé.
- [ ] Sauvegarde réalisée.
- [ ] Migrations TEST appliquées dans l'ordre.
- [ ] APEXlang importé sans suppression manuelle de l'application.
- [ ] Recette fonctionnelle et technique réussie.
- [ ] Résultats et hash du ZIP archivés.

## 27. Checklist PROD

- [ ] Tag final créé sur le commit accepté en TEST.
- [ ] Approbation de mise en production obtenue.
- [ ] Sauvegarde et plan de restauration disponibles.
- [ ] Profil PROD contrôlé par deux personnes.
- [ ] SQL de migration et rollback relus.
- [ ] Artefact construit depuis le tag final.
- [ ] Migrations appliquées avant l'application lorsque compatibles.
- [ ] Application importée par-dessus l'existante.
- [ ] Smoke tests réussis.
- [ ] Livraison enregistrée avec commit, tag et hash SHA-256.

## 28. Cycle résumé

```text
main à jour
    ↓
branche feature/* ou fix/*
    ↓
modification APEXlang et/ou migration SQL
    ↓
validation locale + tests DEV
    ↓
commit + push de la branche
    ↓
Pull Request + revue
    ↓
fusion dans main
    ↓
tag candidat rc → déploiement TEST
    ↓
recette et corrections éventuelles
    ↓
tag final sur le même commit
    ↓
migrations PROD + import APEXlang PROD
    ↓
smoke tests et archivage des preuves
```

Cette méthode garantit qu'un développeur peut restaurer un fichier, annuler un commit ou reconstruire une application complète sans supprimer l'historique et sans perdre le travail des autres membres de l'équipe.
