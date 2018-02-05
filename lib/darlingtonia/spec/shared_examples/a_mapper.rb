# frozen_string_literal: true

shared_examples 'a Darlingtonia::Mapper' do
  subject(:mapper) { described_class.new }

  before { mapper.metadata = metadata }

  describe '#metadata' do
    it 'can be set' do
      expect { mapper.metadata = nil }
        .to change { mapper.metadata }
    end
  end

  describe '#field?' do
    it 'does not have bogus fields' do
      expect(mapper.field?(:NOT_A_REAL_FIELD)).to be_falsey
    end

    it 'has fields that are expected' do
      if defined?(expected_fields)
        expected_fields.each do |field|
          expect(mapper.field?(field)).to be_truthy
        end
      end
    end
  end

  describe '#fields' do
    it { expect(mapper.fields).to contain_exactly(*expected_fields) }
  end
end
