# frozen_string_literal: true

shared_examples 'a Darlingtonia::MessageStream' do
  describe '#<<' do
    it { is_expected.to respond_to(:<<) }

    it 'accepts a string argument' do
      expect { stream << 'some string' }.not_to raise_error
    end
  end
end
