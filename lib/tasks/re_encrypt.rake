namespace :encryption do
  desc "Re-encrypt all encrypted attributes with the current primary key"
  task re_encrypt: :environment do
    puts "Starting re-encryption..."

    # User モデル
    user_count = 0
    User.find_each do |user|
      user.encrypt
      user_count += 1
      print "."
    end
    puts "\nUsers: #{user_count} records re-encrypted"

    puts "Re-encryption completed!"
  end

  desc "Show encryption status for a sample of records"
  task status: :environment do
    puts "=== Encryption Status ==="
    puts ""

    user = User.first
    if user
      puts "User ##{user.id}:"
      puts "  email (decrypted): #{user.email}"
      puts "  email (raw):       #{user.email_before_type_cast.truncate(60)}"
      puts "  phone (decrypted): #{user.phone}"
      puts "  phone (raw):       #{user.phone_before_type_cast&.truncate(60) || 'nil'}"
    else
      puts "No users found"
    end
  end
end
