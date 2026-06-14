# Guide pas a pas pour auditer Sentinel/XDR en mode Reader

## Objectif

Ce guide t'aide a :

- te connecter proprement aux portails Microsoft utiles
- verifier ton contexte Azure
- exporter un inventaire en lecture seule
- remplir ton audit sans rien modifier dans le tenant

## Avant de commencer

Tu as besoin de :

- VS Code
- PowerShell 7 (`pwsh`)
- un compte ayant au minimum des droits de lecture sur Azure / Sentinel / Defender
- une connexion reseau vers Microsoft Defender, Azure et Entra

## Etape 1 - Ouvrir le bon dossier dans VS Code

Ouvre le dossier suivant :

- [audit-reader](audit-reader)

Tu y trouveras :

- les scripts dans [audit-reader/scripts](audit-reader/scripts)
- les sorties dans [audit-reader/output](audit-reader/output)
- les modeles dans [audit-reader/templates](audit-reader/templates)

## Etape 2 - Installer les prerequis PowerShell

Dans un terminal PowerShell, place-toi a la racine du repo puis lance :

```powershell
pwsh ./audit-reader/scripts/install-reader-prereqs.ps1 -IncludeResourceGraph
```

Ce script installe les modules utiles :

- `Az.Accounts`
- `Az.Resources`
- `Az.OperationalInsights`
- `Az.ResourceGraph` en option utile pour enrichir l'inventaire Sentinel

Si tu ne veux pas `Az.ResourceGraph`, lance :

```powershell
pwsh ./audit-reader/scripts/install-reader-prereqs.ps1
```

## Etape 3 - Te connecter et ouvrir les portails

Lance ensuite :

```powershell
pwsh ./audit-reader/scripts/connect-portals-reader.ps1 -UseDeviceCode
```

Ce script :

- ouvre une authentification Azure en `device code`
- confirme le tenant, la subscription et le compte courant
- ouvre les portails utiles

Les portails cibles sont :

- `https://security.microsoft.com`
- `https://portal.azure.com`
- `https://entra.microsoft.com`

Si tu veux viser directement une subscription :

```powershell
pwsh ./audit-reader/scripts/connect-portals-reader.ps1 -SubscriptionId <subscription-id> -UseDeviceCode
```

## Etape 4 - Exporter l'inventaire en lecture seule

Lance ensuite :

```powershell
pwsh ./audit-reader/scripts/export-sentinel-xdr-reader-inventory.ps1 -UseDeviceCode
```

Ou avec une subscription cible :

```powershell
pwsh ./audit-reader/scripts/export-sentinel-xdr-reader-inventory.ps1 -SubscriptionId <subscription-id> -UseDeviceCode
```

Ce script exporte dans [audit-reader/output](audit-reader/output) :

- les subscriptions visibles
- les workspaces Log Analytics
- les ressources Sentinel detectees via Resource Graph si le module est installe
- un resume Markdown

## Etape 5 - Remplir la checklist

Ouvre et complete :

- [audit-reader/checklist-audit-reader.md](audit-reader/checklist-audit-reader.md)
- [audit-reader/questions-preparation-datalake.md](audit-reader/questions-preparation-datalake.md)

Pendant cette etape, verifie en priorite :

- le workspace principal Sentinel
- la region du workspace principal
- les workspaces dans la meme region
- la connexion de Sentinel au portail Defender
- les connecteurs et dependances critiques
- les risques de doublons incidents Sentinel / Defender
- les contraintes CMK, Azure Policy et gouvernance

## Etape 6 - Renseigner le compte-rendu

Copie les constats dans :

- [audit-reader/templates/audit-notes-template.md](audit-reader/templates/audit-notes-template.md)

Tu peux ensuite demander a Copilot :

- de resumer l'environnement
- de produire une analyse de risques
- de lister les prerequis Data Lake manquants
- de proposer un Go / No-Go

## Etape 7 - Ce que tu dois regarder dans chaque portail

### Defender portal

- Microsoft Sentinel
- Incidents
- Hunting
- Configuration > Analytics
- Configuration > Data connectors
- Configuration > Watchlists

### Azure portal

- Log Analytics workspaces
- Microsoft Sentinel
- Resource groups
- Azure Policy
- Role assignments

### Entra admin center

- Roles and administrators
- Sign-in logs
- Risky users

## Probleme courant

### Erreur : `Az.Accounts module is required`

Cause : les modules PowerShell Azure ne sont pas installes.

Correction :

```powershell
pwsh ./audit-reader/scripts/install-reader-prereqs.ps1 -IncludeResourceGraph
```

Puis relance :

```powershell
pwsh ./audit-reader/scripts/connect-portals-reader.ps1 -UseDeviceCode
```

### Erreur d'authentification

Cause possible :

- compte sans acces Azure suffisant
- mauvais tenant
- session expiree

Correction :

- relancer avec `-ForceLogin`
- preciser `-TenantId <tenant-id>` si besoin

Exemple :

```powershell
pwsh ./audit-reader/scripts/connect-portals-reader.ps1 -TenantId <tenant-id> -ForceLogin -UseDeviceCode
```

### Aucun resultat utile dans l'inventaire

Cause possible :

- mauvaise subscription
- pas d'acces Reader sur la subscription cible
- aucun workspace visible avec ce compte

Correction :

- verifier la subscription courante
- relancer avec `-SubscriptionId`
- verifier les droits Azure RBAC

## Resultat attendu

A la fin, tu dois avoir :

- un acces confirme aux portails
- un export d'inventaire dans [audit-reader/output](audit-reader/output)
- une checklist d'audit remplie
- un compte-rendu d'audit initial
- une vision claire des prerequis et impacts Data Lake