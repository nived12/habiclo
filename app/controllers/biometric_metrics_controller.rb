class BiometricMetricsController < ApplicationController
  include HealthPageSetup

  before_action :set_metric, only: [ :show, :edit, :update, :destroy ]
  before_action :capture_return_to, only: [ :new, :edit ]

  def index
    redirect_to health_path(tab: "biometria")
  end

  def new
    @metric = current_or_guest_user.biometric_metrics.new
  end

  def create
    @metric = current_or_guest_user.biometric_metrics.new(metric_params)
    @metric.position = current_or_guest_user.biometric_metrics.count
    if @metric.save
      respond_to do |format|
        format.turbo_stream do
          @biometric_metrics = current_or_guest_user.biometric_metrics.includes(:biometric_entries).ordered
          render turbo_stream: [
            turbo_stream.update(
              "health_tab",
              partial: "health/biometria",
              locals: { metrics: @biometric_metrics, metric: current_or_guest_user.biometric_metrics.new }
            ),
            turbo_stream.update("health_modal", "")
          ]
        end
        format.html { redirect_after_save(fallback: health_path(tab: "biometria")) }
      end
    else
      @return_to = safe_return_path(params[:return_to])
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "health_modal",
            partial: "biometric_metrics/form",
            locals: { metric: @metric, return_to: @return_to }
          )
        end
        format.html { redirect_after_save(fallback: health_path(tab: "biometria")) }
      end
    end
  end

  def show
    @entries = @metric.biometric_entries.order(recorded_on: :desc, id: :desc)
    render layout: false
  end

  def edit; end

  def update
    if @metric.update(metric_params)
      respond_to do |format|
        format.turbo_stream do
          @biometric_metrics = current_or_guest_user.biometric_metrics.includes(:biometric_entries).ordered
          render turbo_stream: [
            turbo_stream.update(
              "health_tab",
              partial: "health/biometria",
              locals: { metrics: @biometric_metrics, metric: current_or_guest_user.biometric_metrics.new }
            ),
            turbo_stream.update("health_modal", "")
          ]
        end
        format.html { redirect_after_save(fallback: health_path(tab: "biometria")) }
      end
    else
      @return_to = safe_return_path(params[:return_to])
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "health_modal",
            partial: "biometric_metrics/form",
            locals: { metric: @metric, return_to: @return_to }
          )
        end
        format.html do
          flash.now[:alert] = @metric.errors.full_messages.to_sentence
          render :edit, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @metric.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_after_save(fallback: health_path(tab: "biometria")) }
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
