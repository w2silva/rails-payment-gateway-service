class PlanService < BaseService
  attr_accessor :payment_gateway_plan_identifier, :name, :currency, :price_cents, :interval

  def initialize(payment_gateway_plan_identifier, name, currency, price_cents, interval)
    @payment_gateway_plan_identifier = payment_gateway_plan_identifier
    @currency = currency
    @name = name
    @price_cents = price_cents
    @interval = interval
  end

  # Send details and create new subscription in the gateway
  #============================================
  def call
    ActiveRecord.transaction do
      create_gateway_plan
      create_plan
    rescue ActiveRecord::RecordNorSaved => e
      errors.add(errors: e.message)
      nil
    end
  end

  private 
  
    # Send details and create new subscription in the gateway
    #============================================
    def create_gateway_plan
      gateway.create_plan!(
        name,
        id: payment_gateway_plan_identifier,
        amount: price_cents,
        currency: currency,
        interval: interval
      )
    end

    # Send details and create new subscription in the gateway
    #============================================
    def create_plan
      Plan.create!(
        payment_gateway_plan_identifier: payment_gateway_plan_identifier,
        name: name,
        price_cents: price_cents,
        interval: interval,
        status: :active
      )
    end
end