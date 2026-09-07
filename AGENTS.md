# Projet Oracle APEX Service Desk Lite

## Finalité

Ce dépôt contient l'application Oracle APEX 26.1 Service Desk Lite, ses sources APEXlang, les objets Oracle, les API PL/SQL, les définitions ORDS, les tests et la documentation.

## Source de vérité

- Git est la source de vérité.
- Les sources APEXlang sont sous `apex/`.
- Les sources de base de données sont sous `database/`.
- Les définitions ORDS sont sous `ords/`.
- Les anciens exports SQL restent des artefacts de référence tant que la baseline APEXlang n'est pas validée.

## Environnement actuel

- Application source : APEX 102.
- Schéma de déploiement DEV : `TESTCL`.
- Connexion locale : SQLcl via OREST, sans mot de passe dans le dépôt.
- Aucun import TEST, UAT ou PROD sans autorisation explicite.

## Méthode obligatoire

1. Lire `docs/requirements.md` et `docs/architecture.md`.
2. Pour une modification significative, proposer un plan et la liste des fichiers touchés.
3. Faire le plus petit changement qui satisfait le besoin.
4. Valider APEXlang et exécuter les tests DB/API pertinents.
5. Examiner le diff et rechercher les changements destructifs ou sans rapport.
6. Indiquer les commandes exécutées, leurs résultats, les risques restants et les tests manuels.

## Conventions Oracle

- Utiliser SQLcl approuvé pour les opérations Oracle et APEX.
- Ne jamais stocker de mot de passe, wallet, jeton ou donnée de production dans Git.
- Avant un import, afficher et contrôler l'utilisateur, le schéma, le workspace, l'application et le fichier de déploiement.
- Utiliser des bind variables et des packages PL/SQL pour la logique métier réutilisable.
- Ne pas placer de `COMMIT` dans une fonction appelée depuis SQL.
- Appliquer les autorisations côté serveur, pas uniquement par conditions d'affichage.
- Conserver JavaScript et CSS dans des fichiers centralisés lorsque possible.

## Terminer seulement lorsque

- les exigences et critères d'acceptation sont couverts ;
- `apex validate` ne produit aucune erreur bloquante ;
- les objets Oracle sont valides et les tests pertinents réussissent ;
- l'import dans la copie DEV et le smoke test sont documentés ;
- le diff est ciblé et ne contient aucun secret.
