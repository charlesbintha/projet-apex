# Procédure APEX, APEXlang, SQLcl et Git de bout en bout

## 1. Objectif

Cette procédure décrit le cycle complet utilisé pour Service Desk Lite :

1. maintenir le schéma Oracle ;
2. développer ou modifier l'application APEX ;
3. exporter ou modifier les sources APEXlang ;
4. valider les sources localement avec SQLcl ;
5. enregistrer une version dans Git et GitHub ;
6. reconstruire exactement l'application depuis un commit ;
7. importer cette version dans APEX.

## 2. Environnements actuels

| Rôle | Application | Schéma d'analyse | Utilisation |
| --- | ---: | --- | --- |
| Source historique | 102 | `WKSP_DEVSEN` | Référence initiale, à ne pas écraser pendant les tests |
| Développement cible | 110 | `TESTCL` | Application de développement actuelle |

Le dépôt GitHub est : <https://github.com/charlesbintha/projet-apex.git>.

La branche principale est `main`. La première baseline publiée est le commit `c246aa9`.

## 3. Organisation du dépôt

| Répertoire | Contenu |
| --- | --- |
| `apex/` | Sources APEXlang de l'application |
| `apex/pages/` | Pages APEX séparées |
| `apex/shared-components/` | Listes, LOV, sécurité, tâches, workflows, CSS et thème |
| `apex/deployments/` | Paramètres propres aux environnements |
| `database/` | Installation du schéma, package métier, workflow et vérifications |
| `scripts/` | Validation, création du ZIP et déploiement |
| `dist/` | ZIP généré pour l'import ; ce répertoire n'est pas versionné |
| `apex/apex-exports/raw/` | Archives APEX brutes conservées localement ; non versionnées |

SQLcl, les wallets, les mots de passe, les clés et les archives brutes sont exclus par `.gitignore`.

## 4. Passage de `WKSP_DEVSEN` vers `TESTCL`

Le schéma cible n'est pas choisi dans les pages APEXlang. Il est défini dans un fichier de déploiement.

Le profil cible utilisé par défaut est `apex/deployments/default.json` :

```json
{
  "app": {
    "name": "Demande Interne TESTCL",
    "alias": "DEMANDE-INTERNE-TESTCL",
    "databaseSession": {
      "parsingSchema": "TESTCL"
    }
  }
}
```

Ce profil ne contient volontairement pas d'ID. Lors d'une première installation, APEX peut ainsi attribuer un nouvel ID sans écraser l'application 102.

Le profil de la source historique est conservé dans `apex/deployments/source-app-102.json` :

```json
{
  "app": {
    "id": 102,
    "name": "Demande Interne",
    "alias": "DEMANDE-INTERNE",
    "databaseSession": {
      "parsingSchema": "WKSP_DEVSEN"
    }
  }
}
```

Pour le développement courant, ne pas remplacer `default.json` par le profil source. Le fichier `default.json` doit continuer à cibler `TESTCL`.

Avant chaque import, vérifier les trois valeurs suivantes :

- ID 110 pour mettre à jour l'application DEV existante, ou attribution automatique pour créer une nouvelle copie ;
- schéma d'analyse `TESTCL` ;
- alias `DEMANDE-INTERNE-TESTCL`.

## 5. Installation initiale du schéma

Cette étape a déjà été exécutée dans `TESTCL` :

```sql
show user
@"/Users/admin/Projects/Projet Test APEX/database/install-testcl-first-time.sql"
```

Le script refuse de s'exécuter si l'utilisateur n'est pas `TESTCL` ou si les objets Service Desk existent déjà.

Ne pas le relancer pour une modification ordinaire : il s'agit d'un script de première installation. Les évolutions futures de la base doivent être écrites sous forme de scripts incrémentaux, relus et testés avant exécution.

La vérification non destructive est disponible ici :

```sql
@"/Users/admin/Projects/Projet Test APEX/database/tests/00_verify_install.sql"
```

## 6. Modifier l'application

Deux méthodes sont possibles.

### 6.1 Modification dans App Builder

1. Ouvrir l'application 110.
2. Modifier les pages ou composants partagés.
3. Tester la modification dans APEX.
4. Depuis App Builder, exporter l'application au format APEXlang.
5. Télécharger le ZIP sur le Mac.
6. Conserver une copie brute dans `apex/apex-exports/raw/`. Ce répertoire n'est pas envoyé dans Git.
7. Extraire l'archive dans un répertoire temporaire, puis valider cet export avant de remplacer la baseline.

Exemple :

```bash
cd "/Users/admin/Projects/Projet Test APEX"
repertoire_temporaire="$(mktemp -d)"
unzip "/chemin/vers/export-app-110.zip" -d "$repertoire_temporaire"
scripts/validate.sh "$repertoire_temporaire"
```

Si la validation réussit, recopier les éléments APEXlang dans `apex/` :

```bash
rsync -a --delete "$repertoire_temporaire/pages/" apex/pages/
rsync -a --delete "$repertoire_temporaire/shared-components/" apex/shared-components/
cp "$repertoire_temporaire/application.apx" apex/application.apx
cp "$repertoire_temporaire/page-groups.apx" apex/page-groups.apx
cp "$repertoire_temporaire/.apex/apexlang.json" apex/.apex/apexlang.json
```

