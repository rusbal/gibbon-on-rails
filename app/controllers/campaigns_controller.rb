class CampaignsController < ApplicationController
  before_action :load_mailchimp_campaign, only: [:edit, :update]
  before_action :set_template, only: [:new, :create]

  def index
    @campaigns = @gibbon.campaigns.retrieve(params: {count: "30"})["campaigns"]
  end

  def show 
    begin
      @gibbon.campaigns.send(params[:id]).actions.send.create
      flash[:success] = "Campaign sent."
    rescue Gibbon::MailChimpError => error
      flash[:error] = error
      false
    end

    redirect_to campaigns_path
  end

  def new 
    @campaign = Campaign.new
    @campaign.template_id = @template["id"]
  end

  def create
    save_campaign or render 'new'
  end

  def edit
  end

  def update
    update_campaign or render 'edit'
  end

  def destroy
    begin
      @gibbon.campaigns(params[:id]).delete
      flash[:success] = "Campaign deleted."
    rescue Gibbon::MailChimpError => error
      flash[:error] = error
      false
    end

    redirect_to campaigns_path
  end

  private

  def load_mailchimp_campaign
    mc = @gibbon.campaigns(params[:id]).retrieve
    @campaign = Campaign.create({
      template_id:  mc["settings"]["template_id"],
      list_id:      mc["recipients"]["list_id"],
      subject_line: mc["settings"]["subject_line"],
      title:        mc["settings"]["title"],
      from_name:    mc["settings"]["from_name"],
      reply_to:     mc["settings"]["reply_to"]
    })
    @campaign.id = params[:id] # Presense of ID field triggers update
    set_template @campaign.template_id
  end

  def save_campaign 
    @campaign = Campaign.new(params_campaign)
    @campaign.template_id = @template["id"]

    if @campaign.valid?
      if gibbon_save_campaign
        redirect_to campaigns_path
      end
    end
  end

  def update_campaign 
    p = params_campaign

    @campaign.template_id  = p[:template_id]
    @campaign.list_id      = p[:list_id]
    @campaign.subject_line = p[:subject_line]
    @campaign.title        = p[:title]
    @campaign.from_name    = p[:from_name]
    @campaign.reply_to     = p[:reply_to]

    if @campaign.valid?
      if gibbon_update_campaign
        redirect_to campaigns_path
      end
    end
  end

  def gibbon_save_campaign
    recipients = { list_id: @campaign.list_id }
    settings = { 
      :subject_line => @campaign.subject_line, 
      :title => @campaign.title,
      :from_name => @campaign.from_name,
      :reply_to => @campaign.reply_to
    }
    body = { 
      type: "regular", 
      recipients: recipients, 
      settings: settings
    }
    update_body = { 
      template: { id: @campaign.template_id } 
    }

    begin
      campaign = @gibbon.campaigns.create(body: body)

      @gibbon.campaigns(campaign["id"]).content.upsert(body: update_body)
      flash[:success] = "Campaign created."
      true

    rescue Gibbon::MailChimpError => error
      # puts "Gibbon::MailChimpError: #{e.message} - #{e.raw_body}"
      @campaign.errors[:base] << error
      false
    end
  end

  def gibbon_update_campaign
    recipients = { list_id: @campaign.list_id }
    settings = { 
      :subject_line => @campaign.subject_line, 
      :title => @campaign.title,
      :from_name => @campaign.from_name,
      :reply_to => @campaign.reply_to
    }
    body = { 
      type: "regular", 
      recipients: recipients, 
      settings: settings, 
      template: { id: @campaign.template_id } 
    }

    begin

      # @gibbon.campaigns(params[:id]).content.upsert(body: body)
      # @gibbon.campaigns(params[:id]).update(body: body)

      @gibbon.campaigns.send(params[:id]).update(body: body)

      flash[:success] = "Campaign updated."
      true

    rescue Gibbon::MailChimpError => error
      @campaign.errors[:base] << error
      false
    end
  end

  def set_template(id = nil)
    template_id = get_template_id

    if template_id.blank?
      template_id = id
    end

    if template_id == 0 || template_id.blank?
      flash[:info] = "Select template to use on campaign."
      redirect_to templates_path(campaign_id: params[:id])

    else
      begin
        @template = @gibbon.templates(template_id).retrieve

      rescue Gibbon::MailChimpError => error
        flash[:danger] = "Template ID: %s cannot be used." % template_id
        flash[:error] = error
        redirect_to templates_path
      end
    end
  end

  def get_template_id
    params[:template_id] || (params[:campaign][:template_id] if params[:campaign])
  end

  def params_campaign
    params.require(:campaign).permit(:template_id, :list_id, :subject_line, :title, :from_name, :reply_to)
  end

end

