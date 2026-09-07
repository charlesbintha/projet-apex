# Modèle de sécurité

## Principes

- `TESTCL` est un environnement DEV, pas un compte de production.
- Les identifiants SQLcl sont saisis au moment de la connexion ou conservés dans un gestionnaire local approuvé.
- Aucun secret ou wallet n'est stocké dans Git.
- Les tests utilisent uniquement des données synthétiques.
- Les autorisations APEX sont appliquées côté serveur aux pages, régions, processus et actions.
- Les scripts SQL doivent être relus avant exécution et ne doivent pas supprimer d'objets hors périmètre.

## Contrôle avant import

Avant toute installation ou import, exécuter `show user` et confirmer explicitement que la cible est `TESTCL`.
