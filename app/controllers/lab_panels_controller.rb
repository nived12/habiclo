class LabPanelsController < ApplicationController
  before_action :set_panel, only: [:edit, :update, :destroy]

  def index
    redirect_to health_path(tab: "labs")
  end

  def new
    @lab_panel = current_or_guest_user.lab_panels.new
  end

  def create
    @lab_panel = current_or_guest_user.lab_panels.new(panel_params)
    @lab_panel.position = current_or_guest_user.lab_panels.count
    if @lab_panel.save
      respond_to do |format|
        format.turbo_stream do
          panels = current_or_guest_user.lab_panels.includes(:lab_results).ordered
          render turbo_stream: [
            turbo_stream.update("health_tab",
              partial: "health/labs",
              locals: { lab_panels: panels, lab_panel: current_or_guest_user.lab_panels.new }),
            turbo_stream.update("health_modal", "")
          ]
        end
        format.html { redirect_to health_path(tab: "labs") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("health_modal",
            partial: "lab_panels/form",
            locals: { lab_panel: @lab_panel })
        end
        format.html { redirect_to health_path(tab: "labs"), alert: @lab_panel.errors.full_messages.to_sentence }
      end
    end
  end

  def edit
    @tab = "labs"
    @lab_panels = current_or_guest_user.lab_panels.includes(:lab_results).ordered
    render "health/show"
  end

  def update
    if @panel.update(panel_params)
      redirect_to health_path(tab: "labs")
    else
      redirect_to health_path(tab: "labs"), alert: @panel.errors.full_messages.to_sentence
    end
  end

  def destroy
    @panel.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_to health_path(tab: "labs") }
    end
  end

  private

  def set_panel
    @panel = current_or_guest_user.lab_panels.find(params[:id])
  end

  def panel_params
    params.require(:lab_panel).permit(:name, :notes)
  end
end
