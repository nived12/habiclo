class TemplatesController < ApplicationController
  def index
    @templates = Templates::Catalog.public_templates
  end

  def show
    @key = params[:id]
    unless Templates::Catalog.exists?(@key) && Templates::Catalog.find(@key)[:public]
      redirect_to templates_path, alert: t("templates.not_found") and return
    end

    @template = Templates::Catalog.find(@key)
  end
end
