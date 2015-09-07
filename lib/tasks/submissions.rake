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
    Submission.where(notified:false).in_groups_of(100) do |group|
      notify_group(group)
    end
    Submission.where(notified:false).in_groups_of(20) do |group|
      notify_group(group)
    end
    Submission.where(notified:false).in_groups_of(15) do |group|
      notify_group(group)
    end
    Submission.where(notified:false).in_groups_of(10) do |group|
      notify_group(group)
    end
    Submission.where(notified:false).in_groups_of(5) do |group|
      notify_group(group)
    end
    Submission.where(notified:false).in_groups_of(1) do |group|
      notify_group(group)
    end
  end
end
