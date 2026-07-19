# claude.md — Mémoire technique du projet EEDS / Hitobito

> Document de référence pour Claude / Copilot / l'équipe de développement.
> Décrit l'objectif du projet, l'architecture Hitobito (core + wagons youth + pbs)
> et les points d'extension à utiliser pour construire l'application des
> Éclaireuses et Éclaireurs du Sénégal (EEDS).

---

## 1. Objectif du projet

Construire **`hitobito_eeds`**, un wagon Hitobito dédié à la gestion des membres,
groupes, activités et cotisations des **Éclaireuses et Éclaireurs du Sénégal**.

Principe directeur : **ne pas modifier le cœur de Hitobito ni le wagon PBS**.
Toute la spécificité sénégalaise vit dans un nouveau wagon `hitobito_eeds`,
inspiré structurellement de `hitobito_pbs` mais débarrassé des éléments
strictement suisses (Census, BSV, J+S, cantons, etc.).

Documents de référence métier (dossier `eeds/`) :
- `eeds/TECH_SPEC_HITOBITO_EEDS.md` — spec développeur de haut niveau
- `eeds/definition structure et roles.md` — structure organisationnelle EEDS
- `eeds/reconstitution_detaillee_des_structures_pbs_vers_eeds.md` — mapping PBS → EEDS

---

## 2. Stack technique Hitobito

| Élément | Version / Choix |
|---|---|
| Langage | **Ruby 3.2.6** |
| Framework | **Rails ~> 8.0** |
| Base de données | **PostgreSQL** (`pg`) |
| Serveur | **Puma** |
| Auth | `devise` + 2FA TOTP (`rotp`, `rqrcode`) ; OAuth/OIDC via `doorkeeper` + `doorkeeper-openid_connect` + `doorkeeper-jwt` |
| Jobs asynchrones | **`delayed_job_active_record`** (PAS Sidekiq) |
| Permissions | **CanCanCan** + DSL maison (`AbilityDsl`) |
| Vues | **HAML**, **Bootstrap**, **ViewComponent ~3.12**, **Turbo-Rails** |
| Assets | **Webpacker** + **Sprockets** |
| Sérialisation API | **Graphiti** (JSON:API), **Oat** |
| Décorateurs | **Draper** |
| Arbre de groupes | **`acts_as_nested_set`** + STI |
| Audit / soft-delete | **PaperTrail**, **Paranoia** |
| I18n colonnes | **Globalize** |
| Tags | **`acts-as-taggable-on`** |
| Stockage | AWS S3 (Active Storage) |
| Monitoring | Sentry, Airbrake, Prometheus exporter |

Pour le développement : **Docker Compose** (voir `docker-compose.yml` racine du
repo `GalleApp`) et la commande `hit` (`bin/dev-env.sh` puis `hit up`).

---

## 3. Architecture : core + wagons

### 3.1 Cœur — `app/hitobito`

Arborescence pertinente :

```
app/
  abilities/    # Ability + *Ability + *Readables enregistrées via AbilityDsl::Store
  controllers/  # Contrôleurs Rails standard (overridables par wagons)
  decorators/   # Draper (GroupDecorator, PersonDecorator, …)
  domain/       # Service objects, exporters, business logic
  helpers/      # NavigationHelper::MAIN = menu principal
  jobs/         # Delayed::Job
  models/       # Group, Person, Role, Event, … (STI partout)
  resources/    # Graphiti JSON:API
  serializers/  # Oat
  views/        # HAML
  components/   # ViewComponent
config/
  locales/      # de/en/fr/it (models.*.yml, views.*.yml)
  settings.yml  # gem `Config`, surchargeable par wagon
  initializers/
db/             # migrate/, seeds/, schema.rb
lib/            # generators, import, tasks, …
Wagonfile       # liste des wagons à charger (eval depuis Gemfile L179)
```

### 3.2 Modèles de domaine clefs

**`Group`** (`app/models/group.rb`)
- STI (colonne `type`) + arbre **nested-set** via `Group::NestedSet`
  (colonnes `lft`, `rgt`, `parent_id`, `layer_group_id`).
- Une "**layer**" = groupe dont la classe a `self.layer = true` ; sert de
  frontière de permission.
- Les **types de groupe sont des classes Ruby** sous-classant `Group`.
- DSL exposé par `Group::Types` (`app/models/group/types.rb`) :
  ```ruby
  class_attribute :layer, :role_types, :possible_children,
                  :default_children, :event_types, :standard_role
  def self.children(*group_types)  ... # types autorisés en enfants
  def self.roles(*types)           ... # rôles disponibles
  def self.root_types(*types)      ... # types racine (au démarrage)
  ```

