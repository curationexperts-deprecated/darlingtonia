# frozen_string_literal: true

module Darlingtonia
  class RecordImporter
    ##
    # @!attribute [rw] error_stream
    #   @return [#<<]
    # @!attribute [rw] info_stream
    #   @return [#<<]
    # @!attribute [rw] batch_id
    #   @return [String] an optional batch id for this import run
    # @!attribute [rw] success_count
    #   @return [Integer] a count of the records that were successfully created
    # @!attribute [rw] failure_count
    #   @return [Integer] a count of the records that failed import
    attr_accessor :error_stream, :info_stream, :batch_id, :success_count, :failure_count

    ##
    # @param error_stream [#<<]
    def initialize(error_stream: Darlingtonia.config.default_error_stream,
                   info_stream: Darlingtonia.config.default_info_stream)
      self.error_stream = error_stream
      self.info_stream  = info_stream
    end

    ##
    # @param record [ImportRecord]
    #
    # @return [void]
    def import(record:)
      create_for(record: record)
    rescue Faraday::ConnectionFailed, Ldp::HttpError => e
      error_stream << e
    rescue RuntimeError => e
      error_stream << e
      raise e
    end

    def import_type
      raise 'No curation_concern found for import' unless
        defined?(Hyrax) && Hyrax&.config&.curation_concerns&.any?

      Hyrax.config.curation_concerns.first
    end

    private

      def create_for(record:)
        info_stream << 'Creating record: ' \
                       "#{record.respond_to?(:title) ? record.title : record}."

        created = import_type.create(record.attributes)

        info_stream << "Record created at: #{created.id}"
      end
  end
end
