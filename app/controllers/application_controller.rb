class ApplicationController < ActionController::Base
  include GuestPipeline
  include ReturnTo
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :set_locale
  around_action :use_time_zone

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  private

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
    user = current_or_guest_user
    Time.use_zone(user&.time_zone.presence || tz_from_cookie || "UTC") { yield }
  end

  def tz_from_cookie
    iana = cookies[:tz_iana].to_s
    return if iana.blank?

    ActiveSupport::TimeZone.all.find { |z| z.tzinfo.name == iana }&.name
  end

  def forbidden
    respond_to do |format|
      format.html { redirect_to root_path, alert: I18n.t("errors.forbidden") }
      format.json { render json: { error: "forbidden" }, status: :forbidden }
    end
  end
end
