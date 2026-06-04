# Habiclo seeds — Nived's personal account.
# Run via: bin/rails db:seed
# Idempotent: re-running rebuilds the day plan for the seeded user only.

NIVED_EMAIL = "nivedvengilat@example.com"
NIVED_PASSWORD = "test123"

puts "Seeding #{NIVED_EMAIL}..."

user = User.find_or_initialize_by(email: NIVED_EMAIL)
user.assign_attributes(
  password: NIVED_PASSWORD,
  password_confirmation: NIVED_PASSWORD,
  first_name: "Nived",
  last_name: "Vengilat",
  username: "nived",
  time_zone: "America/Mexico_City",
  locale: "es",
  brand_hue: 25,
  guest: false,
  health_modules: { "sleep" => true, "cardio_safety" => true, "med_labs" => true, "dermatitis" => true, "nutrition" => true }
)
user.save!

puts "  ↳ User id=#{user.id}"

# === Wipe & rebuild the personal corpus ===
HabitCompletion.where(habit_id: user.habits.select(:id)).delete_all
user.habits.destroy_all
user.medications.destroy_all
user.lab_panels.destroy_all
user.biometric_metrics.destroy_all
user.agenda_items.destroy_all

# === Habits — the day plan ===
h = ->(name, time, dur, cat, hue, opts = {}) {
  hour, min = time.split(":").map(&:to_i)
  user.habits.create!({
    name: name,
    scheduled_at_minute: hour * 60 + min,
    duration_minutes: dur,
    category: cat,
    color_hue: hue,
    frequency_type: "daily",
    target_value: 1.0,
    unit: "times",
    position: user.habits.count
  }.merge(opts))
}

# La Mañana
h.call("Despertar sin pantallas", "06:45", 15, "mind",     220, description: "Prohibido revisar celular, correo del trabajo o código de Vittio.")
h.call("Pesaje matinal",          "06:50", 5,  "general", 280, unit: "kg",  target_value: 86.0, description: "Vacía la vejiga. En ropa interior. Es solo un dato.")
h.call("Hidratación 500 ml",      "06:55", 5,  "nutrition", 200, unit: "ml", target_value: 500.0, description: "Vaso grande de agua. Acompaña la dosis matinal.")
h.call("Caminata con Blite (Zona 2)", "07:10", 30, "movement", 25, description: "Ritmo constante, sin picos. Oxigena y suma pasos sin exigirle al corazón.")
h.call("Ducha y café negro",      "07:40", 80, "general", 35,  description: "Solo agua, té o café sin azúcar ni leche. Cero calorías.")

# El Día
h.call("Iniciar Home Office",     "09:00", 15, "mind",     220, description: "Termo de 1 L en el escritorio. Tómatelo antes de la primera comida.")
h.call("Walking Pad",             "11:00", 45, "movement", 120, description: "Caminadora de escritorio durante correos y juntas sin cámara.")
h.call("Comida 1 (rompe ayuno)",  "13:00", 30, "nutrition", 60,  description: "Prioriza proteína y grasas. Ensalada con pollo o tacos de carne asada con pico y aguacate.")
h.call("Creatina 5 g",            "13:00", 1,  "medical",  320, unit: "g",  target_value: 5.0, description: "Mezcla con el agua de la comida.")
h.call("Segundo litro de agua",   "13:45", 5,  "nutrition", 200, unit: "L", target_value: 1.0, description: "Llena el termo otra vez.")
h.call("Cerrar laptop del trabajo", "17:00", 5, "mind",   220, description: "Sin este límite, el día se vuelve una masa amorfa de estrés.")

# La Tarde
h.call("Entrenamiento de fuerza (sin Valsalva)", "17:15", 45, "movement", 0,
       frequency_type: "weekly_days", recurrence_days: [1, 3, 5],
       description: "Mancuernas, kettlebells o ligas. Exhala al levantar — la maniobra de Valsalva sube la presión intraocular.")
h.call("Whey Protein con agua",   "18:00", 5,  "nutrition", 60, unit: "g", target_value: 30.0,
       frequency_type: "weekly_days", recurrence_days: [1, 3, 5],
       description: "Ventana anabólica inmediata post-entrenamiento.")

