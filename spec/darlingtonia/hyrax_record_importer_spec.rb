# frozen_string_literal: true
require 'spec_helper'

describe Darlingtonia::HyraxRecordImporter, :clean do
  subject(:importer) do
    described_class.new(error_stream: error_stream, info_stream: info_stream)
  end

  load File.expand_path("../../support/shared_contexts/with_work_type.rb", __FILE__)
  include_context 'with a work type'

  let(:error_stream) { [] }
  let(:info_stream)  { [] }
  let(:record)       { Darlingtonia::InputRecord.from(metadata: metadata) }

  context 'collection id' do
    subject(:importer) do
      described_class.new(attributes: { collection_id: collection_id })
    end
    let(:collection_id) { '123' }

    it 'can have a collection id' do
      expect(importer.collection_id).to eq collection_id
    end
  end

  context 'with no attached files' do
    let(:metadata) do
      {
        'title' => 'A Title',
        'language' => 'English',
        'visibility' => 'open'
      }
    end

    it 'creates a work for record' do
      expect { importer.import(record: record) }
        .to change { Work.count }
        .by 1
    end
  end

  # Instead of having a files field in the mapper, which will create a
  # Hyrax::UploadedFile for each file before attaching it, some importers will
  # use a remote_files strategy and instead treat each file as a remote file and
  # fetch it at object creation time. This might be faster, and we might eventually
  # want to adopt it as our default. For now, do not raise an error if there is no
  # `files` field in the mapper being used.
  context 'with no files filed in the mapper' do
    let(:metadata) do
      {
        'title' => 'A Title',
        'language' => 'English',
        'visibility' => 'open'
      }
    end
    let(:record) { Darlingtonia::InputRecord.from(metadata: metadata, mapper: Darlingtonia::MetadataMapper.new) }

    it 'creates a work for record' do
      expect { importer.import(record: record) }
        .to change { Work.count }
        .by 1
    end
  end

  context 'with attached files' do
    before do
      ENV['IMPORT_PATH'] = File.expand_path('../fixtures/images', File.dirname(__FILE__))
    end
    let(:metadata) do
      {
        'title' => 'A Title',
        'language' => 'English',
        'visibility' => 'open',
        'files' => 'darlingtonia.png|~|cat.png'
      }
    end
    it 'finds a file even if it is in a subdirectory' do
      expect(importer.find_file_path('cat.png')).to eq "#{ENV['IMPORT_PATH']}/animals/cat.png"
    end
    it 'creates a work for record' do
      expect { importer.import(record: record) }
        .to change { Work.count }
        .by 1
    end
    it 'makes an uploaded file object for each file attachment' do
      expect { importer.import(record: record) }
        .to change { Hyrax::UploadedFile.count }
        .by 2
    end
  end

  context 'with attached files, alternate capitalization and whitespace in "files" header' do
    before do
      ENV['IMPORT_PATH'] = File.expand_path('../fixtures/images', File.dirname(__FILE__))
    end
    let(:metadata) do
      {
        'title' => 'A Title',
        'visibility' => 'open',
        ' Files' => 'darlingtonia.png|~|cat.png'
      }
    end

    it 'makes an uploaded file object for each file attachment' do
      expect { importer.import(record: record) }
        .to change { Hyrax::UploadedFile.count }
        .by 2
    end
  end

  context 'with missing files' do
    before do
      ENV['IMPORT_PATH'] = File.expand_path('../fixtures/images', File.dirname(__FILE__))
    end
    it 'raises an exception' do
      expect { importer.find_file_path('foo.png') }.to raise_exception(RuntimeError)
    end
  end

  describe '#set_depositor' do
    let(:metadata) { { 'title' => 'A Title' } }

    context 'when no depositor is set' do
      it 'sets the Hyrax default batch user' do
        expect(importer.depositor.user_key).to eq 'batchuser@example.com'
      end
    end

    context 'when depositor is passed to initializer' do
      subject(:importer) { described_class.new(error_stream: error_stream, info_stream: info_stream, attributes: { depositor_id: user.user_key }) }

      let(:user) { ::User.new(id: '123', user_key: 'special_user@example.com') }
      before { allow(::User).to receive(:find).and_return(user) }

      it 'sets it to the passed-in depositor' do
        expect(importer.depositor.user_key).to eq 'special_user@example.com'
      end
    end

    context 'when depositor is set in metadata' do
      let(:metadata) do
        { 'title' => 'A Title',
          'Depositor' => 'metadata_user@example.com' }
      end

      it 'sets the Hyrax default batch user' do
        expect(importer.depositor.user_key).to eq 'batchuser@example.com'
        # TODO: expect(importer.depositor.user_key).to eq 'metadata_user@example.com'
        # The metadata depositor should probably override any passed-in or default depositor.
      end
    end
  end
  # When submitting location data (a.k.a., the "based near" attribute) via the UI,
  # Hyrax expects to receive a `based_near_attributes` hash in a specific format.
  # We need to take geonames urls as provided by the customer and transform them to
  # mimic what the Hyrax UI would ordinarily produce. These will get turned into
  # Hyrax::ControlledVocabularies::Location objects upon ingest.
  context 'with location uris' do
    let(:based_near) { ['http://www.geonames.org/5667009/montana.html', 'http://www.geonames.org/6252001/united-states.html'] }
    let(:expected_bn_hash) do
      {
        "0" => {
          "id" => "http://sws.geonames.org/5667009/", "_destroy" => ""
        },
        "1" => {
          "id" => "http://sws.geonames.org/6252001/", "_destroy" => ""
        }
      }
    end
    it "gets a sws uri from a geonames uri" do
      expect(importer.uri_to_sws("http://www.geonames.org/6252001/united-states.html")).to eq "http://sws.geonames.org/6252001/"
    end
    it 'transforms an array of geonames uris into the expected based_near_attributes hash' do
      expect(importer.based_near_attributes(based_near)).to eq expected_bn_hash
    end
  end
end
