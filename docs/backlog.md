# Habiclo — Backlog

Two items remain before the app can be considered feature-complete. Everything else in the original scope is shipped.

---

## 1. API v1

**Status:** Routes are defined. Zero controllers exist yet.

### What's already in place

`config/routes.rb` declares a full `namespace :api do namespace :v1` block:

```
POST   /api/v1/login
DELETE /api/v1/logout
GET    /api/v1/agenda
GET/POST/PATCH/DELETE /api/v1/habits (+ POST :toggle)
GET/POST/PATCH/DELETE /api/v1/agenda_items
GET/POST/PATCH/DELETE /api/v1/biometric_metrics
POST   /api/v1/biometric_metrics/:id/biometric_entries
GET/POST/PATCH/DELETE /api/v1/medications
GET/POST/PATCH/DELETE /api/v1/lab_panels/:id/lab_results
```

Auth uses **devise-jwt** (Bearer token, `jti` matcher strategy). Guest sessions are not supported on the API — requires a registered account.

### Controllers to create

All go in `app/controllers/api/v1/`.

| Controller | Actions | Notes |
|---|---|---|
| `Api::V1::BaseController` | — | Sets `before_action :authenticate_user!`, renders JSON errors, handles `Pundit::NotAuthorizedError`. |
| `Api::V1::SessionsController` | `create`, `destroy` | Devise handles token issuance; controller just delegates. |
| `Api::V1::AgendaController` | `index` | Returns day entries for `?on=YYYY-MM-DD`. Re-use `Agenda::DayComposer`. |
| `Api::V1::HabitsController` | `index, create, update, destroy, toggle` | Index returns habits scoped to user. Toggle calls `Habits::ToggleCompleter`. |
| `Api::V1::AgendaItemsController` | `index, create, update, destroy` | |
| `Api::V1::BiometricMetricsController` | `index, create, update, destroy` | Include latest entry and sparkline values in index response. |
| `Api::V1::BiometricEntriesController` | `create` | Nested under `:biometric_metric_id`. |
| `Api::V1::MedicationsController` | `index, create, update, destroy` | |
| `Api::V1::LabPanelsController` | `index, create, update, destroy` | Include nested `lab_results` in show/index. |
| `Api::V1::LabResultsController` | `create, update, destroy` | Nested under `:lab_panel_id`. |

### Response format

Use **jbuilder** (already in Gemfile). Suggested conventions:
- `GET /habits` → `{ data: [{ id, name, frequency_type, scheduled_at_minute, … }] }`
- `GET /agenda?on=2026-06-04` → `{ date, entries: [{ source, id, title, scheduled_at_minute, completed, … }] }`
- Errors → `{ error: "message" }` with appropriate HTTP status.
- All timestamps in ISO 8601. All minutes fields as integers (0–1439).

### Swagger / OpenAPI

`rswag-api` and `rswag-ui` are in the Gemfile. Generate specs in `spec/requests/api/v1/` using rswag DSL, then run `bin/rails rswag:specs:swaggerize` to produce `swagger/v1/swagger.yaml`.

---

## 2. Quality gate

**Status:** FactoryBot factories exist for all models. A handful of model specs exist. No request specs, no feature/system specs.

### Existing test infrastructure

```
spec/
  factories/
    users.rb, habits.rb, habit_completions.rb, medications.rb,
    biometric_entries.rb, lab_panels.rb, agenda_items.rb
  models/
    user_spec.rb, habit_spec.rb, habit_completion_spec.rb,
    medication_spec.rb, biometric_entry_spec.rb, lab_panel_spec.rb,
    agenda_item_spec.rb
  rails_helper.rb, spec_helper.rb
```

**Factories that need updating** (post Round 4 schema changes):
- `biometric_entries.rb` — must now associate with `biometric_metric` instead of using `metric` string.
- `lab_panels.rb` — remove `due_on`, `completed_on`, `result_summary`. Add `notes`, `position`.
- Add new factories: `biometric_metrics.rb`, `lab_results.rb`.

### Tests to write

**Model specs** (missing or stale):
- `biometric_metric_spec.rb` — `latest_entry`, `delta`, `entries_count`, uniqueness validation
- `biometric_entry_spec.rb` — update to use `biometric_metric` association
- `lab_panel_spec.rb` — `status_for_chip` with each state (empty / pending / completed)
- `lab_result_spec.rb` — `pending?`, `display_date`
- `user_spec.rb` — `tab_visible?` with empty and populated `tabs_visibility`

**Service specs** (missing):
- `habits/strength_calculator_spec.rb` — preloaded vs live, decay math, edge cases (no completions, all completions)
- `habits/toggle_completer_spec.rb`
- `agenda/day_composer_spec.rb` — correct sorting, all four entry sources
- `lab_results/due_expander_spec.rb`
- `users/guest_converter_spec.rb`

**Request specs** (none exist yet):
- `spec/requests/habits_spec.rb` — CRUD + toggle
- `spec/requests/health_spec.rb` — tab switching, visibility toggle
- `spec/requests/biometric_metrics_spec.rb`
- `spec/requests/lab_panels_spec.rb` + `lab_results_spec.rb`

**System / feature specs** (Playwright or Capybara + Selenium):
- Home ring: click segment → marks habit complete → ring segment fills → legend updates
- Agenda week: toggle habit → ink stroke appears without page reload
- Health / Biometría: create metric → card appears → add value → sparkline updates
- Health / Labs: create panel → expand row → add result → chip updates
- Health / Configuración: toggle off a tab → tab disappears from nav → toggle on → reappears

### Suggested approach

1. Fix stale factories first.
2. Write model + service specs (fast, no browser).
3. Write request specs for the API v1 controllers (combine with rswag).
4. Add Playwright (`playwright-ruby-client` gem) or Capybara + `selenium-webdriver` for the browser flows.
5. Add CI (GitHub Actions) with `bundle exec rspec` + `bin/rails assets:precompile` smoke test.

---

## Notes for the next Claude session

- Start by reading `CLAUDE.md` — it contains the full architecture, model overview, and naming conventions.
- Fix any bugs found in the current UI **before** starting API v1 or the test suite.
- The seed account is `nivedvengilat@example.com` / `test123`. Run `bin/rails db:reset && bin/rails db:seed` to get a clean state.
