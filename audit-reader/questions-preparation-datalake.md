# Questions a valider avant onboarding Microsoft Sentinel Data Lake

## Questions techniques

- Quel est le workspace principal Sentinel retenu ?
- Dans quelle region est-il heberge ?
- Quels workspaces additionnels sont dans la meme region ?
- Quels workspaces sont deja connectes au portail Defender ?
- Utilisons-nous des tables auxiliaires en hunting ou reporting ?
- Utilisons-nous des CMK sur les workspaces concernes ?
- Des Azure Policies risquent-elles de bloquer le deploiement du service Data Lake ?

## Questions fonctionnelles

- Quelles regles analytics sont critiques pour le SOC ?
- Quels workbooks sont indispensables au quotidien ?
- Quelles watchlists sont utilisees pour la detection ou l'investigation ?
- Quels playbooks sont relies a des incidents ou alertes Sentinel ?
- Quelles requetes KQL custom devront etre revalidees apres changement d'experience ?

## Questions gouvernance

- Qui possede les droits Subscription Owner ou Contributor pour la facturation ?
- Qui possede les droits Global Administrator ou Security Administrator si necessaire ?
- Qui valide l'impact residence des donnees et conformite ?
- Qui valide le changement de modele de facturation ?

## Questions exploitation SOC

- Le SOC travaille-t-il deja dans le portail Defender ?
- Les incidents Defender et Sentinel sont-ils deja unifies ?
- Faut-il desactiver certaines regles de creation d'incidents Microsoft pour eviter les doublons ?
- Faut-il prevoir une phase pilote avant activation generale ?

## Questions decisionnelles

- Que veut-on obtenir en priorite avec le Data Lake ?
- Investigation plus rapide ?
- MCP Sentinel ?
- Graph et blast radius ?
- Consolidation des donnees ?
- Reduction de cout ou meilleure retention ?

## Conclusion attendue

A la fin de cette revue, il faut pouvoir dire :

- si l'environnement est pret ou non
- ce qui bloque techniquement
- ce qui doit etre arbitre par la gouvernance
- quels tests faire avant onboarding
- quel sera l'impact probable sur l'exploitation SOC
