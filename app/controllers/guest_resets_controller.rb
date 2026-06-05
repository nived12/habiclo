class GuestResetsController < ApplicationController
  def create
    user = current_or_guest_user
    unless user&.guest?
      redirect_to root_path, alert: t("templates.reset_only_guest") and return
    end

    Users::GuestResetter.call(user)
    redirect_to root_path, notice: t("templates.reset_done")
  end
end
