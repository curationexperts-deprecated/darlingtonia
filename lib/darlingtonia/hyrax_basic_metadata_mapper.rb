# frozen_string_literal: true

module Darlingtonia
  ##
  # A mapper for Hyrax metadata.
  #
  # Maps from hash accessor syntax (`['title']`) to method call dot syntax (`.title`).
  #
  # The fields provided by this mapper are the same as the properties defined in `Hyrax::CoreMetadata` and `Hyrax::BasicMetadata`.
  #
  # @note This mapper allows you to set values for all the Hyrax fields, but depending on how you create the records, some of the values might get clobbered.  For example, if you use Hyrax's actor stack to create records, it might overwrite fields like `date_modified` or `depositor`.
  #
  # @see HashMapper Parent class for more info and examples.
  class HyraxBasicMetadataMapper < HashMapper
    # If your CSV headers don't exactly match the
    # the method name for the property's setter
    # method, add a mapping here.
    # Example: the method name is work.resource_type,
    # but in the CSV file, the header is
    # 'resource type' (without the underscore).
    CSV_HEADERS = {
      resource_type: 'resource type',
      description: 'abstract or summary',
      rights_statement: 'rights statement',
      date_created: 'date created',
      based_near: 'location',
      related_url: 'related url'
    }.freeze

    ##
    # @return [Enumerable<Symbol>] The fields the mapper can process.
    def fields
      core_fields + basic_fields + [:visibility]
    end

    # Properties defined with `multiple: false` in
    # Hyrax should return a single value instead of
    # an Array of values.
    def depositor
      metadata['depositor']
    end

    def date_uploaded
      metadata['date_uploaded']
    end

    def date_modified
      metadata['date_modified']
    end

    def label
      metadata['label']
    end

    def relative_path
      metadata['relative_path']
    end

    def import_url
      metadata['import_url']
    end

    def visibility
      metadata['visibility']
    end

    ##
    # @return [String] The delimiter that will be used to split a metadata field into separate values.
    # @example
    #   mapper = HyraxBasicMetadataMapper.new
    #   mapper.metadata = { 'language' => 'English|~|French|~|Japanese' }
    #   mapper.language = ['English', 'French', 'Japanese']
    #
    def delimiter
      @delimiter ||= '|~|'
    end
    attr_writer :delimiter

    ##
    # @see MetadataMapper#map_field
    def map_field(name)
      method_name = name
      method_name = CSV_HEADERS[name] if CSV_HEADERS.keys.include?(name)
      Array(metadata[method_name.to_s]&.split(delimiter))
    end

    protected

      # Properties defined in Hyrax::CoreMetadata
      def core_fields
        [:depositor, :title, :date_uploaded, :date_modified]
      end

      # Properties defined in Hyrax::BasicMetadata
      def basic_fields
        [:label, :relative_path, :import_url,
         :resource_type, :creator, :contributor,
         :description, :keyword, :license,
         :rights_statement, :publisher, :date_created,
         :subject, :language, :identifier,
         :based_near, :related_url,
         :bibliographic_citation, :source]
      end
  end
end
