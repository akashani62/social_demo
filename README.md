# Social Demo

## Setup

- Install gems: `bundle install`
- Prepare DBs: `bin/rails db:prepare` and `RAILS_ENV=test bin/rails db:prepare`
- Start app: `bin/rails server`

## Post Sharing Campaign System

### Domain model

- `Campaign` belongs to `User` and `Post`.
- `Recipient` is a normalized unique email identity.
- `Delivery` joins campaign + recipient and stores operational state:
  - `status` (`pending`, `sent`, `failed`)
  - `sent_at`
  - `error_message`
  - retry metadata (`attempts_count`, `last_attempt_at`, `next_retry_at`)

### Service architecture

Business logic is intentionally outside controllers/models:

- `CampaignCreator`
  - parses recipient input (comma/newline/semicolon)
  - normalizes + deduplicates emails
  - validates inputs
  - creates campaign, recipients, and pending deliveries transactionally
  - returns structured result object
- `CampaignScheduler`
  - immediate execution or scheduled enqueueing
  - returns structured result object
- `DeliveryProcessor`
  - sends one delivery email
  - updates delivery status/timestamps/errors
  - triggers Turbo dashboard updates
  - returns structured result object
- `RetryFailedDeliveries`
  - finds retry-eligible failed deliveries
  - re-enqueues with exponential backoff
  - returns structured result object

### Async execution flow

- `CampaignExecutionJob` marks campaign running and enqueues delivery jobs.
- `DeliveryJob` calls `DeliveryProcessor`.
- On failure, retry orchestration goes through `RetryFailedDeliveries`.
- Campaign status transitions to terminal states when work is complete:
  - `completed`
  - `completed_with_failures`

### Data integrity guarantees

- Unique recipient email globally (`recipients.email`).
- Unique delivery target per campaign (`deliveries(campaign_id, recipient_id)`).
- Foreign keys on campaign/user/post/recipient relations.
- Retry cap enforced by service policy (`MAX_ATTEMPTS`).

### UI + live updates

- Campaign creation form: `CampaignsController#new`.
- Campaign dashboard: `CampaignsController#show`.
- Turbo Stream updates:
  - `_stats` partial (total/pending/sent/failed)
  - `_status_badge` partial (campaign lifecycle state)

## Running tests

- All campaign tests:
  - `bin/rails test test/models/campaign_test.rb test/models/recipient_test.rb test/models/delivery_test.rb`
  - `bin/rails test test/services/campaign_creator_test.rb test/services/campaign_scheduler_test.rb test/services/delivery_processor_test.rb test/services/retry_failed_deliveries_test.rb`
  - `bin/rails test test/jobs/campaign_execution_job_test.rb test/jobs/delivery_job_test.rb test/jobs/retry_failed_deliveries_job_test.rb`
  - `bin/rails test test/controllers/campaigns_controller_test.rb`
  - `bin/rails test test/system/campaigns_flow_test.rb`
