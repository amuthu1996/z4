source 'https://rubygems.org'

# core - base
ruby '2.5.5'
gem 'rails', '5.2.3'

# core - rails additions
gem 'activerecord-import'
gem 'activerecord-session_store'
gem 'bootsnap', require: false
gem 'composite_primary_keys'
gem 'json'
gem 'rails-observers'

# core - application servers
gem 'puma', group: :puma
gem 'unicorn', group: :unicorn
gem 'underlock', '~> 0.0.5'

# core - supported ORMs
gem 'activerecord-nulldb-adapter', group: :nulldb
gem 'mysql2', '0.4.10', group: :mysql
gem 'pg', '0.21.0', group: :postgres

# core - asynchrous task execution
gem 'daemons'
gem 'delayed_job_active_record'

# core - websocket
gem 'em-websocket'
gem 'eventmachine'

# core - password security
gem 'argon2'

# core - state machine
gem 'aasm'

# performance - Memcached
gem 'dalli'

# asset handling - coffee-script
gem 'coffee-rails'
gem 'coffee-script-source'

# asset handling - frontend templating
gem 'eco'

# asset handling - SASS
gem 'sassc-rails'

# asset handling - pipeline
gem 'sprockets'
gem 'uglifier'

gem 'autoprefixer-rails'

# asset handling - javascript execution for e.g. linux
gem 'execjs'
gem 'libv8'
gem 'mini_racer'

# authentication - provider
gem 'doorkeeper'
gem 'oauth2'

# authentication - third party
gem 'omniauth-rails_csrf_protection'

# authentication - third party providers
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-gitlab'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-microsoft-office365'
gem 'omniauth-oauth2'
gem 'omniauth-saml'
gem 'omniauth-twitter'
gem 'omniauth-weibo-oauth2'

# channels
gem 'koala'
gem 'telegramAPI'
gem 'twitter', git: 'https://github.com/sferik/twitter.git'

# channels - email additions
gem 'htmlentities'
gem 'mail', git: 'https://github.com/zammad-deps/mail', branch: '2-7-stable'
gem 'mime-types'
gem 'rchardet', '>= 1.8.0'
gem 'valid_email2'

# feature - business hours
gem 'biz'

# feature - signature diffing
gem 'diffy'

# feature - excel output
gem 'writeexcel'

# feature - device logging
gem 'browser'

# feature - iCal export
gem 'icalendar'
gem 'icalendar-recurrence'

# feature - phone number formatting
gem 'telephone_number'

# feature - SMS
gem 'twilio-ruby'

# feature - ordering
gem 'acts_as_list'

# integrations
gem 'clearbit'
gem 'net-ldap'
gem 'slack-notifier'
gem 'zendesk_api'

# integrations - exchange
gem 'autodiscover', git: 'https://github.com/zammad-deps/autodiscover'
gem 'rubyntlm', git: 'https://github.com/wimm/rubyntlm'
gem 'viewpoint'

# image processing
gem 'rszr', '0.5.2'

# Gems used only for develop/test and not required
# in production environments by default.
group :development, :test do

  # app boottime improvement
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-testunit'

  # debugging
  gem 'byebug'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'

  # test frameworks
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'test-unit'

  # code coverage
  gem 'coveralls', require: false
  gem 'simplecov'
  gem 'simplecov-rcov'

  # UI tests w/ Selenium
  gem 'capybara'
  gem 'selenium-webdriver'

  # livereload on template changes (html, js, css)
  gem 'guard',             require: false
  gem 'guard-livereload',  require: false
  gem 'rack-livereload',   require: false
  gem 'rb-fsevent',        require: false

  # auto symlinking
  gem 'guard-symlink', require: false

  # code QA
  gem 'coffeelint'
  gem 'pre-commit'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'

  # changelog generation
  gem 'github_changelog_generator'

  # generate random test data
  gem 'factory_bot_rails'
  gem 'faker'

  # mock http calls
  gem 'webmock'

  # record and replay TCP/HTTP transactions
  gem 'tcr', git: 'https://github.com/zammad-deps/tcr'
  gem 'vcr'

  # handle deprecations in core and addons
  gem 'deprecation_toolkit'
end

# Want to extend Zammad with additional gems?
# ZAMMAD USERS: Specify them in Gemfile.local
#               (That way, you can customize the Gemfile
#               without having your changes overwritten during upgrades.)
# ZAMMAD DEVS:  Consult the internal wiki
#               (or else risk pushing unwanted changes to Gemfile.lock!)
#               https://git.znuny.com/zammad/zammad/wikis/Tips#user-content-customizing-the-gemfile
eval_gemfile 'Gemfile.local' if File.exist?('Gemfile.local')
