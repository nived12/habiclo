module ReturnTo
  extend ActiveSupport::Concern

  included do
    helper_method :return_to_param
  end

  private

  def capture_return_to
    @return_to = safe_return_path(params[:return_to])
  end

  def redirect_after_save(fallback:)
    redirect_to safe_return_path(params[:return_to]) || fallback
  end

  def safe_return_path(url)
    return if url.blank?

    path = url.to_s
    if path.start_with?("http")
      uri = URI.parse(path)
      return unless uri.host == request.host

      path = uri.path
      path += "?#{uri.query}" if uri.query.present?
    end
    return unless path.start_with?("/")

    path
  rescue URI::InvalidURIError
    nil
  end

  def return_to_param
    path = safe_return_path(request.original_url)
    path ? { return_to: path } : {}
  end
end
