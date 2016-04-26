class Subscriber < ActiveType::Object

  # this is not backed by a db table

  attribute :email_address, :string
  attribute :fname, :string
  attribute :lname, :string
  attribute :subscribed, :boolean, default: true

  validates :email_address, presence: true
  validates :fname, presence: true
  validates :lname, presence: true

end
