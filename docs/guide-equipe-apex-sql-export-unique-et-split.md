# Guide d'équipe Oracle APEX au format SQL : fichier unique et export fractionné

## 1. Objet

Ce guide décrit le versionnement et le déploiement d'une application Oracle APEX exportée au format SQL classique `APPLICATION_SOURCE`.

Il couvre les deux formes proposées par APEX :

1. le fichier unique, par exemple `f12010.sql` ;
2. l'export fractionné, par exemple le dossier `f12010/` contenant toutes les pages et tous les composants.

Il présente également l'organisation d'une équipe avec :

- un seul développeur backend ;
- plusieurs développeurs APEX répartis par plages de pages ;
- Git, Pull Requests et tags ;
- les environnements DEV, TEST et PROD ;
- les migrations de schéma ;
- les procédures de restauration.

> Tous les noms, URLs, schémas, workspaces, IDs et dépôts de ce document sont fictifs. Ils servent uniquement d'exemples.

## 2. Différence avec APEXlang

| Sujet | Export SQL | APEXlang |
| --- | --- | --- |
| Format | Appels PL/SQL APEX dans des fichiers `.sql` | Description déclarative dans des fichiers `.apx` |
| Import | Exécution de `fXXXXX.sql` ou `install.sql` | Commande `apex import` ou import App Builder |
| Validation hors connexion | Contrôles texte et scripts personnalisés | `apex validate` avec SQLcl `/nolog` |
| Fichier unique | Oui | ZIP ou arborescence APEXlang |
| Export fractionné | Oui, avec `-split` | Naturellement organisé par composants |
| Travail Git par page | Recommandé avec l'export fractionné | Recommandé |
| Modification manuelle | Possible mais délicate | Conçue pour être plus lisible et éditable |

Le format SQL reste parfaitement utilisable pour Git. Pour une équipe travaillant sur plusieurs pages en parallèle, l'export fractionné est nettement préférable au fichier unique.

Les fichiers SQL exportés contiennent des appels aux API internes d'import APEX. Les développeurs réalisent donc leurs changements dans App Builder puis réexportent les composants. Une modification manuelle du SQL généré reste exceptionnelle, limitée, revue et testée sur une copie DEV.

Documentation Oracle :

- <https://docs.oracle.com/en/database/oracle/apex/26.1/aeadm/exporting-one-or-more-applications.html>
- <https://docs.oracle.com/en/database/oracle/apex/26.1/aeadm/installing-an-application.html>

## 3. Les deux méthodes d'export SQL

### 3.1 Méthode 1 — fichier unique

Un export complet produit un fichier :

```text
f12010.sql
```

Ce fichier contient la définition complète de l'application : pages, composants partagés, sécurité, navigation, processus, tâches et workflows.

Commande SQLcl :

```sql
apex export -applicationid 12010 -exptype APPLICATION_SOURCE -skipexportdate -exporiginalids -expsupportingobjects Y -dir "/chemin/vers/export"
```

La commande doit être saisie sur une seule ligne dans l'invite SQLcl.

Avantages :

- très simple à télécharger, archiver et importer ;
- adapté aux sauvegardes ponctuelles ;
- pratique pour une petite application gérée par une seule personne ;
- un seul artefact à transmettre.

Inconvénients :

- toute modification apparaît dans le même gros fichier ;
- les différences Git sont plus difficiles à lire ;
- deux développeurs modifiant des pages différentes créent malgré tout un conflit dans `f12010.sql` ;
- la répartition par plages de pages n'apporte presque aucun bénéfice dans Git ;
- une restauration d'une page isolée est plus difficile.

### 3.2 Méthode 2 — export fractionné

L'option `-split` produit un dossier structuré :

```text
f12010/
├── install.sql
└── application/
    ├── create_application.sql
    ├── set_environment.sql
    ├── end_environment.sql
    ├── pages/
    │   ├── page_00001.sql
    │   ├── page_00002.sql
    │   ├── page_00101.sql
    │   └── page_00201.sql
    └── shared_components/
        ├── navigation/
        ├── security/
        ├── user_interface/
        ├── workflows/
        └── files/
```

