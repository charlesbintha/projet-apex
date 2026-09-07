# Service Desk Lite Oracle APEX

Ce dépôt organise la reprise de l'application APEX 102 et son déploiement reproductible dans le schéma DEV `TESTCL` avec SQLcl, APEXlang et Git.

## Situation actuelle

- La connexion SQLcl OREST vers `TESTCL` fonctionne.
- Le schéma Service Desk Lite et ses extensions workflow sont installés dans `TESTCL`.
- L'application source 102 est visible, mais reste attachée à son schéma d'origine.
- La baseline APEXlang fournie a été assainie et validée sans erreur par SQLcl 26.2.
- Le profil de déploiement par défaut cible `TESTCL` sans réutiliser l'ID 102.

## Ordre de mise en place

1. Générer le paquet avec `scripts/package-apex.sh`.
2. Dans App Builder, ouvrir **Importer**, téléverser `dist/demande-interne-testcl.zip` et choisir l'import APEXlang.
3. Choisir **Attribuer un nouvel ID d'application** ; ne pas utiliser 102.
4. Vérifier avant confirmation : nom `Demande Interne TESTCL`, alias `DEMANDE-INTERNE-TESTCL`, schéma d'analyse `TESTCL`.
5. Installer l'application puis lancer les smoke tests : connexion, navigation, création de ticket, affectation, traitement et validation de résolution.
6. Examiner le diff et créer la baseline Git.

L'import par App Builder est le chemin recommandé avec la connexion OREST actuelle : l'export SQLcl a échoué sur une méthode JDBC REST non prise en charge. Une connexion Oracle Net/wallet permettra ensuite d'automatiser l'import avec `scripts/deploy-dev.sh`.

## Règle de sécurité

Les mots de passe, wallets, clés et exports contenant des données d'exécution ne doivent jamais être ajoutés au dépôt.
