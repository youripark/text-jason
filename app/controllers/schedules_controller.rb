require 'rubygems'
require 'rufus-scheduler'
require 'twilio-ruby'

class SchedulesController < ApplicationController
  def index
    @current_time = Time.now.to_s(:time) + " AM"
    hour = @current_time[0..1].to_i
    if hour > 12
      hour -= 12
      @current_time = hour.to_s + @current_time[2..4] + " PM"
    end
  end

  def new
    @schedule = Schedule.new
  end

  def create
    scheduler = Rufus::Scheduler.singleton
    client = Twilio::REST::Client.new ENV['twilio_account_sid'], ENV['twilio_auth_token']
    error_message = "Could not schedule text, please fill out form correctly"
    recipient = nil

    recipient_name = params[:schedule][:recipient]
    if recipient_name.downcase == 'youri'
      recipient = ENV['youri_number']
    elsif recipient_name.downcase == 'jason'
      recipient = ENV['jason_number']
    else
      error_message = "Cannot schedule message for: " + receipient_name + ", UNKNOWN USER"
    end

    if recipient != nil and params[:schedule][:passcode] == ENV['schedule_password']
      date = params[:schedule][:date] + " " + params[:schedule][:time]
      text = params[:schedule][:text]
      scheduler.schedule date do
        client.account.messages.create(
          :from => ENV['twilio_number'],
          :to => recipient,
          :body => text
        )
        # Set message_sent to true after delivery
        id = params[:schedule][:id]
        s = Schedule.find(id)
        s.message_sent = true unless s.nil?
        s.save
      end
      flash[:success] = "Your text to " + recipient_name.downcase.capitalize + " was successfully scheduled!"
      redirect_to '/schedules/index'
    else
      flash[:error] = error_message
      redirect_to '/schedules/index'
    end
  end

  def show
    @schedule = Schedule.find(params[:id])
  end
end
