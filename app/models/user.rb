class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :habits, dependent: :destroy
  has_many :habit_completions, through: :habits
  has_many :agenda_items, dependent: :destroy
  has_many :biometric_entries, dependent: :destroy
  has_many :medications, dependent: :destroy
  has_many :lab_panels, dependent: :destroy
  has_many :biometric_metrics, dependent: :destroy

  before_validation :ensure_jti

  validates :first_name, :last_name, presence: true, on: :create, unless: :guest?
  validate :password_has_number

  HEALTH_MODULES = %w[medications labs biometrics].freeze

  def section_enabled?(name)
    tab_visible?(name)
  end

  def guest?
    guest == true
  end

  def display_name
    return I18n.t("nav.guest_name", default: "Guest") if guest?

    username.presence || first_name.presence || email.split("@").first
  end

  def days_until_reset
    return if data_resets_at.blank?

    seconds = data_resets_at - Time.current
    return 0 if seconds <= 0

    (seconds / 1.day).ceil
  end

  def hours_until_reset
    return if data_resets_at.blank?

    seconds = data_resets_at - Time.current
    return 0 if seconds <= 0

    (seconds / 1.hour).ceil
  end

  def help_seen?
    help_seen_at.present?
  end

  def mark_help_seen!
    update!(help_seen_at: Time.current) unless help_seen?
  end

  def health_module_enabled?(name)
    health_modules[name.to_s] == true
  end

  def tab_visible?(tab)
    tabs_visibility.fetch(tab.to_s, true)
  end

  private

  def ensure_jti
    self.jti ||= SecureRandom.uuid
  end

  def password_has_number
    return if password.blank?
    return if password.match?(/\d/)

    errors.add(:password, :missing_number)
  end
end
