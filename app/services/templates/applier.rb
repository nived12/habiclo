module Templates
  class Applier < ApplicationService
    Result = Struct.new(:added, :skipped, keyword_init: true)

    def initialize(user, template_key, force: false, seed_history: nil)
      @user = user
      @template = Templates::Catalog.find(template_key)
      @key = template_key.to_s
      @force = force
      @seed_history = seed_history.nil? ? @key == "welcome" : seed_history
      @added = { habits: 0, medications: 0, biometric_metrics: 0 }
      @skipped = { habits: 0, medications: 0, biometric_metrics: 0 }
    end

    def call
      ActiveRecord::Base.transaction do
        new_habits  = create_habits
        create_medications
        new_metrics = create_biometric_metrics
        seed_history_for(new_habits, new_metrics) if @seed_history
        @user.update!(template_key: @key, template_applied_at: Time.current)
      end
      Result.new(added: @added, skipped: @skipped)
    end

    private

    def create_habits
      created = []
      @template[:habits].each_with_index do |spec, idx|
        name = habit_name(spec)
        if !@force && habit_exists?(name)
          @skipped[:habits] += 1
          next
        end
        habit = @user.habits.create!(
          name: name,
          description: habit_description(spec),
          frequency_type: spec[:frequency_type],
          category: spec[:category],
          color_hue: spec[:color_hue] || @user.brand_hue,
          target_value: spec[:target_value] || 1,
          unit: habit_unit(spec),
          scheduled_at_minute: spec[:scheduled_at_minute],
          duration_minutes: spec[:duration_minutes],
          recurrence_days: spec[:recurrence_days] || [],
          weekly_target: spec[:weekly_target],
          monthly_day: spec[:monthly_day],
          occurs_on: spec[:occurs_on],
          position: @user.habits.count + idx
        )
        @added[:habits] += 1
        created << [ habit, spec ]
      end
      created
    end

    def create_medications
      @template[:medications].each do |spec|
        name = med_name(spec)
        if !@force && med_exists?(name)
          @skipped[:medications] += 1
          next
        end
        @user.medications.create!(
          name: name,
          dose: med_dose(spec),
          schedule_minutes: spec[:schedule_minutes] || [],
          notes: med_notes(spec)
        )
        @added[:medications] += 1
      end
    end

    def create_biometric_metrics
      created = []
      @template[:biometric_metrics].each_with_index do |spec, idx|
        name = metric_name(spec)
        if !@force && metric_exists?(name)
          @skipped[:biometric_metrics] += 1
          next
        end
        metric = @user.biometric_metrics.create!(
          name: name,
          unit: spec[:unit],
          category: metric_category(spec),
          position: @user.biometric_metrics.count + idx
        )
        @added[:biometric_metrics] += 1
        created << [ metric, spec ]
      end
      created
    end

    def seed_history_for(habits, metrics)
      today = Date.current
      days = 7
      habits.each do |habit, spec|
        days.times do |i|
          date = today - (days - i).days
          next unless habit.scheduled_for?(date)
          next if rand < 0.25

          value = realistic_value(spec)
          habit.habit_completions.create!(
            completed_on: date,
            completed_at_minute: spec[:scheduled_at_minute],
            value: value
          )
        end
      end
      metrics.each do |metric, spec|
        base = baseline_for(spec[:i18n])
        drift = 0
        (1..days).each do |i|
          date = today - (days - i + 1).days
          drift += (rand - 0.5) * drift_step(spec[:i18n])
          value = (base + drift).round(2)
          metric.biometric_entries.create!(
            user: @user,
            recorded_on: date,
            value: value,
            source: "manual"
          )
        end
      end
    end

    def realistic_value(spec)
      target = spec[:target_value] || 1
      jitter = target * (0.6 + rand * 0.6)
      jitter.round(2)
    end

    def baseline_for(i18n_key)
      {
        "weight" => 75.0,
        "sleep" => 7.0,
        "hrv" => 55.0,
        "body_fat" => 22.0,
        "blood_pressure" => 120.0
      }.fetch(i18n_key.to_s, 1.0)
    end

    def drift_step(i18n_key)
      {
        "weight" => 0.3,
        "sleep" => 0.6,
        "hrv" => 4.0,
        "body_fat" => 0.2,
        "blood_pressure" => 3.0
      }.fetch(i18n_key.to_s, 0.1)
    end

    def habit_name(spec)
      t(
        "templates.#{@key}.habits.#{spec[:i18n]}.name",
        default: t("templates.shared.habits.#{spec[:i18n]}.name", default: spec[:i18n].to_s.titleize)
      )
    end

    def habit_description(spec)
      t(
        "templates.#{@key}.habits.#{spec[:i18n]}.description",
        default: t("templates.shared.habits.#{spec[:i18n]}.description", default: "")
      )
    end

    def med_name(spec)
      t(
        "templates.#{@key}.medications.#{spec[:i18n]}.name",
        default: t("templates.shared.medications.#{spec[:i18n]}.name", default: spec[:i18n].to_s.titleize)
      )
    end

    def med_dose(spec)
      t(
        "templates.#{@key}.medications.#{spec[:i18n]}.dose",
        default: t("templates.shared.medications.#{spec[:i18n]}.dose", default: "")
      )
    end

    def habit_unit(spec)
      return spec[:unit] if spec[:unit].present?
      return "times" if spec[:unit_i18n].blank?

      t(
        "templates.shared.units.#{spec[:unit_i18n]}",
        default: spec[:unit_i18n].to_s
      )
    end

    def med_notes(spec)
      t(
        "templates.#{@key}.medications.#{spec[:i18n]}.notes",
        default: t("templates.shared.medications.#{spec[:i18n]}.notes", default: "")
      )
    end

    def metric_name(spec)
      t("templates.shared.metrics.#{spec[:i18n]}.name", default: spec[:i18n].to_s.titleize)
    end

    def metric_category(spec)
      key = spec[:category_i18n]
      return if key.blank?

      t("templates.shared.categories.#{key}", default: key.to_s.titleize)
    end

    def habit_exists?(name)
      @user.habits.where("LOWER(name) = ?", name.downcase).exists?
    end

    def med_exists?(name)
      @user.medications.where("LOWER(name) = ?", name.downcase).exists?
    end

    def metric_exists?(name)
      @user.biometric_metrics.where("LOWER(name) = ?", name.downcase).exists?
    end

    def t(key, **opts)
      I18n.t(key, locale: @user.locale, **opts)
    end
  end
end
