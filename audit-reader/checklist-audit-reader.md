# Checklist d'audit Reader pour Sentinel et Defender XDR

## 1. Inventaire general

- Identifier le tenant cible
- Identifier les subscriptions utilisees par Sentinel
- Identifier le resource group securite
- Identifier le workspace principal Microsoft Sentinel
- Identifier les workspaces secondaires
- Noter la region de chaque workspace
- Verifier quels workspaces sont connectes au portail Defender

## 2. Portail Defender et experience unifiee

- Verifier si Microsoft Sentinel est visible dans https://security.microsoft.com
- Verifier si les incidents Sentinel et Defender sont unifies
- Verifier si les menus Sentinel sont accessibles avec le role actuel
- Verifier si les equipes utilisent deja le portail Defender ou encore principalement Azure portal

## 3. RBAC et acces

- Verifier le role Azure RBAC actuel
- Verifier si le role Sentinel Reader est present
- Verifier si des roles Defender RBAC sont aussi utilises
- Identifier les comptes qui devront avoir plus que Reader pour l'onboarding Data Lake
- Identifier qui detient Owner ou Contributor sur la subscription cible
- Identifier qui detient Global Administrator ou Security Administrator si necessaire

## 4. Architecture workspace

- Verifier si tous les workspaces utiles sont dans la meme region que le workspace principal
- Identifier les workspaces qui ne sont pas dans la meme region
- Identifier les workspaces non connectes au portail Defender
- Noter les contraintes de residence de donnees

## 5. Connecteurs et sources de donnees

- Lister les connecteurs Microsoft Entra ID
- Lister les connecteurs Microsoft 365
- Lister les connecteurs Defender for Endpoint
- Lister les connecteurs Defender for Identity
- Lister les connecteurs Defender for Cloud Apps
- Lister les connecteurs CEF, Syslog et custom connectors
- Identifier les sources critiques pour les investigations et detections
- Identifier les sources qui alimentent UEBA

## 6. Regles analytics et incidents

- Lister les regles analytics actives
- Identifier les regles liees a des produits Microsoft Defender integres
- Verifier les regles de creation d'incidents Microsoft
- Reperer les risques de doublons d'incidents entre Sentinel et Defender XDR
- Identifier les regles fortement dependantes de tables specifiques

## 7. Hunting, KQL et tables

- Identifier les principales requetes KQL custom
- Identifier les tables critiques pour le hunting
- Verifier l'usage de tables auxiliaires
- Verifier si certaines analyses dependent d'Advanced Hunting plutot que du Data Lake
- Noter les tables qui devront etre revalidees apres onboarding

## 8. Workbooks, watchlists et automatisation

- Lister les workbooks critiques
- Identifier les watchlists utilisees dans les regles ou requetes
- Lister les playbooks Logic Apps relies a Sentinel
- Lister les automation rules
- Identifier les dependances a des schemas ou tables specifiques

## 9. Gouvernance et blocages potentiels

- Verifier si des Azure Policies peuvent bloquer le deploiement Data Lake
- Verifier si des Customer-Managed Keys sont utiliseses sur les workspaces
- Verifier les contraintes internes de chiffrement et de residence de donnees
- Verifier les exigences d'approbation securite, reseau et gouvernance

## 10. Couts et retention

- Documenter la retention actuelle
- Documenter l'usage d'archive ou long-term retention
- Identifier les usages de search jobs et queries sensibles au changement de billing
- Identifier les impacts financiers a faire valider avant onboarding

## 11. Preparation Data Lake

- Confirmer le workspace principal cible
- Confirmer la region cible
- Confirmer les workspaces qui seront automatiquement rattaches
- Confirmer les roles necessaires pour l'onboarding
- Confirmer les prerequis Microsoft Entra / Microsoft 365 si graph et entity analysis sont vises
- Confirmer le plan de communication sur les impacts attendus

## 12. Sorties attendues de l'audit

- Une cartographie des workspaces et regions
- Une liste des connecteurs et dependances critiques
- Une liste des objets a revalider apres onboarding
- Une analyse des risques de doublons d'incidents
- Une liste des blocages techniques et organisationnels
- Une recommandation Go / No-Go pour preparer l'onboarding Data Lake
