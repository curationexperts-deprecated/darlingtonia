# frozen_string_literal: true

describe Darlingtonia::InputRecord do
  subject(:record) { described_class.from(metadata: metadata) }

  let(:metadata) do
    { 'title'       => 'Comet in Moominland',
      'description' => 'A book about moomins.' }
  end

  it 'has metadata and a mapper' do
    is_expected
      .to have_attributes(mapper: an_instance_of(Darlingtonia::HashMapper))
  end

  describe '#attributes' do
    it 'handles basic text fields' do
      expect(record.attributes).to include(:title, :description)
    end
  end

  describe 'mapped fields' do
    it 'has methods for metadata fields' do
      expect(record.title).to contain_exactly metadata['title']
    end

    it 'has methods for additional mapped metadata fields' do
      expect(record.description).to contain_exactly metadata['description']
    end

    it 'knows it responds to methods for metadata fields' do
      expect(record).to respond_to :title
    end

    it 'knows it responds to methods for additional metadata fields' do
      expect(record).to respond_to :description
    end
  end
end
