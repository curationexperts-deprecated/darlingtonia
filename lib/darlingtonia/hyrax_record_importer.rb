# frozen_string_literal: true
module Darlingtonia
  class HyraxRecordImporter < RecordImporter
    # TODO: Get this from Hyrax config
    DEFAULT_CREATOR_KEY = 'batchuser@example.com'

    ##
    # @!attribute [rw] creator
    #   @return [User]
    attr_accessor :creator

    ##
    # @param creator   [User]
    def initialize(*)
      self.creator = ::User.find_or_create_system_user(DEFAULT_CREATOR_KEY)
      super
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

    # Depositor is a required field for Hyrax
    # If it hasn't been set in the metadata, set it to the Hyrax default batch user
    # Even if it has been set, for now, override that with the batch user.
    # @param Darlingtonia::InputRecord
    def set_depositor(record)
      record.mapper.metadata["depositor"] = @creator.user_key
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
      file_attachment_filenames = record.mapper.metadata["files"]
      return [] if file_attachment_filenames.nil? || file_attachment_filenames.empty?

      files_to_attach = file_attachment_filenames.split(record.mapper.delimiter)

      uploaded_file_ids = []
      files_to_attach.each do |filename|
        file = File.open(Pathname.new(file_attachments_path).join(filename))
        uploaded_file = Hyrax::UploadedFile.create(user: @creator, file: file)
        uploaded_file_ids << uploaded_file.id
        file.close
      end
      uploaded_file_ids
    end

    private

      # Create an object using the Hyrax actor stack
      # We assume the object was created as expected if the actor stack returns true.
      def create_for(record:)
        info_stream << 'Creating record: ' \
                       "#{record.respond_to?(:title) ? record.title : record}."
        set_depositor(record)
        uploaded_files = { uploaded_files: create_upload_files(record) }
        created    = import_type.new
        attributes = record.attributes.merge(uploaded_files)

        actor_env  = Hyrax::Actors::Environment.new(created,
                                                    ::Ability.new(@creator),
                                                    attributes)

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
