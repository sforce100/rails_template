# Add the current directory to the path Thor uses
# to look up files
def source_paths
  Array(super) + 
    [File.expand_path(File.dirname(__FILE__))]
end
 
remove_file "Gemfile"
run "touch Gemfile"
add_source 'https://ruby.taobao.org'
gem 'rails', '4.2.1'
gem 'sqlite3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Unicorn as the app server
# gem 'unicorn'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem_group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-rvm'
end

# Bootstrap
gem 'bootstrap-sass'
gem 'bootstrap-datepicker-rails'
gem "font-awesome-rails"
gem "gon"
gem "jquery-tmpl-rails"
# General Rack Authentication Framework
gem 'warden'
# SEO
gem 'metamagic'
# eco页面渲染模版
gem 'eco'
# 禁用 烦人的 assets 请求日志
gem 'quiet_assets', :git => 'git://github.com/AgilionApps/quiet_assets.git'
# 网络请求
gem 'httpi'
gem 'httparty'
gem 'pry'
# yaml配置
gem 'settingslogic', '2.0.9'
# redis cache
gem 'redis-rails'
# cache
gem "redis", "~> 3.0.1"
gem "hiredis", "~> 0.4.5"
# 又拍云
gem 'rails-assets-for-upyun', '>= 0.0.9'

gem_group :test, :development do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  gem "rspec-rails"
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-rspec', require: false
  gem 'rack-livereload'
  gem 'rb-inotify', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-fchange', require: false
  gem 'terminal-notifier-guard'
  gem 'guard-cucumber'
  gem 'guard-bundler'
  gem 'guard-jruby-rspec', platforms: :jruby
  gem 'raddocs'
  gem 'rspec_api_documentation'
  gem "factory_girl_rails"
  gem 'cucumber-rails', require: false
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # run spring: spring binstub --all
  gem 'spring'
  # run spring rspec: bundle exec spring rspec
  gem 'spring-commands-rspec'
end

gem_group :test do
  # 测试覆盖率
  gem 'simplecov', require: false
  # Fuubar is an instafailing RSpec formatter that uses a progress bar instead of a string of letters and dots as feedback.
  gem 'fuubar'
  # test matchers
  gem 'shoulda-matchers', require: false
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  # generage mock data： Faker::Name.name => "Christophe Bartell"
  gem 'faker'
  # gem 'ruby_gntp'
  gem 'forgery'
end

# remove_file ".gitignore"
# copy_file ".gitignore"

# settingslogic
create_file "config/application.yml" do <<-EOF
# config/application.yml
defaults: &defaults

development:
  <<: *defaults

test:
  <<: *defaults

staging:
  <<: *defaults

production:
  <<: *defaults
EOF
end

create_file "app/models/settings.rb" do <<-'EOF'
class Settings < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env
end
EOF
end




after_bundle do
  run "spring stop"

  generate "rspec:install"
  # rspec settings 
  run "mkdir spec/factories spec/features spec/support"
  create_file "spec/support/factory_girl.rb" do <<-EOF
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
  EOF
  end

  create_file "spec/support/url_helpers.rb" do <<-EOF
RSpec.configure do |config|
  config.include Rails.application.routes.url_helpers
end
  EOF
  end

  insert_into_file 'spec/rails_helper.rb', after: "require 'rspec/rails'\n" do <<-EOF
require "capybara/rails"
require "shoulda/matchers"
  EOF
  end

  append_to_file '.rspec' do <<-EOF
--format Fuubar
--color
  EOF
  end

  run "guard init"
  generate "forgery"
  run "cap install"

  git :init
  git add: "."
  git commit: "-a -m 'Initial commit'"
end

