# Sources du schéma Oracle

Les scripts seront installés dans `TESTCL` dans un ordre déterministe. Les fichiers monolithiques actuellement présents dans `database/` seront conservés comme sources jusqu'à leur analyse et leur découpage.

## Informations nécessaires avant le découpage

1. Nom du schéma source.
2. DDL complet des tables, contraintes, séquences, index et triggers.
3. Spécifications et corps des packages, procédures et fonctions.
4. Vues utilisées par l'application.
5. Grants et synonymes indispensables.
6. Liste des données de référence à recréer avec des valeurs non sensibles.
7. Liste des jobs, credentials, database links ou intégrations à exclure ou reconfigurer.

## Ordre cible

1. Tables et séquences.
2. Contraintes et index.
3. Packages, procédures et fonctions.
4. Vues.
5. Triggers.
6. Données de référence.
7. Grants strictement nécessaires.
8. Compilation et tests.

## Première installation dans TESTCL

Le script `install-testcl-first-time.sql` contrôle que l'utilisateur courant est exactement `TESTCL` et qu'aucun objet `SD_*` n'existe avant d'appeler les deux scripts sources. Il ne doit servir qu'à la première installation du schéma DEV.

Depuis une session SQLcl déjà connectée à `TESTCL` :

```sql
show user
@database/install-testcl-first-time.sql
```

Les évolutions ultérieures devront utiliser des migrations incrémentales et ne devront pas relancer le script destructif initial.
