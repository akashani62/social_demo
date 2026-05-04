class DeliveryJob < ApplicationJob
  queue_as :default

  def perform(delivery_id)
    delivery = Delivery.includes(:campaign, :recipient).find_by(id: delivery_id)
    return unless delivery

    campaign = delivery.campaign
    return if campaign.completed? || campaign.completed_with_failures?

    result = DeliveryProcessor.new(delivery: delivery).call
    if result.success?
      finalize_campaign_if_finished!(campaign)
      return
    end

    retry_result = RetryFailedDeliveries.new(campaign: campaign).call
    Rails.logger.info("Retry enqueued for #{retry_result.retried_count} deliveries on campaign ##{campaign.id}")
    finalize_campaign_if_finished!(campaign)
  end

  private

    def finalize_campaign_if_finished!(campaign)
      return if campaign.deliveries.pending.exists?
      return if retryable_failed_deliveries(campaign).exists?

      campaign.update!(
        status: campaign.deliveries.failed.exists? ? :completed_with_failures : :completed,
        processed_at: Time.current
      )
      broadcast_dashboard(campaign)
    end

    def retryable_failed_deliveries(campaign)
      campaign.deliveries.failed.where("attempts_count < ?", RetryFailedDeliveries::MAX_ATTEMPTS)
    end

    def broadcast_dashboard(campaign)
      campaign.broadcast_replace_to(
        campaign,
        target: ActionView::RecordIdentifier.dom_id(campaign, :status_badge),
        partial: "campaigns/status_badge",
        locals: { campaign: campaign }
      )
      campaign.broadcast_replace_to(
        campaign,
        target: ActionView::RecordIdentifier.dom_id(campaign, :stats),
        partial: "campaigns/stats",
        locals: { campaign: campaign }
      )
    end
end
