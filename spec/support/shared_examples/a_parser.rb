shared_examples 'a Darlingtonia::Parser' do
  subject(:parser) { described_class.new }

  describe '#records' do
    it 'enumerates records' do
      expect(parser.records).to contain_exactly(*records)
    end

    it 'yields records' do
      expect { |b| parser.records(&b) }
        .to yield_control.exactly(records.count).times
    end
  end
end
