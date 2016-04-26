class SubscribersController < ApplicationController

  def index
    redirect_to list_path(id: params[:list_id])
  end

  def new
    @subscriber = Subscriber.new
  end

  def create
    save_subscriber or render 'new'
  end

  def destroy
    begin
      @gibbon.lists(params[:list_id]).members(params[:id]).delete
      flash[:success] = "Member unsubscribed."
    rescue Gibbon::MailChimpError => error
      flash[:error] = error
    end

    redirect_to list_path(id: params[:list_id])
  end

  private

  def save_subscriber
    @subscriber = Subscriber.new(params_subscriber)

    # Call to save only validates
    if @subscriber.save
      if gibbon_create_subscriber
        redirect_to list_path(id: params[:list_id])
      end
    end
  end

  def gibbon_create_subscriber
    body = {
      email_address: @subscriber.email_address,
      status: @subscriber.subscribed ? "subscribed" : "pending", 
      merge_fields: {
        FNAME: @subscriber.fname, 
        LNAME: @subscriber.lname
      }
    }

    begin
      @gibbon.lists(params[:list_id]).members.create(body: body)
      flash[:success] = "Member subscribed."
    rescue Gibbon::MailChimpError => error
      @subscriber.errors[:base] << error
      false
    end
  end

  def params_subscriber
    params.require(:subscriber).permit(:email_address, :fname, :lname, :subscribed)
  end

end
