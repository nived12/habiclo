class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("TRANSACTIONAL_FROM", "Habiclo <noreply@habiclo.com>")
  layout "mailer"
end
