# frozen_string_literal: true
require 'spec_helper'

describe Darlingtonia::HyraxRecordImporter, :clean do
  subject(:importer) do
    described_class.new(error_stream: error_stream, info_stream: info_stream)
  end

  let(:error_stream) { [] }
  let(:info_stream)  { [] }
  let(:record)       { Darlingtonia::InputRecord.from(metadata: metadata) }

  context 'collection id' do
    subject(:importer) do
      described_class.new(collection_id: collection_id)
    end
    let(:collection_id) { '123' }

    load File.expand_path("../../support/shared_contexts/with_work_type.rb", __FILE__)
    include_context 'with a work type'

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
    load File.expand_path("../../support/shared_contexts/with_work_type.rb", __FILE__)
    include_context 'with a work type'

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
    load File.expand_path("../../support/shared_contexts/with_work_type.rb", __FILE__)
    include_context 'with a work type'
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

  context 'with missing files' do
    before do
      ENV['IMPORT_PATH'] = File.expand_path('../fixtures/images', File.dirname(__FILE__))
    end
    it 'raises an exception' do
      expect { importer.find_file_path('foo.png') }.to raise_exception(RuntimeError)
    end
  end

  context 'with and without a depositor value' do
    context 'when there is no depositor set' do
      let(:metadata) do
        {
          'title' => 'A Title',
          'language' => 'English',
          'visibility' => 'open'
        }
      end
      it 'adds the batch user as the depositor' do
        importer.set_depositor(record)
        expect(record.mapper.metadata["depositor"]).to eq "batchuser@example.com"
      end
    end
    context 'when there is a depositor set' do
      let(:metadata) do
        {
          'title' => 'A Title',
          'language' => 'English',
          'visibility' => 'open',
          'depositor' => 'my@custom.depositor'
        }
      end
      it 'resets the batch user as the depositor' do
        importer.set_depositor(record)
        expect(record.mapper.metadata["depositor"]).to eq "batchuser@example.com"
      end
    end
  end
end
