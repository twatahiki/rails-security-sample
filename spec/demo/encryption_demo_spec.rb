require "rails_helper"

RSpec.describe "Encryption Demo", type: :model do
  describe "User model without encryption (main branch)" do
    it "stores email as plain text in database" do
      user = User.create!(
        name: "Demo User",
        email: "demo@example.com",
        phone: "090-1234-5678",
        address: "Tokyo, Japan"
      )

      # Railsを通さずに直接DBを参照
      raw_record = ActiveRecord::Base.connection.execute(
        "SELECT email FROM users WHERE id = #{user.id}"
      ).first

      # mainブランチでは平文で保存される
      expect(raw_record.first).to eq("demo@example.com")
    end

    it "can search by email directly" do
      User.create!(name: "Search Test", email: "searchme@example.com")

      # 平文なので直接検索できる
      found = User.find_by(email: "searchme@example.com")
      expect(found).not_to be_nil
      expect(found.name).to eq("Search Test")
    end
  end

  describe "Data visibility demonstration" do
    before do
      User.create!(
        name: "Sensitive User",
        email: "sensitive@example.com",
        phone: "080-9999-8888",
        address: "Secret Location 123"
      )
    end

    it "exposes PII when querying database directly" do
      # DBに直接SQLを投げると個人情報が見える
      result = ActiveRecord::Base.connection.execute(
        "SELECT name, email, phone, address FROM users WHERE name = 'Sensitive User'"
      ).first

      # すべて平文で取得できてしまう（これが問題）
      expect(result).to include("sensitive@example.com")
      expect(result).to include("080-9999-8888")
      expect(result).to include("Secret Location 123")
    end
  end
end
