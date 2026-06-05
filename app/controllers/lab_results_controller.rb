class LabResultsController < ApplicationController
  before_action :set_panel
  before_action :set_result, only: [ :edit, :update, :destroy ]

  def new
    @result = @panel.lab_results.new(completed_on: Date.current)
  end

  def create
    @result = @panel.lab_results.new(result_params)
    if @result.save
      respond_to do |format|
        format.turbo_stream do
          panels = current_or_guest_user.lab_panels.includes(:lab_results).ordered
          render turbo_stream: turbo_stream.update(
            "health_tab",
            partial: "health/labs",
            locals: { lab_panels: panels, lab_panel: current_or_guest_user.lab_panels.new }
          )
        end
        format.html { redirect_to health_path(tab: "labs") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "lab_result_form_#{@panel.id}",
            partial: "lab_results/form",
            locals: { panel: @panel, result: @result }
          )
        end
        format.html { redirect_to health_path(tab: "labs") }
      end
    end
  end

  def edit
    render "lab_results/edit"
  end

  def update
    if @result.update(result_params)
      redirect_to health_path(tab: "labs")
    else
      redirect_to health_path(tab: "labs"), alert: @result.errors.full_messages.to_sentence
    end
  end

  def destroy
    @result.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.turbo_stream do
        panels = current_or_guest_user.lab_panels.includes(:lab_results).ordered
        render turbo_stream: turbo_stream.update(
          "health_tab",
          partial: "health/labs",
          locals: { lab_panels: panels, lab_panel: current_or_guest_user.lab_panels.new }
        )
      end
      format.html { redirect_to health_path(tab: "labs") }
    end
  end

  private

  def set_panel
    @panel = current_or_guest_user.lab_panels.find(params[:lab_panel_id])
  end

  def set_result
    @result = @panel.lab_results.find(params[:id])
  end

  def result_params
    params.require(:lab_result).permit(:due_on, :completed_on, :result_summary)
  end
end
