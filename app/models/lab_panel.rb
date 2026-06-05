class LabPanel < ApplicationRecord
  belongs_to :user
  has_many :lab_results, -> { order(Arel.sql("COALESCE(completed_on, due_on) DESC, id DESC")) },
    dependent: :destroy

  validates :name, presence: true, length: { maximum: 120 }

  scope :ordered, -> { order(:position, :id) }

  def latest_result
    return nil if lab_results.empty?

    lab_results.loaded? ? lab_results.first : lab_results.first
  end

  def pending_result
    lab_results.detect { |r| r.completed_on.nil? } if lab_results.loaded?
  end

  def status_for_chip
    latest = latest_result
    return :empty if latest.nil?
    return :pending if latest.completed_on.nil?

    :completed
  end
end
