# frozen_string_literal: true

require 'active_fedora'

##
# Bulk object import for Hyrax.
#
# @example A basic configuration
#   Darlingtonia.config do |config|
#     # error streams must respond to `#<<`
#     config.default_error_stream = MyErrorStream.new
#   end
#
module Darlingtonia
  ##
  # @yield the current configuration
  # @yieldparam config [Darlingtonia::Configuration]
  #
  # @return [Darlingtonia::Configuration] the current configuration
  def config
    yield @configuration if block_given?
    @configuration
  end
  module_function :config

  ##
  # Module-wide options for `Darlingtonia`.
  class Configuration
    ##
    # @!attribute [rw] default_error_stream
    #   @return [#<<]
    attr_accessor :default_error_stream

    def initialize
      self.default_error_stream = STDOUT
    end
  end

  @configuration = Configuration.new

  require 'darlingtonia/version'
  require 'darlingtonia/hash_mapper'

  require 'darlingtonia/importer'
  require 'darlingtonia/record_importer'

  require 'darlingtonia/input_record'

  require 'darlingtonia/validator'
  require 'darlingtonia/validators/csv_format_validator'

  require 'darlingtonia/parser'
  require 'darlingtonia/parsers/csv_parser'
end
