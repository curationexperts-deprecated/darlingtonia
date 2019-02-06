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

    # @param attributes [Hash] Attributes that come
    #        from the UI or importer rather than from
    #        the CSV/mapper.
    # @example
    #   attributes: { collection_id: '123',
    #                 depositor_id: '456' }
    def initialize(error_stream: Darlingtonia.config.default_error_stream,
                   info_stream: Darlingtonia.config.default_info_stream,
                   attributes: {})
      self.collection_id = attributes[:collection_id]
      set_depositor(attributes[:depositor_id])

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

    private

      # Create an object using the Hyrax actor stack
      # We assume the object was created as expected if the actor stack returns true.
      def create_for(record:)
        info_stream << 'Creating record: ' \
                       "#{record.respond_to?(:title) ? record.title : record}."
        additional_attrs = {
          uploaded_files: create_upload_files(record),
          depositor: @depositor.user_key
        }
        created = import_type.new

        attrs = record.attributes.merge(additional_attrs)
        attrs = attrs.merge(member_of_collections_attributes: { '0' => { id: collection_id } }) if collection_id

        actor_env = Hyrax::Actors::Environment.new(created,
                                                   ::Ability.new(@depositor),
                                                   attrs)

        if Hyrax::CurationConcern.actor.create(actor_env)
          info_stream << "Record created at: #{created.id}"
        else
          created.errors.each do |attr, msg|
            error_stream << "Validation failed: #{attr.capitalize}. #{msg}"
          end
        end

        info_stream << "Record created at: #{created.id}"
      end
  end
end
