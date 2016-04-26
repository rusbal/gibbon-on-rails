class List < ActiveType::Object

  # this is not backed by a db table

  attribute :name, :string
  attribute :company, :string
  attribute :address1, :string
  attribute :city, :string
  attribute :state, :string
  attribute :zip, :integer
  attribute :country, :string
  attribute :permission_reminder, :string
  attribute :from_name, :string
  attribute :from_email, :string
  attribute :subject, :string
  attribute :language, :string

  validates :name, presence: true
  validates :company, presence: true
  validates :address1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true, numericality: true
  validates :country, presence: true
  validates :permission_reminder, presence: true
  validates :from_name, presence: true
  validates :from_email, presence: true, email: true
  validates :subject, presence: true
  validates :language, presence: true

end
