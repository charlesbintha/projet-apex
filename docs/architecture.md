# Architecture de développement et de déploiement

## Source

L'application 102 et ses objets de données existent actuellement dans l'environnement APEX d'origine. Les exports SQL présents dans ce dossier servent de référence jusqu'à création d'une baseline APEXlang validée.

## Cible DEV

- Schéma Oracle : `TESTCL`.
- Accès : SQLcl via OREST.
- Application : copie DEV de l'application 102.
- Dépôt : GitHub `charlesbintha/projet-apex`.

## Flux

1. Schéma source vers scripts versionnés sous `database/`.
2. Scripts versionnés vers `TESTCL`.
3. Application APEX source vers export APEXlang sous `apex/`.
4. Validation locale avec SQLcl.
5. Import dans une copie DEV et smoke test.
6. Revue Git avant toute promotion.

## Séparation des responsabilités

- `database/ddl/` : tables, séquences, contraintes, index et triggers techniques.
- `database/packages/` : spécifications et corps PL/SQL.
- `database/views/` : vues et vues matérialisées.
- `database/seed/` : données synthétiques et référentiels autorisés.
- `database/tests/` : contrôles de compilation et tests PL/SQL.
- `apex/` : source APEXlang standard et exports de référence.
- `ords/` : services REST et tests contractuels.
