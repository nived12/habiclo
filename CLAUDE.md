# Habiclo — Claude Project Context

> Read this file at the start of every session. It is the authoritative single source of truth for the project's current state, architecture, and conventions.

---

## What this app is

**Habiclo** is a personal health OS built as a Rails 8 monolith. Core idea: a daily habit ring (home view) + a time-blocked agenda (day / week / month) + a health module (medications, biometrics, lab panels). The tagline: *"Build who you want to be, one habit at a time."*

- Owner / primary user: **Nived Vengilat** (`nivedvengilat@gmail.com`)
- Dev seed account: `nivedvengilat@example.com` / `test123`
- Stack: **Rails 8.0.5 · Ruby 3.3 · PostgreSQL · Hotwire (Turbo + Stimulus) · Tailwind CSS (cssbundling)**
- No Webpack. Asset pipeline via **Propshaft**. JS bundled via **esbuild** (`bin/dev`).

---

## Running locally

```bash
bin/dev           # starts Rails + esbuild + CSS watcher (Procfile.dev)
bin/rails db:reset && bin/rails db:seed   # full reset with Nived's data
bin/rails db:migrate                       # apply pending migrations only
bin/rails runner "puts User.count"        # quick sanity checks
```

---

## Deployment (Railway) — read before touching deploy config

