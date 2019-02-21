# frozen_string_literal: true

module Darlingtonia
  class HyraxRecordImporter < RecordImporter
    # TODO: Get this from Hyrax config
    DEFAULT_CREATOR_KEY = 'batchuser@example.com'

    # @!attribute [rw] depositor
    # @return [User]
    attr_accessor :depositor

    # @!attribute [rw] collection_id
    # @return [String] The fedora ID for a Collection.
    attr_accessor :collection_id

    # @!attribute [rw] batch_id
    # @return [String] an id number associated with the process that kicked off this import run
    attr_accessor :batch_id

    # @!attribute [rw] success_count
    # @return [String] the number of records this importer has successfully created
    attr_accessor :success_count

    # @!attribute [rw] failure_count
    # @return [String] the number of records this importer has failed to create
    attr_accessor :failure_count

    # @param attributes [Hash] Attributes that come
    #        from the UI or importer rather than from
    #        the CSV/mapper. These are useful for logging
    #        and tracking the output of an import job for
    #        a given collection, user, or batch.
    # @example
    #   attributes: { collection_id: '123',
    #                 depositor_id: '456',
    #                 batch_id: '789' }
    def initialize(error_stream: Darlingtonia.config.default_error_stream,
                   info_stream: Darlingtonia.config.default_info_stream,
                   attributes: {})
      self.collection_id = attributes[:collection_id]
      self.batch_id = attributes[:batch_id]
      set_depositor(attributes[:depositor_id])
      @success_count = 0
      @failure_count = 0
      super(error_stream: error_stream, info_stream: info_stream)
    end

    # "depositor" is a required field for Hyrax.  If
    # it hasn't been set, set it to the Hyrax default
    # batch user.
    def set_depositor(user_id)
      user = User.find(user_id) if user_id
      user ||= ::User.find_or_create_system_user(DEFAULT_CREATOR_KEY)
      self.depositor = user
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

    # TODO: You should be able to specify the import type in the import
    def import_type
      raise 'No curation_concern found for import' unless
        defined?(Hyrax) && Hyrax&.config&.curation_concerns&.any?

      Hyrax.config.curation_concerns.first
    end

    # The path on disk where file attachments can be found
    def file_attachments_path
      ENV['IMPORT_PATH'] || '/opt/data'
    end

    # Create a Hyrax::UploadedFile for each file attachment
    # TODO: What if we can't find the file?
    # TODO: How do we specify where the files can be found?
    # @param [Darlingtonia::InputRecord]
    # @return [Array] an array of Hyrax::UploadedFile ids
    def create_upload_files(record)
      files_to_attach = record.mapper.files
      return [] if files_to_attach.nil? || files_to_attach.empty?

      uploaded_file_ids = []
      files_to_attach.each do |filename|
        file = File.open(find_file_path(filename))
        uploaded_file = Hyrax::UploadedFile.create(user: @depositor, file: file)
        uploaded_file_ids << uploaded_file.id
        file.close
      end
      uploaded_file_ids
    end

    ##
    # Within the directory specified by ENV['IMPORT_PATH'], find the first
    # instance of a file matching the given filename.
    # If there is no matching file, raise an exception.
    # @param [String] filename
    # @return [String] a full pathname to the found file
    def find_file_path(filename)
      filepath = Dir.glob("#{ENV['IMPORT_PATH']}/**/#{filename}").first
      raise "Cannot find file #{filename}... Are you sure it has been uploaded and that the filename matches?" if filepath.nil?
      filepath
    end

    ##
    # When submitting location data (a.k.a. the "based near" attribute) via the UI,
    # Hyrax expects to receive a `based_near_attributes` hash in a specific format.
    # We need to take geonames urls as provided by the customer and transform them to
    # mimic what the Hyrax UI would ordinarily produce. These will get turned into
    # Hyrax::ControlledVocabularies::Location objects upon ingest.
    # The expected hash looks like this:
    #   "based_near_attributes"=>
    #     {
    #       "0"=> {
    #               "id"=>"http://sws.geonames.org/5667009/", "_destroy"=>""
    #             },
    #       "1"=> {
    #               "id"=>"http://sws.geonames.org/6252001/", "_destroy"=>""
    #             },
    #   }
    # @return [Hash] a "based_near_attributes" hash as
    def based_near_attributes(based_near)
      original_geonames_uris = based_near
      return if original_geonames_uris.empty?
      based_near_attributes = {}
      original_geonames_uris.each_with_index do |uri, i|
        based_near_attributes[i.to_s] = { 'id' => uri_to_sws(uri), "_destroy" => "" }
      end
      based_near_attributes
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

    private

      # Create an object using the Hyrax actor stack
      # We assume the object was created as expected if the actor stack returns true.
      def create_for(record:)
        info_stream << "event: record_import_started, batch_id: #{batch_id}, collection_id: #{collection_id}, record_title: #{record.respond_to?(:title) ? record.title : record}"

        additional_attrs = {
          uploaded_files: create_upload_files(record),
          depositor: @depositor.user_key
        }

        created = import_type.new

        attrs = record.attributes.merge(additional_attrs)
        attrs = attrs.merge(member_of_collections_attributes: { '0' => { id: collection_id } }) if collection_id

        # Ensure nothing is passed in the files field,
        # since this is reserved for Hyrax and is where uploaded_files will be attached
        attrs.delete(:files)

        based_near = attrs.delete(:based_near)
        attrs = attrs.merge(based_near_attributes: based_near_attributes(based_near)) unless based_near.nil? || based_near.empty?

        actor_env = Hyrax::Actors::Environment.new(created,
                                                   ::Ability.new(@depositor),
                                                   attrs)

        if Hyrax::CurationConcern.actor.create(actor_env)
          info_stream << "event: record_created, batch_id: #{batch_id}, record_id: #{created.id}, collection_id: #{collection_id}, record_title: #{attrs[:title].first}"
          @success_count += 1
        else
          created.errors.each do |attr, msg|
            error_stream << "event: validation_failed, batch_id: #{batch_id}, collection_id: #{collection_id}, attribute: #{attr.capitalize}, message: #{msg}, record_title: record_title: #{attrs[:title] ? attrs[:title] : attrs}"
          end
          @failure_count += 1
        end
      end
  end
end
