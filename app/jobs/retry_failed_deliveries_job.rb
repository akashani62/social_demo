class RetryFailedDeliveriesJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = Campaign.find_by(id: campaign_id)
    return unless campaign

    RetryFailedDeliveries.new(campaign: campaign).call
  end
end
