# frozen_string_literal: true

require 'pry' unless ENV['CI']
ENV['environment'] ||= 'test'

require 'bundler/setup'
require 'active_fedora'
require 'active_fedora/cleaner'
require 'darlingtonia'
require 'darlingtonia/spec'
require 'byebug'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:each, clean: true) { ActiveFedora::Cleaner.clean! }
end
