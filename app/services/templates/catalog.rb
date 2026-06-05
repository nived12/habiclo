module Templates
  module Catalog
    ALL = {
      "welcome" => {
        category: "demo",
        public: false,
        icon: "sparkles",
        habits: [
          { i18n: "hydration",   frequency_type: "daily", category: "nutrition", scheduled_at_minute: 540,
target_value: 2,  unit: "L",     color_hue: 200, duration_minutes: 5 },
          { i18n: "walk",        frequency_type: "daily", category: "movement",  scheduled_at_minute: 1080,
target_value: 30, unit: "min",   color_hue: 140, duration_minutes: 30 },
          { i18n: "read",        frequency_type: "daily", category: "mind",      scheduled_at_minute: 1320,
target_value: 20, unit: "min",   color_hue: 40,  duration_minutes: 20 },
          { i18n: "weigh_in",    frequency_type: "daily", category: "medical",   scheduled_at_minute: 420,
target_value: 1,  unit: "times", color_hue: 280, duration_minutes: 5 },
          { i18n: "stretch",     frequency_type: "x_per_week", category: "mind", weekly_target: 3, target_value: 10,
unit: "min", color_hue: 320, duration_minutes: 10 }
        ],
        medications: [
          { i18n: "vitamin_d", schedule_minutes: [ 480 ] }
        ],
        biometric_metrics: [
          { i18n: "weight", unit: "kg", category_i18n: "body" },
          { i18n: "sleep",  unit: "h",  category_i18n: "recovery" }
        ]
      },

      "wellness_basics" => {
        category: "health",
        public: true,
        icon: "leaf",
        habits: [
          { i18n: "hydration",  frequency_type: "daily", category: "nutrition", scheduled_at_minute: 540,
target_value: 2,  unit: "L",     color_hue: 200, duration_minutes: 5 },
          { i18n: "walk",       frequency_type: "daily", category: "movement",  scheduled_at_minute: 1080,
target_value: 30, unit: "min",   color_hue: 140, duration_minutes: 30 },
          { i18n: "sleep_7h",   frequency_type: "daily", category: "sleep",     scheduled_at_minute: 1380,
target_value: 7,  unit: "h",     color_hue: 240, duration_minutes: 420 },
          { i18n: "breakfast",  frequency_type: "daily", category: "nutrition", scheduled_at_minute: 480,
target_value: 1,  unit: "times", color_hue: 30,  duration_minutes: 20 }
        ],
        medications: [],
        biometric_metrics: [
          { i18n: "weight", unit: "kg", category_i18n: "body" }
        ]
      },

      "strength" => {
        category: "movement",
        public: true,
        icon: "fire",
        habits: [
          { i18n: "lift",     frequency_type: "weekly_days", category: "movement",  recurrence_days: [ 1, 3, 5 ],
scheduled_at_minute: 1080, target_value: 60, unit: "min", color_hue: 0,   duration_minutes: 60 },
          { i18n: "protein",  frequency_type: "daily",       category: "nutrition", scheduled_at_minute: 780,
target_value: 130, unit: "g",  color_hue: 10,  duration_minutes: 5 },
          { i18n: "creatine", frequency_type: "daily",       category: "nutrition", scheduled_at_minute: 480,
target_value: 5,   unit: "g",  color_hue: 60,  duration_minutes: 1 },
          { i18n: "mobility", frequency_type: "x_per_week",  category: "movement",  weekly_target: 3,
target_value: 15,  unit: "min", color_hue: 150, duration_minutes: 15 },
          { i18n: "rest_day", frequency_type: "weekly_days", category: "sleep",     recurrence_days: [ 7 ],
target_value: 1,   unit: "times", color_hue: 230, duration_minutes: 1 }
        ],
        medications: [],
        biometric_metrics: [
          { i18n: "weight",   unit: "kg", category_i18n: "body" },
          { i18n: "body_fat", unit: "%",  category_i18n: "body" }
        ]
      },

      "personal_growth" => {
        category: "mind",
        public: true,
        icon: "book-open",
        habits: [
          { i18n: "read",      frequency_type: "daily", category: "mind", scheduled_at_minute: 1320, target_value: 30,
unit: "min", color_hue: 40,  duration_minutes: 30 },
          { i18n: "journal",   frequency_type: "daily", category: "mind", scheduled_at_minute: 1380, target_value: 1,
unit: "times", color_hue: 290, duration_minutes: 10 },
          { i18n: "meditate",  frequency_type: "daily", category: "mind", scheduled_at_minute: 420,  target_value: 10,
unit: "min", color_hue: 260, duration_minutes: 10 },
          { i18n: "deep_work", frequency_type: "weekly_days", category: "mind", recurrence_days: [ 1, 2, 3, 4, 5 ],
scheduled_at_minute: 600, target_value: 90, unit: "min", color_hue: 220, duration_minutes: 90 },
          { i18n: "no_phone",  frequency_type: "daily", category: "mind", scheduled_at_minute: 1320, target_value: 1,
unit: "times", color_hue: 0, duration_minutes: 60 }
        ],
        medications: [],
        biometric_metrics: []
      },

      "sleep_recovery" => {
        category: "health",
        public: true,
        icon: "moon",
        habits: [
          { i18n: "bedtime",       frequency_type: "daily", category: "sleep",    scheduled_at_minute: 1350,
target_value: 1,  unit: "times", color_hue: 240, duration_minutes: 5 },
          { i18n: "no_screens",    frequency_type: "daily", category: "sleep",    scheduled_at_minute: 1290,
target_value: 60, unit: "min",   color_hue: 250, duration_minutes: 60 },
          { i18n: "magnesium",     frequency_type: "daily", category: "medical",  scheduled_at_minute: 1290,
target_value: 1,  unit: "times", color_hue: 200, duration_minutes: 1 },
          { i18n: "morning_light", frequency_type: "daily", category: "movement", scheduled_at_minute: 420,
target_value: 10, unit: "min",   color_hue: 50,  duration_minutes: 10 }
        ],
        medications: [],
        biometric_metrics: [
          { i18n: "sleep", unit: "h",  category_i18n: "recovery" },
          { i18n: "hrv",   unit: "ms", category_i18n: "recovery" }
        ]
      },

      "nutrition" => {
        category: "health",
        public: true,
        icon: "apple",
        habits: [
          { i18n: "vegetables", frequency_type: "daily", category: "nutrition", scheduled_at_minute: 780,
target_value: 3, unit_i18n: "servings", color_hue: 130, duration_minutes: 5 },
          { i18n: "hydration",  frequency_type: "daily", category: "nutrition", scheduled_at_minute: 540,
target_value: 2, unit: "L",         color_hue: 200, duration_minutes: 5 },
          { i18n: "no_sugar",   frequency_type: "daily", category: "nutrition", scheduled_at_minute: 1080,
target_value: 1, unit: "times",     color_hue: 350, duration_minutes: 1 },
          { i18n: "log_meals",  frequency_type: "daily", category: "nutrition", scheduled_at_minute: 1200,
target_value: 1, unit: "times",     color_hue: 30,  duration_minutes: 5 }
        ],
        medications: [],
        biometric_metrics: [
          { i18n: "weight", unit: "kg", category_i18n: "body" }
        ]
      },

      "med_adherence" => {
        category: "medical",
        public: true,
        icon: "pill",
        habits: [
          { i18n: "check_bp", frequency_type: "daily", category: "medical", scheduled_at_minute: 480, target_value: 1,
unit: "times", color_hue: 350, duration_minutes: 3 }
        ],
        medications: [
          { i18n: "morning_meds", schedule_minutes: [ 480 ] },
          { i18n: "evening_meds", schedule_minutes: [ 1260 ] }
        ],
        biometric_metrics: [
          { i18n: "blood_pressure", unit: "mmHg", category_i18n: "vitals" }
        ]
      }
    }.freeze

    def self.find(key)
      ALL[key.to_s] || raise(ArgumentError, "Unknown template: #{key.inspect}")
    end

    def self.public_keys
      ALL.select { |_, t| t[:public] }.keys
    end

    def self.public_templates
      public_keys.map { |k| [ k, ALL[k] ] }
    end

    def self.exists?(key)
      ALL.key?(key.to_s)
    end
  end
end
