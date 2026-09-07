# Installation du workflow Service Desk Lite

## Ordre d'execution

1. Installer le schema principal si necessaire : `database/01_service_desk_lite_schema.sql`.
2. Executer l'extension : `database/02_service_desk_workflow.sql`.
3. Importer `apex/f102_workflow_shared_components.sql` dans l'application 102.
4. Importer les pages 30, 31 et 32.
5. Reimporter les pages 1, 11 et 20 mises a jour.
6. Dans Shared Components > Workflows, ouvrir `SD_TICKET_LIFECYCLE`, verifier la version 1.0 et l'activer si l'instance l'importe en mode Development.
7. Televerser `static/app.css` comme fichier statique d'application sous le nom `app.css` si ce n'est pas deja fait.

Le fichier des composants partages est destine a la premiere installation. Pour le reimporter pendant le developpement, supprimer d'abord dans Shared Components le workflow `SD_TICKET_LIFECYCLE` puis les trois definitions de taches `SD_TICKET_TRIAGE`, `SD_TICKET_PROCESSING` et `SD_RESOLUTION_APPROVAL`.

## Identites APEX

Les participants des taches sont des utilisateurs APEX. La colonne `SD_AGENTS.APEX_USERNAME` est initialisee avec l'adresse electronique en majuscules. Avant le test, remplacer ces valeurs par les identifiants reels des comptes APEX si ceux-ci sont differents.

Pour un ticket cree depuis l'application, `REQUESTER_USERNAME` prend en priorite `APP_USER`. Le createur recoit donc la tache finale de validation de la resolution.

Exemple :

```sql
update sd_agents
   set apex_username = 'MON_UTILISATEUR_APEX'
 where role_code = 'ADMIN';

commit;
```

## Scenario de verification

1. Creer un ticket sur la page 11.
2. Ouvrir la page 30 et reclamer la tache d'affectation.
3. Selectionner un agent puis valider l'affectation.
4. Se connecter avec l'utilisateur APEX de cet agent.
5. Reclamer la tache de traitement, saisir une note de resolution et terminer la tache.
6. Se reconnecter avec le createur du ticket.
7. Approuver ou refuser la resolution.
8. Controler le ticket sur la page 20 et le diagramme sur la page 32.

En cas de refus, le ticket retourne au statut `IN_PROGRESS` et une nouvelle tache de traitement est creee.
