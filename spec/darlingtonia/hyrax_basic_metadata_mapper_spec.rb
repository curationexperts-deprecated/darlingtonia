# frozen_string_literal: true
require 'spec_helper'

describe Darlingtonia::HyraxBasicMetadataMapper do
  let(:mapper) { described_class.new }

  # Properties defined in Hyrax::CoreMetadata
  let(:core_fields) do
    [:depositor, :title, :date_uploaded, :date_modified]
  end

  # Properties defined in Hyrax::BasicMetadata
  let(:basic_fields) do
    [:label, :relative_path, :import_url,
     :resource_type, :creator, :contributor,
     :description, :keyword, :license,
     :rights_statement, :publisher, :date_created,
     :subject, :language, :identifier, :based_near,
     :related_url, :bibliographic_citation, :source]
  end

  it_behaves_like 'a Darlingtonia::Mapper' do
    let(:metadata) do
      { title: ['A Title for a Record'],
        my_custom_field: ['This gets ignored'] }
    end
    let(:expected_fields) { core_fields + basic_fields }
  end

  context 'with metadata, but some missing fields' do
    before { mapper.metadata = metadata }
    let(:metadata) do
      { 'depositor' => 'someone@example.org',
        'title' => 'A Title',
        'language' => 'English' }
    end

    it 'provides methods for the fields, even fields that aren\'t included in the metadata' do
      expect(metadata).to include('title')
      expect(mapper).to respond_to(:title)

      expect(metadata).not_to include('label')
      expect(mapper).to respond_to(:label)
    end

    it 'returns single values for single-value fields' do
      expect(mapper.depositor).to eq 'someone@example.org'
      expect(mapper.date_uploaded).to eq nil
      expect(mapper.date_modified).to eq nil
      expect(mapper.label).to eq nil
      expect(mapper.relative_path).to eq nil
      expect(mapper.import_url).to eq nil
    end

    it 'returns array values for multi-value fields' do
      expect(mapper.title).to eq ['A Title']
      expect(mapper.language).to eq ['English']
      expect(mapper.keyword).to eq []
      expect(mapper.subject).to eq []
    end
  end

  context 'fields with multiple values' do
    before { mapper.metadata = metadata }
    let(:metadata) do
      { 'title' => 'A Title',
        'language' => 'English|~|French|~|Japanese' }
    end

    it 'splits the values using the delimiter' do
      expect(mapper.title).to eq ['A Title']
      expect(mapper.language).to eq ['English', 'French', 'Japanese']
      expect(mapper.keyword).to eq []
    end

    it 'can set a different delimiter' do
      expect(mapper.delimiter).to eq '|~|'
      mapper.delimiter = 'ಠ_ಠ'
      expect(mapper.delimiter).to eq 'ಠ_ಠ'
    end
  end
end
