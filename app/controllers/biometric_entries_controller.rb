class BiometricEntriesController < ApplicationController
  before_action :set_metric, except: [ :picker ]
  before_action :set_entry, only: [ :edit, :update, :destroy ]

  before_action :capture_return_to, only: [ :new, :create, :update, :picker ]

  def picker
    @metrics = current_or_guest_user.biometric_metrics.ordered.to_a
  end

  def new
    @entry = @metric.biometric_entries.new(
      recorded_on: Time.current.in_time_zone(current_or_guest_user.time_zone).to_date,
      source: "manual"
    )
  end

  def create
    @entry = @metric.biometric_entries.new(entry_params)
    @entry.user = current_or_guest_user
    if @entry.save
      respond_to do |format|
        format.turbo_stream do
          metrics = current_or_guest_user.biometric_metrics.includes(:biometric_entries).ordered
          render turbo_stream: [
            turbo_stream.update(
              "health_tab",
              partial: "health/biometrics",
              locals: { metrics: metrics, metric: current_or_guest_user.biometric_metrics.new }
            ),
            turbo_stream.update("health_modal", "")
          ]
        end
        format.html { redirect_after_save(fallback: health_path(tab: "biometrics")) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "health_modal",
            partial: "biometric_entries/form",
            locals: { metric: @metric, entry: @entry, return_to: @return_to }
          )
        end
        format.html { redirect_after_save(fallback: health_path(tab: "biometrics")) }
      end
    end
  end

  def edit; end

  def update
    if @entry.update(entry_params)
      respond_to do |format|
        format.turbo_stream do
          metrics = current_or_guest_user.biometric_metrics.includes(:biometric_entries).ordered
          render turbo_stream: [
            turbo_stream.update(
              "health_tab",
              partial: "health/biometrics",
              locals: { metrics: metrics, metric: current_or_guest_user.biometric_metrics.new }
            ),
            turbo_stream.update("health_modal", "")
          ]
        end
        format.html { redirect_after_save(fallback: health_path(tab: "biometrics")) }
      end
    else
      redirect_after_save(fallback: health_path(tab: "biometrics"))
    end
  end

  def destroy
    @entry.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.turbo_stream do
        metrics = current_or_guest_user.biometric_metrics.includes(:biometric_entries).ordered
        render turbo_stream: turbo_stream.update(
          "health_tab",
          partial: "health/biometrics",
          locals: { metrics: metrics, metric: current_or_guest_user.biometric_metrics.new }
        )
      end
      format.html { redirect_after_save(fallback: health_path(tab: "biometrics")) }
    end
  end

  private

  def set_metric
    @metric = current_or_guest_user.biometric_metrics.find(params[:biometric_metric_id])
  end

  def set_entry
    @entry = @metric.biometric_entries.find(params[:id])
  end

  def entry_params
    params.require(:biometric_entry).permit(:value, :recorded_on, :recorded_at_minute, :source)
  end
end
