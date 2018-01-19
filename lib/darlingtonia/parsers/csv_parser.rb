# frozen_string_literal: true

require 'csv'

module Darlingtonia
  ##
  # A parser for CSV files. A single `InputRecord` is returned for each row
  # parsed from the input.
  #
  # Validates the format of the CSV, generating a single error the file is
  # malformed. This error gives the line number and a message for the first
  # badly formatted row.
  #
  # @see CsvFormatValidator
  class CsvParser < Parser
    DEFAULT_VALIDATORS = [CsvFormatValidator.new].freeze
    EXTENSION = '.csv'

    class << self
      ##
      # Matches all '.csv' filenames.
      def match?(file:, **_opts)
        File.extname(file) == EXTENSION
      rescue TypeError
        false
      end
    end

    ##
    # Gives a record for each line in the .csv
    #
    # @see Parser#records
    def records
      return enum_for(:records) unless block_given?

      file.rewind

      CSV.parse(file.read, headers: true).each do |row|
        yield InputRecord.from(metadata: row)
      end
    rescue CSV::MalformedCSVError
      []
    end
  end
end
