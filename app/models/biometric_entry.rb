class BiometricEntry < ApplicationRecord
  belongs_to :user
  belongs_to :biometric_metric

  SOURCES = %w[manual whoop healthkit habit].freeze

  validates :source, inclusion: { in: SOURCES }
  validates :recorded_on, presence: true
  validates :value, presence: true, numericality: true
end