**`Role`** (`app/models/role.rb`)
- STI également. Chaque rôle est une **classe imbriquée dans une sous-classe
  de `Group`** (ex. `Group::Bund::Adressverwaltung < ::Role`).
- Attributs déclaratifs :
  ```ruby
  self.permissions = [:layer_and_below_full, :contact_data, …]
  self.kind = :passive | :external                # défaut :member
  self.two_factor_authentication_enforced = true
  self.basic_permissions_only
  self.terminatable
  ```

**`Person`** (`app/models/person.rb`)
- Contact / utilisateur central.
- `has_many :roles, :groups (through), :qualifications, :phone_numbers,
  :additional_emails, :social_accounts, :households`.
- Auth Devise + 2FA TOTP + Doorkeeper.

**Permissions** : `app/abilities/ability.rb` agrège ~25 classes `*Ability`.
Symboles canoniques : `:layer_and_below_full`, `:group_read`, `:contact_data`,
`:admin`, `:finance`, `:approve_applications`, `:impersonation`,
`:manual_deletion`, `:crisis_trigger`, …

**Champs personnalisés** :
- `MountedAttribute` : table polymorphe key/value (YAML). Inclure `MountedAttr`
  dans le modèle puis `mounted_attr :ma_clef, :string`. Idéal pour champs
  optionnels rarement requêtés.
- Tables structurées dédiées : `additional_emails`, `phone_numbers`,
  `social_accounts`, `additional_addresses`.
- Pour des colonnes requêtables : ajouter directement via migration de wagon
  + concern Person (cf. PBS qui ajoute `pbs_number`, `salutation`, …).

### 3.3 Mécanisme des wagons

- Gem **`wagons`** (Puzzle ITC). Un wagon = `Rails::Engine` qui inclut
  `Wagons::Wagon`.
- Chargés par le `Wagonfile` à la racine de core (eval depuis `Gemfile` L179).
- Pattern d'override : le wagon définit des **modules mixins** dans
  `app/models/<wagon>/group.rb`, `app/models/<wagon>/person.rb`, etc.
  Puis dans `Wagon#config.to_prepare` :
  ```ruby
  Group.include  Eeds::Group
  Person.include Eeds::Person
  PeopleController.include Eeds::PeopleController   # ou .prepend
  ```
- **Group/role types** : sous-classer `Group` dans le wagon et déclarer les
  enfants ; types racine via `Group.root_types(...)`.
- **I18n** : déposer `config/locales/{models,views}.<wagon>.<locale>.yml`,
  Rails fusionne automatiquement.
- **Settings** : chaque wagon ajoute son propre `config/settings.yml` via
  `Settings.add_source!` dans son initializer.
- **Feature flags** : `FeatureGate.if("groups.nextcloud") { … }`.
- **Seeds** : surcharger `seed_fixtures` dans la classe Wagon ; utilise
  `seed-fu`.
- **Vues** : core auto-rend `_<partial>_<wagon>.html.haml` (ex.
  `_fields_youth.html.haml`), donc déposer `_fields_eeds.html.haml`.

### 3.4 Wagon `hitobito_youth`

Base générique "association de jeunesse" utilisée par PBS (et JuBLA).
- Ajoute champs **J+S (Jugend+Sport)** au `Person` : `j_s_number`,
  `nationality_j_s`.
- Étend `Event / Event::Course / Event::Participation` (candidatures
  tentatives, question AHV, validateur AHV).
- Ajoute des Abilities propres.
- **Ne définit AUCUN type de groupe ni rôle** — c'est au wagon pays de le
  faire.
- **Décision EEDS** : *probablement à NE PAS inclure* (les concepts J+S et
  AHV sont strictement suisses). On peut copier le pattern d'extension
  d'`Event` sans dépendre du wagon.

### 3.5 Wagon `hitobito_pbs` (référence à mimer mais pas à dépendre)

Hiérarchie effective (extrait) :

```
Group::Root (layer)
└── Group::Bund (layer)
    └── Group::Kantonalverband (layer)
        └── Group::Region (layer)
            └── Group::Abteilung (layer)
                ├── Group::Biber          (5–6 ans)
                ├── Group::Woelfe         (7–10)
                ├── Group::Pfadi          (11–14)
                ├── Group::Pio            (15–17)
                ├── Group::AbteilungsRover (18+)
                └── Group::Pta            (handi-scoutisme)
```

Plus : `Gremium`, `Kommission`, `BundesKommission`, `KantonaleKommission`,
`RegionaleKommission`, `Ausbildungskommission`, etc.

