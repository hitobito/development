# DOCUMENT TECHNIQUE DÉTAILLÉ – STRUCTURE ORGANISATIONNELLE DES EEDS  
## Destiné aux développeurs (Application PBS / ERP / Gestion interne)

---

# 1. OBJECTIF DU DOCUMENT

Ce document décrit de manière **fonctionnelle et technique** la structure organisationnelle des **Éclaireuses et Éclaireurs du Sénégal (EEDS)** afin de permettre à une équipe de développement de :

- Modéliser la base de données
- Concevoir les rôles utilisateurs
- Construire les modules de gestion
- Paramétrer PBS / ERPNext / Odoo / Application sur mesure
- Gérer les affectations des membres
- Générer les organigrammes
- Produire les statistiques nationales

---

# 2. HIÉRARCHIE GLOBALE DES ENTITÉS

```text
NATIONAL
 ├── Régions
      ├── Districts
            ├── Groupes Locaux
                  ├── Unités
                        ├── Sous-groupes
                              ├── Membres
3. NIVEAUX ORGANISATIONNELS
3.1 NIVEAU NATIONAL
Entité : Association Nationale EEDS
Champs principaux :
Champ	Type
id	UUID
nom	string
sigle	string
siège	string
date_fondation	date
devise	string
statut_juridique	string
Organes Nationaux
A. Assemblée Générale
Composition :
Délégués régionaux
Comité Directeur
Équipe Nationale
Représentants désignés
Fonctions :
Vote des orientations
Élection des dirigeants
Validation stratégie nationale
B. Comité Directeur
Postes :
Président
Vice-président(s)
Secrétaire Général
Trésorier Général
Conseillers
Fonctions :
Gouvernance
Contrôle stratégique
Validation politique générale
C. Équipe Nationale
Postes :
Poste	Nombre
Commissaire Général	1
Commissaires Nationaux	N
Secrétaire Administratif	1
Responsable Finances	1
Responsable Communication	1
Responsable Formation	1
Responsable Programme Jeunes	1
Responsable Digital	1
3.2 NIVEAU RÉGIONAL
Entité : Région
Champs :
Champ	Type
id	UUID
nom	string
code	string
siège	string
Organes
Congrès Régional
Comité Régional
Équipe Régionale
Postes :
Commissaire Régional
Commissaire Régional Adjoint
Responsable Finances
Responsable Formation
Responsable Communication
Responsable Programme
3.3 NIVEAU DISTRICT
Entité : District
Champs :
Champ	Type
id	UUID
region_id	FK
nom	string
code	string
Organes
Congrès de District
Comité de District
Équipe de District
Postes :
Commissaire District
Adjoint
Secrétaire
Trésorier
Responsable Formation
Responsable Animation
3.4 NIVEAU GROUPE LOCAL
Entité : Groupe Local
Champs :
Champ	Type
id	UUID
district_id	FK
nom	string
quartier	string
adresse	text
Organes
Conseil de Groupe
Postes :
Chef de Groupe
Chef Adjoint
Secrétaire
Trésorier
Responsable Matériel
Responsable Parents / Supporters
4. UNITÉS PAR BRANCHE
4.1 JIWU WI (5 à 11 ans)
Unité : Mbootaay
Membres :
Caat
Encadrement :
Njiit
Reefaan
Rambeen
Sous-groupes :
Pegg
4.2 LAWTAN WI (12 à 15 ans)
Unité : Kayon
Membres :
Arunga
Encadrement :
Njiit
Reefaan
Rambeen
Sous-groupes :
Jiyon
4.3 TOOR-TOOR WI (16 à 18 ans)
Unité : Dental / Ñawka
Membres :
Jàmbaar
Encadrement :
Njiit
Reefaan
Rambeen
Sous-groupes :
Fedde
4.4 MEÑÑEEF MI (18+)
Unité : Gàlle
Membres :
Mawdo
Encadrement :
Njiit
Reefaan
Rambeen
Sous-groupes :
Suudu
5. MODÈLE BASE DE DONNÉES RECOMMANDÉ
Table entities
id
name
type
parent_id
status
created_at
Types possibles :
national
region
district
groupe
unite
sous_groupe
Table members
id
firstname
lastname
birthdate
gender
phone
email
branch
entity_id
status
Table positions
id
title
level
entity_type

Exemples :

Commissaire Général
Commissaire Régional
Chef de Groupe
Njiit
Reefaan
Table assignments
id
member_id
position_id
entity_id
start_date
end_date
active
6. RÈGLES MÉTIER IMPORTANTES
Hiérarchie
Une région contient plusieurs districts
Un district contient plusieurs groupes
Un groupe contient plusieurs unités
Une unité contient plusieurs membres
Affectation
Un membre peut occuper plusieurs postes
Un poste appartient à une entité
Historisation obligatoire
Âge automatique branche
Âge	Branche
5-11	Jiwu
12-15	Lawtan
16-18	Toor-Toor
18+	Menñeef
7. DROITS UTILISATEURS
Rôle	Accès
Admin National	Tout
Admin Région	Région
Admin District	District
Chef Groupe	Groupe
Chef Unité	Unité
Membre	Profil uniquement
8. MODULES À DÉVELOPPER
Core
Gestion membres
Organigramme
Affectations
Cotisations
Présence
Activités
Rapports
Avancé
Badges / Progression
Formations
Communication SMS
Carte membre QR Code
Portail parents
API Mobile
9. API RECOMMANDÉES
GET /regions
GET /districts/:id
GET /groups/:id
GET /members/:id
POST /assignments
GET /organigramme
10. INTERFACE RECOMMANDÉE
Dashboard National
Nombre total membres
Répartition branches
Régions actives
Cotisations
Croissance annuelle
Dashboard Région
Districts
Groupes
Effectifs
Dashboard Groupe
Unités
Encadreurs
Présences
11. WORKFLOW PBS
Créer Région
Créer District
Créer Groupe
Créer Unité
Importer Membres
Nommer Responsables
Générer Rapports
12. PRIORITÉ MVP
Phase 1
Membres
Entités
Affectations
Dashboard
Phase 2
Finances
Activités
Progression
Phase 3
Mobile App
QR Cards
Notifications
13. RECOMMANDATION TECH STACK
Backend
Laravel / Django / NodeJS
Frontend
React / NextJS
Mobile
Flutter
DB
PostgreSQL
Hosting
Azure / AWS / DigitalOcean
14. CONCLUSION

La structure EEDS est parfaitement adaptée à un modèle hiérarchique multi-niveaux.

Le meilleur design technique :

Entity Tree + Roles + Assignments + Members + Activities

Cela permettra une application moderne, scalable et nationale.