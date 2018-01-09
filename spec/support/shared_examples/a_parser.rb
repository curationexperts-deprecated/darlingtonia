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
end
