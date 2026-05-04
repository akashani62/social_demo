class RetryFailedDeliveries
  Result = Struct.new(:success?, :retried_count, :errors, keyword_init: true)

  MAX_ATTEMPTS = 5
  BASE_DELAY = 30.seconds

  def self.next_retry_time(attempts_count, from_time: Time.current)
    from_time + (BASE_DELAY * (2**attempts_count))
  end

  def initialize(campaign:, delivery_job_class: DeliveryJob, at_time: Time.current)
    @campaign = campaign
    @delivery_job_class = delivery_job_class
    @at_time = at_time
  end

  def call
    return failure("Campaign is required") unless @campaign

    retried_count = 0
    retryable_deliveries.find_each do |delivery|
      @delivery_job_class.set(wait_until: delivery.next_retry_at || @at_time).perform_later(delivery.id)
      retried_count += 1
    end

    Result.new(success?: true, retried_count: retried_count, errors: [])
  rescue StandardError => error
    failure(error.message)
  end

  private

    def retryable_deliveries
      @campaign.deliveries.failed.where("attempts_count < ?", MAX_ATTEMPTS).where(
        "next_retry_at IS NULL OR next_retry_at <= ?",
        @at_time
      )
    end

    def failure(errors)
      Result.new(success?: false, retried_count: 0, errors: Array(errors))
    end
end
