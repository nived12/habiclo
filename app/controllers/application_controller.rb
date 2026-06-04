class ApplicationController < ActionController::Base
  include GuestPipeline
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :set_locale
  around_action :use_time_zone

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  private

  def set_locale
    user = user_signed_in? ? current_user : load_guest_for_locale
    I18n.locale = user&.locale&.to_sym || params[:locale]&.to_sym || I18n.default_locale
  end

  def load_guest_for_locale
    return nil unless cookies.encrypted[GuestPipeline::GUEST_COOKIE].present?
    User.where(guest: true).find_by(id: cookies.encrypted[GuestPipeline::GUEST_COOKIE])
  end

  def use_time_zone
    user = current_or_guest_user
    Time.use_zone(user&.time_zone || "America/Mexico_City") { yield }
  end

  def forbidden
    respond_to do |format|
      format.html { redirect_to root_path, alert: I18n.t("errors.forbidden") }
      format.json { render json: { error: "forbidden" }, status: :forbidden }
    end
  end
end
