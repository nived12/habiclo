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

  HEALTH_MODULES = %w[sleep cardio_safety med_labs dermatitis nutrition].freeze

  def guest?
    guest == true
  end

  def display_name
    return "Invitado" if guest?
    username.presence || email.split("@").first
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
end
