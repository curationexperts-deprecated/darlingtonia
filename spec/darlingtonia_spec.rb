# frozen_string_literal: true

require 'spec_helper'

describe Darlingtonia do
  describe '#config' do
    it 'can set a default error stream' do
      stream = []

      expect { described_class.config { |c| c.default_error_stream = stream } }
        .to change { described_class.config.default_error_stream }
        .from(STDOUT)
        .to(stream)
    end
  end
end
