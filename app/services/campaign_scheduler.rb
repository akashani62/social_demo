class CampaignScheduler
  Result = Struct.new(:success?, :campaign, :errors, :scheduled_for, keyword_init: true)

  def initialize(campaign:, execution_job_class: CampaignExecutionJob)
    @campaign = campaign
    @execution_job_class = execution_job_class
  end

  def call
    return failure("Campaign is required") unless @campaign

    if @campaign.immediate?
      @execution_job_class.perform_later(@campaign.id)
      success(Time.current)
    else
      return failure("Scheduled time is required") if @campaign.scheduled_at.blank?
      return failure("Scheduled time must be in the future") if @campaign.scheduled_at <= Time.current

      @execution_job_class.set(wait_until: @campaign.scheduled_at).perform_later(@campaign.id)
      success(@campaign.scheduled_at)
    end
  end

  private

    def success(scheduled_for)
      Result.new(success?: true, campaign: @campaign, errors: [], scheduled_for: scheduled_for)
    end

    def failure(errors)
      Result.new(success?: false, campaign: @campaign, errors: Array(errors), scheduled_for: nil)
    end
end