Commande SQLcl :

```sql
apex export -applicationid 12010 -split -exptype APPLICATION_SOURCE -skipexportdate -exporiginalids -expsupportingobjects Y -dir "/chemin/vers/export"
```

Avantages :

- chaque page possède son propre fichier ;
- Git montre précisément les pages et composants modifiés ;
- les développeurs travaillant sur des plages différentes produisent peu de conflits ;
- une page peut être examinée ou restaurée séparément ;
- les Pull Requests sont plus lisibles ;
- Oracle recommande cette forme pour le contrôle de source.

Inconvénients :

- l'arborescence contient davantage de fichiers ;
- l'ajout ou la suppression d'une page peut aussi modifier les fichiers d'installation ;
- les composants partagés restent des zones de conflit ;
- l'intégrateur doit contrôler la cohérence de l'export complet.

## 4. Choix recommandé

Utiliser :

- **l'export fractionné comme source de vérité dans Git** ;
- **le fichier unique comme sauvegarde ou artefact de livraison facultatif**.

Ne pas maintenir simultanément un fichier unique et un dossier fractionné comme deux sources modifiables. Ils finiraient par représenter des versions différentes.

La structure recommandée est :

```text
atlas-apex-demo/
├── apex-sql/
│   └── f12010/
│       ├── install.sql
│       └── application/
├── database/
│   ├── migrations/
│   └── tests/
├── deployment/
│   ├── dev/
│   ├── test/
│   └── prod/
├── docs/
├── scripts/
└── test-evidence/
```

Les fichiers uniques générés pour une livraison peuvent être joints à une GitHub Release au lieu d'être modifiés directement dans la branche principale.

## 5. Environnements fictifs

| Environnement | Workspace | Application | Schéma |
| --- | --- | ---: | --- |
| DEV | `ATLAS_DEV_WS` | 12010 | `ATLAS_DEV` |
| TEST | `ATLAS_TEST_WS` | 12020 | `ATLAS_TEST` |
| PROD | `ATLAS_PROD_WS` | 12030 | `ATLAS_PROD` |

Si les trois environnements utilisent la même instance APEX, les IDs d'application doivent être différents. Sur des instances séparées, l'équipe peut conserver le même ID lorsqu'il n'existe aucun conflit.

Les mots de passe, wallets et clés ne sont jamais enregistrés dans Git.

## 6. Organisation de l'équipe

### 6.1 Développeur backend unique

Un seul développeur est propriétaire de :

- `database/` ;
- `ords/` ;
- tables, vues, séquences et index ;
- packages, fonctions et procédures ;
- triggers ;
- migrations et scripts de rollback ;
- API REST et contrats utilisés par les pages.

Les développeurs APEX ne modifient pas directement le backend. Ils documentent leurs besoins dans un ticket et coordonnent la version de migration nécessaire.

Branches backend :

```text
backend/atlas-166-ajout-date-echeance
backend/atlas-174-api-recherche-client
```

### 6.2 Développeurs APEX par plages

| Développeur | Plage | Fichiers autorisés |
| --- | ---: | --- |
| APEX A | 1 à 100 | `page_00001.sql` à `page_00100.sql` |
| APEX B | 101 à 200 | `page_00101.sql` à `page_00200.sql` |
| APEX C | 201 à 300 | `page_00201.sql` à `page_00300.sql` |
| APEX D | 301 à 400 | `page_00301.sql` à `page_00400.sql` |

La page globale 0, la page de connexion 9999, `create_application.sql`, `install.sql` et les composants partagés sont réservés à l'intégrateur APEX.

### 6.3 Working Copy ou copie d'application

Chaque développeur APEX utilise de préférence une Working Copy ou une copie de l'application DEV. Il travaille seulement sur sa plage puis exporte ses composants.

