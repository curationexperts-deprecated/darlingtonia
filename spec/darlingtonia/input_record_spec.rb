# frozen_string_literal: true

require 'spec_helper'

describe Darlingtonia::InputRecord do
  subject(:record) { described_class.from(metadata: metadata) }

  let(:metadata) do
    { 'title' => 'Comet in Moominland',
      'abstract or summary' => 'A book about moomins.' }
  end

  it 'defaults to a Hyrax Mapper' do
    expect(described_class.new).to have_attributes(mapper: an_instance_of(Darlingtonia::HyraxBasicMetadataMapper))
  end

  it 'has metadata and a mapper' do
    is_expected
      .to have_attributes(mapper: an_instance_of(Darlingtonia::HyraxBasicMetadataMapper))
  end

  describe '#attributes' do
    it 'handles basic text fields' do
      expect(record.attributes).to include(:title, :description)
    end

    it 'does not include representative_file' do
      expect(record.attributes).not_to include(:representative_file)
    end
  end

  describe '#representative_file' do
    it 'is nil if mapper does not provide a representative file' do
      expect(record.representative_file).to be_nil
    end

    context 'when mapper provides representative_file' do
      let(:representative_file) { :A_DUMMY_FILE }

      before do
        allow(record.mapper)
          .to receive(:representative_file)
          .and_return(representative_file)
      end

      it 'is the file from the mapper' do
        expect(record.representative_file).to eql representative_file
      end
    end
  end

  describe 'mapped fields' do
    it 'has methods for metadata fields' do
      expect(record.title).to contain_exactly metadata['title']
    end

    it 'has methods for additional mapped metadata fields' do
      expect(record.description).to contain_exactly metadata['abstract or summary']
    end

    it 'knows it responds to methods for metadata fields' do
      expect(record).to respond_to :title
    end

    it 'knows it responds to methods for additional metadata fields' do
      expect(record).to respond_to :description
    end
  end
end
