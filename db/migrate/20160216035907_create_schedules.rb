class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.date :date
      t.time :time
      t.text :text
      t.string :recipient
      t.boolean :message_sent

      t.timestamps null: false
    end
  end
end
