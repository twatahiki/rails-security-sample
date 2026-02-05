require "rails_helper"

RSpec.describe Inquiry, type: :model do
  let(:user) { User.create!(name: "Test User", email: "test@example.com") }

  describe "validations" do
    it "is valid with subject and body" do
      inquiry = Inquiry.new(user: user, subject: "Test Subject", body: "Test Body")
      expect(inquiry).to be_valid
    end

    it "is invalid without subject" do
      inquiry = Inquiry.new(user: user, body: "Test Body")
      expect(inquiry).not_to be_valid
      expect(inquiry.errors[:subject]).to include("can't be blank")
    end

    it "is invalid without body" do
      inquiry = Inquiry.new(user: user, subject: "Test Subject")
      expect(inquiry).not_to be_valid
      expect(inquiry.errors[:body]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end
  end
end
