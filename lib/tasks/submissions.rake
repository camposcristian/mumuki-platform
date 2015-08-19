def notify_group(group)
  begin
    EventSubscriber.notify_submissions!(group)
    puts "#{group.map(&:id)}"
  rescue => e
    puts e
  end
end

namespace :submissions do
  task notify_all: :environment do
    Submission.where(notified:false).in_groups_of(1) do |group|
      notify_group(group)
    end
  end
end
