class HealthController < ApplicationController
  CANONICAL_TABS = %w[medicamentos labs biometria configuracion].freeze
  TOGGLEABLE_TABS = %w[medicamentos labs biometria].freeze

  def show
    requested = params[:tab].presence_in(CANONICAL_TABS)
    @user = current_or_guest_user
    @visible_tabs = visible_tabs_for(@user)
    @tab = requested && (@visible_tabs.include?(requested) || requested == "configuracion") ? requested : @visible_tabs.first
    load_tab_data
  end

  def tab
    requested = params[:tab].presence_in(CANONICAL_TABS)
    @user = current_or_guest_user
    @visible_tabs = visible_tabs_for(@user)
    @tab = requested && (@visible_tabs.include?(requested) || requested == "configuracion") ? requested : @visible_tabs.first
    load_tab_data
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("health_tab", partial: "health/#{@tab}", locals: tab_locals) }
      format.html { render :show }
    end
  end

  private

  def visible_tabs_for(user)
    tabs = TOGGLEABLE_TABS.select { |t| user.tab_visible?(t) }
    tabs << "configuracion"
    tabs
  end

  def load_tab_data
    case @tab
    when "medicamentos"
      @medications = @user.medications.order(:name)
      @medication  = @user.medications.new
    when "labs"
      @lab_panels = @user.lab_panels.includes(:lab_results).order(:position, :id)
      @lab_panel  = @user.lab_panels.new
    when "biometria"
      @biometric_metrics = @user.biometric_metrics
                                .includes(:biometric_entries)
                                .order(:position, :id)
      @biometric_metric = @user.biometric_metrics.new
    when "configuracion"
      # nothing to preload — partial reads from current_user
    end
  end

  def tab_locals
    case @tab
    when "medicamentos" then { medications: @medications, medication: @medication }
    when "labs"         then { lab_panels: @lab_panels, lab_panel: @lab_panel }
    when "biometria"    then { metrics: @biometric_metrics, metric: @biometric_metric }
    when "configuracion" then { user: @user }
    else {}
    end
  end
end
