module HealthPageSetup
  extend ActiveSupport::Concern

  CANONICAL_TABS = %w[medications labs biometrics settings].freeze
  TOGGLEABLE_TABS = %w[medications labs biometrics].freeze

  private

  def setup_health_page(tab:, medication: nil, lab_panel: nil, biometric_metric: nil)
    @user = current_or_guest_user
    @visible_tabs = visible_tabs_for(@user)
    requested = tab.presence_in(CANONICAL_TABS)
    visible = requested && (@visible_tabs.include?(requested) || requested == "settings")
    @tab = visible ? requested : @visible_tabs.first
    load_health_tab_data(medication: medication, lab_panel: lab_panel, biometric_metric: biometric_metric)
  end

  def visible_tabs_for(user)
    tabs = TOGGLEABLE_TABS.select { |t| user.tab_visible?(t) }
    tabs << "settings"
    tabs
  end

  def load_health_tab_data(medication: nil, lab_panel: nil, biometric_metric: nil)
    case @tab
    when "medications"
      @medications = @user.medications.order(:name)
      @medication  = medication || @user.medications.new
    when "labs"
      @lab_panels = @user.lab_panels.includes(:lab_results).order(:position, :id)
      @lab_panel  = lab_panel || @user.lab_panels.new
    when "biometrics"
      @biometric_metrics = @user.biometric_metrics.includes(:biometric_entries).order(:position, :id)
      @biometric_metric = biometric_metric || @user.biometric_metrics.new
    end
  end

  def health_tab_locals
    case @tab
    when "medications" then { medications: @medications, medication: @medication }
    when "labs"        then { lab_panels: @lab_panels, lab_panel: @lab_panel }
    when "biometrics"  then { metrics: @biometric_metrics, metric: @biometric_metric }
    when "settings"    then { user: @user }
    else {}
    end
  end
end
