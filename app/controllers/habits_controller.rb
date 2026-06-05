class HabitsController < ApplicationController
  before_action :set_habit, only: [ :edit, :update, :destroy ]

  def index
    @habits = current_or_guest_user.habits.ordered
  end

  def new
    @habit = current_or_guest_user.habits.new(
      category: "general",
      frequency_type: "daily",
      color_hue: current_or_guest_user.brand_hue
    )
  end

  def create
    @habit = current_or_guest_user.habits.new(habit_params)
    if @habit.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @habit.update(habit_params)
      redirect_to root_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit.destroy
    respond_to do |format|
      format.json { render json: { ok: true } }
      format.html { redirect_to root_path }
    end
  end

  private

  def set_habit
    @habit = current_or_guest_user.habits.find(params[:id])
  end

  def parse_time_to_minute(value)
    return value if value.is_a?(Integer)
    return nil if value.blank?

    if value.match?(/\A\d{2}:\d{2}\z/)
      h, m = value.split(":").map(&:to_i)
      h * 60 + m
    else
      value.to_i
    end
  end

  def habit_params
    params.require(:habit).permit(
      :name, :description, :frequency_type, :target_value, :unit,
      :category, :color_hue, :position, :scheduled_at_minute, :duration_minutes,
      :occurs_on, :weekly_target, :monthly_day,
      recurrence_days: []
    ).tap do |p|
      if p.key?(:recurrence_days)
        p[:recurrence_days] = p[:recurrence_days].to_a.map(&:to_i).select { |d| (1..7).include?(d) }
      end
      p[:scheduled_at_minute] = parse_time_to_minute(p[:scheduled_at_minute]) if p[:scheduled_at_minute].present?
    end
  end
end
