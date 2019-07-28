# Class base to all services in application, from it some service
# can communication in somewhere in application.
class BaseService
  # Become new method private 
  private_class_method :new

  prepend SimpleCommand

  def self.call(*args)
    new(*args).call
  end

  private

    def stripe_gateway
      @gateway ||= StripeGateway.new
    end

    def pagseguro_gateway
      @gateway ||= PagseguroClient.new
    end

  protected 

    def gateway
      pagseguro_gateway
    end
end
