# frozen_string_literal: true

shared_examples 'a Darlingtonia::MessageStream' do
  it { is_expected.to respond_to(:<<) }
end
