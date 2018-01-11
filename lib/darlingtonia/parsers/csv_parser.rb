# frozen_string_literal: true

require 'csv'

module Darlingtonia
  ##
  # A parser for CSV files
  class CsvParser < Parser
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
    end
  end
end
