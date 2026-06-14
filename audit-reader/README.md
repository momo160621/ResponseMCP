# Audit Sentinel/XDR en mode Reader

Ce dossier sert de base de travail pour preparer un audit Microsoft Sentinel et Microsoft Defender XDR avec des droits en lecture seule.

## Objectif

Travailler dans VS Code avec GitHub Copilot pour :

- inventorier l'existant
- identifier les prerequis du Data Lake
- evaluer les impacts potentiels
- preparer un plan d'onboarding sans modifier la configuration en production

## Perimetre en mode Reader

Avec un acces Reader, tu peux surtout :

- lire la configuration visible dans Azure et Defender
- exporter des informations d'inventaire
- verifier les workspaces, regions, ressources et connecteurs
- documenter les dependances entre Sentinel et Defender XDR
- preparer la migration vers le portail Defender et le Data Lake

Avec un acces Reader, tu ne peux pas :

- activer le Data Lake
- modifier les connecteurs
- changer les regles analytics
- modifier les workbooks, playbooks ou watchlists
- attribuer des roles ou changer la facturation

## Portails a utiliser

- Microsoft Defender portal : https://security.microsoft.com
- Azure portal : https://portal.azure.com
- Microsoft Entra admin center : https://entra.microsoft.com

## Ce qu'il faut verifier en priorite

1. Workspace principal Sentinel
2. Region du workspace principal
3. Autres workspaces dans la meme region
4. Connexion de Sentinel au portail Defender
5. Connecteurs actifs
6. Regles analytics existantes
7. Workbooks, watchlists, playbooks et automatisations
8. Presence de tables auxiliaires et usages d'Advanced Hunting
9. RBAC Azure et RBAC Defender
10. Presence de CMK et politiques Azure potentiellement bloquantes

## Fichiers du dossier

- checklist-audit-reader.md : checklist detaillee d'audit
- questions-preparation-datalake.md : questions a valider avant onboarding
- guide-step-by-step.md : guide d'utilisation pas a pas
- scripts/install-reader-prereqs.ps1 : installe les modules PowerShell requis en lecture seule
- scripts/connect-portals-reader.ps1 : ouvre les portails utiles et confirme le contexte Azure
- scripts/export-sentinel-xdr-reader-inventory.ps1 : exporte un inventaire lecture seule des subscriptions, workspaces et ressources Sentinel
- templates/audit-notes-template.md : modele de compte-rendu d'audit

## Usage conseille avec VS Code + Copilot

1. Ouvre ce dossier dans VS Code.
2. Lance le script scripts/connect-portals-reader.ps1 pour ouvrir les portails et verifier le contexte.
3. Lance le script scripts/export-sentinel-xdr-reader-inventory.ps1 pour generer un inventaire local dans le dossier output.
4. Utilise la checklist pour faire l'inventaire fonctionnel et technique.
5. Copie les resultats dans templates/audit-notes-template.md ou dans un export CSV/JSON.
6. Demande ensuite a Copilot de :
   - resumer les ecarts
   - detecter les risques
   - proposer un plan de remediation
   - evaluer l'impact Data Lake

## Commandes de depart

Depuis PowerShell :

```powershell
pwsh ./audit-reader/scripts/install-reader-prereqs.ps1 -IncludeResourceGraph
pwsh ./audit-reader/scripts/connect-portals-reader.ps1 -UseDeviceCode
pwsh ./audit-reader/scripts/export-sentinel-xdr-reader-inventory.ps1 -UseDeviceCode
```

Si tu connais deja la subscription cible :

```powershell
pwsh ./audit-reader/scripts/connect-portals-reader.ps1 -SubscriptionId <subscription-id> -UseDeviceCode
pwsh ./audit-reader/scripts/export-sentinel-xdr-reader-inventory.ps1 -SubscriptionId <subscription-id> -UseDeviceCode
```

## Sorties generees

Le script d'inventaire cree des fichiers JSON et un resume Markdown dans le dossier output.

Ces fichiers servent a :

- relire l'existant hors connexion
- demander a Copilot un resume de l'environnement
- preparer la revue d'impact Data Lake
- construire le compte-rendu d'audit

## Resultat attendu

A la fin, tu dois etre capable de repondre clairement a ces questions :

- Mon environnement est-il pret pour connecter Sentinel et Defender proprement ?
- Qu'est-ce qui risque d'etre impacte par l'onboarding Data Lake ?
- Quels changements sont organisationnels, techniques ou financiers ?
- Quels prealables doivent etre corriges avant activation ?
