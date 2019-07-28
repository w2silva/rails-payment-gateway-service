class UserService < BaseService
  attr_accessor :user

  def initialize(user, options = {})
    @user = user
  end

  # Create or return a new user instance from gateway
  #============================================
  def call
    gateway.create_customer!(customer: @user).tap do |gateway_customer|
      @user.payment_gateway_customer_identifier = gateway_customer.id
      if @user.valid? && @user.save
        @user
      else
        errors.add(errors: @user.errors)
        nil
      end
    end
  end
end
