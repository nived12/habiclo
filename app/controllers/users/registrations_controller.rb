module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    def sign_up(resource_name, resource)
      result = nil
      if cookies.encrypted[GuestPipeline::GUEST_COOKIE].present?
        result = convert_guest!(resource)
      end
      super
      ahoy.track "Signed up" if resource.persisted?
      flash[:notice] = imported_flash(result.counts) if result&.success? && result.counts.values.sum.positive?
    end

    private

    def imported_flash(counts)
      parts = []
      parts << I18n.t("registrations.import_habits", count: counts[:habits])             if counts[:habits].positive?
      parts << I18n.t(
        "registrations.import_completions",
        count: counts[:completions]
      )   if counts[:completions].positive?
      parts << I18n.t(
        "registrations.import_medications",
        count: counts[:medications]
      )   if counts[:medications].positive?
      parts << I18n.t(
        "registrations.import_metrics",
        count: counts[:biometric_metrics]
      ) if counts[:biometric_metrics].positive?
      parts << I18n.t(
        "registrations.import_metric_entries",
        count: counts[:biometric_entries]
      ) if counts[:biometric_entries].positive?

      summary = parts.to_sentence
      I18n.t("registrations.imported_flash", summary: summary)
    end
  end
end
