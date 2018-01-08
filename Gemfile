# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

unless ENV['CI']
  gem 'guard'
  gem 'pry'
end