# La Noche
h.call("Deep Work — Vittio",      "18:30", 120, "mind",    220, description: "Bloque de máxima concentración. Cerebro oxigenado, sin estrés laboral.")
h.call("Comida 2 (cena ligera)",  "20:30", 30, "nutrition", 60, description: "Proteína ligera. Sashimi, salmón o pollo con vegetales. Cero carbohidratos pesados.")
h.call("Magnesio",                "21:30", 1,  "medical",  300, unit: "mg", target_value: 400.0, description: "Relaja el sistema nervioso, controla la presión nocturna, mejora el sueño.")
h.call("Apagón digital",          "22:00", 30, "mind",     220, description: "Cierra el código. Deja el celular lejos de la cama.")
h.call("Dormir 7.5 h",            "22:30", 30, "sleep",    200, unit: "hours", target_value: 7.5, description: "Mínimo 7.5 horas para recuperación real.")

puts "  ↳ #{user.habits.count} habits"

# === Medications ===
[
  { name: "Aprovasc",     dose: "150/5 mg",  schedule_minutes: [6 * 60 + 55], notes: "Irbesartán + amlodipino. Hipertensión." },
  { name: "Cibinqo",      dose: "100 mg",    schedule_minutes: [6 * 60 + 55], notes: "Abrocitinib. Dermatitis atópica. Vigilar lípidos + hematología." },
  { name: "Mio-inositol", dose: "2 g",       schedule_minutes: [6 * 60 + 55], notes: "Sensibilidad a la insulina." },
  { name: "Creatina",     dose: "5 g",       schedule_minutes: [13 * 60],     notes: "Mezcla con agua." },
  { name: "Whey Protein", dose: "30 g",      schedule_minutes: [18 * 60],     notes: "Ventana anabólica post-fuerza." },
  { name: "Magnesio",     dose: "400 mg",    schedule_minutes: [21 * 60 + 30], notes: "Bisglicinato preferido." }
].each { |attrs| user.medications.create!(attrs) }

puts "  ↳ #{user.medications.count} medications"

# === Lab panels — Cibinqo cadence (containers + results) ===
today = Date.current

panels_spec = [
  { name: "Biometría hemática",  notes: "Vigilancia Cibinqo. Cadencia trimestral.", due_offset: 3.months },
  { name: "Perfil de lípidos",   notes: "Vigilancia Cibinqo. Cadencia semestral.",  due_offset: 6.months },
  { name: "Función renal",       notes: "Filtrado glomerular + creatinina.",        due_offset: 6.months },
  { name: "Función hepática",    notes: "Transaminasas + bilirrubina.",             due_offset: 6.months },
  { name: "Perfil metabólico",   notes: "Glucosa, insulina, HbA1c.",                due_offset: 12.months }
]

panels_spec.each_with_index do |spec, i|
  panel = user.lab_panels.create!(name: spec[:name], notes: spec[:notes], position: i)
  # Un resultado pendiente futuro
  panel.lab_results.create!(due_on: today + spec[:due_offset])
  # Un resultado pasado (completado) para mostrar histórico
  panel.lab_results.create!(
    due_on: today - spec[:due_offset],
    completed_on: today - spec[:due_offset] + 3.days,
    result_summary: "Resultados dentro de rango. Sin observaciones."
  )
end

puts "  ↳ #{user.lab_panels.count} lab panels (#{LabResult.joins(:lab_panel).where(lab_panels: { user_id: user.id }).count} results)"

# === Biometric metrics + entries (from your Health Report) ===
baseline = today - 1.day

metric_specs = [
  { name: "Peso",                unit: "kg",      category: "Antropometría", values: [88.2, 87.8, 87.4, 87.1, 87.0] },
  { name: "Frec. cardiaca reposo", unit: "bpm",   category: "Cardio",        values: [64, 63, 62, 61, 61] },
  { name: "Sueño",               unit: "h",       category: "Recuperación",  values: [5.5, 5.8, 6.2, 6.0, 6.0] },
  { name: "HRV",                 unit: "ms",      category: "Recuperación",  values: [32.1, 34.8, 36.2, 37.5, 38.7] },
  { name: "Minutos aeróbicos",   unit: "min",     category: "Cardio",        values: [12, 18, 22, 24, 26] },
  { name: "% grasa corporal",    unit: "%",       category: "Antropometría", values: [29.1, 28.6, 28.0, 27.8, 27.5] }
]

metric_specs.each_with_index do |spec, i|
  metric = user.biometric_metrics.create!(
    name: spec[:name], unit: spec[:unit], category: spec[:category], position: i
  )
  # Sembrar 5 valores en los últimos 28 días
  spec[:values].each_with_index do |v, day_back|
    metric.biometric_entries.create!(
      user: user,
      value: v,
      recorded_on: baseline - (4 - day_back) * 7,
      source: "manual"
    )
  end
end

puts "  ↳ #{user.biometric_metrics.count} biometric metrics (#{user.biometric_entries.count} entries)"

puts "Done. Sign in: #{NIVED_EMAIL} / #{NIVED_PASSWORD}"
