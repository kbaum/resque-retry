require 'resque/failure/multiple'

class RetryFailureBackend < Resque::Failure::Multiple

  include Resque::Helpers

  def save
    unless retrying?
      super
    else
      data = {
              :failed_at => Time.now.strftime("%Y/%m/%d %H:%M:%S"),
              :payload   => payload,
              :exception => exception.class.to_s,
              :error     => exception.to_s,
              :backtrace => Array(exception.backtrace),
              :worker    => worker.to_s,
              :queue     => queue
      }
      data = Resque.encode(data)
      Resque.redis[failure_key]=data
    end
  end

  protected

  def retrying?
    Resque.redis.get(retry_key)
  end

  def failure_key
    "failure_#{retry_key}"
  end

  def retry_key
    klass.redis_retry_key(payload["args"])
  end

  def klass
    constantize(payload["class"])
  end
end