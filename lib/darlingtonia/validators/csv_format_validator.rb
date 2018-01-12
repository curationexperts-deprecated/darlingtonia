# frozen_string_literal: true

module Darlingtonia
  ##
  # A validator for correctly formatted CSV.
  #
  # @example
  #   parser = Parser.new(file: File.open('path/to/my.csv'))
  #
  #   CsvFormatValidator.new.validate(parser: parser)
  #
  # @see http://ruby-doc.org/stdlib-2.0.0/libdoc/csv/rdoc/CSV/MalformedCSVError.html
  class CsvFormatValidator < Validator
    ##
    # @see Validator#validate
    def validate(parser:, **)
      return [] if CSV.parse(parser.file.read)
    rescue CSV::MalformedCSVError => e
      [Error.new(self.class, e.class, e.message)]
    ensure
      parser.file.rewind
    end
  end
end
