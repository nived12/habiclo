class AgendaItemsController < ApplicationController
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @items = current_or_guest_user.agenda_items.order(:occurs_on)
  end

  def new
    @item = current_or_guest_user.agenda_items.new(
      occurs_on: parse_date(:on) || today,
      kind: "event"
    )
  end

  def create
    @item = current_or_guest_user.agenda_items.new(item_params)
    if @item.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @item.update(item_params)
      redirect_to root_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_to root_path }
    end
  end

  private

  def set_item
    @item = current_or_guest_user.agenda_items.find(params[:id])
  end

  def item_params
    params.require(:agenda_item).permit(:title, :notes, :occurs_on, :scheduled_at_minute, :duration_minutes, :kind)
  end

  def today
    Time.current.in_time_zone(current_or_guest_user.time_zone).to_date
  end

  def parse_date(key)
    Date.parse(params[key]) if params[key].present?
  rescue ArgumentError
    nil
  end
end
