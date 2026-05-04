class SharesController < ApplicationController
  before_action :authenticate_user!

  def create
    result = SharePost.new(
      post_id: params[:post_id],
      recipient_email: share_params[:recipient_email],
      sender: current_user
    ).call

    if result.success?
      redirect_to post_path(params[:post_id]), notice: "Post shared successfully."
    else
      redirect_to post_path(params[:post_id]), alert: result.errors.to_sentence
    end
  end

  private

    def share_params
      params.expect(share: [ :recipient_email ])
    end
end
