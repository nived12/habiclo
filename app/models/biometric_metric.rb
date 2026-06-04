class BiometricMetric < ApplicationRecord
  belongs_to :user
  has_many :biometric_entries, -> { order(recorded_on: :desc, id: :desc) }, dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 },
                   uniqueness: { scope: :user_id, case_sensitive: false }
  validates :unit, length: { maximum: 24 }, allow_blank: true
  validates :category, length: { maximum: 40 }, allow_blank: true

  scope :ordered, -> { order(:position, :id) }

  def latest_entry
    @latest_entry ||= biometric_entries.loaded? ? biometric_entries.first : biometric_entries.first
  end

  def previous_entry
    return @previous_entry if defined?(@previous_entry)
    @previous_entry = if biometric_entries.loaded?
      biometric_entries[1]
    else
      biometric_entries.offset(1).first
    end
  end

  def delta
    return nil unless latest_entry && previous_entry
    latest_entry.value - previous_entry.value
  end

  def entries_count
    biometric_entries.loaded? ? biometric_entries.size : biometric_entries.count
  end
end
