class PostShareMailer < ApplicationMailer
  def shared_post
    @share = params[:share]
    @post = @share.post
    @sender = @share.user

    mail(
      to: @share.recipient_email,
      subject: "#{@sender.name} shared a post with you"
    )
  end
end
