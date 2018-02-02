# frozen_string_literal: true

require 'spec_helper'
require 'darlingtonia/streams/formatted_message_stream'

describe Darlingtonia::FormattedMessageStream do
  subject(:stream)     { described_class.new(stream: fake_stream) }
  let(:fake_stream)    { [] }

  it_behaves_like 'a Darlingtonia::MessageStream'

  describe '#stream' do
    subject(:stream) { described_class.new }

    it 'is STDOUT by default' do
      expect(stream.stream).to eq STDOUT
    end
  end

  describe '#<<' do
    it 'appends newlines by default' do
      expect { stream << 'moomin' }
        .to change { fake_stream }
        .to contain_exactly("moomin\n")
    end

    it 'uses other % formatters' do
      stream.formatter = "!!!%s!!!"

      expect { stream << 'moomin' }
        .to change { fake_stream }
        .to contain_exactly('!!!moomin!!!')
    end
  end
end
