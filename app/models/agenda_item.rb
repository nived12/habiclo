class AgendaItem < ApplicationRecord
  belongs_to :user
  belongs_to :linked, polymorphic: true, optional: true

  KINDS = %w[event appointment reminder].freeze

  validates :title, presence: true
  validates :occurs_on, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :scheduled_at_minute, numericality: { in: 0..1439 }, allow_nil: true
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true
end
