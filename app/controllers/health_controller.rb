class HealthController < ApplicationController
  include HealthPageSetup

  def show
    setup_health_page(tab: params[:tab])
  end

  def tab
    setup_health_page(tab: params[:tab])
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("health_tab", partial: "health/#{@tab}", locals: health_tab_locals)
      end
      format.html { render :show }
    end
  end
end
