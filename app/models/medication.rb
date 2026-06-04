class Medication < ApplicationRecord
  belongs_to :user
  has_many :medication_intakes, dependent: :destroy

  validates :name, presence: true

  def taken_on?(date, minute = nil)
    if medication_intakes.loaded?
      medication_intakes.any? { |i| i.taken_on == date && (minute.nil? || i.scheduled_minute == minute) }
    elsif minute
      medication_intakes.exists?(taken_on: date, scheduled_minute: minute)
    else
      medication_intakes.exists?(taken_on: date)
    end
  end

  def toggle_intake!(date, minute = nil)
    scope = medication_intakes.where(taken_on: date, scheduled_minute: minute)
    if scope.exists?
      scope.destroy_all
      false
    else
      medication_intakes.create!(taken_on: date, scheduled_minute: minute)
      true
    end
  end
end
