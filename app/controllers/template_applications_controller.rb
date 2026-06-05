class TemplateApplicationsController < ApplicationController
  def create
    key = params[:template_id]
    unless Templates::Catalog.exists?(key) && Templates::Catalog.find(key)[:public]
      redirect_to templates_path, alert: t("templates.not_found") and return
    end

    result = Templates::Applier.new(current_or_guest_user, key).call
    redirect_to root_path, notice: apply_message(result)
  end

  private

  def apply_message(result)
    total_added = result.added.values.sum
    total_skipped = result.skipped.values.sum
    if total_skipped.zero?
      t("templates.applied_simple", count: total_added)
    else
      t("templates.applied_detailed", added: total_added, skipped: total_skipped)
    end
  end
end
