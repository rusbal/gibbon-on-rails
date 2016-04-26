class ListsController < ApplicationController

  def index
    @lists = @gibbon.lists.retrieve["lists"]
  end

  def show 
    @members = @gibbon.lists.send(params[:id]).members.retrieve["members"]
  end

  def new 
    @list = List.new
  end

  def create
    save_list or render 'new'
  end

  def destroy
    begin
      @gibbon.lists(params[:id]).delete
      flash[:success] = "List deleted."
    rescue Gibbon::MailChimpError => error
      flash[:error] = error
      false
    end

    redirect_to root_path
  end

  private

  def save_list 
    @list = List.new(params_list)

    # Call to save only validates
    if @list.save
      if gibbon_create_list
        redirect_to root_path
      end
    end
  end

  def gibbon_create_list
    body = {
      name: @list.name,
      contact: {
        company: @list.company,
        address1: @list.address1,
        city: @list.city,
        state: @list.city,
        zip: @list.zip.to_s,
        country: @list.country,
      },
      permission_reminder: @list.permission_reminder,
      campaign_defaults: {
        from_name: @list.from_name,
        from_email: @list.from_email,
        subject: @list.subject,
        language: @list.language 
      },
      email_type_option: true,
      visibility: "pub"
    }

    begin
      @gibbon.lists.create(body: body)
      flash[:success] = "List created."
    rescue Gibbon::MailChimpError => error
      @list.errors[:base] << error
      false
    end
  end

  def params_list
    params.require(:list).permit(:name, :company, :address1, :city, :state, :zip, :country, :permission_reminder, :from_name, :from_email, :subject, :language)
  end

end
