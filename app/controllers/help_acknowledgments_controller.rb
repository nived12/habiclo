class HelpAcknowledgmentsController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.update(help_seen_at: Time.current)
    head :no_content
  end
end
