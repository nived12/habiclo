class Habit < ApplicationRecord
  belongs_to :user
  has_many :habit_completions, dependent: :destroy

  FREQUENCY_TYPES = %w[daily weekly_days x_per_week monthly once].freeze
  CATEGORIES = %w[movement nutrition sleep medical mind general].freeze

  validates :name, presence: true
  validates :frequency_type, inclusion: { in: FREQUENCY_TYPES }
  validates :category, inclusion: { in: CATEGORIES }
  validates :color_hue, numericality: { in: 0..360 }
  validates :target_value, numericality: { greater_than: 0 }
  validates :scheduled_at_minute, numericality: { in: 0..1439 }, allow_nil: true
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true
  validate :time_slot_not_overloaded, if: -> { scheduled_at_minute.present? }

  MAX_HABITS_PER_SLOT = 3

  scope :ordered, -> { order(:position, :id) }
  scope :on_dashboard, -> { where(hidden_from_dashboard: false) }

  def scheduled?
    scheduled_at_minute.present?
  end

  def scheduled_for?(local_date)
    case frequency_type
    when "daily"       then true
    when "weekly_days" then recurrence_days.include?(local_date.cwday)
    when "x_per_week"  then true
    when "monthly"     then local_date.day == (monthly_day || 1)
    when "once"        then occurs_on == local_date
    else false
    end
  end

  private

  def time_slot_not_overloaded
    # Stop counting once we hit the limit — no point scanning the full set.
    count = user.habits
                .where(scheduled_at_minute: scheduled_at_minute)
                .where.not(id: id)
                .limit(MAX_HABITS_PER_SLOT)
                .count
    if count >= MAX_HABITS_PER_SLOT
      errors.add(:scheduled_at_minute, :slot_full, count: MAX_HABITS_PER_SLOT)
    end
  end

  public

  def completed_on?(local_date)
    if habit_completions.loaded?
      habit_completions.any? { |c| c.completed_on == local_date }
    else
      habit_completions.exists?(completed_on: local_date)
    end
  end
end
