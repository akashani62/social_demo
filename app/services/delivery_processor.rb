class DeliveryProcessor
  Result = Struct.new(:success?, :delivery, :errors, keyword_init: true)

  def initialize(delivery:, mailer_class: CampaignMailer)
    @delivery = delivery
    @mailer_class = mailer_class
  end

  def call
    return failure("Delivery is required") unless @delivery
    return success if @delivery.sent?

    @delivery.update!(
      status: :pending,
      last_attempt_at: Time.current,
      attempts_count: @delivery.attempts_count + 1,
      error_message: nil
    )

    @mailer_class.with(delivery: @delivery).delivery_email.deliver_now
    @delivery.update!(status: :sent, sent_at: Time.current, next_retry_at: nil)
    broadcast_stats

    success
  rescue StandardError => error
    Rails.logger.error("Delivery ##{@delivery.id} failed: #{error.message}")
    @delivery.update!(
      status: :failed,
      error_message: error.message.to_s.truncate(500),
      next_retry_at: RetryFailedDeliveries.next_retry_time(@delivery.attempts_count)
    )
    broadcast_stats
    failure(error.message)
  end

  private

    def broadcast_stats
      campaign = @delivery.campaign.reload

      campaign.broadcast_replace_to(
        @delivery.campaign,
        target: ActionView::RecordIdentifier.dom_id(campaign, :stats),
        partial: "campaigns/stats",
        locals: { campaign: campaign }
      )

      campaign.broadcast_replace_to(
        campaign,
        target: ActionView::RecordIdentifier.dom_id(campaign, :status_badge),
        partial: "campaigns/status_badge",
        locals: { campaign: campaign }
      )
    end

    def success
      Result.new(success?: true, delivery: @delivery, errors: [])
    end

    def failure(errors)
      Result.new(success?: false, delivery: @delivery, errors: Array(errors))
    end
end
