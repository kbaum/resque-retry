require 'resque/failure/multiple'

class RetryFailureBackend < Resque::Failure::Multiple

  include Resque::Helpers

  def save
    super unless retrying?
  end

  protected

  def retrying?
    Resque.redis.get(klass.redis_retry_key(payload["args"]))
  end

  def klass
    constantize(payload["class"])
  end
end