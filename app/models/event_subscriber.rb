class EventSubscriber < ActiveRecord::Base
  validates_presence_of :url

  def notify_submissions!(submissions)
    notify({events: submissions.as_json(
         except: [:exercise_id, :submission_id],
         include: {
             exercise: {only: [:id, :guide_id]},
             submitter: {only: [:id, :name]}}
    )}.to_json, 'batch/submissions')
  end

  def self.notify_submissions!(submissions)
    all.where(enabled: true).each do |it|
      it.notify_submissions!(submissions)
    end
    transaction do
      submissions.each do |it|
        it.update!(notified: true)
      end
    end
  end

  private

  def self.notify!(mode, event)
    EventSubscriber.all.select { |it| it.subscribed_to? event }.each do |it|
      event.send "notify_#{mode}!", it
    end
  end

  def do_request(event, path)
    RestClient.post("#{url}/#{path}", event, content_type: :json)
  end

  def validate_response(response)
    Rails.logger.info "response from server #{response}" if response != {'status' => 'ok'}
  end
end