Rôles : ~30+ par layer (Sekretariat, Adressverwaltung, Coach, Praesidium,
Kassier, StufenleitungXxx, Ehrenmitglied, Passivmitglied, Selbstregistriert,
Materialwart, Webmaster, …).

Rôles d'unité scoute (les "membres") :
`Einheitsleitung, Mitleitung, Adressverwaltung, Leitwolf|Leitpfadi|…`,
puis le rôle standard `Biber|Wolf|Pfadi|Pio|Rover`.

Champs Person ajoutés par PBS :
`pbs_number`, `salutation`, `title`, `grade_of_school`, `entry_date`,
`leaving_date`, `correspondence_language`, `prefers_digital_correspondence`,
`pronouns`, `kantonalverband_id`.

Champs Group ajoutés : `pta, vkp, pbs_material_insurance, website,
pbs_shortname, bank_account, group_health, gender, try_out_day_at, hostname,
application_approver_role`.

Fonctionnalités PBS — décisions de reprise pour EEDS :

| Module PBS | Décision EEDS | Stratégie |
|---|---|---|
| **Census / MemberCount** | ✅ **Reprendre** | Fork/copie dans `hitobito_eeds` ; adapter le découpage par branche (Mbootaay/Kayon/Ñawka/Gàlle) et par tranches d'âge EEDS |
| **Crisis** (+ `:crisis_trigger`) | ✅ **Reprendre** | Fork tel quel ; adapter libellés FR/WO |
| **Camps** (`Event::Camp`, `CampReminderJob`, `AlumniInvitationsJob`) | ✅ **Reprendre** | Fork ; ajouter champs EEDS (autorisation parentale, transport, capacité) |
| **BlackList** (+ `BlackListMailer`) | ✅ **Reprendre** | Fork tel quel |
| **Event::Approval** (+ `ApprovalAbility`, `ApprovalCleanupJob`) | ✅ **Reprendre** | Fork ; adapter chaînes d'approbation à la hiérarchie EEDS (Unité → Groupe Local → District → Région → National) |
| **BSV reports** | ❌ Ignorer | Strictement réglementaire suisse |
| **Geolocations** (bornées CH) | 🔄 Transposer | Refaire avec bornes lat/lon Sénégal |
| **Kantonalverband / cantons** | 🔄 Transposer | Devient "Régions EEDS" (14 régions du Sénégal) |
| **J+S Person fields** | ❌ Ignorer | Spécifique loi suisse (programme Jugend+Sport) |

**Approche d'implémentation** : ne PAS dépendre du gem `hitobito_pbs` (62 migrations
CH, locales DE/FR/IT, hostnames suisses…). À la place, **copier dans le wagon
`hitobito_eeds` les fichiers utiles** (Census, Camp, Approval, BlackList, Crisis)
en retirant les couplages CH et en renommant les concepts vers le vocabulaire EEDS.
Compatible AGPL et conforme à l'esprit du doc *reconstitution PBS → EEDS*.

Fichiers de référence à étudier pour bâtir le wagon EEDS :
- `app/hitobito_pbs/lib/hitobito_pbs/wagon.rb` — pattern engine + to_prepare + langues
- `app/hitobito_pbs/app/models/group/abteilung.rb` — type avec multiples enfants
- `app/hitobito_pbs/app/models/group/woelfe.rb` — feuille avec rôles membres
- `app/hitobito_pbs/app/models/pbs/person.rb` — concern Person + colonnes custom
- `app/hitobito_pbs/config/locales/models.pbs.de.yml` — clefs i18n group/role
- `app/hitobito_pbs/db/seeds/groups.rb` — seeds racine

---

## 4. Mapping PBS → EEDS

### 4.1 Hiérarchie

| PBS (technique) | EEDS (affichage) | Classe wagon EEDS proposée |
|---|---|---|
| Root | Fédération / super-admin | (réutiliser `Group::Root` du core) |
| Bund | National | `Group::National` |
| Kantonalverband | Région | `Group::Region` (⚠ collision possible avec `Group::Region` PBS — préfixer `Group::RegionEeds` si on cohabite) |
| Region | District | `Group::District` |
| Abteilung | Groupe Local | `Group::GroupeLocal` |
| Biber / Woelfe / Pfadi / Pio / Rover / PTA | Mbootaay / Kayon / Ñawka / Gàlle | `Group::Mbootaay`, `Group::Kayon`, `Group::Nawka`, `Group::Galle` |

### 4.2 Branches pédagogiques EEDS

