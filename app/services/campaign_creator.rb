class CampaignCreator
  Result = Struct.new(
    :success?,
    :campaign,
    :errors,
    :invalid_emails,
    :recipient_count,
    keyword_init: true
  )

  EMAIL_FORMAT = URI::MailTo::EMAIL_REGEXP

  def initialize(user:, post:, recipient_emails:, send_mode:, scheduled_at: nil)
    @user = user
    @post = post
    @recipient_emails = recipient_emails
    @send_mode = send_mode.to_s
    @scheduled_at = scheduled_at
  end

  def call
    return failure("User is required") unless @user
    return failure("Post is required") unless @post

    normalized_emails = normalize_emails(@recipient_emails)
    return failure("At least one recipient email is required") if normalized_emails.empty?

    invalid_emails = normalized_emails.reject { |email| valid_email?(email) }
    return failure("One or more recipient emails are invalid", invalid_emails: invalid_emails) if invalid_emails.any?

    campaign = nil
    Campaign.transaction do
      campaign = Campaign.create!(
        user: @user,
        post: @post,
        send_mode: @send_mode,
        scheduled_at: scheduled_time
      )

      normalized_emails.each do |email|
        recipient = Recipient.find_or_create_by!(email: email)
        Delivery.create!(campaign: campaign, recipient: recipient, status: :pending)
      end
    end

    success(campaign, recipient_count: normalized_emails.size)
  rescue ActiveRecord::RecordInvalid => error
    failure(error.record.errors.full_messages)
  rescue ArgumentError => error
    failure(error.message)
  end

  private

    def normalize_emails(input)
      Array(input)
        .flat_map { |value| value.to_s.split(/[,\n;]/) }
        .map { |email| email.strip.downcase }
        .reject(&:blank?)
        .uniq
    end

    def valid_email?(email)
      email.match?(EMAIL_FORMAT)
    end

    def scheduled_time
      return nil unless @send_mode == "scheduled"

      parsed = @scheduled_at.is_a?(String) ? Time.zone.parse(@scheduled_at) : @scheduled_at
      raise ArgumentError, "Scheduled time is required for scheduled campaigns" if parsed.blank?
      raise ArgumentError, "Scheduled time must be in the future" if parsed <= Time.current

      parsed
    end

    def success(campaign, recipient_count:)
      Result.new(
        success?: true,
        campaign: campaign,
        errors: [],
        invalid_emails: [],
        recipient_count: recipient_count
      )
    end

    def failure(errors, invalid_emails: [])
      Result.new(
        success?: false,
        campaign: nil,
        errors: Array(errors),
        invalid_emails: invalid_emails,
        recipient_count: 0
      )
    end
end