Un développeur ne doit jamais remplacer l'export fractionné complet de Git par l'export de sa copie personnelle.

## 7. Création du projet Git

Créer un dépôt distant fictif, puis :

```bash
mkdir atlas-apex-demo
cd atlas-apex-demo
git init -b main
git remote add origin https://github.com/acme-example/atlas-apex-demo.git
mkdir -p apex-sql database/migrations database/tests deployment docs scripts test-evidence
```

Ajouter un `.gitignore` excluant au minimum :

```gitignore
.DS_Store
sqlcl/
.env
.env.*
wallet/
Wallet_*/
*.pem
*.key
*.p12
*.sso
*.log
dist/
apex-exports/raw/
```

Après le premier export fractionné :

```bash
git add .gitignore apex-sql database deployment docs scripts
git commit -m "Initialiser l'application APEX au format SQL fractionné"
git push -u origin main
```

## 8. Stratégie Git

### 8.1 Branches

La branche `main` contient la version validée et livrable.

Chaque développeur crée une branche courte :

```text
feature/atlas-142-page-115-detail-client
fix/atlas-151-page-220-validation
backend/atlas-166-ajout-date-echeance
hotfix/atlas-201-erreur-connexion
```

Création :

```bash
git switch main
git pull --ff-only origin main
git switch -c feature/atlas-142-page-115-detail-client
```

Le développeur pousse uniquement sa branche :

```bash
git push -u origin feature/atlas-142-page-115-detail-client
```

Les push directs et les force push sur `main` sont interdits.

### 8.2 Fusion

Les Pull Requests sont fusionnées une par une avec **Squash and merge**. Une fonctionnalité correspond ainsi à un commit facilement annulable.

Avant la fusion :

```bash
git fetch origin
git merge origin/main
git status
git diff origin/main...HEAD
git push
```

Ordre conseillé :

1. migration backend additive ;
2. composants partagés ;
3. pages consommatrices ;
4. export complet de consolidation ;
5. documentation.

Une merge queue GitHub est préférable. À défaut, l'intégrateur fusionne manuellement une Pull Request après l'autre.

## 9. Exporter avec App Builder

### 9.1 Fichier unique

Dans l'application :

1. ouvrir **Export/Import** puis **Export** ;
2. choisir le format SQL ;
3. désactiver l'option Split Export ;
4. télécharger `f12010.sql`.

### 9.2 Export fractionné

Dans l'application :

1. ouvrir **Export/Import** puis **Export** ;
2. choisir le format SQL ;
3. activer **Split Export** ;
4. télécharger le ZIP ;
5. extraire le dossier `f12010/` dans un répertoire temporaire.

Conserver l'archive brute hors de Git jusqu'à contrôle de son contenu.

## 10. Exporter avec SQLcl

Se connecter au schéma d'analyse du workspace :

```sql
connect utilisateur/mot_de_passe@hote:port/service
show user
```

Export unique :

```sql
apex export -applicationid 12010 -exptype APPLICATION_SOURCE -skipexportdate -exporiginalids -expsupportingobjects Y -dir "/chemin/vers/export"
```

Export fractionné :

```sql
apex export -applicationid 12010 -split -exptype APPLICATION_SOURCE -skipexportdate -exporiginalids -expsupportingobjects Y -dir "/chemin/vers/export"
```

Options importantes :

| Option | Utilité |
| --- | --- |
| `-split` | Crée un fichier par composant |
| `-skipExportDate` | Évite les différences Git liées uniquement à la date |
| `-expOriginalIds` | Conserve les IDs d'origine |
| `-expSupportingObjects Y` | Inclut les définitions des objets de support |
| `-dir` | Choisit le répertoire de sortie |

Les options SQLcl ne sont pas sensibles à la casse, mais l'équipe doit conserver une écriture cohérente dans ses scripts.

## 11. Intégrer la modification d'un développeur APEX

### 11.1 Page existante