| Branche | Tranche d'âge | Unité (groupe scout) | Membre | Sous-groupe |
|---|---|---|---|---|
| Jiwu wi   | 5–11  | **Mbootaay** | Caat    | Pegg  |
| Lawtan wi | 12–15 | **Kayon**    | Arunga  | Jiyon |
| Toor-Toor wi | 16–18 | **Ñawka** (Dental) | Jàmbaar | Fedde |
| Meññeef mi | 18+  | **Gàlle**    | Mawdo   | Suudu |

Encadrement (toutes branches) : **Njiit**, **Reefaan**, **Rambeen**.

### 4.3 Postes par niveau (rôles à modéliser)

- **National** : Président, Commissaire Général, Commissaire International,
  Trésorier National, Secrétaire Général, Responsable Communication,
  Responsable Digital, Commissaires Nationaux (N), Resp. Formation, Resp.
  Programme Jeunes.
- **Région** : Commissaire Régional, Adjoint, Trésorier, Resp. Formation,
  Resp. Programme, Resp. Communication.
- **District** : Commissaire District, Adjoint, Secrétaire, Trésorier,
  Resp. Formation, Resp. Animation.
- **Groupe Local** : Chef de Groupe, Adjoint, Secrétaire, Trésorier,
  Resp. Matériel, Resp. Parents.
- **Unité (toute branche)** : Chef d'Unité (Njiit), Adjoint (Reefaan),
  Assistant (Rambeen), Chef de Patrouille / responsable d'équipe.
- **Membre standard** : Caat / Arunga / Jàmbaar / Mawdo selon la branche
  (`self.standard_role`).

---

## 5. Surface d'adaptation EEDS — checklist

Wagon à créer : `hitobito_eeds` dans `app/hitobito_eeds/` (à côté de
`app/hitobito_pbs` et `app/hitobito_youth`), puis ajouter
`gem 'hitobito_eeds', path: '…'` au `Wagonfile`.

| Objectif | Fichiers à créer |
|---|---|
| Gemspec & loader | `hitobito_eeds.gemspec`, `lib/hitobito_eeds.rb`, `lib/hitobito_eeds/wagon.rb`, `lib/hitobito_eeds/version.rb` |
| Types de groupe | `app/models/group/{national,region_eeds,district,groupe_local,mbootaay,kayon,nawka,galle}.rb` |
| Concerns Person/Group | `app/models/eeds/{person,group,role}.rb` + migrations |
| Locales | `config/locales/{models,views}.eeds.{fr,wo}.yml` |
| Settings | `config/settings.yml` (langues fr/wo, devise XOF, …) |
| Seeds racine | `db/seeds/groups.rb` |
| Vues custom | `app/views/people/_fields_eeds.html.haml`, `_details_eeds.html.haml` |
| Abilities éventuelles | `app/abilities/eeds/*.rb` |
| Activation | ajouter le wagon au `Wagonfile` racine |

### 5.1 Champs Person EEDS à ajouter

Via migration + concern `Eeds::Person` :
- `matricule_scout` (string, indexé unique)
- `branche` (enum string : jiwu, lawtan, toor_toor, mennneef)
- `unite` (référence ou string)
- `assurance_expiration` (date)
- `progression_badges` (jsonb)
- `contact_parent_name`, `contact_parent_phone`, `contact_parent_email`
- `profession` (string)
- `competences` (text / jsonb)

Mécanisme : voir patron `Pbs::Person` pour `pbs_number`. Penser à pousser
les champs dans `Person::PUBLIC_ATTRS`, `SEARCHABLE_ATTRS`, `used_attributes`
et à étendre `PeopleController.permitted_attrs`.

### 5.2 Internationalisation Wolof

1. Settings du wagon :
   ```yaml
   application:
     languages:
       fr: Français
       wo: Wolof
   ```
2. `I18n.available_locales += [:wo]` (initializer).
3. Locales : `models.eeds.wo.yml`, `views.eeds.wo.yml` + un `wo.yml`
   minimal pour les formats date/nombre (pas dans `rails-i18n` officiel).
4. Traduire toutes les clefs `activerecord.models.group/<sti>.{one,other,long}`
   et `activerecord.models.<role_sti>.{one,other}`.

### 5.3 Modules métier EEDS additionnels

