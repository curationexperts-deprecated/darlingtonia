# frozen_string_literal: true

module Darlingtonia
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
    # @param parser [Parser]
    def initialize(parser:, record_importer: RecordImporter.new)
      self.parser          = parser
      self.record_importer = record_importer
    end

    ##
    # @return [void]
    def import
      records.each { |record| record_importer.import(record: record) }
    end
  end
end
