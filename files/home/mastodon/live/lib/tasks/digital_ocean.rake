# frozen_string_literal: true

require 'tty-prompt'
require 'tty-reader'

namespace :digitalocean do
  desc 'Configure the instance for production use'
  task :setup do
    prompt = TTY::Prompt.new
    env    = {}

    begin
      prompt.ok('Welcome to the Mastodon first-time setup!')

      env['LOCAL_DOMAIN'] = prompt.ask('Domain name:') do |q|
        q.required true
        q.modify :strip
        q.validate(/\A[a-z0-9\.\-]+\z/i)
        q.messages[:valid?] = 'Invalid domain. If you intend to use unicode characters, enter punycode here'
      end

      %w(SECRET_KEY_BASE OTP_SECRET).each do |key|
        env[key] = SecureRandom.hex(64)
      end

      vapid_key = Webpush.generate_key

      env['VAPID_PRIVATE_KEY'] = vapid_key.private_key
      env['VAPID_PUBLIC_KEY']  = vapid_key.public_key

      using_docker        = false
      db_connection_works = true

      env['DB_HOST'] = '/var/run/postgresql'
      env['DB_PORT'] = 5432
      env['DB_NAME'] = 'mastodon_production'
      env['DB_USER'] = 'mastodon'

      env['REDIS_HOST'] = 'localhost'
      env['REDIS_PORT'] = 6379

      if prompt.yes?('Do you want to store user-uploaded files on the cloud?', default: false)
        case prompt.select('Provider', ['DigitalOcean Space','Amazon S3', 'Wasabi', 'Minio', 'Google Cloud Storage'])
        when 'DigitalOcean Space'
          env['S3_ENABLED'] = 'true'
          env['S3_PROTOCOL'] = 'https'

          env['S3_BUCKET'] = prompt.ask('Space name:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end

          env['S3_REGION'] = prompt.ask('Space region:') do |q|
            q.required true
            q.default 'nyc3'
            q.modify :strip
          end

          env['S3_HOSTNAME'] = prompt.ask('Space endpoint:') do |q|
            q.required true
            q.default 'nyc3.digitaloceanspaces.com'
            q.modify :strip
          end

          env['S3_ENDPOINT'] = 'https://' + env['S3_HOSTNAME']

          env['AWS_ACCESS_KEY_ID'] = prompt.ask('Space access key:') do |q|
            q.required true
            q.modify :strip
          end

          env['AWS_SECRET_ACCESS_KEY'] = prompt.ask('Space secret key:') do |q|
            q.required true
            q.modify :strip
          end
        when 'Amazon S3'
          env['S3_ENABLED']  = 'true'
          env['S3_PROTOCOL'] = 'https'

          env['S3_BUCKET'] = prompt.ask('S3 bucket name:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end

          env['S3_REGION'] = prompt.ask('S3 region:') do |q|
            q.required true
            q.default 'us-east-1'
            q.modify :strip
          end

          env['S3_HOSTNAME'] = prompt.ask('S3 hostname:') do |q|
            q.required true
            q.default 's3-us-east-1.amazonaws.com'
            q.modify :strip
          end

          env['AWS_ACCESS_KEY_ID'] = prompt.ask('S3 access key:') do |q|
            q.required true
            q.modify :strip
          end

          env['AWS_SECRET_ACCESS_KEY'] = prompt.ask('S3 secret key:') do |q|
            q.required true
            q.modify :strip
          end
        when 'Wasabi'
          env['S3_ENABLED']  = 'true'
          env['S3_PROTOCOL'] = 'https'
          env['S3_REGION']   = 'us-east-1'
          env['S3_HOSTNAME'] = 's3.wasabisys.com'
          env['S3_ENDPOINT'] = 'https://s3.wasabisys.com/'

          env['S3_BUCKET'] = prompt.ask('Wasabi bucket name:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end

          env['AWS_ACCESS_KEY_ID'] = prompt.ask('Wasabi access key:') do |q|
            q.required true
            q.modify :strip
          end

          env['AWS_SECRET_ACCESS_KEY'] = prompt.ask('Wasabi secret key:') do |q|
            q.required true
            q.modify :strip
          end
        when 'Minio'
          env['S3_ENABLED']  = 'true'
          env['S3_PROTOCOL'] = 'https'
          env['S3_REGION']   = 'us-east-1'

          env['S3_ENDPOINT'] = prompt.ask('Minio endpoint URL:') do |q|
            q.required true
            q.modify :strip
          end

          env['S3_PROTOCOL'] = env['S3_ENDPOINT'].start_with?('https') ? 'https' : 'http'
          env['S3_HOSTNAME'] = env['S3_ENDPOINT'].gsub(/\Ahttps?:\/\//, '')

          env['S3_BUCKET'] = prompt.ask('Minio bucket name:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end

          env['AWS_ACCESS_KEY_ID'] = prompt.ask('Minio access key:') do |q|
            q.required true
            q.modify :strip
          end

          env['AWS_SECRET_ACCESS_KEY'] = prompt.ask('Minio secret key:') do |q|
            q.required true
            q.modify :strip
          end
        when 'Google Cloud Storage'
          env['S3_ENABLED']             = 'true'
          env['S3_PROTOCOL']            = 'https'
          env['S3_HOSTNAME']            = 'storage.googleapis.com'
          env['S3_ENDPOINT']            = 'https://storage.googleapis.com'
          env['S3_MULTIPART_THRESHOLD'] = 50.megabytes

          env['S3_BUCKET'] = prompt.ask('GCS bucket name:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end

          env['S3_REGION'] = prompt.ask('GCS region:') do |q|
            q.required true
            q.default 'us-west1'
            q.modify :strip
          end

          env['AWS_ACCESS_KEY_ID'] = prompt.ask('GCS access key:') do |q|
            q.required true
            q.modify :strip
          end

          env['AWS_SECRET_ACCESS_KEY'] = prompt.ask('GCS secret key:') do |q|
            q.required true
            q.modify :strip
          end
        end

        if prompt.yes?('Do you want to access the uploaded files from your own domain?')
          env['S3_ALIAS_HOST'] = prompt.ask('Domain for uploaded files:') do |q|
            q.required true
            q.default "files.#{env['LOCAL_DOMAIN']}"
            q.modify :strip
          end
        end
      end

      loop do
        env['SMTP_SERVER'] = prompt.ask('SMTP server:') do |q|
          q.required true
          q.default 'smtp.mailgun.org'
          q.modify :strip
        end

        env['SMTP_PORT'] = prompt.ask('SMTP port:') do |q|
          q.required true
          q.default 587
          q.convert :int
        end

        env['SMTP_LOGIN'] = prompt.ask('SMTP username:') do |q|
          q.modify :strip
        end

        env['SMTP_PASSWORD'] = prompt.ask('SMTP password:') do |q|
          q.echo false
        end

        env['SMTP_AUTH_METHOD'] = prompt.ask('SMTP authentication:') do |q|
          q.required
          q.default 'plain'
          q.modify :strip
        end

        env['SMTP_OPENSSL_VERIFY_MODE'] = prompt.select('SMTP OpenSSL verify mode:', %w(none peer client_once fail_if_no_peer_cert))

        env['SMTP_FROM_ADDRESS'] = prompt.ask('E-mail address to send e-mails "from":') do |q|
          q.required true
          q.default "Mastodon <notifications@#{env['LOCAL_DOMAIN']}>"
          q.modify :strip
        end

        break unless prompt.yes?('Send a test e-mail with this configuration right now?')

        send_to = prompt.ask('Send test e-mail to:', required: true)

        begin
          ActionMailer::Base.smtp_settings = {
            port:                 env['SMTP_PORT'],
            address:              env['SMTP_SERVER'],
            user_name:            env['SMTP_LOGIN'].presence,
            password:             env['SMTP_PASSWORD'].presence,
            domain:               env['LOCAL_DOMAIN'],
            authentication:       env['SMTP_AUTH_METHOD'] == 'none' ? nil : env['SMTP_AUTH_METHOD'] || :plain,
            openssl_verify_mode:  env['SMTP_OPENSSL_VERIFY_MODE'],
            enable_starttls_auto: true,
          }

          ActionMailer::Base.default_options = {
            from: env['SMTP_FROM_ADDRESS'],
          }

          mail = ActionMailer::Base.new.mail to: send_to, subject: 'Test', body: 'Mastodon SMTP configuration works!'
          mail.deliver
          break
        rescue StandardError => e
          prompt.error 'E-mail could not be sent with this configuration, try again.'
          prompt.error e.message
          break unless prompt.yes?('Try again?')
        end
      end

      prompt.ok "Great! Saving this configuration..."

      File.write(Rails.root.join('.env.production'), "# Generated with mastodon:setup on #{Time.now.utc}\n\n" + env.each_pair.map { |key, value| "#{key}=#{value}" }.join("\n") + "\n")

      prompt.say "Booting up Mastodon..."

      env.each_pair do |key, value|
        ENV[key] = value.to_s
      end

      require_relative '../../config/environment'
      disable_log_stdout!

      if !system(env.transform_values(&:to_s).merge({ 'RAILS_ENV' => 'production' }), 'rails db:seed')
        prompt.error 'Could not seed the database, aborting'
        exit(1)
      end

      prompt.ok "It is time to create an admin account that you'll be able to use from the browser!"

      username = prompt.ask('Username:') do |q|
        q.required true
        q.default 'admin'
        q.validate(/\A[a-z0-9_]+\z/i)
        q.modify :strip
        end

      email = prompt.ask('E-mail:') do |q|
        q.required true
        q.modify :strip
      end

      password = SecureRandom.hex(16)

      if (existing_user = User.find_by(email: email))
        existing_user.account&.destroy
        existing_user.destroy
      end

      if (existing_account = Account.find_local(username))
        existing_account.user&.destroy
        existing_account.destroy
      end

      user = User.new(admin: true, email: email, password: password, confirmed_at: Time.now.utc, account_attributes: { username: username })
      user.save(validate: false)

      prompt.ok "You can login with the password: #{password}"
      prompt.ok "The web interface should be momentarily accessible via https://#{env['LOCAL_DOMAIN']}/"
    rescue TTY::Reader::InputInterrupt
      prompt.ok 'Aborting. Bye!'
      exit(1)
    end
  end
end

def disable_log_stdout!
  dev_null = Logger.new('/dev/null')

  Rails.logger                 = dev_null
  ActiveRecord::Base.logger    = dev_null
  HttpLog.configuration.logger = dev_null
  Paperclip.options[:log]      = false
end
