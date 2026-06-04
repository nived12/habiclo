class ApplicationService
  def self.call(...)
    new(...).call
  end

  Result = Struct.new(:success, :value, :error, keyword_init: true) do
    def success? = success
    def failure? = !success
  end

  private

  def success(value = nil)
    Result.new(success: true, value: value, error: nil)
  end

  def failure(error)
    Result.new(success: false, value: nil, error: error)
  end
end
