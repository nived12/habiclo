class HelpAcknowledgmentsController < ApplicationController
  def create
    current_or_guest_user.mark_help_seen!
    head :no_content
  end
end
