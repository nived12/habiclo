class MedicationsController < ApplicationController
  include HealthPageSetup

  before_action :set_med, only: [ :edit, :update, :destroy ]
  before_action :capture_return_to, only: [ :new, :edit ]

  def index
    redirect_to health_path(tab: "medicamentos")
  end

  def new
    setup_health_page(tab: "medicamentos")
    render "health/show"
  end

  def create
    @medication = current_or_guest_user.medications.new(med_params)
    if @medication.save
      redirect_after_save(fallback: health_path(tab: "medicamentos"))
    else
      redirect_to health_path(tab: "medicamentos"), alert: @medication.errors.full_messages.to_sentence
    end
  end

  def edit
    setup_health_page(tab: "medicamentos", medication: @med)
    render "health/show"
  end

  def update
    if @med.update(med_params)
      redirect_after_save(fallback: health_path(tab: "medicamentos"))
    else
      redirect_to health_path(tab: "medicamentos"), alert: @med.errors.full_messages.to_sentence
    end
  end

  def destroy
    @med.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_to health_path(tab: "medicamentos") }
    end
  end

  private

  def set_med
    @med = current_or_guest_user.medications.find(params[:id])
  end

  def med_params
    raw = params.require(:medication).permit(:name, :dose, :notes, schedule_minutes: [])
    raw[:schedule_minutes] = (raw[:schedule_minutes] || [])
      .reject(&:blank?)
      .map { |t| h, m = t.split(":").map(&:to_i); h * 60 + m }
    raw
  end
end
