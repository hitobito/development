# Reconstitution détaillée des structures PBS vers EEDS

## Adaptation complète de Hitobito PBS pour les Éclaireuses et Éclaireurs du Sénégal (EEDS)

### Version 1.0 — Avril 2026

## Introduction

Ce document présente une stratégie détaillée pour transformer la structure organisationnelle de Hitobito PBS (modèle suisse) afin de l’aligner entièrement sur l’organisation statutaire et opérationnelle des Éclaireuses et Éclaireurs du Sénégal (EEDS), tout en conservant la robustesse technique du noyau PBS.

## 1. Objectifs du projet

- Adapter PBS aux réalités institutionnelles des EEDS.
- Préserver la compatibilité avec les futures mises à jour Hitobito.
- Intégrer les branches pédagogiques sénégalaises.
- Reconstituer les rôles hiérarchiques EEDS.
- Simplifier l’administration nationale, régionale et locale.
- Préparer l’évolution future vers une fédération multi-associations.

## 2. Structure actuelle PBS

- Root
- Bund
- Kantonalverband
- Region
- Abteilung
- Sous-groupes / branches

## 3. Structure officielle EEDS

- National
- Régions
- Districts
- Groupes Locaux
- Unités pédagogiques : Mbootaay, Kayon, Ñawka, Gàlle

## 4. Modèle de correspondance recommandé

| PBS Technique | Affichage EEDS | Usage |
|---|---|---|
| Root | Fédération / Super Admin | Niveau système |
| Bund | National | Direction nationale |
| Kantonalverband | Région | Coordination régionale |
| Region | District | Pilotage intermédiaire |
| Abteilung | Groupe Local | Base opérationnelle |
| Sous-groupes | Unités | Animation pédagogique |

## 5. Hiérarchie cible

Root
└── National
    ├── Région Dakar
    │   ├── District Rufisque
    │   │   ├── Groupe Local Rufisque Centre
    │   │   │   ├── Mbootaay
    │   │   │   ├── Kayon
    │   │   │   ├── Ñawka
    │   │   │   └── Gàlle

## 6. Branches pédagogiques EEDS

| Branche | Âges | Unité |
|---|---|---|
| Jiwu wi | 5 à 11 ans | Mbootaay |
| Lawtan wi | 12 à 15 ans | Kayon |
| Toor-Toor wi | 16 à 18 ans | Ñawka |
| Meññeef mi | 18+ | Gàlle |

## 7. Mapping branches PBS vers EEDS

| PBS | EEDS |
|---|---|
| Biber | Mbootaay |
| Woelfe | Kayon |
| Pfadi | Ñawka |
| Rover | Gàlle |
| Pio | Réserve / Projet jeunes |
| PTA | Inclusion |

## 8. Rôles par niveau

### National
- Président
- Commissaire Général
- Commissaire International
- Trésorier National
- Secrétaire Général
- Responsable Communication
- Responsable Digital

### Région
- Commissaire Régional
- Commissaire Régional Adjoint
- Trésorier Régional
- Responsable Formation
- Responsable Programme

### District
- Commissaire District
- Assistant District
- Trésorier District

### Groupe Local
- Chef de Groupe
- Chef de Groupe Adjoint
- Responsable Matériel
- Secrétaire Local

### Unité
- Chef d’Unité
- Adjoint d’Unité
- Assistant
- Chef de Patrouille / Responsable équipe

## 9. Gestion des sous-groupes

### Mbootaay
Petites équipes de 6 à 8 enfants.

### Kayon
Patrouilles ou sizaines.

### Ñawka
Clans ou équipes projets.

### Gàlle
Commissions, cellules service, réseau adultes.

## 10. Paramétrage Hitobito recommandé

### À renommer uniquement
- Bund → National
- Kantonalverband → Région
- Region → District
- Abteilung → Groupe Local

### À personnaliser
- labels UI
- rôles
- formulaires membres
- qualifications
- rapports
- exports

## 11. Pourquoi ce modèle est durable

- Aucun changement du noyau technique.
- Mise à jour PBS facilitée.
- Forte stabilité.
- Formation utilisateurs simplifiée.
- Architecture prête pour croissance nationale.
- Possibilité multi-associations future.

## 12. Évolution future fédérale

Root = Fédération Sénégalaise du Scoutisme
- Bund = EEDS
- Bund = autre association scout
- Bund = autre branche nationale

## 13. Feuille de route projet

### Phase 1
- Traductions labels
- Rôles EEDS
- Nettoyage profils membres

### Phase 2
- Branches pédagogiques
- Permissions fines
- Organigrammes

### Phase 3
- Portail public
- Statistiques nationales
- Automatisation cotisations

### Phase 4
- Application mobile
- E-learning cadres
- Cartographie nationale

## 14. Recommandation stratégique finale

Le meilleur choix pour les EEDS est de conserver la mécanique PBS et d’adapter uniquement la couche métier EEDS.

Cela réduit les coûts, les risques et garantit la pérennité du système.

## 15. Résultat attendu

Un Hitobito entièrement sénégalisé, moderne, évolutif et administrativement cohérent pour les EEDS.

