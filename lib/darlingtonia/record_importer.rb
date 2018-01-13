# frozen_string_literal: true

module Darlingtonia
  class RecordImporter
    ##
    # @!attribute [rw] error_stream
    #   @return [#<<]
    attr_accessor :error_stream

    ##
    # @param error_stream [#<<]
    def initialize(error_stream: STDOUT)
      self.error_stream = error_stream
    end

    ##
    # @param record [ImportRecord]
    #
    # @return [void]
    def import(record:)
      import_type.create(record.attributes)
    rescue RuntimeError => e
      error_stream << e
      raise e
    end

    def import_type
      raise 'No curation_concern found for import' unless
        defined?(Hyrax) && Hyrax&.config&.curation_concerns&.any?

      Hyrax.config.curation_concerns.first
    end
  end
end
