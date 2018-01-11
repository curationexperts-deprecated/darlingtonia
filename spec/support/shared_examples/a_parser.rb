# frozen_string_literal: true

require 'darlingtonia/always_invalid_validator'

shared_examples 'a Darlingtonia::Parser' do
  describe '#file' do
    it 'is an accessor' do
      expect { parser.file = :a_new_file }
        .to change { parser.file }
        .to(:a_new_file)
    end
  end

  describe '#records' do
    it 'yields records' do
      unless described_class == Darlingtonia::Parser
        expect { |b| parser.records(&b) }
          .to yield_control.exactly(record_count).times
      end
    end
  end

  describe '#valid?' do
    it 'is valid' do
      expect(parser).to be_valid
    end

    context 'when not valid' do
      before do
        parser.validators = [Darlingtonia::AlwaysInvalidValidator.new]
      end

      it 'is invalid' do
        expect { parser.validate }
          .to change { parser.valid? }
          .to be_falsey
      end
    end
  end

  describe '#validate' do
    it 'is true when valid' do
      expect(parser.validate).to be_truthy
    end

    context 'when not valid' do
      before do
        parser.validators = [Darlingtonia::AlwaysInvalidValidator.new]
      end

      it 'is invalid' do
        expect(parser.validate).to be_falsey
      end
    end
  end

  describe '#validate!' do
    it 'is true when valid' do
      expect(parser.validate).to be_truthy
    end

    context 'when not valid' do
      before do
        parser.validators = [Darlingtonia::AlwaysInvalidValidator.new]
      end

      it 'raises a ValidationError' do
        expect { parser.validate! }
          .to raise_error Darlingtonia::Parser::ValidationError
      end
    end
  end
end
