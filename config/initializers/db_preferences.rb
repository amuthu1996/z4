case ActiveRecord::Base.connection_config[:adapter]
when 'mysql2'
  Rails.application.config.db_4bytes_utf8 = false
  Rails.application.config.db_case_sensitive = false
  Rails.application.config.db_like = 'LIKE'
  Rails.application.config.db_null_byte = true
when 'postgresql'
  Rails.application.config.db_4bytes_utf8 = true
  Rails.application.config.db_case_sensitive = true
  Rails.application.config.db_like = 'ILIKE'
  Rails.application.config.db_null_byte = false

  Underlock::Base.configure do |config|
    config.public_key  = File.read('./key.pub')
    config.private_key = File.read('./key.priv')
    config.cipher      = OpenSSL::Cipher.new('aes-256-gcm')
  end

when 'sqlite3'
  Rails.application.config.db_4bytes_utf8 = true
  Rails.application.config.db_case_sensitive = true
  Rails.application.config.db_like = 'ILIKE'
  Rails.application.config.db_null_byte = false
end
