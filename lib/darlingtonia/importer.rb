# frozen_string_literal: true

module Darlingtonia
  ##
  # The chief entry point for bulk import of records. `Importer` accepts a
  # {Parser} on initialization and iterates through its {Parser#records}, importing
  # each using a given {RecordImporter}.
  #
  # @example Importing in bulk from a CSV file
  #   parser = Darlingtonia::Parser.for(file: File.new('path/to/import.csv'))
  #
  #   Darlingtonia::Importer.new(parser: parser).import if parser.validate
  #
  class Importer
    extend Forwardable

    ##
    # @!attribute [rw] parser
    #   @return [Parser]
    # @!attribute [rw] record_importer
    #   @return [RecordImporter]
    attr_accessor :parser, :record_importer

    ##
    # @!method records()
    #   @see Parser#records
    def_delegator :parser, :records, :records

    ##
    # @param parser          [Parser] The parser to use as the source for import
    #   records.
    # @param record_importer [RecordImporter] An object to handle import of
    #   each record
    def initialize(parser:, record_importer: RecordImporter.new, info_stream: Darlingtonia.config.default_info_stream, error_stream: Darlingtonia.config.default_error_stream)
      self.parser          = parser
      self.record_importer = record_importer
      @info_stream = info_stream
      @error_stream = error_stream
    end

    ##
    # Import each record in {#records}.
    #
    # @return [void]
    def import
      start_time = Time.zone.now
      @info_stream << "event: start_import, batch_id: #{record_importer.batch_id}, expecting to import #{records.count} records."
      records.each { |record| record_importer.import(record: record) }
      end_time = Time.zone.now
      elapsed_time = end_time - start_time
      @info_stream << "event: finish_import, batch_id: #{record_importer.batch_id}, successful_record_count: #{record_importer.success_count}, failed_record_count: #{record_importer.failure_count}, elapsed_time: #{elapsed_time}, elapsed_time_per_record: #{elapsed_time/records.count}"
    end
  end
end