Exemple : le développeur B a modifié la page 115.

Depuis son export fractionné temporaire, il copie uniquement :

```bash
cp "/tmp/export-f12010/application/pages/page_00115.sql" \
   "apex-sql/f12010/application/pages/page_00115.sql"
```

Puis il contrôle :

```bash
git status --short
git diff -- apex-sql/f12010/application/pages/page_00115.sql
```

Il ne copie ni `install.sql`, ni `create_application.sql`, ni les autres pages, sauf si l'intégrateur l'a demandé.

### 11.2 Nouvelle page

L'ajout d'une page peut modifier :

- le nouveau fichier `page_XXXXX.sql` ;
- `install.sql` ;
- `create_application.sql` ou d'autres fichiers de contrôle selon la version APEX.

Le développeur fournit un export partiel de la nouvelle page et signale qu'il s'agit d'une création. L'intégrateur applique `install_component.sql` sur l'application de consolidation DEV, puis réalise un export fractionné complet afin de régénérer correctement les fichiers de page et de contrôle avant la fusion finale.

Ne pas écrire manuellement une liste de pages dans `install.sql` sans vérifier le format généré par APEX.

### 11.3 Suppression de page

Une suppression peut générer un fichier `delete_XXXXX.sql` lors d'un export partiel et modifier les fichiers de contrôle lors d'un export complet.

La suppression doit être isolée dans une Pull Request explicite et validée par l'intégrateur. Elle ne doit pas être déduite simplement parce qu'un fichier manque dans l'export d'un développeur.

## 12. Exporter seulement quelques composants

SQLcl peut produire un export partiel :

```sql
apex export -applicationid 12010 -split -expcomponents "PAGE:101 PAGE:115"
```

Le dossier généré utilise alors `install_component.sql`.

Installation de l'export partiel :

```sql
@f12010/install_component.sql
```

Cette méthode est utile pour échanger quelques pages, mais la version de release doit toujours être reconstruite à partir d'un export complet et cohérent.

## 13. Contrôler avant commit

Le format SQL classique ne dispose pas de l'équivalent complet de `apex validate` hors connexion. Les contrôles reposent donc sur :

- la génération par APEX ou SQLcl ;
- la revue du diff ;
- la recherche de secrets ;
- un import dans une application DEV de test ;
- les smoke tests.

Commandes Git :

```bash
git status
git diff --stat
git diff --check
git diff -- apex-sql database deployment
```

Vérifier qu'aucun mot de passe, wallet, token, credential ou donnée d'exécution n'est présent.

## 14. Commit d'une page

Exemple pour la page 115 :

```bash
git add apex-sql/f12010/application/pages/page_00115.sql
git diff --cached --stat
git diff --cached
git commit -m "Modifier le détail client de la page 115"
git push -u origin feature/atlas-142-page-115-detail-client
```

La Pull Request indique :

- la plage et les pages concernées ;
- les composants partagés éventuels ;
- la migration backend requise ;
- les tests effectués ;
- le plan de retour arrière.

## 15. Gérer les composants partagés

Les composants suivants ne sont pas protégés par les plages de pages :

- listes et menus ;
- LOV ;
- authentification et autorisations ;
- CSS et JavaScript globaux ;
- tâches et workflows ;
- paramètres applicatifs ;
- `install.sql` et `create_application.sql`.

Une modification partagée doit être annoncée avant développement. Une seule Pull Request modifiant le même composant partagé est fusionnée à la fois.

L'intégrateur est propriétaire de la consolidation finale.

## 16. Versionner le schéma Oracle

Le schéma est indépendant de l'export APEX. Les tables, vues, packages et triggers sont versionnés sous forme de migrations :

```text
database/migrations/
├── V001__baseline_atlas.sql
├── V002__ajout_date_echeance.sql
├── V003__index_priorite.sql
└── V004__evolution_package_client.sql
```

Une migration déjà appliquée ne doit jamais être modifiée. Une correction devient une nouvelle migration.

