require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with name and email" do
      user = User.new(name: "Test User", email: "test@example.com")
      expect(user).to be_valid
    end

    it "is invalid without name" do
      user = User.new(email: "test@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "is invalid without email" do
      user = User.new(name: "Test User")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is invalid with duplicate email" do
      User.create!(name: "User 1", email: "duplicate@example.com")
      user = User.new(name: "User 2", email: "duplicate@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end
  end

  describe "associations" do
    it "has many inquiries" do
      association = described_class.reflect_on_association(:inquiries)
      expect(association.macro).to eq(:has_many)
    end
  end
end
