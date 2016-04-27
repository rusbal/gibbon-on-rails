class TemplatesController < ApplicationController

  def index
    @templates = @gibbon.templates.retrieve["templates"]
  end

  def show 
    @members = @gibbon.templates.send(params[:id]).members.retrieve["members"]
  end

  def new 
    @template = Template.new
  end

  def create
    save_template or render 'new'
  end

  def destroy
    begin
      @gibbon.templates(params[:id]).delete
      flash[:success] = "Template deleted."
    rescue Gibbon::MailChimpError => error
      flash[:error] = error
      false
    end

    redirect_to templates_path
  end

  private

  def save_template 
    @template = Template.new(params_template)

    # Call to save only validates
    if @template.save
      if gibbon_create_template
        redirect_to templates_path
      end
    end
  end

  def gibbon_create_template
    body = {
      name: @template.name,
      contact: {
        company: @template.company,
        address1: @template.address1,
        city: @template.city,
        state: @template.city,
        zip: @template.zip.to_s,
        country: @template.country,
      },
      permission_reminder: @template.permission_reminder,
      campaign_defaults: {
        from_name: @template.from_name,
        from_email: @template.from_email,
        subject: @template.subject,
        language: @template.language 
      },
      email_type_option: true,
      visibility: "pub"
    }

    begin
      @gibbon.templates.create(body: body)
      flash[:success] = "Template created."
    rescue Gibbon::MailChimpError => error
      @template.errors[:base] << error
      false
    end
  end

  def params_template
    params.require(:template).permit(:name, :company, :address1, :city, :state, :zip, :country, :permission_reminder, :from_name, :from_email, :subject, :language)
  end
end