Exemple :

```sql
whenever sqlerror exit failure rollback

alter table at_requests
    add due_at timestamp with time zone;

create index at_requests_due_at_ix
    on at_requests(due_at);

commit;
```

Le développeur backend est le seul à créer et modifier ces fichiers.

## 17. Ordre de déploiement

Utiliser la stratégie expansion/contraction :

1. déployer une migration additive compatible avec l'ancienne application ;
2. vérifier les objets Oracle ;
3. importer la nouvelle version APEX ;
4. exécuter les smoke tests ;
5. supprimer les anciens objets dans une release ultérieure.

Éviter de supprimer ou renommer une colonne avant que toutes les versions APEX qui l'utilisent aient été retirées.

## 18. Importer le fichier unique

### 18.1 Même environnement et même ID

Dans SQLcl :

```sql
@"/chemin/vers/f12010.sql"
```

L'application portant le même ID est réinstallée avec la définition exportée.

### 18.2 Environnement différent

Créer un script de déploiement qui prépare le contexte :

```sql
begin
    apex_application_install.set_workspace('ATLAS_TEST_WS');
    apex_application_install.set_application_id(12020);
    apex_application_install.generate_offset;
    apex_application_install.set_schema('ATLAS_TEST');
    apex_application_install.set_application_alias('ATLAS-TEST');
end;
/

@"/chemin/vers/f12010.sql"
```

Pour laisser APEX choisir un nouvel ID :

```sql
begin
    apex_application_install.set_workspace('ATLAS_TEST_WS');
    apex_application_install.generate_application_id;
    apex_application_install.generate_offset;
    apex_application_install.set_schema('ATLAS_TEST');
    apex_application_install.set_application_alias('ATLAS-TEST-COPY');
end;
/

@"/chemin/vers/f12010.sql"
```

## 19. Importer l'export fractionné

### 19.1 Application complète

```sql
@"/chemin/vers/f12010/install.sql"
```

### 19.2 Avec changement d'environnement

```sql
begin
    apex_application_install.set_workspace('ATLAS_PROD_WS');
    apex_application_install.set_application_id(12030);
    apex_application_install.generate_offset;
    apex_application_install.set_schema('ATLAS_PROD');
    apex_application_install.set_application_alias('ATLAS-PROD');
end;
/

@"/chemin/vers/f12010/install.sql"
```

### 19.3 Supporting Objects

Si l'export contient des Supporting Objects devant être installés automatiquement :

```sql
begin
    apex_application_install.set_auto_install_sup_obj(true);
end;
/
```

Ce choix doit être contrôlé, car les Supporting Objects peuvent créer ou modifier le schéma.

## 20. Importer depuis App Builder

Le fichier unique `.sql` ou le ZIP fractionné peut être téléversé depuis la page **Importer** du workspace cible.

Avant l'installation :

1. sauvegarder l'application cible ;
2. vérifier l'ID ;
3. vérifier le workspace ;
4. vérifier le schéma d'analyse ;
5. vérifier l'alias ;
6. contrôler les Supporting Objects.

Pour redéployer une application existante, réutiliser son ID lors de l'installation. Ne pas supprimer manuellement l'application avant l'import, notamment lorsqu'elle utilise des workflows et tâches en cours.

## 21. Limitations possibles avec OREST

Une connexion OREST peut permettre :

- `show user` ;
- les requêtes SQL ;
- les blocs PL/SQL ;
- l'exécution de scripts avec `@fichier.sql`.

Certaines plateformes peuvent cependant refuser des opérations JDBC utilisées par les commandes intégrées APEX.

### 21.1 `apex export` échoue

Erreur possible :

```text
RestJdbcUnsupportedException: Method setNull(...) not supported
```

Solution : exporter le fichier unique ou fractionné depuis App Builder.

### 21.2 Import SQL par `@` échoue

L'import d'une application SQL par OREST doit être testé sur une copie DEV avant toute utilisation en TEST ou PROD.

