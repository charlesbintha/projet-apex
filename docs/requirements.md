# Exigences Service Desk Lite

## Objectif

Reproduire l'application APEX 102 dans un environnement DEV isolé utilisant le schéma `TESTCL`, tout en conservant les sources APEX, SQL et PL/SQL dans Git.

## Périmètre initial

- Schéma de données Service Desk Lite.
- Application APEX 102 et ses composants partagés.
- Pages du tableau de bord, liste, création et détail des tickets.
- Tâches d'affectation, traitement et validation de résolution.
- CSS centralisé.

## Critères d'acceptation de la baseline

- Tous les objets requis sont installés et valides dans `TESTCL`.
- L'export APEXlang de l'application 102 est validé sans erreur bloquante.
- L'application importée utilise les objets de `TESTCL`.
- Authentification, navigation, tableau de bord, liste et détail fonctionnent.
- Les workflows et tâches peuvent être créés et traités.
- Aucun secret ni donnée de production n'est versionné.

## Points à confirmer

- Nom exact du schéma source contenant actuellement les tables.
- Workspace et schéma d'analyse actuels de l'application 102.
- Objets à migrer et objets à exclure.
- Besoin de données de démonstration synthétiques.
