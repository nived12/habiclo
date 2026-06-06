# Habiclo

> Build who you want to be, one habit at a time.

A personal health OS: daily habit ring + time-blocked agenda + health tracking (medications, biometrics, lab panels).

---

## Tech stack

| Layer | Choice |
|---|---|
| Backend | Ruby 3.3 · Rails 8.0.5 |
| Database | PostgreSQL |
| Frontend | Hotwire (Turbo + Stimulus) · Tailwind CSS |
| Auth | Devise + devise-jwt |
| Assets | Propshaft + esbuild + cssbundling |

---

## Local setup

```bash
# Prerequisites: Ruby 3.3, PostgreSQL running locally

bundle install
yarn install

bin/rails db:create db:migrate
bin/rails db:seed        # seeds dev account: nivedvengilat@example.com / test123

bin/dev                  # starts Rails + esbuild + CSS watcher
```

Open `http://localhost:3000`.

---

## Key commands

```bash
bin/dev                                      # run all processes (Procfile.dev)
bin/rails db:migrate                         # apply pending migrations
bin/rails db:reset && bin/rails db:seed     # full reset
bin/rails routes | grep health               # inspect routes
bin/rails runner "puts User.count"           # quick DB check
```

---

## Project structure

```
app/
  models/           habit, habit_completion, medication, medication_intake,
                    biometric_metric, biometric_entry, lab_panel, lab_result,
                    agenda_item, user
  controllers/      home, agenda, health, habits, medications, lab_panels,
                    lab_results, biometric_metrics, biometric_entries,
                    settings, agenda_items
  services/
    agenda/         day_composer.rb
    habits/         strength_calculator.rb, toggle_completer.rb
    lab_results/    due_expander.rb
    medications/    dose_expander.rb
    users/          guest_converter.rb
  views/
    home/           ring view (monthly habit ring)
    agenda/         day, week, month views + _block partial
    health/         tabs: medications, labs, biometrics, settings
  javascript/controllers/   Stimulus controllers
  assets/stylesheets/       application.tailwind.css (design system)
config/
  routes.rb
  locales/es.yml en.yml
db/
  schema.rb
  migrate/
  seeds.rb
spec/
  models/           unit tests (FactoryBot)
  factories/
```

---

## Design system

**"The Quiet Almanac"** — warm off-white paper tones, serif display type, mono numbers, accent color driven by per-user `brand_hue` (oklch).

CSS custom properties: `--color-paper`, `--color-ink`, `--color-accent`, `--color-hairline`, and variants. See `app/assets/stylesheets/application.tailwind.css`.

---

## Feature status

| Area | Status |
|---|---|
| Auth (email/password + guest mode) | ✅ |
| Habits CRUD (daily/weekly/x-per-week/monthly/once) | ✅ |
| Time-blocked agenda (day / week / month) | ✅ |
| Home ring (monthly completion ring) | ✅ |
| Medications + intake tracking | ✅ |
| Biometric metrics (user-defined, value history, sparkline) | ✅ |
| Lab panels (container + result history, agenda integration) | ✅ |
| Health tab visibility toggles (Configuración) | ✅ |
| i18n ES + EN | ✅ |
| API v1 (routes defined, controllers pending) | ⏳ |
| RSpec request + feature test suite | ⏳ |

---

## What's pending

See [`docs/backlog.md`](docs/backlog.md) for detailed specs on the two remaining items:
- **API v1** — mobile/external client endpoints
- **Quality gate** — RSpec + Playwright test suite

---

## For Claude Code sessions

Read [`CLAUDE.md`](CLAUDE.md) at the start of every session. It contains the full architecture, naming conventions, performance patterns, and what **not** to do.
