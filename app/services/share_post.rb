class SharePost
  EMAIL_FORMAT = URI::MailTo::EMAIL_REGEXP
  Result = Struct.new(:success?, :share, :errors, keyword_init: true)

  def initialize(post_id:, recipient_email:, sender:)
    @post_id = post_id
    @recipient_email = recipient_email.to_s.strip.downcase
    @sender = sender
  end

  def call
    return failure("Post not found") unless post
    return failure("Sender is required") unless @sender
    return failure("Recipient email is invalid") unless valid_recipient_email?
    return failure("This post was already shared with that email") if duplicate_share?

    share = post.shares.build(user: @sender, recipient_email: @recipient_email)

    if share.save
      PostShareMailer.with(share: share).shared_post.deliver_now
      success(share)
    else
      failure(share.errors.full_messages, share)
    end
  rescue ActiveRecord::RecordNotUnique
    failure("This post was already shared with that email")
  end

  private

    def post
      @post ||= Post.find_by(id: @post_id)
    end

    def valid_recipient_email?
      @recipient_email.match?(EMAIL_FORMAT)
    end

    def duplicate_share?
      post.shares.exists?(recipient_email: @recipient_email)
    end

    def success(share)
      Result.new(success?: true, share: share, errors: [])
    end

    def failure(errors, share = nil)
      Result.new(success?: false, share: share, errors: Array(errors))
    end
end
