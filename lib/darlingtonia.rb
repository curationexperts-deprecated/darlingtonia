# frozen_string_literal: true

##
# Bulk object import for Samvera.
#
# == Importers
#
# {Importer} is the core class for importing records using {Darlingtonia}.
# Importers accept a {Parser} and (optionally) a custom {RecordImporter}, and
# process each record in the given parser (see: {Parser#records}).
#
# @example Importing in bulk from a file
#   parser = Darlingtonia::Parser.for(file: File.new('path/to/file.ext'))
#
#   Darlingtonia::Importer.new(parser: parser).import if parser.validate
#
# @example A basic configuration
#   Darlingtonia.config do |config|
#     # error/info streams must respond to `#<<`
#     config.default_error_stream = MyErrorStream.new
#     config.default_info_stream  = STDOUT
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

  require 'darlingtonia/log_stream'
  ##
  # Module-wide options for `Darlingtonia`.
  class Configuration
    ##
    # @!attribute [rw] default_error_stream
    #   @return [#<<]
    # @!attribute [rw] default_info_stream
    #   @return [#<<]
    attr_accessor :default_error_stream, :default_info_stream

    def initialize
      self.default_error_stream = Darlingtonia::LogStream.new
      self.default_info_stream  = Darlingtonia::LogStream.new
    end
  end

  @configuration = Configuration.new

  require 'darlingtonia/version'
  require 'darlingtonia/metadata_mapper'
  require 'darlingtonia/hash_mapper'
  require 'darlingtonia/hyrax_basic_metadata_mapper'

  require 'darlingtonia/importer'
  require 'darlingtonia/record_importer'
  require 'darlingtonia/hyrax_record_importer'

  require 'darlingtonia/input_record'

  require 'darlingtonia/validator'
  require 'darlingtonia/validators/csv_format_validator'
  require 'darlingtonia/validators/title_validator'

  require 'darlingtonia/parser'
  require 'darlingtonia/parsers/csv_parser'
  require 'darlingtonia/metadata_only_stack'
end
