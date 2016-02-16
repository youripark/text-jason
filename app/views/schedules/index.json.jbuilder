json.array!(@schedules) do |schedule|
  json.extract! schedule, :id, :date, :time, :text, :recipient, :message_sent
  json.url schedule_url(schedule, format: :json)
end
