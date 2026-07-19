# TECH_SPEC_HITOBITO_EEDS.md

## Spécification Développeur Avancée — EEDS / Hitobito

## 1. Objectif
Adapter Hitobito pour les Éclaireuses et Éclaireurs du Sénégal (EEDS) avec modules métier, rôles, langues et déploiement moderne.

## 2. Stack Technique
- Ruby on Rails (Hitobito core)
- PostgreSQL
- Redis / Sidekiq
- Docker / Docker Compose
- Nginx / Caddy
- GitHub Actions CI/CD

## 3. Modules à Développer

### 3.1 Structure EEDS
Hiérarchie :
National > Région > District > Groupe Local > Unité

Branches :
- Jiwu wi
- Lawtan wi
- Toor-Toor wi
- Meññeef mi

### 3.2 Champs Personnalisés Personne
- matricule_scout
- branche
- unité
- assurance_expiration
- progression_badges
- contact_parent
- profession
- compétences

### 3.3 Cotisations
Tables :
- subscriptions
- payments
- invoices

### 3.4 Activités
Ajouter :
- type_activité
- camp_avec_nuitée
- autorisation_parentale
- capacité
- transport

### 3.5 Rapports
- effectifs par région
- croissance annuelle
- taux assurance
- participation activités

## 4. Modèle Rails suggéré

```ruby
class Person < ApplicationRecord
  has_many :roles
  belongs_to :group
end

class Group < ApplicationRecord
  acts_as_tree
end

class Subscription < ApplicationRecord
  belongs_to :person
end
```

## 5. Seeds Initiales Sénégal

Créer :
- National EEDS
- 14 Régions
- Districts autonomes
- Groupes locaux autonomes

## 6. Internationalisation

Locales :
- fr.yml
- en.yml
- wo.yml

Exemple :
```yml
wo:
  member: "Jëfandikukat"
```

## 7. Authentification

Ajouter :
- Microsoft 365 SSO
- Google OAuth
- 2FA TOTP

## 8. Déploiement Docker

```yaml
services:
  web:
    build: .
  db:
    image: postgres:16
  redis:
    image: redis:7
```

## 9. CI/CD GitHub Actions

```yaml
name: test
on: [push]
jobs:
  rspec:
    runs-on: ubuntu-latest
```

## 10. Prompt Claude / Copilot

Construis un plugin Hitobito pour EEDS qui ajoute :
1. branches scoutes du Sénégal
2. cotisations annuelles
3. assurance membres
4. rapports régionaux
5. traduction wolof
6. import CSV membres
7. dashboard moderne Tailwind

## 11. MVP Prioritaire (30 jours)

Semaine 1:
- setup env
- branding EEDS
- rôles

Semaine 2:
- membres + imports

Semaine 3:
- cotisations + assurance

Semaine 4:
- rapports + production deploy

## 12. Commandes Utiles

```bash
docker compose up
bundle exec rails db:migrate
bundle exec rspec
```
