class Gateway
  attr_accessor :external_gateway

  def initialize(external_gateway)
    @external_gateway = external_gateway
  end

  def method_missing(*args, &block)
    begin
      external_gateway.send(*args, &block)
    rescue => e
      raise StandardError.new(e.message)
    end
  end
end
