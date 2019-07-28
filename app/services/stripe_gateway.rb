class StripeGateway

  # This method create a new customer from Stripe API
  def get_customer!(customer)
    handle_client_error do
      if customer[:payment_gateway_customer_identifier].nil?
        Stripe::Customer.create(email: customer[:email])
      else
        stripe_customer = Stripe::Customer.retrieve(customer[:payment_gateway_customer_identifier])
        if stripe_customer.nil?
          stripe_customer = Stripe::Customer.create(email: customer[:email])
        end
        stripe_customer
      end
    end
  end
  
  # This method create a new plan from Stripe API
  def create_plan!(product_name, options = {})
    handle_client_error do 
      Stripe::Plan.create(
        id: options[:id],
        amount: options[:amount],
        currency: options[:currency] || 'brl',
        interval: options[:interval] || 'month',
        product: {
          name: product_name
        }
      )
    end
  end

  # This method create a new subscription from Stripe API
  def create_subscription!(customer: , plan: , token: )
    handle_client_error do
      Stripe::Subscription.create(
        customer: customer,
        source: token,
        items: [{
          plan: plan[:payment_gateway_plan_identifier]
        }]
      )
    end
  end

  private

    # Handle any error who happing
    def handle_client_error(message, &block)
      begin
        yield
      rescue Stripe::StripeError => e
        puts e.message
        # raise PaymentGateway::StripeClientError.new(e.message)        
      end
    end
end
