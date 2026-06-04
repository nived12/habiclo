class BiometricMetricsController < ApplicationController
  before_action :set_metric, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to health_path(tab: "biometria")
  end

  def new
    @metric = current_or_guest_user.biometric_metrics.new
    render "health/show", locals: { tab: "biometria" }
  end

  def create
    @metric = current_or_guest_user.biometric_metrics.new(metric_params)
    @metric.position = current_or_guest_user.biometric_metrics.count
    if @metric.save
      respond_to do |format|
        format.turbo_stream do
          @biometric_metrics = current_or_guest_user.biometric_metrics.includes(:biometric_entries).ordered
          render turbo_stream: [
            turbo_stream.update("health_tab",
              partial: "health/biometria",
              locals: { metrics: @biometric_metrics, metric: current_or_guest_user.biometric_metrics.new }),
            turbo_stream.update("health_modal", "")
          ]
        end
        format.html { redirect_to health_path(tab: "biometria") }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("health_modal",
            partial: "biometric_metrics/form",
            locals: { metric: @metric })
        end
        format.html { redirect_to health_path(tab: "biometria"), alert: @metric.errors.full_messages.to_sentence }
      end
    end
  end

  def show
    @entries = @metric.biometric_entries.order(recorded_on: :desc, id: :desc)
    render layout: false
  end

  def edit
    @tab = "biometria"
    @biometric_metrics = current_or_guest_user.biometric_metrics.includes(:biometric_entries).ordered
    render "health/show"
  end

  def update
    if @metric.update(metric_params)
      redirect_to health_path(tab: "biometria")
    else
      redirect_to health_path(tab: "biometria"), alert: @metric.errors.full_messages.to_sentence
    end
  end

  def destroy
    @metric.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_to health_path(tab: "biometria") }
    end
  end

  private

  def set_metric
    @metric = current_or_guest_user.biometric_metrics.find(params[:id])
  end

  def metric_params
    params.require(:biometric_metric).permit(:name, :unit, :category)
  end
end
