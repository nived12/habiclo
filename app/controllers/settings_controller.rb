class SettingsController < ApplicationController
  def show
    @user = current_or_guest_user
  end

  def update
    user = current_or_guest_user
    locale_changing = settings_params[:locale].present? && settings_params[:locale] != user.locale
    if user.update(settings_params)
      respond_to do |format|
        format.turbo_stream do
          locale_changing ? redirect_to(settings_path) : head(:ok)
        end
        format.html { redirect_to settings_path, notice: t("settings.saved") }
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    raw = params.require(:user).permit(:brand_hue, :time_zone, :locale,
                                       health_modules: {}, tabs_visibility: {})
    bool_caster = ActiveModel::Type::Boolean.new
    %i[health_modules tabs_visibility].each do |key|
      next unless raw[key].is_a?(ActionController::Parameters)
      raw[key] = raw[key].transform_values { |v| bool_caster.cast(v) }
    end
    raw
  end
end
