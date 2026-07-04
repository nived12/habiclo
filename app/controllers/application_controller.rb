class ApplicationController < ActionController::Base
  include GuestPipeline
  include ReturnTo
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  around_action :use_time_zone
  after_action :track_page_view

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  # Infra/non-content paths we never want in analytics. /up especially: it renders
  # a 200 HTML page, so healthchecks/uptime monitors would otherwise log a $view +
  # a new (cookieless) visit row on every ping — this once filled the DB volume.
  SKIP_TRACK_PREFIXES = %w[/admin /up /rails /cable /assets].freeze

  private

  def track_page_view
    return unless request.get? && request.format.html? && response.successful?
    return if SKIP_TRACK_PREFIXES.any? { |prefix| request.path.start_with?(prefix) }

    ahoy.track "$view", path: request.path, signed_in: user_signed_in?, visitor: visitor_fingerprint
  end

  # Plausible/Fathom-style daily-rotating fingerprint: lets us count daily unique
  # visitors without a cookie (no consent-banner obligation). The salt rotates each
  # day, so a fingerprint is only comparable within the same day, and the raw IP is
  # never stored (Ahoy.mask_ips = true).
  def visitor_fingerprint
    day_salt = OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, Date.current.to_s)
    OpenSSL::HMAC.hexdigest("SHA256", day_salt, "#{request.remote_ip}#{request.user_agent}")[0, 16]
  end

  def set_locale
    user = user_signed_in? ? current_user : load_guest_for_locale
    I18n.locale = user&.locale&.to_sym || params[:locale]&.to_sym || locale_from_browser || I18n.default_locale
  end

  def load_guest_for_locale
    return nil unless cookies.encrypted[GuestPipeline::GUEST_COOKIE].present?

    User.where(guest: true).find_by(id: cookies.encrypted[GuestPipeline::GUEST_COOKIE])
  end

  def locale_from_browser
    header = request.env["HTTP_ACCEPT_LANGUAGE"]
    return if header.blank?

    available = I18n.available_locales.map(&:to_s)
    parsed = header.split(",").map do |part|
      tag, q = part.strip.split(";q=")
      [ tag.to_s.downcase.split("-").first, (q || "1").to_f ]
    end
    parsed.sort_by { |_, q| -q }.each do |tag, _|
      return tag.to_sym if available.include?(tag)
    end
    nil
  end

  def use_time_zone
    # Never create a guest just to resolve a timezone (this ran on every request).
    tz = user_signed_in? ? current_user.time_zone : (tz_from_cookie || "UTC")
    Time.use_zone(tz.presence || "UTC") { yield }
  end

  def tz_from_cookie
    iana = cookies[:tz_iana].to_s
    return if iana.blank?

    ActiveSupport::TimeZone.all.find { |z| z.tzinfo.name == iana }&.name
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :first_name, :last_name])
  end

  def forbidden
    respond_to do |format|
      format.html { redirect_to root_path, alert: I18n.t("errors.forbidden") }
      format.json { render json: { error: "forbidden" }, status: :forbidden }
    end
  end
end
