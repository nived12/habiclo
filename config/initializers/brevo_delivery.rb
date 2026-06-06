require "json"
require "net/http"
require "uri"

module Mail
  class BrevoDelivery
    class DeliveryError < StandardError; end

    attr_accessor :settings

    def initialize(settings = {})
      @settings = settings
    end

    def deliver!(mail)
      api_key = settings[:api_key].presence
      raise DeliveryError, "BREVO_API_KEY is not set" if api_key.blank?

      payload = payload_for(mail)
      raise DeliveryError,
        "Brevo email has no html or text body" if payload[:htmlContent].blank? && payload[:textContent].blank?

      uri = URI("https://api.brevo.com/v3/smtp/email")
      request = Net::HTTP::Post.new(uri)
      request["api-key"] = api_key
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request.body = payload.to_json

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 15) do |http|
        http.request(request)
      end

      return mail if response.code.to_i.between?(200, 299)

      raise DeliveryError, "Brevo API error (#{response.code}): #{response.body}"
    end

    private

    def payload_for(mail)
      {
        sender: address_to_hash(mail[:from]&.formatted&.first || mail.from&.first),
        to: Array(mail.to).filter_map { |addr| address_to_hash(addr) },
        subject: mail.subject,
        htmlContent: html_body(mail),
        textContent: text_body(mail)
      }.compact
    end

    def html_body(mail)
      part = mail.html_part || (mail.content_type.to_s.include?("html") ? mail : nil)
      part&.body&.decoded
    end

    def text_body(mail)
      part = mail.text_part || (mail.content_type.to_s.include?("plain") ? mail : nil)
      part&.body&.decoded
    end

    def address_to_hash(address)
      return if address.blank?

      if (match = address.to_s.match(/\A\s*(.+?)\s*<(.+?)>\s*\z/))
        { name: match[1].gsub(/\A"|"\z/, ""), email: match[2] }
      else
        { email: address.to_s.strip }
      end
    end
  end
end

ActionMailer::Base.add_delivery_method :brevo, Mail::BrevoDelivery
