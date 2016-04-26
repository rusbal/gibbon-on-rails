class SubscribersController < ApplicationController

  def index
    redirect_to list_path(id: params[:list_id])
  end

  def new
    @subscriber = Subscriber.new
  end

  def create
    @subscriber = Subscriber.new(params_subscriber)
    if @subscriber.save
      save_subscriber or render 'new'
    else
      render 'new'
    end
  end

  def save_subscriber
    if gibbon_create_subscriber
      redirect_to list_path(id: params[:list_id])
    end
  end

  def gibbon_create_subscriber

    subs = params_subscriber
    body = {
      email_address: subs[:email_address], 
      status: subs[:subscribed] == "1" ? "subscribed" : "pending", 
      merge_fields: {
        FNAME: subs[:fname], 
        LNAME: subs[:lname]
      }
    }

    begin
      @gibbon.lists(params[:list_id]).members.create(body: body)
    rescue Gibbon::MailChimpError
      raise
      p body
      false
    end
  end

  private

  def params_subscriber
    params.require(:subscriber).permit(:email_address, :fname, :lname, :subscribed)
  end

end
