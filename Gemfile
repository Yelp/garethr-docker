source "http://rubygems.org"

group :test do
  gem "rake", "~> 10.0"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem 'safe_yaml', '~> 1.0.4'
  gem "puppet-lint"
  gem "puppet-lint-unquoted_string-check"
  gem "rspec-puppet"
  gem "puppet-syntax", "2.1.0"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "beaker-rspec"
  gem "beaker", "~> 2.0"
  gem "puppet-blacksmith"
  gem "guard-rake"
  gem "pry"
  gem "yard"
  gem "vagrant-wrapper"
end
