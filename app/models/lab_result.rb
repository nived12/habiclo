class LabResult < ApplicationRecord
  belongs_to :lab_panel

  scope :pending, -> { where(completed_on: nil) }
  scope :completed, -> { where.not(completed_on: nil) }

  def pending?
    completed_on.nil?
  end

  def display_date
    completed_on || due_on
  end
end
