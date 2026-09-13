# Demonstration de migration DEV vers PROD simulee

Application 100 : TEST_ENV. Application 101 : PROD_ENV.
Les anciens scripts install-testcl-first-time.sql et tests/00_verify_install.sql
contiennent encore des references a TESTCL : ne pas les utiliser pour cette demo.

## DEV, avant le commit

Dans une session SQLcl dediee, connectee a TEST_ENV, sans transaction en cours :

```sql
show user
@"/Users/admin/Projects/Projet Test APEX/database/migrations/V001__ajout_reference_externe.sql" TEST_ENV
@"/Users/admin/Projects/Projet Test APEX/database/tests/01_verify_reference_externe.sql"
```

Verifier le message OK, les eventuels objets invalides, puis tester la liste,
la creation et le detail d'un ticket dans l'application 100. La colonne facultative
n'apparait pas automatiquement dans les pages APEX ; cette demo porte sur le DDL.

## Git

Sur feature/migration-reference-externe, apres tests :

```bash
git add database/migrations/V001__ajout_reference_externe.sql database/migrations/README.md database/tests/01_verify_reference_externe.sql
git diff --cached
git commit -m "feat: ajouter la reference externe des tickets"
git push -u origin feature/migration-reference-externe
```

Ouvrir une Pull Request vers main, joindre les resultats DEV, faire approuver
par le responsable backend et fusionner. Recuperer ensuite le commit approuve.

## PROD simulee, seulement apres approbation

Sauvegarder selon la procedure de l'environnement. Dans une session SQLcl
dediee connectee a PROD_ENV, executer les memes fichiers issus du commit approuve :

```sql
show user
@"/Users/admin/Projects/Projet Test APEX/database/migrations/V001__ajout_reference_externe.sql" PROD_ENV
@"/Users/admin/Projects/Projet Test APEX/database/tests/01_verify_reference_externe.sql"
```

Tester l'application 101 et noter le SHA Git dans la preuve de livraison.
Ne pas executer les deux environnements en parallele pendant la demonstration.

## Limites et reprise

- Le journal SD_SCHEMA_MIGRATIONS est local a chaque schema.
- Un seul operateur execute les migrations, sans lancement concurrent.
- Ce journal simplifie n'implemente pas les checksums/verrous de Liquibase.
  Une migration livree est immuable ; une correction devient V002.
- Un second lancement verifie la colonne et ne rejoue pas l'ALTER si V001 est journalisee.
- Un DDL Oracle valide implicitement des transactions : ROLLBACK ne retire pas
  la colonne. Si la creation reussit mais la journalisation echoue, le script
  s'arrete au prochain lancement. Inspecter et reconcilier, sans supprimer de donnees.
- Pour revenir a l'ancienne application, conserver cette colonne nullable.
  Une suppression ulterieure necessite une migration revue et une analyse des donnees.
- Le test SQL verifie la colonne et le journal ; les objets invalides et les tests
  fonctionnels doivent egalement etre controles avant promotion.

Les fichiers ont ete prepares localement ; leur execution en base et les tests
fonctionnels doivent etre confirmes par l'operateur.
