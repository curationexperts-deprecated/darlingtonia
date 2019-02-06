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
      subject(:importer) { described_class.new(error_stream: error_stream, info_stream: info_stream, attributes: { depositor_id: user.id }) }

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
end
