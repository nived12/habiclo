module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    def sign_up(resource_name, resource)
      convert_guest!(resource) if cookies.encrypted[GuestPipeline::GUEST_COOKIE].present?
      super
    end
  end
end
