class Campaign < ActiveType::Object

  # this is not backed by a db table

  attribute :id, :string
  attribute :template_id, :integer
  attribute :list_id, :string
  attribute :subject_line, :string
  attribute :title, :string
  attribute :from_name, :string
  attribute :reply_to, :string

  validates :template_id, presence: true
  validates :list_id, presence: true
  validates :subject_line, presence: true
  validates :title, presence: true
  validates :from_name, presence: true
  validates :reply_to, presence: true, email: true

end