Si l'exécution échoue :

1. conserver l'erreur complète ;
2. ne pas supprimer l'application cible ;
3. utiliser l'import App Builder ;
4. prévoir une connexion wallet ou Oracle Net pour l'automatisation.

### 21.3 `connect` ne fonctionne pas dans le terminal

Si le terminal affiche :

```text
zsh: command not found: connect
```

lancer d'abord SQLcl :

```bash
./sqlcl/bin/sql /nolog
```

Puis exécuter `connect` dans l'invite `SQL>`.

### 21.4 Barre oblique inverse refusée

Dans l'invite SQLcl, saisir les commandes `apex export` sur une seule ligne. Le caractère `\` de continuation du shell n'est pas accepté comme dans `zsh`.

## 22. Promotion DEV → TEST → PROD

### 22.1 DEV

1. développer dans une copie ou Working Copy ;
2. exporter les pages concernées ;
3. appliquer d'abord les migrations backend additives dans DEV ;
4. intégrer les exports partiels dans l'application de consolidation DEV ;
5. effectuer un export fractionné complet depuis cette application ;
6. fusionner l'export consolidé par Pull Request ;
7. réinstaller l'artefact construit depuis Git dans DEV ;
8. exécuter les smoke tests.

### 22.2 TEST

Créer un tag candidat :

```bash
git switch main
git pull --ff-only origin main
git tag -a v1.3.0-rc.1 -m "Candidat recette 1.3.0"
git push origin v1.3.0-rc.1
```

Construire l'artefact depuis ce tag, appliquer le contexte TEST et installer `f12010.sql` ou `f12010/install.sql`.

### 22.3 PROD

Après acceptation du candidat :

```bash
git tag -a v1.3.0 -m "Version production 1.3.0" v1.3.0-rc.1
git push origin v1.3.0
```

Déployer exactement le même commit avec le contexte PROD.

## 23. Construire depuis un commit ou un tag

Ne pas déployer directement un répertoire contenant des modifications locales.

Extraire une version Git propre :

```bash
version_release="v1.3.0"
repertoire_release="$(mktemp -d)"
git archive "$version_release" | tar -x -C "$repertoire_release"
```

L'export fractionné se trouve ensuite sous :

```text
$repertoire_release/apex-sql/f12010/
```

Calculer le hash de l'artefact :

```bash
cd "$repertoire_release/apex-sql"
zip -r "atlas-apex-v1.3.0.zip" f12010
shasum -a 256 "atlas-apex-v1.3.0.zip"
```

Archiver le tag, le hash Git, le hash SHA-256 et les résultats des tests.

## 24. Restaurer une page avec l'export fractionné

Afficher l'historique :

```bash
git log --oneline -- apex-sql/f12010/application/pages/page_00115.sql
```

Examiner une version :

```bash
git show COMMIT:apex-sql/f12010/application/pages/page_00115.sql
```

Restaurer sans effacer l'historique :

```bash
git switch -c fix/restauration-page-115
git restore --source COMMIT -- apex-sql/f12010/application/pages/page_00115.sql
git add apex-sql/f12010/application/pages/page_00115.sql
git commit -m "Restaurer la page 115 depuis une version stable"
git push -u origin fix/restauration-page-115
```

Créer ensuite une Pull Request. La restauration devient un nouveau commit.

## 25. Restaurer avec le fichier unique

Avec un fichier unique, il n'est pas sûr d'extraire manuellement une seule page depuis un ancien `f12010.sql`.

Deux solutions :

1. restaurer le fichier complet depuis un tag et réinstaller toute l'application ;
2. exporter la page voulue depuis une application temporaire créée avec l'ancienne version.

Si le fichier unique est versionné, restaurer toute l'application avec :

```bash
git show v1.2.0:apex-sql/f12010.sql > /tmp/f12010-v1.2.0.sql
```

Puis importer le fichier après sauvegarde de la version actuelle.

