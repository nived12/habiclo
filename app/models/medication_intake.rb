class MedicationIntake < ApplicationRecord
  belongs_to :medication

  validates :taken_on, presence: true
end
