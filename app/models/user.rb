class User < ApplicationRecord
  has_many :inquiries, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
