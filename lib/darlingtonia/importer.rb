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

    # Do not attempt to run an import if there are no records. Instead, just write to the log.
    def no_records_message
      @info_stream << "event: empty_import, batch_id: #{record_importer.batch_id}"
      @error_stream << "event: empty_import, batch_id: #{record_importer.batch_id}"
    end

    ##
    # Import each record in {#records}.
    #
    # @return [void]
    def import
      no_records_message && return unless records.count.positive?
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @info_stream << "event: start_import, batch_id: #{record_importer.batch_id}, expecting to import #{records.count} records."
      records.each { |record| record_importer.import(record: record) }
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      elapsed_time = end_time - start_time
      @info_stream << "event: finish_import, batch_id: #{record_importer.batch_id}, successful_record_count: #{record_importer.success_count}, failed_record_count: #{record_importer.failure_count}, elapsed_time: #{elapsed_time}, elapsed_time_per_record: #{elapsed_time / records.count}"
    end
  end
end
