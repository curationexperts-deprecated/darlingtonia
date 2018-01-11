# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'fcrepo_wrapper'
require 'solr_wrapper'
require 'active_fedora/rake_support'

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Bundler::GemHelper.install_tasks

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
end

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec)

desc 'Run specs with Fedora & Solr servers'
task :spec_with_server do
  with_test_server { Rake::Task['spec'].invoke }
end

desc 'Check style and run specs'
task ci: %w[rubocop spec_with_server]

task default: :ci
