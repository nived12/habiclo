class HabitCompletion < ApplicationRecord
  belongs_to :habit
  has_one :user, through: :habit

  validates :completed_on, presence: true
  validates :habit_id, uniqueness: { scope: :completed_on }
  validates :value, numericality: { greater_than_or_equal_to: 0 }
  validates :completed_at_minute, numericality: { in: 0..1439 }, allow_nil: true
end
