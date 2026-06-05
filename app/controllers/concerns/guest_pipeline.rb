module GuestPipeline
  extend ActiveSupport::Concern

  GUEST_COOKIE = :habiclo_guest_id

  included do
    helper_method :current_or_guest_user, :current_user_for_view
  end

  def current_or_guest_user
    return current_user if user_signed_in?

    @current_guest ||= load_or_create_guest
  end

  alias_method :current_user_for_view, :current_or_guest_user

  def convert_guest!(target_user)
    guest = load_guest_from_cookie
    return unless guest&.guest?
    return if guest.id == target_user.id

    result = Users::GuestConverter.call(guest: guest, target: target_user)
    cookies.delete(GUEST_COOKIE)
    result
  end

  private

  def load_or_create_guest
    if (existing = load_guest_from_cookie)
      reset_if_expired(existing)
      return existing
    end
    guest = Users::GuestCreator.call(
      time_zone: cookies[:time_zone].presence || "America/Mexico_City",
      locale: I18n.locale.to_s
    )
    cookies.encrypted[GUEST_COOKIE] = {
      value: guest.id,
      expires: 60.days.from_now,
      httponly: true,
      same_site: :lax
    }
    guest
  end

  def reset_if_expired(guest)
    return unless guest.data_resets_at.present? && guest.data_resets_at < Time.current

    Users::GuestResetter.call(guest)
    guest.reload
  end

  def load_guest_from_cookie
    id = cookies.encrypted[GUEST_COOKIE]
    return nil if id.blank?

    User.where(guest: true).find_by(id: id)
  end
end
