class GuestFreshStartsController < ApplicationController
  def create
    user = current_or_guest_user
    unless user&.guest?
      redirect_to root_path, alert: t("guest_banner.fresh_start_only_guest") and return
    end

    Users::GuestFreshStarter.call(user)
    redirect_to root_path, notice: t("guest_banner.fresh_start_done")
  end
end
