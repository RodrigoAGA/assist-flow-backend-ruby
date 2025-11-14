# == Schema Information
#
# Table name: profiles
#
#  id              :uuid             not null, primary key
#  company_id      :uuid             not null
#  email           :string           not null
#  password_digest :string           not null
#  full_name       :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Profile < ApplicationRecord
  # Relationships
  belongs_to :company
  
  # Secure password
  has_secure_password
  
  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }
end