- Prod runs on **Railway** (services: `habiclo` web + `Postgres`), built from the repo **`Dockerfile`** (NOT Nixpacks — Railway uses the Dockerfile because it exists; any `"builder": "NIXPACKS"` in a `railway.json` is ignored).
- **Migrations run automatically on every deploy** via `bin/docker-entrypoint`: it runs `db:prepare` (covers primary + Solid Queue/Cache/Cable schemas) whenever the command ends in `./bin/rails server`, then serves through **Thruster**.
- **DO NOT set a Railway "Custom Start Command" or add a `railway.json` `startCommand`.** Doing so (a) breaks the entrypoint's auto-migrate condition and (b) bypasses Thruster, so the container stays "up" with no Rails process → **502, with empty deploy logs**. This already bit us once (June 2026). New migrations apply through the entrypoint — no override needed.
- Sub-databases (queue/cache/cable) are **schema-loaded**, not migration-based (no `db/queue_migrate/`, so `db:migrate:queue` fails). They share the primary's physical Postgres, so `db:prepare` skips loading their schema files (it sees the DB already exists) → the `solid_*` tables never get created and Solid Queue crashes Puma on boot (`relation "solid_queue_recurring_tasks" does not exist`). **`bin/docker-entrypoint` now handles this**: after `db:prepare` it loads `db:schema:load:{queue,cache,cable}` for any whose tables are missing (idempotent). On a brand-new DB this happens automatically; no manual step.
- Background jobs (Solid Queue) run **inside Puma** via `plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]` — set `SOLID_QUEUE_IN_PUMA=true` on the web service; no separate worker service/cost. Recurring jobs live in `config/recurring.yml`. (This requires the solid_queue tables above to exist — the entrypoint guarantees that.)
- **Zero-downtime deploys** need two Railway settings that work together:
  - **Variable `PORT=80`** — Railway healthchecks/routes to the `PORT` value, but the Dockerfile serves via **Thruster**, which listens on `HTTP_PORT=80` and *ignores* `PORT` (it only sets `PORT=TARGET_PORT=3000` for the Puma child). So Railway must be told to probe 80. Without this, the healthcheck hits the wrong port → "service unavailable" even though the app is healthy. (Puma stays on 3000 via `TARGET_PORT`; no collision.)
  - **Healthcheck Path `/up`** (Rails' `rails/health#show`) in Deploy settings. With both set, Railway waits for the new container to pass `/up` before cutting traffic and keeps the old deploy serving if a new one fails — zero-downtime, and a bad deploy can't take the site down.

---

## Domain model (current schema)

| Table | Key fields | Notes |
|---|---|---|
| `users` | `email, time_zone, locale, brand_hue, health_modules (jsonb), tabs_visibility (jsonb)` | Devise + JWT. `guest` bool. `tab_visible?(tab)` helper. |
| `habits` | `name, frequency_type, scheduled_at_minute, duration_minutes, color_hue, category, position` | `FREQUENCY_TYPES = %w[daily weekly_days x_per_week monthly once]` |
| `habit_completions` | `habit_id, completed_on, value, notes, completed_at_minute` | Unique on `(habit_id, completed_on)` |
| `medications` | `name, dose, schedule_minutes (int[]), notes` | `schedule_minutes` stores integer minutes (0–1439) |
| `medication_intakes` | `medication_id, taken_on, scheduled_minute, taken_at_minute` | Toggle pattern |
| `biometric_metrics` | `user_id, name, unit, category, position` | User-defined metrics (no enum). Unique `(user_id, name)`. |
| `biometric_entries` | `biometric_metric_id, user_id, value, recorded_on, source` | `SOURCES = %w[manual whoop healthkit habit]` |
| `lab_panels` | `user_id, name, notes, position` | Container only — no dates/results here |
| `lab_results` | `lab_panel_id, due_on, completed_on, result_summary` | `pending` / `completed` scopes |
| `agenda_items` | `user_id, title, occurs_on, scheduled_at_minute, duration_minutes, kind` | |

**Deleted:** `safety_rules` (dropped in Round 4). Never reference `SafetyRule` or `Safety::WarningsEvaluator`.

---

## Key services

| Service | What it does |
|---|---|
| `Habits::StrengthCalculator` | Exponential decay score 0–1. Accepts `completions: [[date, value], …]` to skip DB query. |
| `Habits::ToggleCompleter` | Idempotent toggle; returns `{habit:, completion:, strength:}`. |
| `Agenda::DayComposer` | Builds sorted `Entry` structs for one date from preloaded data. |
| `LabResults::DueExpander` | Converts pending `LabResult` rows into `DayComposer::Entry`. |
| `Medications::DoseExpander` | Same pattern for medication doses. |
| `Users::GuestConverter` | Moves all guest data to real account on sign-up. |

---

## Controllers + views architecture

### Agenda
- `AgendaController` — `#day`, `#week`, `#month`. All use `preload_range` which returns a hash with keys: `habits, completions_map, all_completions_map, meds, intakes_set, agenda_items_by_date, lab_results_by_date`.
- Partial `agenda/_block.html.erb` — unified block for habits and medication doses. Reads `entry.source` to branch.

### Health (`/health`)
- `HealthController` — tabs: `%w[medications labs biometrics settings]`. Dynamic visibility via `User#tab_visible?`.
- Partials: `health/_medications`, `health/_labs`, `health/_biometrics`, `health/_settings`.
- Biometrics uses `turbo_frame "health_modal"` for create/history drawers; Labs uses `turbo_frame "health_tab"` inline.
- Editing a medication or lab panel highlights the form panel (ring + tinted bg) and changes the title.

### Home (`/`)
- Ring view: monthly completion ring per daily habit. Segment toggle via Stimulus `ring-segment` controller.
- `@strengths_map` precomputed in controller to avoid N+1 in template.

---

## Stimulus controllers

| Name | File | Purpose |
|---|---|---|
| `agenda-block` | `agenda_block_controller.js` | Toggle completion via Turbo stream |
| `resource-destroy` | `resource_destroy_controller.js` | Optimistic DELETE (fetch + DOM removal). Values: `url, selector, confirm`. |
| `collapse` | `collapse_controller.js` | Toggle lab panel rows open/closed. Targets: `body`, `chevron`. |
| `ring-segment` | `ring_segment_controller.js` | SVG ring segment toggle + legend sync |
| `legend-toggle` | `legend_toggle_controller.js` | Syncs legend item state with ring |
| `frequency-fields` | `frequency_fields_controller.js` | Show/hide habit form fields by frequency type |
| `brand-hue` | `brand_hue_controller.js` | Live preview of accent color slider |
| `inline-editor` | `inline_editor_controller.js` | In-place text editing |
| `modal` | `modal_controller.js` | Generic modal open/close |

---

## CSS conventions

Design system: **"The Quiet Almanac"** — warm off-white paper, ink serif type, mono numbers, accent from user's `brand_hue` (oklch).

CSS variables (in `application.tailwind.css`):
```
--color-paper          --color-paper-deep
--color-ink            --color-ink-soft     --color-ink-muted
--color-hairline       --color-hairline-deep
--color-accent         --color-accent-muted --color-accent-ghost  --color-accent-ink
```

Component classes: `.almanac-button`, `.almanac-button--ghost`, `.almanac-button--accent`, `.almanac-eyebrow`, `.period-nav`, `.period-nav-item`, `.field-label`, `.field-input`, `.field-hint`, `.log-modal`, `.metric-card`, `.lab-panel-row`, `.lab-status-chip`, `.health-modal-panel`, `.toggle-track`.

---

## i18n

Default locale: `es` (Spanish). Both `es.yml` and `en.yml` are complete.  
Key namespaces: `habits.*`, `completions.*`, `health.*`, `lab_panels.*`, `lab_results.*`, `biometric_metrics.*`, `biometric_entries.*`, `medications.*`, `settings.*`, `agenda.*`.

---

## Performance patterns

- **No N+1 in controllers**: `AgendaController#preload_range` batches all queries for the visible range before rendering.
- `Habits::StrengthCalculator` accepts `completions:` array to skip cache/DB when called in bulk.
- `BiometricMetric` includes entries: `includes(:biometric_entries).ordered` in `HealthController`.
- `LabPanel` includes results: `includes(:lab_results).ordered`.

---

## Analytics (Ahoy) — read before touching tracking

First-party analytics via **`ahoy_matey`** (cookieless: `Ahoy.cookies = :none`, `Ahoy.mask_ips = true`, `track_bots` off by default). Data lives in `ahoy_visits` / `ahoy_events` **in the primary Postgres** (same physical volume as everything else).

- Pageviews auto-tracked in `ApplicationController#track_page_view` (`after_action`). It **skips `SKIP_TRACK_PREFIXES`** (`/admin /up /rails /cable /assets`) — never remove `/up` from that list: it renders 200 HTML, so healthchecks/monitors would log a `$view` **and a new visit row per ping**. Cookieless means one visit row *per request*, so infra pings compound fast.
- Named events: `"Signed up"`, `"Created habit"`, `"Logged completion"` (in the respective controllers).
- Consumer: `Admin::MetricsController` (`/admin/metrics`, owner-only) — the dashboard that reads this data. Don't drop the tables.
- Retention: **90 days** via `PruneAnalyticsJob` (`RETAIN_DAYS = 90`, batched deletes), scheduled daily 3am in `config/recurring.yml`.
- Rate limiting: `rack-attack` (`config/initializers/rack_attack.rb`, in-memory store) throttles 100 req/min/IP.
- **History:** an unfiltered `/up` healthcheck + cookieless visits + a 6-month retention that never fired filled the 5 GB volume and 502'd the site (July 2026). The four safeguards above are the fix — don't undo them.

---

## Guest accounts — read before touching guest creation

Anonymous visitors get a real (persisted) guest `User` seeded with a "welcome" demo (`Users::GuestCreator` → `Templates::Applier`), converted to a real account on sign-up (`Users::GuestConverter`), and reset after 7 days (`Users::GuestResetter` / `GuestResetJob`).

- Guest creation is gated in `GuestPipeline#load_or_create_guest`: **only real, non-bot HTML page loads/writes persist a guest.** Bots (`request_is_bot?` via `device_detector`), blank UAs, and non-HTML GETs get a `transient_guest` (`User.new`, **never saved** — pages render, nothing is written).
- `use_time_zone` must **not** call `current_or_guest_user` — it resolves the tz from `current_user`/cookie only. (It once minted a seeded guest on *every* request.)
- Welcome demo history is capped at `Templates::Applier::HISTORY_DAYS` (small on purpose) so real-visitor guests cost only a handful of rows.
- **History:** cookieless bots minting a fully-seeded guest per request created **530k guests / ~21M rows** and filled the volume (July 2026). Reclaimed by keeping the 2 real users and `TRUNCATE`-ing the rest. Don't undo the bot-gate.

---

## What is NOT here (out of scope)

- `app/controllers/api/v1/` — **routes exist but no controllers**. See `docs/backlog.md`.
- RSpec coverage is partial (model specs only, no request/feature specs). See `docs/backlog.md`.
- No ActionCable / real-time. No dark mode. No drag-and-drop reorder.

---

## Conventions to follow

1. **Hard delete everywhere** — no soft delete, no `Discard` gem. If it's deleted, it's gone.
2. **Turbo-first** — prefer `turbo_stream` responses. Use `respond_to { format.turbo_stream; format.html }`.
3. **Optimistic DOM removal** — use `resource-destroy` Stimulus controller for all delete buttons. Never `button_to` for deletes.
4. **No comments in code** unless the WHY is non-obvious (hidden constraint, workaround).
5. **Preload, don't lazy-load** — add to `preload_range` or use `.includes()` rather than letting the template query.
6. `completed_at_minute` / `scheduled_at_minute` are always integers 0–1439. Time inputs (`type="time"`) must be converted with `parse_time_to_minute` in `HabitCompletionsController`.
7. **UI/UX is part of done** — never report a feature complete without opening every page it touches and confirming the styling matches the Quiet Almanac. Devise scaffold views (`app/views/devise/**`) and other Rails generator output arrive **unstyled** by default — restyle them to match the design system before linking to them. Reference: `app/views/devise/sessions/new.html.erb` and `app/views/devise/registrations/new.html.erb` show the canonical auth-form pattern (`.almanac-eyebrow`, `display-lg`, `.field-label`, `.field-input`, `.almanac-button`, marginalia for errors).
