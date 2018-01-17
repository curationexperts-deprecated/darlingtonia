# frozen_string_literal: true

require 'spec_helper'

describe Darlingtonia::Parser do
  subject(:parser) { described_class.new(file: file) }
  let(:file)       { :fake_file }

  it_behaves_like 'a Darlingtonia::Parser'

  describe '.for' do
    it 'raises an error' do
      expect { described_class.for(file: file) }.to raise_error TypeError
    end

    context 'with a matching parser subclass' do
      before(:context) do
        ##
        # An importer that matches all types
        class MyFakeParser < described_class
          class << self
            def match?(**_opts)
              true
            end
          end
        end

        class NestedParser < MyFakeParser; end
      end

      after(:context) do
        Object.send(:remove_const, :MyFakeParser)
        Object.send(:remove_const, :NestedParser)
      end

      it 'returns an importer instance' do
        expect(described_class.for(file: file)).to be_a NestedParser
      end
    end
  end

  describe '#records' do
    it 'raises NotImplementedError' do
      expect { parser.records }.to raise_error NotImplementedError
    end
  end
end