Ne pas recopier les composants de workspace contenant des credentials ou des paramètres OCI propres à un environnement. Conserver également les profils contrôlés présents dans `apex/deployments/`.

### 6.2 Modification directe avec Codex ou un éditeur

Modifier uniquement le ou les fichiers concernés, par exemple :

```text
apex/pages/p00020-detail-ticket.apx
apex/shared-components/workflows/SD-TICKET-LIFECYCLE.apx
apex/shared-components/static-files/app.css
```

Après chaque modification, exécuter la validation complète depuis la racine du dépôt :

```bash
cd "/Users/admin/Projects/Projet Test APEX"
scripts/validate.sh
```

Le résultat attendu est :

```text
Validation successful.
```

Ne jamais modifier manuellement `.apex/apexlang.json`. Il contient la version des métadonnées APEXlang attendue par le compilateur.

## 7. Examiner et enregistrer la modification dans Git

Vérifier d'abord la branche et les modifications :

```bash
git status
git diff --stat
git diff -- apex database scripts docs
```

Ajouter uniquement les fichiers liés à la modification :

```bash
git add apex
```

Si une migration de base et sa documentation ont également changé :

```bash
git add apex database docs
```

Contrôler exactement ce qui sera enregistré :

```bash
git diff --cached --stat
git diff --cached
```

Créer le commit puis le publier :

```bash
git commit -m "Description courte de la modification APEX"
git push origin main
```

Après le push, vérifier :

```bash
git status --short --branch
git log -1 --oneline --decorate
```

Éviter `git add .` lorsque des exports, documents d'étude ou fichiers temporaires sont présents à la racine.

## 8. Construire le ZIP importable depuis la version courante

Depuis un dépôt à jour :

```bash
cd "/Users/admin/Projects/Projet Test APEX"
git pull --ff-only origin main
scripts/package-apex.sh
```

Le script :

1. valide toute la baseline APEXlang ;
2. exclut les fichiers locaux et le profil historique de l'application 102 ;
3. crée `dist/demande-interne-testcl.zip`.

Le ZIP GitHub du dépôt complet ne doit pas être importé directement dans App Builder. Seul le fichier généré dans `dist/` constitue le paquet APEXlang importable.

## 9. Reconstruire l'application depuis un commit précis

Pour produire un ZIP correspondant exactement à un commit sans changer la branche de travail :

```bash
cd "/Users/admin/Projects/Projet Test APEX"
commit_release="c246aa9"
repertoire_release="$(mktemp -d)"
git archive "$commit_release" | tar -x -C "$repertoire_release"
SQLCL_BIN="$PWD/sqlcl/bin/sql" "$repertoire_release/scripts/package-apex.sh"
```

Le paquet se trouve ensuite ici :

```text
$repertoire_release/dist/demande-interne-testcl.zip
```

Remplacer `c246aa9` par le hash ou le tag réellement choisi pour la livraison.

## 10. Importer le ZIP dans APEX

La connexion SQLcl OREST permet les scripts SQL et PL/SQL, mais l'export APEX échoue actuellement avec `RestJdbcUnsupportedException`. L'import graphique par App Builder reste donc la méthode fiable dans cet environnement.

Avant de mettre à jour l'application 110, effectuer un export de sauvegarde depuis App Builder.

Ensuite :

1. ouvrir App Builder dans le workspace `DEVSEN` ;
2. choisir **Importer** ;
3. téléverser `demande-interne-testcl.zip` ;
4. sélectionner l'import APEXlang ;
5. pour mettre à jour DEV, choisir l'application existante ou l'ID 110 ;
6. vérifier que le schéma d'analyse est `TESTCL` ;
7. vérifier le nom et l'alias ;
8. confirmer l'installation ;
9. exécuter l'application.

Pour créer une nouvelle copie au lieu de remplacer DEV, choisir **Attribuer automatiquement un nouvel ID**. Ne jamais sélectionner 102 lors d'un test destiné à `TESTCL`.

## 11. Smoke tests après import

Tester au minimum :

1. connexion à l'application ;
2. affichage du tableau de bord ;
3. accès à la liste des tickets ;
4. création d'un ticket et redirection vers son détail ;
5. ajout d'un commentaire ;
6. affectation du ticket ;
7. ouverture des pages 30, 31 et 32 ;
8. traitement de la tâche ;
9. validation ou rejet de la résolution ;
10. historique du ticket et statut final.

En cas d'échec, conserver l'export de sauvegarde, les messages d'erreur et le hash du commit déployé. Ne pas modifier directement la production sans créer un nouveau commit correctif.

## 12. Cycle quotidien résumé

```text
Modifier l'application 110 ou les fichiers APEXlang
                         ↓
Tester la fonctionnalité
                         ↓
Valider avec scripts/validate.sh
                         ↓
Examiner git diff
                         ↓
git add + git commit + git push
                         ↓
Choisir un commit de livraison
                         ↓
Construire dist/demande-interne-testcl.zip
                         ↓
Sauvegarder puis importer dans App Builder
                         ↓
Exécuter les smoke tests
```
