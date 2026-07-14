# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_07_14_042203) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "agenda_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "notes"
    t.date "occurs_on", null: false
    t.integer "scheduled_at_minute"
    t.integer "duration_minutes"
    t.string "kind", default: "event", null: false
    t.string "linked_type"
    t.bigint "linked_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["linked_type", "linked_id"], name: "index_agenda_items_on_linked_type_and_linked_id"
    t.index ["user_id", "occurs_on"], name: "index_agenda_items_on_user_id_and_occurs_on"
    t.index ["user_id"], name: "index_agenda_items_on_user_id"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "biometric_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "recorded_on", null: false
    t.integer "recorded_at_minute"
    t.decimal "value", precision: 12, scale: 3, null: false
    t.string "source", default: "manual", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "biometric_metric_id", null: false
    t.index ["biometric_metric_id", "recorded_on"], name: "index_biometric_entries_on_metric_and_date"
    t.index ["biometric_metric_id"], name: "index_biometric_entries_on_biometric_metric_id"
    t.index ["user_id", "recorded_on"], name: "idx_biometric_entries_user_date"
    t.index ["user_id"], name: "index_biometric_entries_on_user_id"
  end

  create_table "biometric_metrics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "unit"
    t.string "category"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_biometric_metrics_on_user_id_and_name", unique: true
    t.index ["user_id", "position"], name: "index_biometric_metrics_on_user_id_and_position"
    t.index ["user_id"], name: "index_biometric_metrics_on_user_id"
  end

  create_table "habit_completions", force: :cascade do |t|
    t.bigint "habit_id", null: false
    t.date "completed_on", null: false
    t.integer "completed_at_minute"
    t.decimal "value", precision: 10, scale: 2, default: "1.0", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["habit_id", "completed_on"], name: "index_habit_completions_on_habit_id_and_completed_on", unique: true
    t.index ["habit_id"], name: "index_habit_completions_on_habit_id"
  end

  create_table "habits", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "frequency_type", default: "daily", null: false
    t.integer "recurrence_days", default: [], null: false, array: true
    t.decimal "target_value", precision: 10, scale: 2, default: "1.0", null: false
    t.string "unit", default: "times", null: false
    t.string "category", default: "general", null: false
    t.integer "color_hue", default: 25, null: false
    t.integer "position", default: 0, null: false
    t.integer "scheduled_at_minute"
    t.integer "duration_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "occurs_on"
    t.integer "weekly_target"
    t.integer "monthly_day"
    t.boolean "hidden_from_dashboard", default: false, null: false
    t.index ["user_id", "position"], name: "index_habits_on_user_id_and_position"
    t.index ["user_id"], name: "index_habits_on_user_id"
  end

  create_table "lab_panels", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.integer "position", default: 0, null: false
    t.index ["user_id", "position"], name: "index_lab_panels_on_user_id_and_position"
    t.index ["user_id"], name: "index_lab_panels_on_user_id"
  end

  create_table "lab_results", force: :cascade do |t|
    t.bigint "lab_panel_id", null: false
    t.date "due_on"
    t.date "completed_on"
    t.text "result_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_on"], name: "index_lab_results_on_due_on"
    t.index ["lab_panel_id", "completed_on"], name: "index_lab_results_on_lab_panel_id_and_completed_on"
    t.index ["lab_panel_id"], name: "index_lab_results_on_lab_panel_id"
  end

  create_table "medication_intakes", force: :cascade do |t|
    t.bigint "medication_id", null: false
    t.date "taken_on", null: false
    t.integer "scheduled_minute"
    t.integer "taken_at_minute"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medication_id", "taken_on", "scheduled_minute"], name: "idx_med_intakes_unique", unique: true
    t.index ["medication_id"], name: "index_medication_intakes_on_medication_id"
    t.index ["taken_on", "medication_id"], name: "idx_med_intakes_date_med"
  end

  create_table "medications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "dose"
    t.integer "schedule_minutes", default: [], null: false, array: true
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_medications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "time_zone", default: "America/Mexico_City", null: false
    t.string "locale", default: "es", null: false
    t.boolean "guest", default: false, null: false
    t.integer "brand_hue", default: 25, null: false
    t.jsonb "health_modules", default: {}, null: false
    t.string "jti", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "tabs_visibility", default: {}, null: false
    t.datetime "help_seen_at"
    t.string "template_key"
    t.datetime "template_applied_at"
    t.datetime "data_resets_at"
    t.index ["data_resets_at"], name: "index_users_on_data_resets_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["guest"], name: "index_users_on_guest"
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "agenda_items", "users"
  add_foreign_key "biometric_entries", "biometric_metrics"
  add_foreign_key "biometric_entries", "users"
  add_foreign_key "biometric_metrics", "users"
  add_foreign_key "habit_completions", "habits"
  add_foreign_key "habits", "users"
  add_foreign_key "lab_panels", "users"
  add_foreign_key "lab_results", "lab_panels"
  add_foreign_key "medication_intakes", "medications"
  add_foreign_key "medications", "users"
end
