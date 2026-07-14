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
      if expired?(existing)
        existing.destroy
        cookies.delete(GUEST_COOKIE)
      else
        slide_ttl(existing)
        return existing
      end
    end
    return transient_guest if skip_guest_persistence?

    guest = Users::GuestCreator.call(
      time_zone: resolved_time_zone,
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

  # In-memory guest for bots / non-page requests: pages still render (empty state),
  # but nothing is written to the DB. This is what stops crawlers — which send no
  # cookie, so every request would otherwise mint a fresh seeded guest — from
  # refilling the volume.
  def transient_guest
    @transient_guest ||= User.new(guest: true, time_zone: resolved_time_zone, locale: I18n.locale.to_s)
  end

  # Persist a guest only for real human HTML navigations and writes. Skip bots (any
  # method) and non-HTML GETs (assets, JSON, healthchecks). Writes (POST / turbo_stream)
  # still persist because request.get? is false for them.
  def skip_guest_persistence?
    request_is_bot? || (request.get? && !request.format.html?)
  end

  def request_is_bot?
    return @request_is_bot if defined?(@request_is_bot)

    ua = request.user_agent
    @request_is_bot = ua.blank? || DeviceDetector.new(ua).bot?
  end

  def expired?(guest)
    guest.data_resets_at.present? && guest.data_resets_at < Time.current
  end

  # Slide the 24h window forward on real activity, but only write when it would
  # meaningfully extend it — avoids a DB write on every pageview.
  def slide_ttl(guest)
    return if guest.data_resets_at.present? && guest.data_resets_at > Users::GuestResetter::TTL.from_now - 1.hour

    guest.update_column(:data_resets_at, Users::GuestResetter::TTL.from_now)
  end

  def resolved_time_zone
    iana = cookies[:tz_iana].to_s
    if iana.present?
      rails_name = ActiveSupport::TimeZone.all.find { |z| z.tzinfo.name == iana }&.name
      return rails_name if rails_name
    end
    cookies[:time_zone].presence || "UTC"
  end

  def load_guest_from_cookie
    id = cookies.encrypted[GUEST_COOKIE]
    return nil if id.blank?

    User.where(guest: true).find_by(id: id)
  end
end
