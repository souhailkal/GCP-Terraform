En Mars:
Infra: 
    - Tous les différents ateliers ont été testé en Lab sur les infrastructures Scalewaqy de MikadoLabs
    - Préparation du code (GitLab mikado) pour intégration (Github Cosmo)
    - Ecriture du code source terraform pour 1 cluster k8s / istio avec 3 node pools

Ateliers :
    Etude des différentes technologies de gestion d'environnments CaaS :
        - HashiCorp : Nomad + consul + vault (Très bon stack techno, mais beaucoup de setup et moins de support)
        - Flynn : Bonne intégration de la sécurité mais pas d'autoscaling des instances

    Etude kubernetes :
        - k8s installé from scratch sur Scalewaay
        - k8s GKE sur GCP
        - k8s GKE sur GCP avec Istio (Solution retenue)

En avril:

 Infra:
   - Déploiement et tests des clusters prod-app et prod-ops composés de 3 noeuds chacuns
   - Ajout de répartiteurs de charges (sans multi-zones)
   - Mise au point du bastion SSH avec clés de l’équipe
   - Mise au point des/du compte de services
   - Zones DNS
   - Partage des zones DNS entre îlots (projets)
   - Tunnels entre îlots
   - Script de rejeu de l’infra
   - Tests de connectivité
   
 Ateliers:
   Premier atelier en présence avec Amar
   Peu d’activité chat
   
   
Mai : 

-	Installation d’une grappe « nopapp » pour les apps hors prod, 3 nœuds comme les clusters prod-app et prod-ops
-	Routage entre les 3 clusters
-	Intégration du provider kubernetes pour mettre en place un pod de déploiement Tiller pour les charms de helm sur chaque cluster


Juin :
-	Intégration du provider helm pour terraform
-	Déploiement de Jenkins et de son volume persistant 
-	Installation des principaux plugins pour jenkins 




