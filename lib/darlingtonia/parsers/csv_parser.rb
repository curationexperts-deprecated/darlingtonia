module Darlingtonia
  ##
  # A parser for CSV files
  class CsvParser < Parser
    EXTENSION = '.csv'.freeze

    class << self
      ##
      # @
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
      []
    end
  end
end
