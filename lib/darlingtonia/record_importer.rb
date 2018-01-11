# frozen_string_literal: true

module Darlingtonia
  class RecordImporter
    ##
    # @param record [ImportRecord]
    #
    # @return [void]
    def import(record:)
      import_type.create(record.attributes)
    end

    def import_type
      raise 'No curation_concern found for import' unless
        defined?(Hyrax) && Hyrax&.config&.curation_concerns&.any?

      Hyrax.config.curation_concerns.first
    end
  end
end