Si le fichier unique est conservé uniquement comme artefact, le télécharger depuis la GitHub Release correspondant au tag au lieu d'utiliser `git show`.

Cette difficulté est une raison supplémentaire de privilégier l'export fractionné dans Git.

## 26. Annuler une fonctionnalité

Ne jamais réécrire l'historique de `main`.

Créer une branche d'annulation :

```bash
git switch main
git pull --ff-only origin main
git switch -c revert/atlas-142
git revert IDENTIFIANT_COMMIT
git push -u origin revert/atlas-142
```

Après la Pull Request, réaliser un nouvel export complet de consolidation et tester l'import en DEV.

## 27. Retour arrière complet

Pour revenir à une release précédente :

1. identifier le dernier tag stable ;
2. extraire ce tag avec `git archive` ;
3. appliquer le contexte de l'environnement ;
4. sauvegarder l'application en cours ;
5. exécuter `fXXXXX.sql` ou `fXXXXX/install.sql` ;
6. lancer les smoke tests ;
7. créer un `git revert` ou une correction sur `main`.

Ne pas utiliser `git reset --hard` ou `git push --force` pour effectuer un rollback partagé.

Le rollback du schéma est séparé. Une ancienne application ne fonctionnera pas forcément avec un schéma devenu incompatible. Les migrations destructives nécessitent un plan de sauvegarde et de restauration spécifique.

## 28. Tests après installation

Tester au minimum :

1. connexion et autorisations ;
2. navigation ;
3. pages appartenant aux différentes plages ;
4. création et modification d'une donnée métier ;
5. traitements backend ;
6. composants partagés ;
7. tâches et workflows ;
8. absence d'objets Oracle invalides ;
9. journaux APEX et erreurs JavaScript.

## 29. Checklist du développeur APEX

- [ ] Branche créée depuis `main` à jour.
- [ ] Pages modifiées uniquement dans la plage attribuée.
- [ ] Aucun export complet personnel n'a remplacé l'arborescence Git.
- [ ] Diff limité aux fichiers attendus.
- [ ] Composants partagés annoncés.
- [ ] Aucun secret ajouté.
- [ ] Test dans une copie DEV réussi.
- [ ] Pull Request créée vers `main`.

## 30. Checklist du développeur backend

- [ ] Migration nouvelle et immuable.
- [ ] Compatibilité avec l'application précédente vérifiée.
- [ ] Script de vérification fourni.
- [ ] SQL destructif identifié explicitement.
- [ ] Plan de rollback ou correction en avant documenté.
- [ ] Migration testée en DEV.
- [ ] Pull Request créée vers `main`.

## 31. Checklist de release

- [ ] Toutes les Pull Requests nécessaires sont fusionnées.
- [ ] Export fractionné complet de consolidation réalisé.
- [ ] `install.sql` et `create_application.sql` cohérents.
- [ ] Commit de consolidation présent sur `main`.
- [ ] Tag candidat ou final créé.
- [ ] Artefact construit depuis le tag.
- [ ] Contexte DEV, TEST ou PROD vérifié.
- [ ] Sauvegarde de l'application cible réalisée.
- [ ] Migrations exécutées dans l'ordre.
- [ ] Import effectué sans suppression manuelle de l'application.
- [ ] Smoke tests réussis.
- [ ] Hash Git et SHA-256 archivés.

## 32. Résumé de la méthode recommandée

```text
Working Copy du développeur
          ↓
export SQL des pages de sa plage
          ↓
branche feature/* et Pull Request
          ↓
fusion séquentielle avec Squash and merge
          ↓
export fractionné complet par l'intégrateur
          ↓
commit de consolidation sur main
          ↓
tag candidat et déploiement TEST
          ↓
tag final sur le même commit
          ↓
migration du schéma puis import SQL en PROD
```

Le fichier unique reste une bonne sauvegarde. L'export fractionné est la forme à privilégier pour le développement collaboratif, la revue Git et la restauration précise d'une page.
