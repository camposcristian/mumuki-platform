class AddNotifiedFlagToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :notified, :boolean, default: false
  end
end