| Module | Approche |
|---|---|
| **Cotisations** | Tables `subscriptions`, `payments`, `invoices` ; envisager d'utiliser le wagon `hitobito_invoices` ou `hitobito_sac_cas` comme inspiration plutôt que de réécrire from scratch |
| **Activités** (camps, autorisation parentale, transport, capacité) | Étendre `Event` via concern `Eeds::Event` + champs custom |
| **Rapports régionaux** | Domain services dans `app/domain/eeds/reports/` + exports tabular |
| **Import CSV membres** | Réutiliser `lib/import/` du core, ajouter mappings custom |
| **Carte membre QR** | Job + endpoint signed URL ; côté view ViewComponent |
| **Portail parents** | Devoirs : nouveau rôle `:parent`, ability dédiée, contrôleurs scoping par enfant |

---

## 6. Conventions de code à respecter

- Suivre le **style Hitobito** (rubocop fourni : `rubocop-must.yml` dans
  chaque wagon ; un `bundle exec rubocop` doit rester vert).
- Tests : **RSpec** pour core et wagons (`hit test`). Toute nouvelle
  classe / migration / feature doit avoir ses specs.
- Migrations : **dans le wagon EEDS** uniquement, jamais dans core.
- I18n : **aucune chaîne en dur** dans les vues. Toutes les chaînes
  passent par `I18n.t`.
- Permissions : ne jamais court-circuiter CanCan ; déclarer une `Ability`
  par domaine et l'enregistrer via `AbilityDsl::Store.register`.
- Versionnement : suivre **SemVer** sur le wagon ; `CHANGELOG.md` à jour.
- Commits : trailer `Co-authored-by: Copilot <…>` exigé.

---

## 7. Commandes utiles (dev)

```bash
# Démarrer l'environnement
bin/dev-env.sh
hit up                     # premier run = long (seeds)
hit help                   # liste des commandes

# Tests
hit test prep              # une fois par jour ou après changement d'assets
hit test                   # ouvre un shell test
rspec                      # tous les tests
rspec spec/models/person_spec.rb

# Debug
hit rails attach           # attache pry au container
hit db console             # console PostgreSQL
hit rails seed             # rejouer les seeds
hit down                   # tout arrêter
```

---

## 8. Questions ouvertes (à trancher avec le métier)

1. Cohabitation avec `hitobito_pbs` ou wagon EEDS **standalone** ? (recommandé
   : standalone, dépend uniquement de core)
2. Inclure ou non `hitobito_youth` ? (recommandé : non, sauf besoin J+S)
3. Modèle de cotisations : interne EEDS ou intégration `hitobito_invoices` ?
4. Authentification : SSO Microsoft 365 / Google requis dès la phase 1 ?
5. Stockage de fichiers : S3 (AWS), MinIO local ou Azure Blob ?
6. Hébergement cible : Azure / AWS / DigitalOcean / OVH / on-prem Sénégal ?
7. Volume estimé (nb membres / régions / districts / groupes) — pour
   dimensionnement.
8. Politique de RGPD / protection des données mineurs au Sénégal.

---

## 9. Roadmap macro (à détailler dans `plan.md`)

### Phase 0 — Cadrage (en cours)
- [x] Analyse hitobito core / youth / pbs
- [x] Mapping PBS → EEDS
- [x] `claude.md` (ce document)
- [ ] Décisions sur les questions ouvertes (§8)

### Phase 1 — Squelette wagon
- Création de `app/hitobito_eeds/` (skeleton à la PBS)
- Types `Group::National`, `Region`, `District`, `GroupeLocal`
- Branches : `Mbootaay`, `Kayon`, `Nawka`, `Galle`
- Rôles minimaux par niveau
- Locale `fr` complète
- Seeds : National + 14 régions
- CI GitHub Actions (rspec + rubocop)

### Phase 2 — Métier membres
- Champs Person EEDS (matricule, branche, contact parent, …)
- Imports CSV
- Vues custom
- Locale `wo`

### Phase 3 — Cotisations & activités
- Module cotisations (subscriptions/payments/invoices)
- **Camps** (fork `Event::Camp` PBS) + champs EEDS (autorisation parentale, transport, capacité)
- **Event::Approval** (fork PBS) adapté à la chaîne hiérarchique EEDS
- Assurance membres

### Phase 4 — Rapports, sécurité & UX
- **Census / MemberCount** (fork PBS) — recensement annuel par branche EEDS
- **Crisis** (fork PBS) — gestion de crise
- **BlackList** (fork PBS)
- Géolocalisation transposée (bornes Sénégal)
- Dashboards National / Régional / Groupe
- Exports
- Carte membre QR
- Portail parents

### Phase 5 — Production
- Auth SSO (M365/Google) + 2FA
- Déploiement Docker + CI/CD
- Monitoring (Sentry/Prometheus)
- Documentation utilisateur (FR/WO)

---

*Dernière mise à jour : 2026-04-29.*
