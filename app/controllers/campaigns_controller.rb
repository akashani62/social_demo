class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: :show

  def new
    @campaign = Campaign.new(post_id: params[:post_id])
  end

  def create
    post = Post.find_by(id: campaign_params[:post_id])
    result = CampaignCreator.new(
      user: current_user,
      post: post,
      recipient_emails: campaign_params[:recipient_emails],
      send_mode: campaign_params[:send_mode],
      scheduled_at: campaign_params[:scheduled_at]
    ).call

    if result.success?
      CampaignScheduler.new(campaign: result.campaign).call
      redirect_to campaign_path(result.campaign), notice: "Campaign created successfully."
    else
      @campaign = Campaign.new(campaign_params.slice(:post_id, :send_mode, :scheduled_at))
      flash.now[:alert] = result.errors.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @campaign = @campaign.reload
  end

  private

    def set_campaign
      @campaign = current_user.campaigns.includes(deliveries: :recipient).find(params[:id])
    end

    def campaign_params
      params.expect(campaign: [ :post_id, :recipient_emails, :send_mode, :scheduled_at ])
    end
end
