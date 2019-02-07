# frozen_string_literal: true
require 'uri'

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
      single_value('depositor')
    end

    def date_uploaded
      single_value('date_uploaded')
    end

    def date_modified
      single_value('date_modified')
    end

    def label
      single_value('label')
    end

    def relative_path
      single_value('relative_path')
    end

    def import_url
      single_value('import_url')
    end

    def visibility
      single_value('visibility')
    end

    def files
      map_field('files')
    end

    ##
    # When submitting location data (a.k.a. the "based near" attribute) via the UI,
    # Hyrax expects to receive a `based_near_attributes` hash in a specific format.
    # We need to take geonames urls as provided by the customer and transform them to
    # mimic what the Hyrax UI would ordinarily produce. These will get turned into
    # Hyrax::ControlledVocabularies::Location objects upon ingest.
    # The expected hash looks like this:
    # {
    #   "based_near_attributes"=>
    #     {
    #       "0"=> {
    #               "hidden_label"=>"Montana",
    #               "id"=>"http://sws.geonames.org/5667009/", "_destroy"=>""
    #             },
    #       "1"=> {
    #               "hidden_label"=>"United States",
    #               "id"=>"http://sws.geonames.org/6252001/", "_destroy"=>""
    #             },
    #   }
    # }
    # @return [Hash] a "based_near_attributes" hash as
    def based_near
      original_geonames_uris = map_field('location')
      return if original_geonames_uris.empty?
      based_near_attributes = { "based_near_attributes" => {} }
      original_geonames_uris.each_with_index do |uri, i|
        based_near_attributes["based_near_attributes"][i.to_s] = { "hidden_label" => uri_to_hidden_label(uri), "id" => uri_to_sws(uri), "_destroy" => "" }
      end
      based_near_attributes
    end

    #
    # Take a geonames URI and return a label. This should be the last bit of the uri
    # (e.g., "montana.html") with the .html removed and the remaining part titleized.
    # @param [String] uri
    # @return [String] a place name
    def uri_to_hidden_label(uri)
      uri = URI(uri)
      uri.path.split('/')[-1].gsub('.html', '').tr('-', ' ').titleize
    end

    #
    # Take a user-facing geonames URI and return an sws URI, of the form Hyrax expects
    # (e.g., "http://sws.geonames.org/6252001/")
    # @param [String] uri
    # @return [String] an sws style geonames uri
    def uri_to_sws(uri)
      uri = URI(uri)
      geonames_number = uri.path.split('/')[1]
      "http://sws.geonames.org/#{geonames_number}/"
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
      method_name = name.to_s
      method_name = CSV_HEADERS[name] if CSV_HEADERS.keys.include?(name)
      key = matching_header(method_name)
      Array(metadata[key]&.split(delimiter))
    end

    protected

      # Some fields should have single values instead
      # of array values.
      def single_value(field_name)
        metadata[matching_header(field_name)]
      end

      # Lenient matching for headers.
      # If the user has headers like:
      #   'Title' or 'TITLE' or 'Title  '
      # it should match the :title field.
      def matching_header(field_name)
        metadata.keys.find do |key|
          next unless key
          key.downcase.strip == field_name
        end
      end

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
