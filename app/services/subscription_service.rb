class SubscriptionService < BaseService
  attr_accessor :user, :plan, :token, :subscription

  def initialize(user, plan, options = {})
    @user = user
    @plan = plan
    @token = options[:token]
    @subscription = nil
  end

  # Execute all process that need for new subscription
  # 
  # 1º Create a subscription from Gateway API, passing
  # the user and plan infos, and token credentials
  #
  # 2º Create a subscription in the database
  # @see https://www.codementor.io/victor_hazbun/stripe-recurring-subscriptions-on-rails-like-a-pro-under-development-iug10rd44
  # ==================================================
  def call
    ActiveRecord::Connection.transaction do
      # Create a subscription remote and local
      create_gateway_subscription do |gateway_subscription| 
        @subscription = create_subscription(
          gateway_subscription: gateway_subscription
        )
      end
    rescue ActiveRecord::RecordNorSaved => e
      errors.add(errors: e.message)
      nil
    end
  end

  private 

    # Send details and create new subscription in the gateway
    #============================================
    def create_gateway_subscription
      gateway_subscription = gateway.create_subscription!(
        user: get_payment_gateway_user,
        plan: get_payment_gateway_plan,
        token: @token
      )

      yield gateway_subscription if block_given?
    end

    # Create new subscription in the database
    #============================================
    def create_subscription(gateway_subscription)
      subscription = Subscription.new(
        user: @user,
        plan: @plan,
        start_date: Time.zone.now.to_date,
        end_date: Time.zone.now.to_date,
        # end_date: @plan.end_date_from,
        status: :active,
        payment_gateway_subscription_id: gateway_subscription.id,
        payment_gateway: :stripe
      )

      if subscription.valid? && subscription.save
        subscription
      else
        errors.add(errors: subscription.errors)
        nil
      end
    end

    # Create or return a new user instance from gateway
    #============================================
    def get_payment_gateway_user
      user_service = UserService.new(user: @user)
      user_service.result if user_service.success?
      nil
    end

    # Create or return a new plan instance from gateway
    #============================================
    def get_payment_gateway_plan
      plan_service = PlanService.new(plan: @plan)
      plan_service.result if plan_service.success?
      nil
    end
end
