class CampaignMailer < ApplicationMailer
  def delivery_email
    @delivery = params[:delivery]
    @campaign = @delivery.campaign
    @post = @campaign.post
    @sender = @campaign.user

    mail(
      to: @delivery.recipient.email,
      subject: "#{@sender.name} shared a post campaign with you"
    )
  end
end
