# frozen_string_literal: true

module Darlingtonia
  ##
  # RSpec test support for {Darlingtonia} importers.
  #
  # @see https://relishapp.com/rspec/rspec-core/docs/
  module Spec
    require 'darlingtonia/spec/shared_examples/a_mapper'
    require 'darlingtonia/spec/shared_examples/a_parser'
    require 'darlingtonia/spec/shared_examples/a_validator'
    require 'darlingtonia/spec/fakes/fake_parser'
  end
end
