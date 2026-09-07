# Sources APEX

La racine `apex/` contient la baseline APEXlang de l'application Service Desk Lite.

- `deployments/default.json` cible le schéma `TESTCL`, avec un nom et un alias distincts de l'application 102 source. Il ne fixe volontairement aucun ID.
- `deployments/source-app-102.json` conserve les métadonnées de la source et ne doit pas être utilisé pour créer la copie TESTCL.
- `apex-exports/raw/` conserve localement l'archive reçue et est exclu de Git.
- Les anciens exports SQL `f102_*.sql` sont conservés comme références historiques ; la baseline déployable est l'arborescence APEXlang.

Avant tout import, exécuter `scripts/validate.sh`.

Pour SQLcl avec une connexion Oracle Net ou wallet :

```bash
SQLCL_CONNECTION_NAME=ma_connexion \
APEX_TARGET_APP_ID=1234 \
DEPLOY_CONFIRM=YES \
scripts/deploy-dev.sh
```

L'ID doit être libre et différent de 102. Avec la connexion OREST Always Free actuelle, privilégier l'import du ZIP depuis App Builder si le pilote REST signale une opération JDBC non prise en charge.
