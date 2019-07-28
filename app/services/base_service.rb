# Class base to all services in application, from it some service
# can communication in somewhere in application.
class BaseService
  # Become new method private 
  private_class_method :new

  prepend SimpleCommand

  def self.call(*args)
    new(*args).call
  end
end
