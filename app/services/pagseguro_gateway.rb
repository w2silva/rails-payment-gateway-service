class PagseguroGateway

  # This method create a new customer from Stripe API
  def get_customer!(options = {})
    handle_client_error do
      # Stripe::Customer.create(email: options[:email])
    end
  end
  
  # This method create a new plan from Stripe API
  def create_plan!(product_name, options = {})
    handle_client_error do 
      PagSeguro::SubscriptionPlan.new(
        reference: options[:id],
        amount: options[:amount],
        charge: :auto,
        details: {
          name: product_name,
          period: options[:interval] || 'monthly',
          expiration: {
            value: 1,
            unit: 'years'
          }
        }
      )
    end
  end

  # This method create a new subscription from Stripe API
  def create_subscription!(customer, plan, token)
    handle_client_error "Handle errors in subscriptions: " do 
      subscription = PagSeguro::Subscription.new(
        plan: 'PLAN00001',
        reference: 'ref000001',
        sender: PagSeguro::Sender.new(
          name: customer.full_name,
          email: '',
          ip: '192.168.0.1', 
          phone: PagSeguro::Phone.new(
            area_code: '11',
            number: '111111111'
          ),
          document: PagSeguro::Document.new(
            type: 'CPF', 
            value: '00000000000'
          )
        ),
        payment_method: PagSeguro::SubscriptionPaymentMethod.new(
          token: 'token',
          holder: {
            name: 'Nome',
            birth_date: '11/01/1984',
            document: { type: 'CPF', value: '00000000191' },
            billing_address: {
              street: 'Av Brigadeira Faria Lima',
              number: '1384',
              complement: '3 andar',
              district: 'Jd Paulistano',
              city: 'Sao Paulo',
              state: 'SP',
              country: 'BRA',
              postal_code: '01452002'
            },
            phone: { area_code: '11', number: '988881234' }
          }
        )
      )
      subscription.credentials = PagSeguro::AccountCredentials.new('', '')
      subscription.create

      if subscription.errors.any?
        puts subscription.errors.join('\n')
      else
        puts subscription.code
      end
    end
  end

  private

    # Handle any error who happing
    def handle_client_error(message = nil, &block)
      begin
        yield
      rescue PagSeguro::Errors => e
        puts message
        raise PaymentGateway::PagseguroClientError.new(e.message)        
      end
    end
end
